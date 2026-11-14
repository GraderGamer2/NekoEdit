#!/usr/bin/env python3
"""Protocol-level smoke test for the raw Wayland bootstrap (no compositor needed).

Python is used only by this test harness; it is not part of NekoEdit's runtime.
"""
from __future__ import annotations

import mmap
import json
import os
import select
import socket
import struct
import subprocess
import sys
import shutil
import tempfile
import threading
import time
import traceback

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "tools"))
from compose_pack import encode_pack as encode_compose_pack


# Frame callbacks are intercepted and acknowledged only after the commit that
# carries each wl_surface.frame request.
_FRAME_CALLBACK_STATES: dict[socket.socket, dict[str, object]] = {}
_BUFFER_TRACKING_STATES: dict[socket.socket, dict[str, object]] = {}


def wire_message(object_id: int, opcode: int, payload: bytes = b"") -> bytes:
    size = 8 + len(payload)
    if size % 4:
        raise ValueError(f"Wayland message is not 4-byte aligned: {size}")
    return struct.pack("<II", object_id, (size << 16) | opcode) + payload


def registry_global(name: int, interface: str, version: int = 1) -> bytes:
    encoded = interface.encode("ascii") + b"\0"
    padded = encoded + b"\0" * (-len(encoded) % 4)
    payload = struct.pack("<II", name, len(encoded)) + padded + struct.pack("<I", version)
    return wire_message(2, 0, payload)


def recv_exact(connection: socket.socket, count: int) -> bytes:
    result = bytearray()
    while len(result) < count:
        chunk = connection.recv(count - len(result))
        if not chunk:
            raise EOFError("client closed the Wayland socket")
        result.extend(chunk)
    return bytes(result)


def recv_wayland_message(connection: socket.socket):
    while True:
        header, ancillary, _flags, _address = connection.recvmsg(8, socket.CMSG_SPACE(4))
        if len(header) != 8:
            raise EOFError(f"short Wayland header: {header!r}")
        object_id, word = struct.unpack("<II", header)
        size, opcode = word >> 16, word & 0xFFFF
        if size < 8:
            raise AssertionError(f"invalid Wayland message size: {size}")
        payload = recv_exact(connection, size - 8)
        received_fds = []
        for level, kind, data in ancillary:
            if level == socket.SOL_SOCKET and kind == socket.SCM_RIGHTS:
                fd_count = len(data) // struct.calcsize("i")
                received_fds.extend(struct.unpack("<" + "i" * fd_count, data[: fd_count * 4]))
        buffer_state = _BUFFER_TRACKING_STATES.get(connection)
        if buffer_state is not None:
            if object_id == 11 and opcode == 0 and len(payload) == 24:
                buffer_id, buffer_offset, _width, _height, _stride, _format = struct.unpack("<6I", payload)
                buffer_state["known_offsets"][buffer_id] = buffer_offset
            elif object_id == 8 and opcode == 1 and len(payload) == 12:
                buffer_id, _x, _y = struct.unpack("<III", payload)
                known = buffer_state["known_offsets"]
                if buffer_id in known:
                    active = buffer_state["active_buffer"]
                    active["id"] = buffer_id
                    active["offset"] = known[buffer_id]

        state = _FRAME_CALLBACK_STATES.get(connection)
        if state is not None and object_id == 8 and opcode == 3:
            if len(payload) != 4 or received_fds:
                raise AssertionError(f"malformed wl_surface.frame request: {payload!r}")
            callback_id, = struct.unpack("<I", payload)
            pending = state["pending"]
            if callback_id == 0 or callback_id in pending:
                raise AssertionError(f"invalid or duplicate frame callback ID: {callback_id}")
            pending.append(callback_id)
            state["ids"].append(callback_id)
            state["requested"] += 1
            continue
        if (
            state is not None
            and object_id == 8
            and opcode == 6
            and state["pending"]
            and not state.get("defer", False)
        ):
            for callback_id in state["pending"]:
                connection.sendall(
                    wire_message(callback_id, 0, struct.pack("<I", state["completed"] + 1))
                )
                state["completed"] += 1
            state["pending"].clear()
        return object_id, opcode, payload, received_fds


def synthetic_true_type_font(*, a_advance: int = 650, a_peak_y: int = 700) -> bytes:
    """Build a tiny SFNT face with configurable A metrics/outline for switch tests."""
    head = bytearray(54)
    struct.pack_into(">I", head, 0, 0x00010000)
    struct.pack_into(">I", head, 12, 0x5F0F3CF5)
    struct.pack_into(">H", head, 18, 1000)
    struct.pack_into(">h", head, 50, 0)

    hhea = bytearray(36)
    struct.pack_into(">I", hhea, 0, 0x00010000)
    struct.pack_into(">h", hhea, 4, 900)
    struct.pack_into(">h", hhea, 6, -300)
    struct.pack_into(">h", hhea, 8, 100)
    struct.pack_into(">H", hhea, 34, 11)

    maxp = struct.pack(">IH", 0x00005000, 11)
    hmtx = struct.pack(">22H", *([600, 0, a_advance, 0, 400, 0, 300, 0] + [600, 0] * 7))
    os2 = bytearray(96)
    struct.pack_into(">H", os2, 0, 4)        # OS/2 version 4
    struct.pack_into(">H", os2, 62, 0x0080)  # fsSelection.USE_TYPO_METRICS
    struct.pack_into(">h", os2, 68, 850)    # sTypoAscender
    struct.pack_into(">h", os2, 70, -250)   # sTypoDescender
    struct.pack_into(">h", os2, 72, 100)    # sTypoLineGap
    # Glyph 1 is a three-point simple contour: (0,0), (500,0), (250,700).
    glyph_a = (
        struct.pack(">5h", 1, 0, 0, 500, a_peak_y)
        + struct.pack(">2H", 2, 0)
        + bytes((0x31, 0x21, 0x01))
        + struct.pack(">2h", 500, -250)
        + struct.pack(">h", a_peak_y)
    )
    # Glyph 2 translates glyph 1 by (+100,+200).
    composite_xy = (
        struct.pack(">5h", -1, 100, 200, 600, 900)
        + struct.pack(">HHhh", 0x0003, 1, 100, 200)
    )
    # Glyph 3 nests glyph 2, scales it by 0.5, then offsets it (-50,+10).
    composite_scaled = (
        struct.pack(">5h", -1, 0, 10, 250, 460)
        + struct.pack(">HHhhh", 0x000B, 2, -50, 10, 8192)
    )
    # Glyph 4 attaches a second copy of glyph 1 by matching parent point 0
    # with child point 1; this covers point-number arguments, not XY offsets.
    composite_point_match = (
        struct.pack(">5h", -1, -500, 0, 500, 700)
        + struct.pack(">HHhh", 0x0023, 1, 0, 0)
        + struct.pack(">HHHH", 0x0001, 1, 0, 1)
    )
    # Glyph 5 references itself. The decoder must reject this cycle safely.
    composite_cycle = (
        struct.pack(">5h", -1, 0, 0, 0, 0)
        + struct.pack(">HHhh", 0x0003, 5, 0, 0)
    )
    # Glyph 6 uses independent X/Y scales (0.5 and 2.0).
    composite_anisotropic = (
        struct.pack(">5h", -1, 0, 0, 250, 1400)
        + struct.pack(">HHhhhh", 0x0043, 1, 0, 0, 8192, 24576)
    )
    # Glyph 7 rotates the simple outline 90 degrees using the 2x2 matrix:
    # x' = -y, y' = x. Stored order is xscale, scale01, scale10, yscale.
    composite_matrix = (
        struct.pack(">5h", -1, -700, 0, 0, 500)
        + struct.pack(">HHhhhhhh", 0x0083, 1, 0, 0, 0, 16384, -16384, 0)
    )
    # Glyph 8 uses signed byte XY offsets rather than 16-bit arguments.
    composite_byte_args = (
        struct.pack(">5h", -1, -10, 5, 490, 705)
        + struct.pack(">HHbb", 0x0002, 1, -10, 5)
    )
    # Glyph 9 has two consecutive off-curve controls. The rasterizer must
    # insert their implied midpoint and flatten both quadratic sections.
    quadratic_glyph = (
        struct.pack(">5h", 1, 100, 0, 300, 400)
        + struct.pack(">2H", 3, 0)
        # p0: signed X word +100, zero Y; p1: positive X byte +200,
        # zero Y; p2: zero X, signed Y word +400; p3: signed X word -200,
        # zero Y. This leaves two successive off-curve controls at p1/p2.
        + bytes((0x21, 0x32, 0x10, 0x21))
        + struct.pack(">hBhh", 100, 200, -200, 400)
    )
    # Glyph 10 maps to lowercase j. Its 1,050-unit vertical extent becomes
    # 34px after scaling to 32px em and adding the two outer raster-padding
    # pixels, deliberately exceeding the old 32x32 glyph-mask limit.
    glyph_j = (
        struct.pack(">5h", 1, 100, -350, 300, 700)
        + struct.pack(">2H", 2, 0)
        + bytes((0x01, 0x01, 0x01))
        + struct.pack(">3h", 100, 200, -100)
        + struct.pack(">3h", -350, 0, 1050)
    )
    glyphs = (b"", glyph_a, composite_xy, composite_scaled,
              composite_point_match, composite_cycle, composite_anisotropic,
              composite_matrix, composite_byte_args, quadratic_glyph, glyph_j)
    glyf = bytearray()
    loca_offsets = [0]
    for glyph in glyphs:
        glyf.extend(glyph)
        if len(glyf) & 1:
            glyf.append(0)
        loca_offsets.append(len(glyf) // 2)
    loca = struct.pack(">12H", *loca_offsets)

    format4 = (
        struct.pack(">7H", 4, 56, 0, 10, 8, 2, 2)
        + struct.pack(">5H", 0x0020, 0x0041, 0x0042, 0x006A, 0xFFFF)
        + struct.pack(">H", 0)
        + struct.pack(">5H", 0x0020, 0x0041, 0x0042, 0x006A, 0xFFFF)
        + struct.pack(">5h", -29, -64, -64, -96, 1)
        + struct.pack(">5H", 0, 0, 0, 0, 0)
    )
    cmap = struct.pack(">HHHHI", 0, 1, 3, 1, 12) + format4
    tables = [
        (b"cmap", cmap),
        (b"glyf", glyf),
        (b"head", bytes(head)),
        (b"hhea", bytes(hhea)),
        (b"hmtx", hmtx),
        (b"loca", loca),
        (b"maxp", maxp),
        (b"OS/2", bytes(os2)),
    ]
    count = len(tables)
    offset = 12 + count * 16
    records = []
    payload = bytearray()
    for tag, table_data in tables:
        offset = (offset + 3) & ~3
        while 12 + count * 16 + len(payload) < offset:
            payload.append(0)
        records.append(struct.pack(">4sIII", tag, 0, offset, len(table_data)))
        payload.extend(table_data)
        while len(payload) % 4:
            payload.append(0)
        offset = 12 + count * 16 + len(payload)
    header = struct.pack(">IHHHH", 0x00010000, count, 0, 0, 0)
    return header + b"".join(records) + bytes(payload)


def expect_message(connection, expected, label: str):
    actual = recv_wayland_message(connection)
    buffer_state = _BUFFER_TRACKING_STATES.get(connection)

    # Older scenarios describe the surface buffer by its initial object ID.
    # The renderer may now create a second wl_buffer lazily; consume that
    # create request and compare the following attach by its known slot ID
    # and origin, without hiding unrelated protocol traffic.
    if buffer_state is not None and expected[:2] == (8, 1) and len(expected[2]) == 12:
        while actual[:2] == (11, 0) and len(actual[2]) == 24:
            actual = recv_wayland_message(connection)
        if actual[:2] == (8, 1) and len(actual[2]) == 12:
            expected_id, expected_x, expected_y = struct.unpack("<III", expected[2])
            actual_id, actual_x, actual_y = struct.unpack("<III", actual[2])
            if (
                (
                    expected_id == buffer_state["initial_buffer_id"]
                    or expected_id in buffer_state["known_offsets"]
                )
                and actual_id in buffer_state["known_offsets"]
                and (actual_x, actual_y) == (expected_x, expected_y)
            ):
                return actual

    # A generation replacement destroys every slot from the previous pool
    # generation. A legacy assertion names slot zero; accept another known
    # slot only when the expected request is a wl_buffer.destroy.
    if (
        buffer_state is not None
        and expected[0] == buffer_state["initial_buffer_id"]
        and expected[1:] == (0, b"")
        and actual[1:] == (0, b"")
        and actual[0] in buffer_state["known_offsets"]
    ):
        buffer_state["known_offsets"].pop(actual[0], None)
        return actual

    # Some resize tests expect the next generation's create_buffer directly
    # after slot-zero destroy. Consume any additional old-generation buffer
    # destroys first; each must correspond to an object we actually created.
    if buffer_state is not None and expected[:2] == (11, 0):
        while (
            actual[1:] == (0, b"")
            and actual[0] in buffer_state["known_offsets"]
        ):
            buffer_state["known_offsets"].pop(actual[0], None)
            actual = recv_wayland_message(connection)

    if actual[:3] != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual[:3]!r}")
    if buffer_state is not None and actual[1:] == (0, b""):
        buffer_state["known_offsets"].pop(actual[0], None)
    return actual


def expect_fractional_scale_startup(
    connection, manager_id: int, viewporter_id: int,
    viewport_id: int, fractional_id: int, sync_callback_id: int,
    preferred_scale: int, keyboard_object_id: int | None = None,
) -> None:
    """Verify extension IDs and deliver startup events before the scale sync."""
    manager_name = b"wp_fractional_scale_manager_v1\0"
    manager_padded = manager_name + (b"\0" * (-len(manager_name) % 4))
    expect_message(
        connection,
        (2, 0, struct.pack("<II", 10, len(manager_name)) + manager_padded
         + struct.pack("<II", 1, manager_id)),
        "bind fractional-scale manager after bootstrap proxies",
    )
    viewporter_name = b"wp_viewporter\0"
    viewporter_padded = viewporter_name + (b"\0" * (-len(viewporter_name) % 4))
    expect_message(
        connection,
        (2, 0, struct.pack("<II", 11, len(viewporter_name)) + viewporter_padded
         + struct.pack("<II", 1, viewporter_id)),
        "bind viewporter after bootstrap proxies",
    )
    expect_message(
        connection, (viewporter_id, 1, struct.pack("<II", viewport_id, 8)),
        "create viewport for main surface",
    )
    expect_message(
        connection, (manager_id, 1, struct.pack("<II", fractional_id, 8)),
        "create fractional-scale object for main surface",
    )
    expect_message(
        connection, (1, 0, struct.pack("<I", sync_callback_id)),
        "sync initial fractional-scale preference",
    )
    scale_and_sync = (
        wire_message(fractional_id, 0, struct.pack("<I", preferred_scale))
        + wire_message(sync_callback_id, 0)
    )
    if keyboard_object_id is None:
        connection.sendall(scale_and_sync)
    else:
        # A second keymap can arrive after the initial seat sync, while this
        # extension-owned sync is blocking. Format NO_KEYMAP still carries
        # an FD, and the client must consume it rather than drop the event.
        keymap_fd = os.memfd_create("nekoedit-fractional-sync-keymap", 0)
        try:
            startup_keymap = wire_message(
                keyboard_object_id, 0, struct.pack("<II", 0, 0)
            )
            connection.sendmsg(
                [startup_keymap + scale_and_sync],
                [(socket.SOL_SOCKET, socket.SCM_RIGHTS, struct.pack("i", keymap_fd))],
            )
        finally:
            os.close(keymap_fd)


def run(
    binary: str,
    *,
    use_wayland_socket: bool = False,
    send_protocol_error: bool = False,
    disconnect_after_configure_ack: bool = False,
    cursor_shape_supported: bool = True,
    advertised_seat_version: int = 7,
    initial_file: str | None = None,
    save_roundtrip: bool = False,
    file_workflow: bool = False,
    keyboard_layout_test: bool = False,
    unicode_keyboard_test: bool = False,
    text_input_test: bool = False,
    text_input_advertised: bool = False,
    text_input_opt_in_fallback_test: bool = False,
    omit_compat_repeat_default: bool = False,
    punctuation_render_test: bool = False,
    utf8_edit_test: bool = False,
    utf8_delete_test: bool = False,
    utf8_invalid_test: bool = False,
    utf8_pointer_test: bool = False,
    gap_buffer_test: bool = False,
    dynamic_growth_test: bool = False,
    line_index_test: bool = False,
    grapheme_test: bool = False,
    font_parser_test: bool = False,
    font_picker_test: bool = False,
    clipboard_test: bool = False,
    context_menu_test: bool = False,
    compose_locale_test: bool = False,
    compose_locale_invalid_test: bool = False,
    compose_locale_settings_test: bool = False,
    compose_locale_system_test: bool = False,
    compose_locale_c_fallback_test: bool = False,
    compose_locale_ctype_test: bool = False,
    compose_locale_lang_test: bool = False,
    compose_locale_saved_preference_test: bool = False,
    compose_locale_finnish_test: bool = False,
    compose_locale_serbian_test: bool = False,
    clipboard_persistence_test: bool = False,
    history_test: bool = False,
    horizontal_scroll_test: bool = False,
    word_navigation_test: bool = False,
    pointer_drag_test: bool = False,
    line_navigation_test: bool = False,
    find_replace_test: bool = False,
    font_test_path: str | None = None,
    initial_height: int = 480,
    sparse_keymap_test: bool = False,
    right_alt_compose_test: bool = False,
    right_alt_level3_test: bool = False,
    expected_saved_bytes: bytes = b"z",
    frame_callback_order_test: bool = False,
    buffer_pool_test: bool = False,
    verify_frame_callbacks: bool = False,
    seat_hotplug_test: bool = False,
    seat_hotplug_ime_test: bool = False,
    initial_preferred_buffer_scale: int = 1,
    initial_preferred_buffer_transform: int = 0,
    dpi_runtime_test: bool = False,
    output_tracking_test: bool = False,
    output_tracking_legacy_test: bool = False,
    window_initial_size_test: bool = False,
    fractional_scale_test: bool = False,
    fractional_sync_keymap_test: bool = False,
    initial_preferred_fractional_scale: int = 120,
    seat_supported: bool = True,
) -> None:
    # Resolve before file-workflow tests change the child process CWD.
    binary = os.path.abspath(binary)
    initial_file_mode = (
        os.stat(initial_file).st_mode & 0o7777
        if initial_file is not None and os.path.isfile(initial_file)
        else None
    )
    if initial_preferred_buffer_scale not in (1, 2):
        raise ValueError("the current Wayland scale tests support only 1x and 2x")
    if initial_preferred_buffer_transform not in range(8):
        raise ValueError("the preferred Wayland buffer transform must be in range 0..7")
    if initial_preferred_fractional_scale <= 0:
        raise ValueError("the preferred fractional scale must be a positive 120ths numerator")
    output_tracking_enabled = output_tracking_test or output_tracking_legacy_test or window_initial_size_test
    runtime_dir = tempfile.mkdtemp(prefix="nekoedit-wayland-")
    locale_scenarios = (
        compose_locale_test, compose_locale_invalid_test, compose_locale_settings_test,
        compose_locale_system_test, compose_locale_c_fallback_test, compose_locale_ctype_test,
        compose_locale_lang_test, compose_locale_saved_preference_test,
        compose_locale_finnish_test, compose_locale_serbian_test,
    )
    if sum(locale_scenarios) > 1:
        raise ValueError("locale-pack scenarios are mutually exclusive")
    if any(locale_scenarios):
        locale_dir = os.path.join(runtime_dir, ".nekoedit", "locales")
        os.makedirs(locale_dir, mode=0o700, exist_ok=True)
        if compose_locale_finnish_test:
            pack_tag = "fi_FI.UTF-8"
            source_json = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                       "data", "locales", pack_tag + ".json")
            with open(source_json, "r", encoding="utf-8") as source_file:
                pack_doc = json.load(source_file)
        elif compose_locale_serbian_test:
            pack_tag = "sr_RS.UTF-8"
            source_json = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                       "data", "locales", pack_tag + ".json")
            with open(source_json, "r", encoding="utf-8") as source_file:
                pack_doc = json.load(source_file)
        elif compose_locale_settings_test:
            # The visible Settings workflow must exercise the shipped dataset,
            # including its locale-specific dead-key mappings and Add Pack copy.
            pack_tag = "pt_BR.UTF-8"
            source_json = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                                       "data", "locales", pack_tag + ".json")
            with open(source_json, "r", encoding="utf-8") as source_file:
                pack_doc = json.load(source_file)
        else:
            pack_tag = "pt_BR.UTF-8" if (
                compose_locale_system_test or compose_locale_c_fallback_test or
                compose_locale_ctype_test or compose_locale_lang_test or
                compose_locale_saved_preference_test
            ) else "xx_TEST.UTF-8"
            pack_doc = {"locale":pack_tag, "sequences":[
                {"input":[0x6f,0x69],"output":[0x2603,0xfe0f]},
                {"input":[0x77,0x65,0x72,0x74],"output":[0x1f642]},
                {"input":[0x79,0x75,0x69],"output":[0x2605]},
                {"kind":"dead_key","input":[0x0301,0x030c,ord("g")],"output":[0x1f642]},
                {"kind":"dead_key","input":[0x0301,0x0304,0x030c,ord("g")],"output":[0x2603,0xfe0f]},
                {"kind":"dead_key","input":[0x0301,0x030c,0x0304,0x0301,0x030c,0x0304,0x0301,ord("g")],"output":[0x2603,0xfe0f]},
            ]}
        pack_data = bytearray(encode_compose_pack(pack_doc))
        if compose_locale_invalid_test: pack_data[-1] ^= 1
        with open(os.path.join(locale_dir, pack_tag + ".nlp"), "wb") as pack_file:
            pack_file.write(pack_data)
        if compose_locale_settings_test:
            # The Add Pack picker starts in the process CWD; keep a separate
            # source copy outside ~/.nekoedit/locales to exercise real install.
            with open(os.path.join(runtime_dir, pack_tag + ".nlp"), "wb") as source_pack_file:
                source_pack_file.write(pack_data)
            # The installed-pack selector must accept more than the bundled pt_BR tag.
            generic_document = {
                "locale": "aa_TEST.UTF-8",
                "sequences": [{"input": [0x6F, 0x69], "output": [0x2605]}],
            }
            with open(os.path.join(locale_dir, "aa_TEST.UTF-8.nlp"), "wb") as generic_file:
                generic_file.write(encode_compose_pack(generic_document))
        if compose_locale_saved_preference_test:
            preferences_path = os.path.join(runtime_dir, ".nekoedit", "preferences")
            with open(preferences_path, "wb") as preferences_file:
                preferences_file.write(b"version=1\ncompose_locale=en_US.UTF-8\n")
    display_name = "wayland-mock"
    if use_wayland_socket:
        client_endpoint, compositor_endpoint = socket.socketpair()
        server = None
    else:
        client_endpoint = None
        compositor_endpoint = None
        socket_path = os.path.join(runtime_dir, display_name)
        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server.bind(socket_path)
        server.listen(1)
        server.settimeout(8)
    observations = []
    frame_callback_stats = {"pending": [], "ids": [], "requested": 0, "completed": 0}
    errors = []
    process_holder = []
    absolute_file_path = (
        f"/tmp/nekoedit-absolute-{os.getpid()}-{time.monotonic_ns()}.txt"
        if file_workflow else None
    )
    if absolute_file_path is not None:
        try:
            os.unlink(absolute_file_path)
        except FileNotFoundError:
            pass
    if file_workflow:
        os.makedirs(os.path.join(runtime_dir, "nested-dir"))
        with open(os.path.join(runtime_dir, "relative-open.txt"), "wb") as document:
            document.write(b"I")
        large_line = (b"0123456789abcdef" * 8) + b"\n"
        large_size = 11 * 1024 * 1024
        large_expected = (large_line * ((large_size + len(large_line) - 1) // len(large_line)))[:large_size]
        with open(os.path.join(runtime_dir, "oversized.txt"), "wb") as document:
            document.write(large_expected)
        # Surround the zero-byte target with ordinary files so its Open test
        # exercises a nonzero list row rather than only row zero.
        with open(os.path.join(runtime_dir, "nested-dir", "aaa.txt"), "wb") as document:
            document.write(b"A")
        with open(os.path.join(runtime_dir, "nested-dir", "inside.txt"), "wb") as document:
            document.write(b"N")
        with open(os.path.join(runtime_dir, "nested-dir", "stale.txt"), "wb") as document:
            document.write(b"W")
        with open(os.path.join(runtime_dir, "nested-dir", "zzz.txt"), "wb") as document:
            document.write(b"Z")
        with open(os.path.join(runtime_dir, "nested-dir", ".hidden-note"), "wb") as document:
            document.write(b"H")
        with open(os.path.join(runtime_dir, "nested-dir", "empty.txt"), "wb") as document:
            document.write(b"")
        with open(os.path.join(runtime_dir, "nested-dir", "prefill-alpha.txt"), "wb") as document:
            document.write(b"A")
        with open(os.path.join(runtime_dir, "nested-dir", "prefill-beta.txt"), "wb") as document:
            document.write(b"B")
        for index in range(32):
            with open(os.path.join(runtime_dir, f"scroll-entry-{index:02d}.txt"), "wb") as document:
                document.write(b"S")
        if font_picker_test:
            with open(os.path.join(runtime_dir, "AB"), "wb") as document:
                document.write(b"AB")
            with open(os.path.join(runtime_dir, "alt.ttf"), "wb") as font_file:
                font_file.write(synthetic_true_type_font(a_advance=550, a_peak_y=400))
            with open(os.path.join(runtime_dir, "bad.ttf"), "wb") as font_file:
                font_file.write(b"not a TrueType SFNT")

    def fake_compositor():
        client = None
        try:
            if use_wayland_socket:
                client = compositor_endpoint
            else:
                client, _ = server.accept()
            _FRAME_CALLBACK_STATES[client] = frame_callback_stats
            client.settimeout(45 if file_workflow or clipboard_test or context_menu_test or compose_locale_test or compose_locale_invalid_test or compose_locale_settings_test or compose_locale_system_test or compose_locale_c_fallback_test or compose_locale_ctype_test or compose_locale_lang_test or compose_locale_saved_preference_test or compose_locale_finnish_test or compose_locale_serbian_test else 8)

            expect_message(client, (1, 1, struct.pack("<I", 2)), "get_registry")
            expect_message(client, (1, 0, struct.pack("<I", 3)), "initial sync")
            compositor_advertised_version = 6 if (
                buffer_pool_test or output_tracking_test or window_initial_size_test or initial_preferred_buffer_scale > 1
                or initial_preferred_buffer_transform != 0 or dpi_runtime_test
                or fractional_scale_test
            ) else 1
            globals_payload = (
                registry_global(1, "wl_compositor", version=compositor_advertised_version)
                + registry_global(2, "wl_shm")
                + registry_global(3, "xdg_wm_base")
            )
            if seat_supported:
                globals_payload += registry_global(4, "wl_seat", version=advertised_seat_version)
            if cursor_shape_supported:
                globals_payload += registry_global(5, "wp_cursor_shape_manager_v1", version=1)
            if clipboard_test or clipboard_persistence_test:
                globals_payload += registry_global(6, "wl_data_device_manager", version=1)
            if text_input_test or text_input_advertised or seat_hotplug_ime_test:
                globals_payload += registry_global(7, "zwp_text_input_manager_v3", version=1)
            if output_tracking_enabled:
                globals_payload += (
                    registry_global(8, "wl_output", version=3)
                    + registry_global(9, "wl_output", version=2)
                )
            if fractional_scale_test:
                globals_payload += (
                    registry_global(10, "wp_fractional_scale_manager_v1", version=1)
                    + registry_global(11, "wp_viewporter", version=1)
                )
            client.sendall(globals_payload + wire_message(3, 0, struct.pack("<I", 1)))

            bind_messages = [recv_wayland_message(client) for _ in range(3)]
            for message, expected_name, expected_iface, expected_object in zip(
                bind_messages,
                (1, 2, 3),
                (b"wl_compositor", b"wl_shm", b"xdg_wm_base"),
                (4, 5, 6),
                strict=True,
            ):
                object_id, opcode, payload, fds = message
                if (object_id, opcode) != (2, 0) or fds:
                    raise AssertionError(f"unexpected registry bind framing: {message!r}")
                global_name, string_len = struct.unpack_from("<II", payload)
                interface = payload[8 : 8 + string_len - 1]
                padded_len = (string_len + 3) & ~3
                version, new_id = struct.unpack_from("<II", payload, 8 + padded_len)
                if (global_name, interface, version, new_id) != (
                    expected_name,
                    expected_iface,
                    (compositor_advertised_version if expected_iface == b"wl_compositor" else 1),
                    expected_object,
                ):
                    raise AssertionError(f"unexpected bind arguments: {message!r}")
                observations.append(f"bind:{interface.decode()}")

            expect_message(client, (1, 0, struct.pack("<I", 7)), "bind sync")
            client.sendall(wire_message(7, 0, struct.pack("<I", 2)))
            expect_message(client, (4, 0, struct.pack("<I", 8)), "create wl_surface")
            expect_message(client, (6, 2, struct.pack("<II", 9, 8)), "get_xdg_surface")
            expect_message(client, (9, 1, struct.pack("<I", 10)), "get_toplevel")
            expect_message(
                client, (10, 8, struct.pack("<ii", 480, 360)),
                "set minimum window size"
            )
            expect_message(
                client, (10, 7, struct.pack("<ii", 3840, 2160)),
                "set maximum window size"
            )
            title = recv_wayland_message(client)
            if title[0:2] != (10, 2) or title[3]:
                raise AssertionError(f"unexpected set_title request: {title!r}")
            title_len = struct.unpack_from("<I", title[2])[0]
            if title[2][4 : 4 + title_len] != b"NekoEdit - development window\0":
                raise AssertionError("window title was not serialized as a Wayland string")
            expect_message(client, (8, 6, b""), "initial surface commit")

            preferred_scale_event = (
                wire_message(8, 2, struct.pack("<I", initial_preferred_buffer_scale))
                if initial_preferred_buffer_scale > 1 else b""
            )
            preferred_transform_event = (
                wire_message(8, 3, struct.pack("<I", initial_preferred_buffer_transform))
                if initial_preferred_buffer_transform != 0 else b""
            )
            client.sendall(
                preferred_scale_event
                + preferred_transform_event
                + wire_message(10, 0, struct.pack("<iiI",
                      0 if window_initial_size_test else 800,
                      0 if window_initial_size_test else initial_height, 0))
                + wire_message(9, 0, struct.pack("<I", 1234))
            )
            expect_message(client, (9, 4, struct.pack("<I", 1234)), "ack_configure")
            if disconnect_after_configure_ack:
                # Close before the next client request to verify the send helper
                # returns EPIPE without process termination by SIGPIPE.
                observations.append("compositor closed after xdg_surface.configure acknowledgement")
                return

            pool = recv_wayland_message(client)
            if pool[0:2] != (5, 0) or len(pool[3]) != 1:
                raise AssertionError(f"wl_shm.create_pool did not transfer exactly one fd: {pool!r}")
            pool_id, buffer_size = struct.unpack("<II", pool[2])
            expected_size = 3840 * 2160 * 4
            expected_pool_size = expected_size * 2
            if (pool_id, buffer_size) != (11, expected_pool_size):
                raise AssertionError(f"unexpected shm pool args: {(pool_id, buffer_size)!r}")
            shm_fd = pool[3][0]
            pixels = None
            try:
                if os.fstat(shm_fd).st_size != expected_pool_size:
                    raise AssertionError("memfd size does not match the two-slot shared buffer pool")
                pixels = mmap.mmap(shm_fd, expected_pool_size, access=mmap.ACCESS_READ)
                # The first wl_buffer uses fixed protocol object ID 12.
                # client_buffer_id is assigned later in specialized test branches.
                active_buffer = {"id": 12, "offset": 0}
                known_buffer_offsets = {12: 0}
                _BUFFER_TRACKING_STATES[client] = {
                    "initial_buffer_id": 12,
                    "active_buffer": active_buffer,
                    "known_offsets": known_buffer_offsets,
                }

                def buffer_release_message() -> bytes:
                    return wire_message(active_buffer["id"], 0)

                def rendered_color_present(
                    x: int, y: int, width: int, height: int, stride: int, color: int
                ) -> bool:
                    return any(
                        struct.unpack_from("<I", pixels, active_buffer["offset"] + row * stride + column * 4)[0] == color
                        for row in range(y, y + height)
                        for column in range(x, x + width)
                    )

                # The first wl_buffer is allocated before optional seat and
                # fractional-scale proxies can be appended to the dense ID map.
                # It therefore starts at 1x and may be replaced before attach
                # once the initial preferred_scale event is received.
                buffer_scale = 1 if fractional_scale_test else initial_preferred_buffer_scale
                raster_scale_120 = buffer_scale * 120

                def scaled_dimension(value: int) -> int:
                    return max(1, (value * raster_scale_120 + 60) // 120)

                surface_pixel_width = scaled_dimension(800)
                surface_pixel_height = scaled_dimension(initial_height)
                buffer_width, buffer_height = (
                    (surface_pixel_height, surface_pixel_width)
                    if initial_preferred_buffer_transform % 2
                    else (surface_pixel_width, surface_pixel_height)
                )
                buffer_stride = buffer_width * 4

                def logical_buffer_pixel(logical_x: int, logical_y: int) -> int:
                    # Surface-local pixels are pre-transformed into buffer coordinates.
                    x = logical_x * raster_scale_120 // 120
                    y = logical_y * raster_scale_120 // 120
                    transform = initial_preferred_buffer_transform
                    if transform == 1:
                        bx, by = y, surface_pixel_width - 1 - x
                    elif transform == 2:
                        bx, by = surface_pixel_width - 1 - x, surface_pixel_height - 1 - y
                    elif transform == 3:
                        bx, by = surface_pixel_height - 1 - y, x
                    elif transform == 4:
                        bx, by = surface_pixel_width - 1 - x, y
                    elif transform == 5:
                        bx, by = y, x
                    elif transform == 6:
                        bx, by = x, surface_pixel_height - 1 - y
                    elif transform == 7:
                        bx, by = surface_pixel_height - 1 - y, surface_pixel_width - 1 - x
                    else:
                        bx, by = x, y
                    return struct.unpack_from(
                        "<I", pixels, by * buffer_stride + bx * 4
                    )[0]

                def antialiased_ink_present(x: int, y: int, width: int, height: int) -> bool:
                    for row in range(y, y + height):
                        for column in range(x, x + width):
                            pixel = logical_buffer_pixel(column, row)
                            red, green, blue = (
                                (pixel >> 16) & 0xFF,
                                (pixel >> 8) & 0xFF,
                                pixel & 0xFF,
                            )
                            if red >= 128 and green >= 138 and blue >= 148:
                                return True
                    return False

                if initial_preferred_buffer_transform != 0:
                    if logical_buffer_pixel(2, 10) != 0xFF78A9D4:
                        raise AssertionError("transformed buffer did not preserve the accent rail")
                    if logical_buffer_pixel(3, 10) != 0xFF343D4B:
                        raise AssertionError("transformed buffer displaced the title-bar boundary")
                    if logical_buffer_pixel(400, 40) != 0xFF252A33:
                        raise AssertionError("transformed buffer did not preserve the document background")
                    if logical_buffer_pixel(4, initial_height - 20) != 0xFF78A9D4:
                        raise AssertionError("transformed buffer did not preserve the status separator")
                    if not any(
                        logical_buffer_pixel(x, y) != 0xFF343D4B
                        for y in range(8, 24) for x in range(16, 112)
                    ):
                        raise AssertionError("transformed buffer did not rasterize visible title text")
                    if font_parser_test and not any(
                        logical_buffer_pixel(x, y) != 0xFF252A33
                        for y in range(88, 124) for x in range(12, 120)
                    ):
                        raise AssertionError("TrueType glyph mask was not rendered through the preferred buffer transform")
                elif buffer_scale == 1:
                    if struct.unpack_from("<I", pixels, 4 * 4)[0] != 0xFF343D4B:
                        raise AssertionError("expected title-bar background was not rendered")
                    if struct.unpack_from("<I", pixels, 0)[0] != 0xFF78A9D4:
                        raise AssertionError("expected title-bar accent rail was not rendered")
                    for button_x, expected_color, button_name in (
                        (696, 0xFF414B5A, "minimize"),
                        (728, 0xFF414B5A, "maximize"),
                        (760, 0xFF754B52, "close"),
                    ):
                        button_pixel = struct.unpack_from(
                            "<I", pixels, 4 * 800 * 4 + button_x * 4
                        )[0]
                        if button_pixel != expected_color:
                            raise AssertionError(
                                f"{button_name} window control was not rendered: {hex(button_pixel)}"
                            )
                    if struct.unpack_from("<I", pixels, 74 * 800 * 4 + 20 * 4)[0] != 0xFF78A9D4:
                        raise AssertionError("active document tab underline was not rendered")
                    status_top = initial_height - 20
                    if struct.unpack_from("<I", pixels, status_top * 800 * 4)[0] != 0xFF78A9D4:
                        raise AssertionError("status bar accent separator was not rendered")
                    if struct.unpack_from("<I", pixels, (status_top + 1) * 800 * 4)[0] != 0xFF343D4B:
                        raise AssertionError("status bar background was not rendered")
    
                    if not font_parser_test and not antialiased_ink_present(16, initial_height - 16, 88, 14):
                        raise AssertionError("logical line status label was not rendered")
                    editor_origin_pixel = struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0]
                    if initial_file is None:
                        if editor_origin_pixel != 0xFF252A33:
                            raise AssertionError(
                                "empty document area should not draw a placeholder; "
                                f"pixel={hex(editor_origin_pixel)}"
                            )
                    elif not antialiased_ink_present(12, 88, 24, 16):
                        raise AssertionError("launch-time file glyph was not rendered near the document origin")
    
    
                else:
                    def physical_pixel(logical_x: int, logical_y: int) -> int:
                        return logical_buffer_pixel(logical_x, logical_y)
                    if physical_pixel(2, 10) != 0xFF78A9D4:
                        raise AssertionError("2x accent rail did not cover the logical 3px width")
                    if physical_pixel(3, 10) != 0xFF343D4B:
                        raise AssertionError("2x accent rail spilled beyond its logical width")
                    if physical_pixel(10, 10) != 0xFF343D4B:
                        raise AssertionError("2x title-bar rectangle did not cover its logical extent")
                    if physical_pixel(400, 40) != 0xFF252A33:
                        raise AssertionError("2x document background was not rendered at the selected scale")
                    if physical_pixel(4, initial_height - 20) != 0xFF78A9D4:
                        raise AssertionError("2x status separator was not rendered at physical pixel scale")
                    # Font loading is disabled in this test by default, so this
                    # confirms that the embedded 5x7 fallback is enlarged too.
                    if not any(
                        physical_pixel(x, y) == 0xFFD8DEE9
                        for y in range(8, 24) for x in range(16, 112)
                    ):
                        raise AssertionError("2x fallback glyphs were not rasterized into physical pixels")
                    observations.append("2x software rectangles and embedded glyphs preserve logical coordinates")

                expect_message(
                    client,
                    (11, 0, struct.pack("<6I", 12, 0, buffer_width, buffer_height, buffer_stride, 1)),
                    "create wl_buffer",
                )
                observations.append("memfd+SCM_RIGHTS buffer verified")

                if not seat_supported:
                    if not fractional_scale_test:
                        raise AssertionError("seat-less fixture is reserved for fractional viewport coverage")
                    viewport_object_id = 15
                    expect_fractional_scale_startup(
                        client, 13, 14, viewport_object_id, 16, 17,
                        initial_preferred_fractional_scale,
                    )
                    client_buffer_id = 12
                    target_raster_scale_120 = initial_preferred_fractional_scale
                    if target_raster_scale_120 != raster_scale_120:
                        expect_message(client, (client_buffer_id, 0, b""), "destroy unattached provisional buffer")
                        client_buffer_id = 18
                        raster_scale_120 = target_raster_scale_120
                        surface_pixel_width = scaled_dimension(800)
                        surface_pixel_height = scaled_dimension(initial_height)
                        buffer_width, buffer_height = (
                            (surface_pixel_height, surface_pixel_width)
                            if initial_preferred_buffer_transform % 2
                            else (surface_pixel_width, surface_pixel_height)
                        )
                        buffer_stride = buffer_width * 4
                        expect_message(
                            client,
                            (11, 0, struct.pack("<6I", client_buffer_id, 0, buffer_width, buffer_height, buffer_stride, 1)),
                            "create fractional-scale replacement buffer",
                        )
                        if logical_buffer_pixel(2, 10) != 0xFF78A9D4 or logical_buffer_pixel(4, 10) != 0xFF343D4B:
                            raise AssertionError("fractional-scale replacement did not rerasterize the accent rail at the exact preferred scale")
                        if logical_buffer_pixel(400, 40) != 0xFF252A33:
                            raise AssertionError("fractional-scale replacement lost logical document background")
                        observations.append("fractional preference rebuilt the unattached buffer at its exact preferred raster scale")
                    expect_message(
                        client, (viewport_object_id, 2, struct.pack("<ii", 800, initial_height)),
                        "set logical viewport destination without a seat",
                    )
                    expect_message(client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), "attach seat-less buffer")
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "damage seat-less surface in logical coordinates",
                    )
                    expect_message(client, (8, 6, b""), "map seat-less fractional surface")
                    observations.append("fractional viewport mapped correctly without wl_seat; client object IDs remained valid")
                    # Force a same-size configure after release. The display
                    # sync used ID 17 and the replacement buffer used ID 18,
                    # so the next frame callback must use ID 19. The mock drains
                    # frame requests while looking for the following attach;
                    # verify the callback ID through the recorded request list.
                    previous_frame_requests = frame_callback_stats["requested"]
                    client.sendall(
                        buffer_release_message()
                        + wire_message(10, 0, struct.pack("<iiI", 800, initial_height, 0))
                        + wire_message(9, 0, struct.pack("<I", 1235))
                    )
                    expect_message(client, (9, 4, struct.pack("<I", 1235)), "acknowledge seat-less configure")
                    expect_message(client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), "reattach seat-less buffer")
                    if (
                        frame_callback_stats["requested"] != previous_frame_requests + 1
                        or not frame_callback_stats["ids"]
                        or frame_callback_stats["ids"][-1] != 19
                    ):
                        raise AssertionError(
                            "seat-less frame callback did not use object ID 19 after fractional proxies: "
                            + repr(frame_callback_stats)
                        )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "damage seat-less redraw in logical coordinates",
                    )
                    expect_message(client, (8, 6, b""), "commit seat-less fractional redraw")
                    client.sendall(wire_message(10, 1))
                    return

                # The seat is bound after the existing window objects to keep
                # the client-side object ID sequence dense.
                seat_bind = expect_message(
                    client,
                    (
                        2,
                        0,
                        struct.pack("<II", 4, 8)
                        + b"wl_seat\0"
                        + struct.pack("<II", min(advertised_seat_version, 4), 13),
                    ),
                    "bind wl_seat",
                )
                expect_message(client, (1, 0, struct.pack("<I", 14)), "seat sync")
                pointer_object_id = 15
                keyboard_object_id = pointer_object_id + 1
                next_test_object_id = keyboard_object_id + 1
                client.sendall(wire_message(13, 0, struct.pack("<I", 3)))
                expect_message(
                    client,
                    (13, 0, struct.pack("<I", pointer_object_id)),
                    "get wl_pointer",
                )
                expect_message(
                    client,
                    (13, 1, struct.pack("<I", keyboard_object_id)),
                    "get wl_keyboard",
                )
                # Exercise a valid wl_keyboard.keymap event before callback 14
                # ends the initial seat roundtrip. The no-keymap format carries
                # an FD too; the client must consume it rather than lose the
                # first keyboard event while waiting for sync.done.
                if keyboard_layout_test or fractional_sync_keymap_test:
                    early_keymap_fd = os.memfd_create("nekoedit-early-no-keymap", 0)
                    try:
                        early_keymap_event = wire_message(
                            keyboard_object_id, 0, struct.pack("<II", 0, 0)
                        )
                        client.sendmsg(
                            [early_keymap_event],
                            [(socket.SOL_SOCKET, socket.SCM_RIGHTS, struct.pack("i", early_keymap_fd))],
                        )
                    finally:
                        os.close(early_keymap_fd)
                # Send pointer.enter only after get_pointer has created its object,
                # and before callback 14 ends the client's initial seat roundtrip.
                client.sendall(
                    wire_message(pointer_object_id, 0, struct.pack("<IIii", 777, 8, 100 * 256, 110 * 256))
                    + wire_message(14, 0, struct.pack("<I", 2))
                )
                if cursor_shape_supported:
                    cursor_shape_manager_id = next_test_object_id
                    cursor_shape_device_id = cursor_shape_manager_id + 1
                    next_test_object_id += 2
                    expect_message(
                        client,
                        (
                            2, 0,
                            struct.pack("<II", 5, 27)
                            + b"wp_cursor_shape_manager_v1\0"
                            + b"\0"
                            + struct.pack("<II", 1, cursor_shape_manager_id),
                        ),
                        "bind cursor-shape manager",
                    )
                    expect_message(
                        client,
                        (cursor_shape_manager_id, 1, struct.pack("<II", cursor_shape_device_id, pointer_object_id)),
                        "get cursor-shape pointer",
                    )
                    expect_message(
                        client, (cursor_shape_device_id, 1, struct.pack("<II", 777, 1)),
                        "set initial default cursor shape",
                    )
                    observations.append("optional cursor-shape manager bound; startup pointer.enter retained and applied")
                if clipboard_test or clipboard_persistence_test:
                    manager_name = b"wl_data_device_manager\0"
                    manager_padded = manager_name + (b"\0" * (-len(manager_name) % 4))
                    clipboard_manager_id = next_test_object_id
                    clipboard_device_id = clipboard_manager_id + 1
                    expect_message(
                        client,
                        (2, 0, struct.pack("<II", 6, len(manager_name)) + manager_padded + struct.pack("<II", 1, clipboard_manager_id)),
                        "bind wl_data_device_manager",
                    )
                    expect_message(
                        client, (clipboard_manager_id, 1, struct.pack("<II", clipboard_device_id, 13)),
                        "get wl_data_device for the application seat",
                    )
                    next_test_object_id += 2
                    observations.append("wl_data_device_manager bound; wl_data_device created for seat 13")
                if text_input_test or seat_hotplug_ime_test:
                    manager_name = b"zwp_text_input_manager_v3\0"
                    manager_padded = manager_name + (b"\0" * (-len(manager_name) % 4))
                    test_text_input_manager_id = next_test_object_id
                    test_text_input_id = test_text_input_manager_id + 1
                    expect_message(
                        client,
                        (2, 0, struct.pack("<II", 7, len(manager_name)) + manager_padded + struct.pack("<II", 1, test_text_input_manager_id)),
                        "bind zwp_text_input_manager_v3",
                    )
                    expect_message(
                        client, (test_text_input_manager_id, 1, struct.pack("<II", test_text_input_id, 13)),
                        "get text-input object for the application seat",
                    )
                    next_test_object_id += 2
                    observations.append("optional text-input-v3 manager bound and object created for seat 13")
                viewport_object_id = 0
                if fractional_scale_test:
                    viewport_object_id = next_test_object_id + 2
                    fractional_id = next_test_object_id + 3
                    fractional_sync_id = next_test_object_id + 4
                    expect_fractional_scale_startup(
                        client, next_test_object_id, next_test_object_id + 1,
                        viewport_object_id, fractional_id, fractional_sync_id,
                        initial_preferred_fractional_scale,
                        keyboard_object_id if (keyboard_layout_test or fractional_sync_keymap_test) else None,
                    )
                    next_test_object_id += 5
                if output_tracking_enabled:
                    # Outputs are created after every fixed bootstrap and optional
                    # input-service proxy, preserving Wayland's contiguous new_id map.
                    output_name = b"wl_output\0"
                    output_padded = output_name + (b"\0" * (-len(output_name) % 4))
                    output_v3_id = next_test_object_id
                    output_v2_id = output_v3_id + 1
                    for global_name, version, object_id in (
                        (8, 3, output_v3_id), (9, 2, output_v2_id)
                    ):
                        expect_message(
                            client,
                            (
                                2, 0,
                                struct.pack("<II", global_name, len(output_name))
                                + output_padded
                                + struct.pack("<II", version, object_id),
                            ),
                            f"bind wl_output global {global_name}",
                        )
                    next_test_object_id += 2
                    output_sync_id = next_test_object_id
                    expect_message(
                        client, (1, 0, struct.pack("<I", output_sync_id)),
                        "sync initial wl_output mode and scale state",
                    )
                    next_test_object_id += 1
                    initial_output_events = b""
                    if window_initial_size_test:
                        initial_output_events += (
                            wire_message(output_v3_id, 1, struct.pack("<IiiI", 1, 1920, 1080, 60000))
                            + wire_message(output_v3_id, 3, struct.pack("<i", 1))
                            + wire_message(output_v3_id, 2)
                            + wire_message(output_v2_id, 1, struct.pack("<IiiI", 1, 2560, 1440, 60000))
                            + wire_message(output_v2_id, 3, struct.pack("<i", 2))
                            + wire_message(output_v2_id, 2)
                        )
                    client.sendall(initial_output_events + wire_message(output_sync_id, 0))
                client_buffer_id = 12
                if window_initial_size_test:
                    expect_message(client, (client_buffer_id, 0, b""), "destroy unattached default-size buffer")
                    client_buffer_id = next_test_object_id
                    next_test_object_id += 1
                    surface_pixel_width = 1280
                    surface_pixel_height = 720
                    buffer_scale = 1
                    buffer_width, buffer_height = surface_pixel_width, surface_pixel_height
                    buffer_stride = buffer_width * 4
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", client_buffer_id, 0, buffer_width, buffer_height, buffer_stride, 1)),
                        "create output-sized startup buffer",
                    )
                    if logical_buffer_pixel(4, 20) != 0xFF78A9D4:
                        raise AssertionError("scaled accent rail did not use the selected UI density")
                    if logical_buffer_pixel(5, 20) != 0xFF343D4B:
                        raise AssertionError("scaled accent rail width did not preserve its boundary")
                    if logical_buffer_pixel(10, 48) != 0xFF252A33:
                        raise AssertionError("scaled title-bar height did not reach the output-space boundary")
                    if not any(
                        logical_buffer_pixel(x, y) == 0xFFD8DEE9
                        for y in range(10, 38) for x in range(20, 120)
                    ):
                        raise AssertionError("UI font glyphs were not rasterized at the selected density")
                    observations.append("initial output mode/scale selected a 1280x720 window and rebuilt the unattached buffer")
                target_raster_scale_120 = initial_preferred_fractional_scale
                if fractional_scale_test and target_raster_scale_120 != raster_scale_120:
                    expect_message(client, (client_buffer_id, 0, b""), "destroy unattached provisional buffer")
                    client_buffer_id = next_test_object_id
                    next_test_object_id += 1
                    raster_scale_120 = target_raster_scale_120
                    surface_pixel_width = scaled_dimension(800)
                    surface_pixel_height = scaled_dimension(initial_height)
                    buffer_width, buffer_height = (
                        (surface_pixel_height, surface_pixel_width)
                        if initial_preferred_buffer_transform % 2
                        else (surface_pixel_width, surface_pixel_height)
                    )
                    buffer_stride = buffer_width * 4
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", client_buffer_id, 0, buffer_width, buffer_height, buffer_stride, 1)),
                        "create fractional-scale replacement buffer",
                    )
                    if logical_buffer_pixel(2, 10) != 0xFF78A9D4 or logical_buffer_pixel(4, 10) != 0xFF343D4B:
                        raise AssertionError("fractional-scale replacement did not rerasterize the accent rail at the exact preferred scale")
                    if logical_buffer_pixel(400, 40) != 0xFF252A33:
                        raise AssertionError("fractional-scale replacement lost logical document background")
                    observations.append("fractional preference rebuilt the unattached buffer at its exact preferred raster scale")
                # Map only after all initial client objects have been allocated.
                # A new wl_surface already defaults to buffer_scale=1;
                # fractional viewport mode must not send a redundant scale
                # request or substitute the oversampled source scale here.
                if not fractional_scale_test and buffer_scale > 1:
                    expect_message(
                        client, (8, 8, struct.pack("<i", buffer_scale)),
                        "set non-default surface buffer scale",
                    )
                if initial_preferred_buffer_transform != 0:
                    expect_message(
                        client,
                        (8, 7, struct.pack("<i", initial_preferred_buffer_transform)),
                        "set preferred surface buffer transform",
                    )
                if fractional_scale_test:
                    expect_message(
                        client, (viewport_object_id, 2, struct.pack("<ii", 800, initial_height)),
                        "set logical viewport destination before mapping",
                    )
                expect_message(client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), "attach buffer")
                expect_message(
                    client,
                    (8, 2, struct.pack("<4I", 0, 0, 800 if fractional_scale_test else surface_pixel_width // buffer_scale, initial_height if fractional_scale_test else surface_pixel_height // buffer_scale)),
                    "damage surface in compositor logical coordinates",
                )
                expect_message(client, (8, 6, b""), "initial map surface")
                if window_initial_size_test:
                    wanted_size_symbols = {
                        "window_surface_width", "window_surface_height",
                        "window_width", "window_height", "window_ui_scale_120",
                        "window_buffer_width", "window_buffer_height", "window_stride",
                        "window_buffer_raster_scale_120", "window_raster_surface_width", "window_raster_surface_height",
                        "output_display_width", "output_display_height",
                        "pointer_x", "pointer_y", "pointer_surface_x", "pointer_surface_y",
                    }
                    size_symbols = {}
                    for line in subprocess.check_output(["nm", "-n", binary], text=True).splitlines():
                        fields = line.split()
                        if len(fields) == 3 and fields[2] in wanted_size_symbols:
                            size_symbols[fields[2]] = int(fields[0], 16)
                    if set(size_symbols) != wanted_size_symbols:
                        raise AssertionError(f"startup size symbols missing: {size_symbols!r}")
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 1002, 168 * 256, 18 * 256))
                    )
                    pointer_deadline = time.monotonic() + 2.0
                    pointer_state = {}
                    while time.monotonic() < pointer_deadline:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            pointer_state = {
                                name: struct.unpack("<I", os.pread(memory.fileno(), 4, size_symbols[name]))[0]
                                for name in ("pointer_x", "pointer_y", "pointer_surface_x", "pointer_surface_y")
                            }
                        if pointer_state == {
                            "pointer_x": 112, "pointer_y": 12,
                            "pointer_surface_x": 168, "pointer_surface_y": 18,
                        }:
                            break
                        time.sleep(0.005)
                    if pointer_state != {
                        "pointer_x": 112, "pointer_y": 12,
                        "pointer_surface_x": 168, "pointer_surface_y": 18,
                    }:
                        raise AssertionError(f"pointer coordinates did not round-trip through the 1.5x UI density: {pointer_state!r}")
                    with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                        state = {
                            name: struct.unpack("<I", os.pread(memory.fileno(), 4, address))[0]
                            for name, address in size_symbols.items()
                        }
                    expected = {
                        "window_surface_width": 1280, "window_surface_height": 720,
                        "window_width": 853, "window_height": 480, "window_ui_scale_120": 180,
                        "window_buffer_width": 1280, "window_buffer_height": 720, "window_stride": 5120,
                        "window_buffer_raster_scale_120": 120,
                        "window_raster_surface_width": 1280, "window_raster_surface_height": 720,
                        "output_display_width": 1920, "output_display_height": 1080,
                        "pointer_x": 112, "pointer_y": 12,
                        "pointer_surface_x": 168, "pointer_surface_y": 18,
                    }
                    if state != expected:
                        raise AssertionError(f"initial size/density did not match 2/3 output rule: {state!r}")
                    observations.append("virtual layout is 853x480 at 150% density inside the 1280x720 output-sized surface")
                    observations.append("surface pointer coordinates map back to the virtual UI space at 1.5x density")
                    client.sendall(wire_message(10, 1))
                    return
                if dpi_runtime_test:
                    wanted_dpi_state = (
                        "window_buffer_scale", "window_buffer_created_scale",
                        "window_buffer_width", "window_buffer_height", "window_stride",
                        "window_buffer_transform", "window_buffer_created_transform",
                        "surface_applied_buffer_transform",
                        "window_buffer_id", "frame_callback_id",
                    )
                    dpi_symbols = {}
                    for symbol_line in subprocess.check_output(["nm", "-n", binary], text=True).splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in wanted_dpi_state:
                            dpi_symbols[fields[2]] = int(fields[0], 16)
                    if set(dpi_symbols) != set(wanted_dpi_state):
                        raise AssertionError(f"DPI state symbols are incomplete: {dpi_symbols!r}")

                    def dpi_value(name: str) -> int:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            raw = os.pread(memory.fileno(), 4, dpi_symbols[name])
                        if len(raw) != 4:
                            raise AssertionError(f"short DPI state read for {name}")
                        return struct.unpack("<I", raw)[0]

                    def wait_dpi(name: str, expected: int) -> None:
                        deadline = time.monotonic() + 3.0
                        actual = dpi_value(name)
                        while actual != expected and time.monotonic() < deadline:
                            time.sleep(0.005)
                            actual = dpi_value(name)
                        if actual != expected:
                            raise AssertionError(
                                f"DPI state {name}: expected {expected}, got {actual}"
                            )

                    # Preference changes immediately, but the original 1x
                    # descriptor must remain untouched until release.
                    client.sendall(wire_message(8, 2, struct.pack("<I", 2)))
                    wait_dpi("window_buffer_scale", 2)
                    wait_dpi("window_buffer_created_scale", 1)
                    client.sendall(buffer_release_message())
                    expect_message(client, (client_buffer_id, 0, b""), "destroy released 1x buffer")
                    create_2x = recv_wayland_message(client)
                    if create_2x[0:2] != (11, 0) or len(create_2x[2]) != 24 or create_2x[3]:
                        raise AssertionError(f"2x buffer was not recreated from the shared pool: {create_2x!r}")
                    buffer_2x, _offset, width_2x, height_2x, stride_2x, format_2x = struct.unpack("<6I", create_2x[2])
                    if (width_2x, height_2x, stride_2x, format_2x) != (1600, 960, 6400, 1):
                        raise AssertionError(
                            f"unexpected 2x physical buffer geometry: {(width_2x, height_2x, stride_2x, format_2x)!r}"
                        )
                    expect_message(client, (8, 8, struct.pack("<i", 2)), "commit 2x buffer scale")
                    expect_message(client, (8, 1, struct.pack("<III", buffer_2x, 0, 0)), "attach 2x buffer")
                    expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "damage in logical coordinates")
                    expect_message(client, (8, 6, b""), "commit 2x buffer")
                    wait_dpi("window_buffer_created_scale", 2)
                    wait_dpi("window_buffer_width", 1600)
                    wait_dpi("window_buffer_height", 960)
                    wait_dpi("frame_callback_id", 0)

                    # Returning to 1x must also wait for release of the 2x
                    # descriptor, then restore physical geometry and scaling.
                    client.sendall(wire_message(8, 2, struct.pack("<I", 1)))
                    wait_dpi("window_buffer_scale", 1)
                    wait_dpi("window_buffer_created_scale", 2)
                    client.sendall(wire_message(buffer_2x, 0))
                    expect_message(client, (buffer_2x, 0, b""), "destroy released 2x buffer")
                    create_1x = recv_wayland_message(client)
                    if create_1x[0:2] != (11, 0) or len(create_1x[2]) != 24 or create_1x[3]:
                        raise AssertionError(f"1x buffer was not recreated from the shared pool: {create_1x!r}")
                    buffer_1x, _offset, width_1x, height_1x, stride_1x, format_1x = struct.unpack("<6I", create_1x[2])
                    if (width_1x, height_1x, stride_1x, format_1x) != (800, 480, 3200, 1):
                        raise AssertionError(
                            f"unexpected restored 1x buffer geometry: {(width_1x, height_1x, stride_1x, format_1x)!r}"
                        )
                    expect_message(client, (8, 8, struct.pack("<i", 1)), "restore 1x buffer scale")
                    expect_message(client, (8, 1, struct.pack("<III", buffer_1x, 0, 0)), "attach restored 1x buffer")
                    expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "damage restored logical surface")
                    expect_message(client, (8, 6, b""), "commit restored 1x buffer")
                    wait_dpi("window_buffer_created_scale", 1)
                    wait_dpi("window_buffer_width", 800)
                    wait_dpi("window_buffer_height", 480)

                    # A transform-only preference change also remains pending
                    # until the current wl_buffer is released.
                    client.sendall(wire_message(8, 3, struct.pack("<I", 1)))
                    wait_dpi("window_buffer_transform", 1)
                    wait_dpi("window_buffer_created_transform", 0)
                    client.sendall(wire_message(buffer_1x, 0))
                    expect_message(client, (buffer_1x, 0, b""), "destroy released normal transform buffer")
                    create_rotated = recv_wayland_message(client)
                    if create_rotated[0:2] != (11, 0) or len(create_rotated[2]) != 24 or create_rotated[3]:
                        raise AssertionError(f"rotated buffer was not recreated from the shared pool: {create_rotated!r}")
                    buffer_rotated, _offset, width_rotated, height_rotated, stride_rotated, format_rotated = struct.unpack("<6I", create_rotated[2])
                    if (width_rotated, height_rotated, stride_rotated, format_rotated) != (480, 800, 1920, 1):
                        raise AssertionError(
                            f"unexpected 90-degree buffer geometry: {(width_rotated, height_rotated, stride_rotated, format_rotated)!r}"
                        )
                    expect_message(client, (8, 7, struct.pack("<i", 1)), "apply runtime 90-degree transform")
                    expect_message(client, (8, 1, struct.pack("<III", buffer_rotated, 0, 0)), "attach rotated buffer")
                    expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "damage logical surface after rotation")
                    expect_message(client, (8, 6, b""), "commit rotated buffer")
                    wait_dpi("window_buffer_created_transform", 1)
                    wait_dpi("window_buffer_width", 480)
                    wait_dpi("window_buffer_height", 800)
                    wait_dpi("frame_callback_id", 0)

                    # Restore normal orientation through the same release gate.
                    client.sendall(wire_message(8, 3, struct.pack("<I", 0)))
                    wait_dpi("window_buffer_transform", 0)
                    wait_dpi("window_buffer_created_transform", 1)
                    client.sendall(wire_message(buffer_rotated, 0))
                    expect_message(client, (buffer_rotated, 0, b""), "destroy released rotated buffer")
                    create_normal = recv_wayland_message(client)
                    if create_normal[0:2] != (11, 0) or len(create_normal[2]) != 24 or create_normal[3]:
                        raise AssertionError(f"normal buffer was not restored: {create_normal!r}")
                    buffer_normal, _offset, width_normal, height_normal, stride_normal, format_normal = struct.unpack("<6I", create_normal[2])
                    if (width_normal, height_normal, stride_normal, format_normal) != (800, 480, 3200, 1):
                        raise AssertionError(
                            f"unexpected normal buffer geometry: {(width_normal, height_normal, stride_normal, format_normal)!r}"
                        )
                    expect_message(client, (8, 7, struct.pack("<i", 0)), "restore normal buffer transform")
                    expect_message(client, (8, 1, struct.pack("<III", buffer_normal, 0, 0)), "attach normal buffer")
                    expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "damage restored logical surface")
                    expect_message(client, (8, 6, b""), "commit normal buffer")
                    wait_dpi("window_buffer_created_transform", 0)
                    wait_dpi("window_buffer_width", 800)
                    wait_dpi("window_buffer_height", 480)
                    wait_dpi("frame_callback_id", 0)

                    observations.append(
                        "preferred 1x/2x/1x scales and 0/90/0 transforms all replace buffers only after release; logical damage remains unchanged"
                    )
                    client.sendall(wire_message(10, 1))
                    return
                if output_tracking_enabled:
                    # Inspect the live output cache and surface membership.
                    output_symbols = {}
                    wanted_outputs = (
                        "output_global_names", "output_object_ids", "output_versions",
                        "output_scales", "output_pending_scales", "output_pending_valid",
                        "output_surface_entered", "surface_output_count", "surface_output_max_scale",
                        "compositor_version", "surface_preferred_buffer_scale",
                        "surface_preferred_scale_seen", "surface_preferred_buffer_transform",
                        "surface_preferred_transform_seen", "surface_effective_buffer_scale",
                    )
                    for symbol_line in subprocess.check_output(
                        ["nm", "-n", binary], text=True
                    ).splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in wanted_outputs:
                            output_symbols[fields[2]] = int(fields[0], 16)
                    if set(output_symbols) != set(wanted_outputs):
                        raise AssertionError(
                            f"output tracking symbols are incomplete: {output_symbols!r}"
                        )

                    def output_value(name: str, index: int = 0) -> int:
                        with open(
                            f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0
                        ) as memory:
                            raw = os.pread(
                                memory.fileno(), 4, output_symbols[name] + index * 4
                            )
                        if len(raw) != 4:
                            raise AssertionError(f"short process-state read for {name}[{index}]")
                        return struct.unpack("<I", raw)[0]

                    def wait_output(name: str, expected: int, index: int = 0) -> None:
                        deadline = time.monotonic() + 3.0
                        actual = output_value(name, index)
                        while actual != expected and time.monotonic() < deadline:
                            time.sleep(0.005)
                            actual = output_value(name, index)
                        if actual != expected:
                            raise AssertionError(
                                f"output state {name}[{index}]: expected {expected}, got {actual}"
                            )

                    # Stage two output scales and enter the surface. Neither
                    # committed output metadata nor the selected scale may move
                    # until each output's done event is received.
                    client.sendall(
                        wire_message(output_v3_id, 3, struct.pack("<I", 2))
                        + wire_message(output_v2_id, 3, struct.pack("<I", 3))
                        + wire_message(8, 0, struct.pack("<I", output_v3_id))
                        + wire_message(8, 0, struct.pack("<I", output_v2_id))
                    )
                    wait_output("compositor_version", 6 if output_tracking_test else 1)
                    wait_output("output_global_names", 8, 0)
                    wait_output("output_global_names", 9, 1)
                    wait_output("output_object_ids", output_v3_id, 0)
                    wait_output("output_object_ids", output_v2_id, 1)
                    wait_output("output_versions", 3, 0)
                    wait_output("output_versions", 2, 1)
                    wait_output("output_pending_valid", 1, 0)
                    wait_output("output_pending_valid", 1, 1)
                    wait_output("output_pending_scales", 2, 0)
                    wait_output("output_pending_scales", 3, 1)
                    wait_output("output_scales", 1, 0)
                    wait_output("output_scales", 1, 1)
                    wait_output("output_surface_entered", 1, 0)
                    wait_output("output_surface_entered", 1, 1)
                    wait_output("surface_output_count", 2)
                    wait_output("surface_output_max_scale", 1)
                    wait_output("surface_effective_buffer_scale", 1)

                    if output_tracking_test:
                        # wl_surface v6's preference is authoritative even when
                        # overlapping outputs advertise different scale factors.
                        client.sendall(
                            wire_message(8, 2, struct.pack("<I", 2))
                            + wire_message(8, 3, struct.pack("<I", 1))
                        )
                        wait_output("surface_preferred_buffer_scale", 2)
                        wait_output("surface_preferred_scale_seen", 1)
                        wait_output("surface_preferred_buffer_transform", 1)
                        wait_output("surface_preferred_transform_seen", 1)
                        wait_output("surface_effective_buffer_scale", 2)
                        client.sendall(
                            wire_message(8, 2, struct.pack("<I", 1))
                            + wire_message(8, 3, struct.pack("<I", 0))
                        )
                        wait_output("surface_preferred_buffer_scale", 1)
                        wait_output("surface_preferred_buffer_transform", 0)
                        wait_output("surface_effective_buffer_scale", 1)
                    else:
                        # Pre-v6 compositors cannot send a per-surface preference;
                        # defaults remain untouched and output scales are fallback.
                        wait_output("surface_preferred_buffer_scale", 1)
                        wait_output("surface_preferred_scale_seen", 0)
                        wait_output("surface_preferred_buffer_transform", 0)
                        wait_output("surface_preferred_transform_seen", 0)

                    client.sendall(
                        wire_message(output_v3_id, 2) + wire_message(output_v2_id, 2)
                    )
                    wait_output("output_pending_valid", 0, 0)
                    wait_output("output_pending_valid", 0, 1)
                    wait_output("output_scales", 2, 0)
                    wait_output("output_scales", 3, 1)
                    wait_output("surface_output_max_scale", 3)
                    wait_output("surface_effective_buffer_scale", 1 if output_tracking_test else 3)
                    if output_tracking_test:
                        observations.append(
                            "wl_compositor v6 preferred surface scale overrides multi-output wl_output scale fallback"
                        )
                    else:
                        observations.append(
                            "pre-v6 compositor selects maximum committed scale among entered wl_output objects"
                        )

                    # Remove an entered v3 output: the client must send its
                    # release request and recalculate the surface's scale cache.
                    client.sendall(wire_message(2, 1, struct.pack("<I", 8)))
                    expect_message(client, (output_v3_id, 0, b""), "release removed wl_output v3")
                    wait_output("output_global_names", 0, 0)
                    wait_output("output_object_ids", 0, 0)
                    wait_output("surface_output_count", 1)
                    wait_output("surface_output_max_scale", 3)
                    wait_output("surface_effective_buffer_scale", 1 if output_tracking_test else 3)

                    hot_added_output_id = next_test_object_id
                    # A hot-added output reuses the free table slot but must
                    # receive a fresh client object ID from the monotonic allocator.
                    client.sendall(registry_global(10, "wl_output", version=3))
                    output_name = b"wl_output\0"
                    output_padded = output_name + (b"\0" * (-len(output_name) % 4))
                    expect_message(
                        client,
                        (
                            2, 0,
                            struct.pack("<II", 10, len(output_name))
                            + output_padded
                            + struct.pack("<II", 3, hot_added_output_id),
                        ),
                        "bind hot-added wl_output with a fresh object ID",
                    )
                    client.sendall(
                        wire_message(hot_added_output_id, 3, struct.pack("<I", 4))
                        + wire_message(8, 0, struct.pack("<I", hot_added_output_id))
                    )
                    wait_output("output_global_names", 10, 0)
                    wait_output("output_object_ids", hot_added_output_id, 0)
                    wait_output("output_pending_valid", 1, 0)
                    wait_output("output_pending_scales", 4, 0)
                    wait_output("output_scales", 1, 0)
                    wait_output("output_surface_entered", 1, 0)
                    wait_output("surface_output_count", 2)
                    wait_output("surface_output_max_scale", 3)
                    wait_output("surface_effective_buffer_scale", 1 if output_tracking_test else 3)
                    client.sendall(wire_message(hot_added_output_id, 2))
                    wait_output("output_pending_valid", 0, 0)
                    wait_output("output_scales", 4, 0)
                    wait_output("surface_output_max_scale", 4)
                    wait_output("surface_effective_buffer_scale", 1 if output_tracking_test else 4)

                    # Remove the v2 output. It has no release request; the next
                    # expected client request is therefore only the v3 output release.
                    client.sendall(
                        wire_message(8, 1, struct.pack("<I", 16))
                        + wire_message(2, 1, struct.pack("<I", 9))
                    )
                    wait_output("output_global_names", 0, 1)
                    wait_output("output_object_ids", 0, 1)
                    wait_output("surface_output_count", 1)
                    wait_output("surface_output_max_scale", 4)
                    wait_output("surface_effective_buffer_scale", 1 if output_tracking_test else 4)

                    client.sendall(wire_message(8, 1, struct.pack("<I", hot_added_output_id)))
                    wait_output("output_surface_entered", 0, 0)
                    wait_output("surface_output_count", 0)
                    wait_output("surface_output_max_scale", 1)
                    wait_output("surface_effective_buffer_scale", 1)

                    client.sendall(wire_message(2, 1, struct.pack("<I", 10)))
                    expect_message(
                        client, (hot_added_output_id, 0, b""), "release removed hot-added wl_output v3"
                    )
                    wait_output("output_global_names", 0, 0)
                    wait_output("output_object_ids", 0, 0)
                    observations.append(
                        "wl_registry.global_remove releases v3 outputs, skips unsupported v2 release, "
                        "and supports output hot-add, surface leave and scale-cache recomputation"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if seat_hotplug_test:
                    # Inspect existing process state, not a test-only app hook.
                    state_symbols = {}
                    wanted_state = (
                        "keyboard_focused", "xkb_modifiers", "ctrl_down",
                        "shift_down", "keyboard_group", "pointer_inside",
                        "pointer_enter_serial", "buffer_busy",
                        "frame_callback_id", "redraw_pending",
                    )
                    for symbol_line in subprocess.check_output(
                        ["nm", "-n", binary], text=True
                    ).splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in wanted_state:
                            state_symbols[fields[2]] = int(fields[0], 16)
                    if set(state_symbols) != set(wanted_state):
                        raise AssertionError(
                            f"hotplug state symbols are incomplete: {state_symbols!r}"
                        )

                    def child_state(name: str) -> int:
                        with open(
                            f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0
                        ) as memory:
                            raw = os.pread(memory.fileno(), 4, state_symbols[name])
                        if len(raw) != 4:
                            raise AssertionError(f"short process-state read for {name}")
                        return struct.unpack("<I", raw)[0]

                    def wait_state(name: str, expected: int) -> None:
                        deadline = time.monotonic() + 3.0
                        actual = child_state(name)
                        while actual != expected and time.monotonic() < deadline:
                            time.sleep(0.005)
                            actual = child_state(name)
                        if actual != expected:
                            raise AssertionError(
                                f"hotplug did not update {name}: expected {expected}, got {actual}"
                            )

                    # Put the one shared buffer and frame callback into the
                    # idle state first. The keyboard removal below must submit
                    # its state-clear redraw immediately, not wait for a future
                    # pointer/key event to wake the renderer.
                    client.sendall(buffer_release_message())
                    wait_state("buffer_busy", 0)
                    initial_callback = child_state("frame_callback_id")
                    if initial_callback:
                        client.sendall(
                            wire_message(initial_callback, 0, struct.pack("<I", 1))
                        )
                        wait_state("frame_callback_id", 0)

                    # Establish real keyboard focus and non-zero modifier state,
                    # then prove capability removal clears it before a new
                    # keyboard object is created.
                    client.sendall(wire_message(keyboard_object_id, 1, struct.pack("<III", 880, 8, 0)))
                    wait_state("keyboard_focused", 1)
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 881, 5, 0, 0, 2))
                    )
                    wait_state("xkb_modifiers", 5)
                    wait_state("ctrl_down", 1)
                    wait_state("shift_down", 1)
                    wait_state("keyboard_group", 2)

                    # Drop/re-add the keyboard, then pointer. Versions 3+ have
                    # explicit release requests; older seat versions do not.
                    client.sendall(wire_message(13, 0, struct.pack("<I", 1)))
                    if advertised_seat_version >= 3:
                        expect_message(client, (16, 0, b""), "release removed wl_keyboard")
                    # For v1/v2 the next expected frame request below also
                    # proves that no unsupported keyboard.release was sent.
                    wait_state("keyboard_focused", 0)
                    wait_state("xkb_modifiers", 0)
                    wait_state("ctrl_down", 0)
                    wait_state("shift_down", 0)
                    wait_state("keyboard_group", 0)

                    # Keyboard removal marked the surface dirty. Because the
                    # initial buffer/frame gates were idle, the seat handler
                    # must present a replacement frame immediately. The
                    # recv_wayland_message helper intentionally consumes
                    # wl_surface.frame requests and records them in
                    # frame_callback_stats, so the first visible request here
                    # is the following buffer attach.
                    previous_frame_requests = frame_callback_stats["requested"]
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)),
                        "attach immediate seat-state redraw buffer",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "damage immediate seat-state redraw buffer",
                    )
                    expect_message(client, (8, 6, b""), "commit immediate seat-state redraw")
                    wait_state("frame_callback_id", 0)
                    wait_state("buffer_busy", 1)
                    wait_state("redraw_pending", 0)
                    if (
                        frame_callback_stats["requested"] != previous_frame_requests + 1
                        or not frame_callback_stats["ids"]
                        or frame_callback_stats["ids"][-1] != 19
                        or frame_callback_stats["completed"] != frame_callback_stats["requested"]
                    ):
                        raise AssertionError(
                            "seat-state redraw did not register and complete exactly one frame callback: "
                            + repr(frame_callback_stats)
                        )

                    client.sendall(wire_message(13, 0, struct.pack("<I", 3)))
                    expect_message(
                        client, (13, 1, struct.pack("<I", 20)),
                        "create a fresh wl_keyboard after capability return",
                    )

                    client.sendall(wire_message(13, 0, struct.pack("<I", 2)))
                    expect_message(client, (18, 0, b""), "destroy cursor-shape device for removed pointer")
                    if advertised_seat_version >= 3:
                        expect_message(client, (15, 1, b""), "release removed wl_pointer")
                    wait_state("pointer_inside", 0)
                    wait_state("pointer_enter_serial", 0)

                    client.sendall(wire_message(13, 0, struct.pack("<I", 3)))
                    expect_message(
                        client, (13, 0, struct.pack("<I", 21)),
                        "create a fresh wl_pointer after capability return",
                    )
                    expect_message(
                        client,
                        (17, 1, struct.pack("<II", 22, 21)),
                        "recreate cursor-shape device for replacement pointer",
                    )
                    client.sendall(
                        wire_message(21, 0, struct.pack("<IIii", 888, 8, 100 * 256, 110 * 256))
                        + wire_message(20, 1, struct.pack("<III", 888, 8, 0))
                    )
                    expect_message(
                        client, (22, 1, struct.pack("<II", 888, 1)),
                        "set cursor using replacement pointer enter serial",
                    )
                    wait_state("keyboard_focused", 1)
                    observations.append(
                        "seat capability removal/re-addition releases v3 proxies, abandons v1/v2 proxies safely, "
                        "clears held modifiers and focus state, resets pointer serial/focus, and recreates cursor-shape device"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                observations.append("seat pointer and keyboard capability/object creation verified")

                # Release the initial buffer before sending a click. The client
                # must not rewrite the shared memory while the compositor owns it.
                client.sendall(
                    buffer_release_message()
                    + wire_message(pointer_object_id, 2,
                        struct.pack(
                            "<Iii", 777,
                            (50 if utf8_pointer_test else (34 if gap_buffer_test else (18 if (utf8_edit_test or utf8_delete_test or utf8_invalid_test or dynamic_growth_test or grapheme_test) else (27 if font_parser_test else 98)))) * 256,
                            (98 if (utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test or gap_buffer_test or dynamic_growth_test or grapheme_test or font_parser_test) else 110) * 256,
                        ),
                    )
                    + wire_message(pointer_object_id, 3, struct.pack("<IIII", 778, 1000, 0x110, 1))
                )
                expect_message(client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), "redraw attach")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "redraw damage")
                expect_message(client, (8, 6, b""), "redraw commit")
                if (initial_preferred_buffer_transform != 0 and not font_parser_test) or not (
                    sparse_keymap_test or punctuation_render_test or line_index_test or grapheme_test
                    or utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test
                    or gap_buffer_test or dynamic_growth_test or font_parser_test or font_picker_test
                    or clipboard_test or clipboard_persistence_test or history_test or horizontal_scroll_test or word_navigation_test or pointer_drag_test
                    or line_navigation_test or find_replace_test
                ):
                    def document_pixel(logical_x: int, logical_y: int) -> int:
                        # Hit testing stays logical; sample the transformed physical buffer.
                        return logical_buffer_pixel(logical_x, logical_y)

                    if initial_file is None or os.path.getsize(initial_file) <= 1:
                        clicked_caret_column = os.path.getsize(initial_file) if initial_file else 0
                        clicked_caret_x = 16 + clicked_caret_column * 8
                        caret_visible = document_pixel(clicked_caret_x, 92) == 0xFFFFFFFF
                    else:
                        # The caret is a scale-sized vertical rectangle. Sample
                        # one physical pixel at the start of each logical row.
                        caret_visible = any(
                            all(
                                document_pixel(x, 92 + row) == 0xFFFFFFFF
                                for row in range(9)
                            )
                            for column in range(9, 12)
                            for x in (16 + column * 8,)
                        )
                    if not caret_visible:
                        debug_names = {
                            "doc_cursor", "doc_view_top_row", "doc_line_index_valid",
                            "doc_line_count", "doc_total_visual_rows", "doc_scroll_thumb_height",
                        }
                        debug_symbols = {}
                        for symbol_line in subprocess.check_output(
                            ["nm", "-n", binary], text=True
                        ).splitlines():
                            fields = symbol_line.split()
                            if len(fields) == 3 and fields[2] in debug_names:
                                debug_symbols[fields[2]] = int(fields[0], 16)
                        debug_state = {}
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            for name, address in debug_symbols.items():
                                debug_state[name] = struct.unpack(
                                    "<I", os.pread(memory.fileno(), 4, address)
                                )[0]
                        caret_candidates = []
                        for candidate_y in range(92, 460 - 9, 12):
                            for candidate_x in range(16, 800 - 1, 8):
                                if all(
                                    struct.unpack_from(
                                        "<I", pixels, (candidate_y + row) * 800 * 4 + candidate_x * 4
                                    )[0] == 0xFFFFFFFF
                                    for row in range(9)
                                ):
                                    caret_candidates.append((candidate_x, candidate_y))
                        raise AssertionError(
                            "document click did not keep the caret visible after clamping to the document; "
                            + repr({"debug_state": debug_state, "caret_candidates": caret_candidates,
                                    "expected_document_click": "near the clicked insertion point"})
                        )
                observations.append("document-area click was routed to the editor and safely redrew the buffer")

                # Exercise the editor with buffer releases between key events.
                # Each new redraw must wait until the compositor releases the
                # single wl_buffer; this avoids racing the mock against batching.
                client.sendall(
                    wire_message(pointer_object_id, 3, struct.pack("<IIII", 779, 1001, 0x110, 0))
                    + buffer_release_message()
                )  # release the initial document click and its buffer

                if fractional_sync_keymap_test:
                    # Keep this regression independent of the much larger XKB
                    # shortcut suite: both NO_KEYMAP events must be dispatched,
                    # but this scenario deliberately does not install an XKB map.
                    nm_text = subprocess.check_output(["nm", "-n", binary], text=True)
                    wanted = {
                        "keymap_event_count",
                        "keymap_event_processed_count",
                        "keymap_processing_complete",
                        "keymap_format",
                        "keymap_size",
                        "keymap_mapping",
                    }
                    addresses = {}
                    for symbol_line in nm_text.splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in wanted:
                            addresses[fields[2]] = int(fields[0], 16)
                    if set(addresses) != wanted:
                        raise AssertionError(
                            "fractional startup keymap probe symbols are incomplete: "
                            + repr(sorted(wanted - addresses.keys()))
                        )
                    if not process_holder:
                        raise AssertionError("child process handle was not published to the mock")
                    with open(
                        f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0
                    ) as memory:
                        def read_u32(name: str) -> int:
                            raw = os.pread(memory.fileno(), 4, addresses[name])
                            if len(raw) != 4:
                                raise AssertionError(f"short process-memory read for {name}")
                            return struct.unpack("<I", raw)[0]

                        def read_u64(name: str) -> int:
                            raw = os.pread(memory.fileno(), 8, addresses[name])
                            if len(raw) != 8:
                                raise AssertionError(f"short process-memory read for {name}")
                            return struct.unpack("<Q", raw)[0]

                        deadline = time.monotonic() + 3.0
                        processed = read_u32("keymap_event_processed_count")
                        while processed < 2 and time.monotonic() < deadline:
                            time.sleep(0.005)
                            processed = read_u32("keymap_event_processed_count")
                        state = {
                            "dispatch_count": read_u32("keymap_event_count"),
                            "processed_count": processed,
                            "processing_complete": read_u32("keymap_processing_complete"),
                            "keymap_format": read_u32("keymap_format"),
                            "keymap_size": read_u32("keymap_size"),
                            "keymap_mapping": read_u64("keymap_mapping"),
                        }
                    if (
                        state["dispatch_count"] != 2
                        or state["processed_count"] != 2
                        or state["processing_complete"] != 1
                        or state["keymap_format"] != 0
                        or state["keymap_size"] != 0
                        or state["keymap_mapping"] != 0
                    ):
                        raise AssertionError(
                            "startup seat/fractional keymap events were not both consumed as NO_KEYMAP: "
                            + repr(state)
                        )
                    observations.append(
                        "FD-backed NO_KEYMAP events were processed during both the initial seat sync and fractional-scale sync"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if keyboard_layout_test or unicode_keyboard_test or compose_locale_test or compose_locale_invalid_test or compose_locale_settings_test or compose_locale_system_test or compose_locale_c_fallback_test or compose_locale_ctype_test or compose_locale_lang_test or compose_locale_saved_preference_test or compose_locale_finnish_test or compose_locale_serbian_test or right_alt_compose_test or right_alt_level3_test:
                    keymap_data = b"""xkb_keymap {
xkb_keycodes "nekoedit-test" {
    minimum = 8;
    maximum = 255;
    <AE01> = 10;
    <AE02> = 11;
    <AE03> = 12;
    <AE04> = 13;
    <AE05> = 14;
    <AE06> = 15;
    <AE07> = 16;
    <AE08> = 17;
    <AE09> = 18;
    <AE10> = 19;
    <AE11> = 20;
    <AE12> = 21;
    <TLDE> = 49;
    <AD11> = 34;
    <AD12> = 35;
    <AC10> = 47;
    <AC11> = 48;
    <AB08> = 59;
        <AB10> = 61;
    <KPDL> = 91;
    <KP0> = 90;
    <AD01> = 24;
    <AD02> = 25;
    <AD03> = 26;
    <AD04> = 27;
    <AD05> = 28;
    <AD06> = 29;
    <AD07> = 30;
    <AD08> = 31;
    <AD09> = 32;
    <AD10> = 33;
    <AC01> = 38;
    <AC02> = 39;
    <AC03> = 40;
    <AC04> = 41;
    <AC05> = 42;
    <AC06> = 43;
    <AC07> = 44;
    <AC08> = 45;
    <AC09> = 46;
    <AB01> = 52;
    <AB02> = 53;
    <AB03> = 54;
    <AB04> = 55;
    <AB05> = 56;
    <AB06> = 57;
    <AB07> = 58;
    <AB09> = 60;
    <LEFT> = 113;
    <RGHT> = 114;
    <RCTL> = 105;
    <RALT> = 108;
    alias <LatQ> = <AD01>;
    alias <LatA> = <AC01>;
    alias <LatZ> = <AB01>;
    alias <ALGR> = <RALT>;
    alias <LatW> = <AD02>;
    <LVL3> = 200;
    <LVL2> = 201;
    <GRP2> = 202;
    <TIE1> = 203;
    <ALL1> = 204;
    <EXT1> = 205;
    <GRP1> = 206;
    <NXT1> = 207;
    <GRPANY> = 208;
    <IMPL> = 209;
    <RPT0> = 210;
    <RPT1> = 211;
    <RPT2> = 212;
    <RPT3> = 213;
    <RPT4> = 214;
    <AR01> = 220;
    <HE01> = 221;
    <TH01> = 222;
    <KO01> = 223;
    <AM01> = 224;
    <GE01> = 225;
    <KA01> = 226;
    <SI01> = 227;
    <BR01> = 228;
    <SHRP> = 229;
    <ANGQ> = 230;
    <PHN7> = 231;
    <DA01> = 232;
    <CP01> = 233;
    <CP02> = 234;
    <CP03> = 235;
    <CP04> = 236;
    <CP05> = 237;
    <CP06> = 238;
    <CP07> = 239;
    <CP08> = 240;
};
xkb_types "nekoedit-test" {
    virtual_modifiers LevelThree = Mod5, NumLock = Mod2,
        V02 = Mod4+Mod5, V03 = none, V04 = none, V05 = none,
        V06 = none, V07 = none, V08 = none, V09 = none, V10 = none,
        V11 = none, V12 = none, V13 = none, V14 = none, V15 = none,
        V16 = none, V17 = none, V18 = none, V19 = none, V20 = none,
        V21 = none, V22 = none, V23 = 0x80000000;
    type "ALPHABETIC" {
        modifiers = Shift+Lock;
        map[Shift] = Level2;
        map[Lock] = Level2;
    };
    type "CUSTOM_ALPHA" {
        modifiers = Shift;
        map[Shift] = Level2;
    };
    type "FOUR_LEVEL" {
        modifiers = Shift+LevelThree;
        map[Shift] = Level2;
        map[LevelThree] = Level3;
        map[Shift+LevelThree] = Level4;
    };
    type "KEYPAD" {
        modifiers = Shift+NumLock;
        map[Shift] = Level2;
        map[NumLock] = Level2;
        map[Shift+NumLock] = Level1;
    };
    type "SEPARATE_CAPS_AND_SHIFT_ALPHABETIC" {
        modifiers = Shift+Lock+LevelThree;
        map[Shift] = Level2;
        map[Lock] = Level4;
        map[LevelThree] = Level3;
        map[Shift+LevelThree] = Level4;
        map[Lock+LevelThree] = Level3;
        map[Shift+Lock+LevelThree] = Level3;
    };
    type "CUSTOM_EIGHT_LEVEL" {
        modifiers = Shift+Lock+Mod3+V23;
        map[None] = Level1;
        map[Shift] = Level2;
        map[Mod3] = Level3;
        map[Shift+Mod3] = Level4;
        map[Lock] = Level5;
        map[Shift+Lock] = Level6;
        map[Mod3+Lock] = Level7;
        map[Shift+Mod3+Lock] = 8;
        map[0x80000000] = 8;
    };
    type "CUSTOM_IMPLICIT" {
        modifiers = V03;
        map[V03] = Level2;
    };
    type "CUSTOM_INDIRECT" {
        modifiers = V04;
        map[V04] = Level2;
    };
    type "CUSTOM_CTRL_PRESERVE" {
        modifiers = Shift+Control;
        map[None] = Level1;
        map[Shift] = Level2;
        preserve[Control] = Control;
        map[Control] = Level3;
        map[Shift+Control] = Level4;
        preserve[Shift+Control] = Control;
    };
    type "CUSTOM_CTRL_CONSUMED" {
        modifiers = Shift+Control;
        map[None] = Level1;
        map[Shift] = Level2;
        map[Control] = Level3;
        map[Shift+Control] = Level4;
    };
    type "CUSTOM_SHIFT_PRESERVE" {
        modifiers = Shift;
        map[None] = Level1;
        preserve[Shift] = Shift;
        map[Shift] = Level2;
    };
    type "CUSTOM_SHIFT_CONSUMED" {
        modifiers = Shift;
        map[None] = Level1;
        map[Shift] = Level2;
    };
};
xkb_compat "nekoedit-test" {
    # Specific predicates outrank the generic Alt_L rule.
    interpret.repeat = False;
    interpret Alt_L {
        virtualModifier = V05;
        action = { SetMods(modifiers=Alt), SetGroup(group=2) };
    };
    interpret Alt_L + NoneOf(Mod1) {
        virtualModifier = V06;
    };
    interpret Any + AnyOf(Mod1) {
        virtualModifier = V08;
    };
    interpret Any + AnyOf(Mod2) {
        repeat = True;
    };
    interpret ISO_Level3_Shift + Any {
        useModMapMods = level1;
        virtualModifier = V07;
    };
    # Same condition at lower precedence, but valid on every group/level.
    # Level1 above wins Group1/Level1; this rule handles the other matches.
    interpret ISO_Level3_Shift + Any {
        useModMapMods = any;
        virtualModifier = V16;
    };
    # Action-only rules are retained for precedence but never executed.
    interpret Shift_L + AnyOf(Shift) {
        action = { SetMods(modifiers=Shift), SetGroup(group=2) };
    };
    # Both NoneOf predicates match the Control-mapped TIE1 key; the first wins.
    interpret Shift_L + NoneOf(Shift) { virtualModifier = V09; };
    interpret Shift_L + NoneOf(Mod1) { virtualModifier = V10; };
    # AllOf accepts the specified modifier even if other bits are present.
    interpret Meta_L + AllOf(Shift) { virtualModifier = V11; };
    # Exactly outranks AllOf when both match the same key modifier map.
    interpret Control_L + AllOf(Mod1) { virtualModifier = V12; };
    interpret Control_L + Exactly(Mod1) { virtualModifier = V13; };
    # Omitting the predicate operator is the XKB shorthand for Exactly(mask).
    interpret Control_L + (Mod2) { virtualModifier = V17; };
    interpret ISO_Group_Shift + Any { virtualModifier = V14; };
    interpret ISO_Next_Group + Any { virtualModifier = V15; };
};
xkb_symbols "nekoedit-test" {
    # Repeated declarations in later components must retain explicit masks.
    virtual_modifiers LevelThree, NumLock, V23;
    # V03 has explicit encoding none above; this real key binding contributes
    # Mod4 to its effective virtual-modifier encoding.
    modifier_map Mod1 { <AB03> };
    modifier_map Mod4 { <AB06> };
    modifier_map Mod2 { <AB05> };
    # Dedicated keycodes test inherited, compat, and direct repeat policies.
    modifier_map Mod1 { <RPT0>, <RPT3> };
    modifier_map Mod2 { <RPT1>, <RPT2> };
    # A matching keycode None removes a previously direct binding.
    modifier_map Mod3 { <RCTL> };
    modifier_map None { <RCTL> };
    # Resolve Alt_L indirectly after symbols have been parsed. The subsequent
    # keycode None entry must not delete this keysym-kind binding.
    modifier_map Mod1 { Alt_L };
    modifier_map None { <RALT> };
    # Same keysym at Group1/Level1, Group1/Level2 and Group2/Level1.
    modifier_map Mod5 { <LVL3>, <LVL2>, <GRP2> };
    # Each key receives at most one real modifier, as required by XKB.
    modifier_map Control { <TIE1> };
    modifier_map Shift { <ALL1> };
    modifier_map Mod1 { <EXT1> };
    modifier_map Mod2 { ISO_Group_Shift, <GRPANY> };
    modifier_map Mod2 { <IMPL> };
    modifier_map Mod5 { ISO_Next_Group };
    key <AD01> {
        type = "FOUR_LEVEL_ALPHABETIC",
        symbols[Group1] = [ a, A, at, quotedbl ],
        symbols[Group2] = [ q, Q ]
    };
    key <AC02> {
        type = "ALPHABETIC",
        symbols[Group1] = [ s, S ]
    };
    key <LatW> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ w, W ] };
    key <AD03> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ e, E ] };
    key <AD04> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ r, R ] };
    key <AD05> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ t, T ] };
    key <AD06> {
        type = "SEPARATE_CAPS_AND_SHIFT_ALPHABETIC",
        symbols[Group1] = [ y, Y, at, quotedbl ]
    };
    key <AD07> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ u, U ] };
    key <AD08> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ i, I ] };
    key <AD09> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ o, O ] };
    key <AD10> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ p, P ] };
    key <AC01> {
        type[Group1] = "CUSTOM_CTRL_PRESERVE",
        symbols[Group1] = [ a, A, at, quotedbl ]
    };
    key <AC03> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ d, D ] };
    key <AC04> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ f, F ] };
    key <AC05> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ g, G ] };
    key <AC06> { [ h, H ] };
    key <AC07> { [ j, J ] };
    key <AC08> { [ k, K ] };
    key <AC09> { [ l, L ] };
    key <AB01> {
        type[Group1] = "CUSTOM_CTRL_CONSUMED",
        symbols[Group1] = [ z, Z, EuroSign, eacute ]
    };
    key <AB02> { [ x, X ] };
    key <AB03> { [ c, C ] };
    key <AB04> {
        type[Group1] = "CUSTOM_INDIRECT",
        symbols[Group1] = [ v, V ]
    };
    key <RCTL> {
        symbols[Group1] = [ Control_R, NoSymbol, Alt_L ]
    };
    key <RALT> {
        virtualModifiers = V04,
        symbols[Group1] = [ NoSymbol, Alt_L ]
    };
    key <LVL3> { symbols[Group1] = [ ISO_Level3_Shift ] };
    key <LVL2> { symbols[Group1] = [ NoSymbol, ISO_Level3_Shift ] };
    key <GRP2> {
        type = "ONE_LEVEL",
        symbols[Group1] = [ x ],
        symbols[Group2] = [ ISO_Level3_Shift ]
    };
    key <TIE1> { symbols[Group1] = [ Shift_L ] };
    key <ALL1> { symbols[Group1] = [ Meta_L ] };
    key <EXT1> { symbols[Group1] = [ Control_L ] };
    key <GRP1> { symbols[Group1] = [ ISO_Group_Shift ] };
    key <NXT1> { symbols[Group1] = [ ISO_Next_Group ] };
    key <IMPL> { symbols[Group1] = [ Control_L ] };
    key <AR01> { symbols[Group1] = [ Arabic_alef ] };
    key <HE01> { symbols[Group1] = [ hebrew_aleph ] };
    key <TH01> { symbols[Group1] = [ Thai_kokai ] };
    key <KO01> { symbols[Group1] = [ Hangul_Kiyeog ] };
    key <AM01> { symbols[Group1] = [ Armenian_AYB ] };
    key <GE01> { symbols[Group1] = [ Georgian_an ] };
    key <KA01> { symbols[Group1] = [ kana_a ] };
    key <SI01> { symbols[Group1] = [ Sinh_a ] };
    key <BR01> { symbols[Group1] = [ braille_dots_12345678 ] };
    key <SHRP> { symbols[Group1] = [ SSHARP ] };
    key <ANGQ> { symbols[Group1] = [ leftsingleanglequotemark ] };
    key <PHN7> { symbols[Group1] = [ XF86XK_Numeric7 ] };
    key <DA01> { symbols[Group1] = [ dead_apostrophe ] };
    key <CP01> { symbols[Group1] = [ period ] };
    key <CP02> { symbols[Group1] = [ S ] };
    key <CP03> { symbols[Group1] = [ greater ] };
    key <CP04> { symbols[Group1] = [ minus ] };
    key <CP05> { symbols[Group1] = [ dead_macron ] };
    key <CP06> { symbols[Group1] = [ dead_caron ] };
    key <CP07> { symbols[Group1] = [ dead_belowdot ] };
    key <CP08> { symbols[Group1] = [ c ] };
    # No useModMapMods attribute: the compat default is any group/level.
    key <GRPANY> {
        type = "ONE_LEVEL",
        symbols[Group1] = [ x ],
        symbols[Group2] = [ ISO_Group_Shift ]
    };
    key <AB05> {
        virtualModifiers = V03,
        symbols[Group1] = [ b, B ]
    };
    key <AB06> {
        type[Group1] = "CUSTOM_IMPLICIT",
        virtualModifiers = V03,
        symbols[Group1] = [ n, N ]
    };
    key <AB07> {
        type[Group1] = "CUSTOM_EIGHT_LEVEL",
        symbols[Group1] = [ m, M, at, quotedbl, q, Q, EuroSign, eacute ]
    };
    key <LEFT> { type[Group1] = "CUSTOM_SHIFT_CONSUMED" };
    key <RGHT> { type[Group1] = "CUSTOM_SHIFT_PRESERVE" };
    # xkbcomp emits the ordinary number row and several punctuation keys
    # in this shorthand form, with no "symbols[Group1] =" attribute.
    key <AE01> { [ 1, exclam ] };
    key <AE02> { [ 2, at ] };
    key <AE03> { [ 3, numbersign ] };
    key <AE04> { [ 4, dollar ] };
    key <AE05> { [ 5, percent ] };
    key <AE06> { [ 6, asciicircum ] };
    key <AE07> { [ 7, ampersand ] };
    key <AE08> { [ 8, asterisk ] };
    key <AE09> { [ 9, parenleft ] };
    key <AE10> { [ 0, parenright ] };
    key <AE11> { [ minus, underscore ] };
    key <AE12> { [ equal, plus ] };
    key <TLDE> { [ grave, asciitilde ] };
    key <AD11> { [ bracketleft, braceleft ] };
    key <AD12> {
        symbols[Group1] = [ bracketright, braceright ],
        symbols[Group2] = [ Alt_L ]
    };
    key <AC10> { [ semicolon, colon ] };
    key <AC11> { [ apostrophe, quotedbl ] };
    key <AB08> { [ comma, less ] };
    key <AB09> { [ period, greater ] };
    key <AB10> { [ slash, question ] };
    key <KPDL> {
        type = "ONE_LEVEL",
        symbols[Group1] = [ comma ]
    };
    key <KP0> {
        type = "KEYPAD",
        symbols[Group1] = [ x, 7 ]
    };
    key <AB09> { [ period, greater ] };
    key <RPT0> { symbols[Group1] = [ q ] };
    key <RPT1> { symbols[Group1] = [ w ] };
    key <RPT2> { repeat = False, symbols[Group1] = [ e ] };
    key <RPT3> { repeat = True, symbols[Group1] = [ r ] };
    key <RPT4> { };
};
};
\0"""
                    if omit_compat_repeat_default:
                        keymap_data = keymap_data.replace(
                            b"    interpret.repeat = False;\n",
                            b"",
                        )
                    if unicode_keyboard_test:
                        keymap_data = keymap_data.replace(
                            b'key <AC01> {\n        type[Group1] = "CUSTOM_CTRL_PRESERVE",\n        symbols[Group1] = [ a, A, at, quotedbl ]\n    };',
                            b"key <AC01> { [ U00E9, U1F600 ] };",
                        )
                        keymap_data = keymap_data.replace(
                            b'key <AC02> {\n        type = "ALPHABETIC",\n        symbols[Group1] = [ s, S ]\n    };',
                            b'key <AC02> {\n        type = "ALPHABETIC",\n        symbols[Group1] = [ EuroSign, eacute ]\n    };',
                        )
                        keymap_data = keymap_data.replace(
                            b'key <AC03> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ d, D ] };',
                            b'key <AC03> { type = "ONE_LEVEL", symbols[Group1] = [ emdash ] };',
                        )
                        keymap_data = keymap_data.replace(
                            b'key <AC04> { type[Group1] = "CUSTOM_ALPHA", symbols[Group1] = [ f, F ] };',
                            b'key <AC04> { type = "ONE_LEVEL", symbols[Group1] = [ dead_acute ] };',
                        )
                        keymap_data = keymap_data.replace(
                            b'key <AB01> {\n        type[Group1] = "CUSTOM_CTRL_CONSUMED",\n        symbols[Group1] = [ z, Z, EuroSign, eacute ]\n    };',
                            b"key <AB01> { [ Greek_alpha ] };",
                        )
                        keymap_data = keymap_data.replace(
                            b"key <AB02> { [ x, X ] };",
                            b"key <AB02> { [ Cyrillic_ya ] };",
                        )
                        keymap_data = keymap_data.replace(
                            b"key <AB03> { [ c, C ] };",
                            b"key <AB03> { [ Multi_key ] };",
                        )
                        if compose_locale_finnish_test:
                            keymap_data = keymap_data.replace(
                                b'key <AC04> { type = "ONE_LEVEL", symbols[Group1] = [ dead_acute ] };',
                                b'key <AC04> { [ f ] };',
                            )
                        if compose_locale_serbian_test:
                            keymap_data = keymap_data.replace(
                                b"key <AC01> { [ U00E9, U1F600 ] };",
                                b"key <AC01> { [ Cyrillic_a ] };",
                            )
                        if compose_locale_finnish_test or compose_locale_serbian_test:
                            keymap_data = keymap_data.replace(
                                b"key <AC08> { [ k, K ] };",
                                b"key <AC08> { [ Cyrillic_ka ] };",
                            )
                        if (
                            b"EuroSign, eacute" not in keymap_data
                            or b"[ emdash ]" not in keymap_data
                            or (not compose_locale_finnish_test and b"[ dead_acute ]" not in keymap_data)
                            or (compose_locale_finnish_test and b"[ f ]" not in keymap_data)
                            or b"[ Greek_alpha ]" not in keymap_data
                            or b"[ Cyrillic_ya ]" not in keymap_data
                            or (compose_locale_serbian_test and b"[ Cyrillic_a ]" not in keymap_data)
                            or (
                                (compose_locale_finnish_test or compose_locale_serbian_test)
                                and b"[ Cyrillic_ka ]" not in keymap_data
                            )
                            or b"[ Multi_key ]" not in keymap_data
                            or b"[ period ]" not in keymap_data
                            or b"[ S ]" not in keymap_data
                            or b"[ greater ]" not in keymap_data
                            or b"[ minus ]" not in keymap_data
                            or b"[ dead_macron ]" not in keymap_data
                            or b"[ dead_caron ]" not in keymap_data
                            or b"[ dead_belowdot ]" not in keymap_data
                        ):
                            raise AssertionError("named Unicode/dead-key/Greek/Cyrillic test substitutions did not apply")
                elif sparse_keymap_test:
                    # This map has enough punctuation symbols to pass the
                    # old symbol-count test, but no alphabetic keys. It must
                    # be rejected so the US-QWERTY fallback stays available.
                    keymap_data = b"""xkb_keymap {
xkb_keycodes "nekoedit-sparse" {
    minimum = 8;
    maximum = 255;
    <AE01> = 10;
    <AE02> = 11;
    <AE03> = 12;
    <AE04> = 13;
    <AE05> = 14;
    <AE06> = 15;
    <AE07> = 16;
    <AE08> = 17;
    <AE09> = 18;
    <AE10> = 19;
    <AE11> = 20;
    <AE12> = 21;
};
xkb_symbols "nekoedit-sparse" {
    key <AE01> { [ 1, exclam ] };
    key <AE02> { [ 2, at ] };
    key <AE03> { [ 3, numbersign ] };
    key <AE04> { [ 4, dollar ] };
    key <AE05> { [ 5, percent ] };
    key <AE06> { [ 6, asciicircum ] };
    key <AE07> { [ 7, ampersand ] };
    key <AE08> { [ 8, asterisk ] };
    key <AE09> { [ 9, parenleft ] };
    key <AE10> { [ 0, parenright ] };
    key <AE11> { [ minus, underscore ] };
    key <AE12> { [ equal, plus ] };
};
};
\0"""
                else:
                    keymap_data = b"xkb_keymap { };\0"
                if right_alt_compose_test or right_alt_level3_test:
                    original_ralt = b"""    key <RALT> {
        virtualModifiers = V04,
        symbols[Group1] = [ NoSymbol, Alt_L ]
    };"""
                    replacement_ralt = (
                        b"    key <RALT> { symbols[Group1] = [ Multi_key ] };"
                        if right_alt_compose_test
                        else b"    key <RALT> { symbols[Group1] = [ ISO_Level3_Shift ] };"
                    )
                    if original_ralt not in keymap_data:
                        raise AssertionError("Right Alt XKB fixture substitution did not find the base RALT key")
                    keymap_data = keymap_data.replace(original_ralt, replacement_ralt, 1)

                keymap_fd = os.memfd_create("nekoedit-test-keymap", 0)
                try:
                    os.write(keymap_fd, keymap_data)
                    keymap_event = wire_message(keyboard_object_id, 0, struct.pack("<II", 1, len(keymap_data)))
                    client.sendmsg(
                        [keymap_event],
                        [(socket.SOL_SOCKET, socket.SCM_RIGHTS, struct.pack("i", keymap_fd))],
                    )
                finally:
                    os.close(keymap_fd)

                # The received descriptor must outlive the recvmsg call as a
                # read-only MAP_PRIVATE mapping, even after the sender closes
                # its copy. Check the child mapping rather than trusting that
                # the connection merely survived the event.
                if not process_holder:
                    raise AssertionError("child process handle was not published to the mock")
                child = process_holder[0]
                maps_path = f"/proc/{child.pid}/maps"
                map_deadline = time.monotonic() + 3.0
                keymap_mapping_lines = []
                while time.monotonic() < map_deadline:
                    try:
                        with open(maps_path, "r", encoding="ascii") as maps_file:
                            keymap_mapping_lines = [
                                line.strip()
                                for line in maps_file
                                if "nekoedit-test-keymap" in line
                            ]
                    except FileNotFoundError:
                        keymap_mapping_lines = []
                    if any(
                        len(line.split()) > 1
                        and line.split()[1] == "r--p"
                        for line in keymap_mapping_lines
                    ):
                        break
                    time.sleep(0.01)
                else:
                    raise AssertionError(
                        "wl_keyboard.keymap FD was not retained as a read-only "
                        f"MAP_PRIVATE mapping: {keymap_mapping_lines!r}"
                    )
                # Inspect the exported parser tables while the child is
                # paused in its event loop. This differentiates an XKB parse
                # failure from a physical modifier / symbol-lookup failure.
                if keyboard_layout_test:
                    nm_text = subprocess.check_output(
                        ["nm", "-n", binary], text=True
                    )
                    symbol_addresses = {}
                    wanted_symbols = {
                        "xkb_key_names",
                        "xkb_key_alias_count",
                        "xkb_ascii_levels",
                        "xkb_keysym_levels",
                        "xkb_key_types",
                        "xkb_group_types",
                        "xkb_type_names",
                        "xkb_type_modifiers",
                        "xkb_type_map_counts",
                        "xkb_type_map_masks",
                        "xkb_type_map_levels",
                        "xkb_type_map_preserves",
                        "xkb_virtual_count",
                        "xkb_virtual_masks",
                        "xkb_key_real_masks",
                        "xkb_key_virtual_maps",
                        "xkb_key_real_map_kinds",
                        "xkb_key_real_map_targets",
                        "xkb_key_virtual_explicit",
                        "xkb_key_repeat_flags",
                        "xkb_key_repeat_explicit",
                        "xkb_compat_default_repeat",
                        "xkb_compat_rule_count",
                        "xkb_compat_rules",
                        "xkb_level_three_mask",
                        "xkb_num_lock_mask",
                        "xkb_keymap_ready",
                        "keymap_processing_complete",
                        "keymap_event_count",
                        "keymap_event_processed_count",
                        "text_input_manager_global",
                        "text_input_manager_object",
                        "text_input_object",
                        "text_input_enabled",
                        "text_input_entered",
                        "text_input_commit_serial",
                        "text_input_state_ready",
                    }
                    for line in nm_text.splitlines():
                        fields = line.split()
                        if len(fields) == 3 and fields[2] in wanted_symbols:
                            symbol_addresses[fields[2]] = int(fields[0], 16)
                    missing_symbols = wanted_symbols - symbol_addresses.keys()
                    if missing_symbols:
                        raise AssertionError(
                            f"XKB test symbols missing from executable: {sorted(missing_symbols)}"
                        )
                    mem_fd = os.open(f"/proc/{child.pid}/mem", os.O_RDONLY)
                    try:
                        def child_memory(name: str, offset: int, size: int) -> bytes:
                            return os.pread(
                                mem_fd, size, symbol_addresses[name] + offset
                            )
                        complete_deadline = time.monotonic() + 3.0
                        complete = struct.unpack(
                            "<I", child_memory("keymap_processing_complete", 0, 4)
                        )[0]
                        while complete != 1 and time.monotonic() < complete_deadline:
                            time.sleep(0.001)
                            complete = struct.unpack(
                                "<I", child_memory("keymap_processing_complete", 0, 4)
                            )[0]
                        if complete != 1:
                            raise AssertionError("XKB keymap parser did not finish processing")
                        keymap_event_deadline = time.monotonic() + 3.0
                        keymap_event_count = struct.unpack(
                            "<I", child_memory("keymap_event_count", 0, 4)
                        )[0]
                        keymap_event_processed = struct.unpack(
                            "<I", child_memory("keymap_event_processed_count", 0, 4)
                        )[0]
                        while keymap_event_processed < 2 and time.monotonic() < keymap_event_deadline:
                            time.sleep(0.001)
                            keymap_event_count = struct.unpack(
                                "<I", child_memory("keymap_event_count", 0, 4)
                            )[0]
                            keymap_event_processed = struct.unpack(
                                "<I", child_memory("keymap_event_processed_count", 0, 4)
                            )[0]
                        if keymap_event_count < 2 or keymap_event_processed < 2:
                            raise AssertionError(
                                "wl_keyboard.keymap sent during the initial seat roundtrip was not processed "
                                f"(expected early no-keymap + test XKB map events, got "
                                f"dispatch={keymap_event_count}, processed={keymap_event_processed})"
                            )
                        if text_input_advertised and not text_input_test:
                            ime_global = struct.unpack("<I", child_memory("text_input_manager_global", 0, 4))[0]
                            ime_manager = struct.unpack("<I", child_memory("text_input_manager_object", 0, 4))[0]
                            ime_object = struct.unpack("<I", child_memory("text_input_object", 0, 4))[0]
                            ime_enabled = struct.unpack("<I", child_memory("text_input_enabled", 0, 4))[0]
                            if ime_global == 0 or ime_manager != 0 or ime_object != 0 or ime_enabled != 0:
                                raise AssertionError(
                                    "advertised text-input-v3 was bound/enabled without explicit opt-in: "
                                    f"global={ime_global}, manager={ime_manager}, object={ime_object}, "
                                    f"enabled={ime_enabled}"
                                )
                            observations.append(
                                "text-input-v3 advertisement leaves the default physical XKB typing path active"
                            )
                        if text_input_opt_in_fallback_test:
                            ime_state = {
                                name: struct.unpack("<I", child_memory(name, 0, 4))[0]
                                for name in (
                                    "text_input_manager_global",
                                    "text_input_manager_object",
                                    "text_input_object",
                                    "text_input_entered",
                                    "text_input_enabled",
                                    "text_input_commit_serial",
                                    "text_input_state_ready",
                                )
                            }
                            if any(ime_state.values()):
                                raise AssertionError(
                                    "text-input-v3 opt-in without an advertised manager "
                                    f"created protocol state instead of falling back to XKB: {ime_state}"
                                )
                            observations.append(
                                "text-input-v3 opt-in without a manager global leaves every protocol state field inactive"
                            )
                        ready = struct.unpack("<I", child_memory("xkb_keymap_ready", 0, 4))[0]
                        key_name = child_memory("xkb_key_names", 24 * 4, 4)
                        key_type = child_memory("xkb_key_types", 24, 1)
                        levels = child_memory("xkb_ascii_levels", 24 * 32, 32)
                        ae01_name = child_memory("xkb_key_names", 10 * 4, 4)
                        ae01_levels = child_memory("xkb_ascii_levels", 10 * 32, 32)
                        ae02_name = child_memory("xkb_key_names", 11 * 4, 4)
                        ae02_levels = child_memory("xkb_ascii_levels", 11 * 32, 32)
                        ad02_name = child_memory("xkb_key_names", 25 * 4, 4)
                        ad02_levels = child_memory("xkb_ascii_levels", 25 * 32, 32)
                        ralt_name = child_memory("xkb_key_names", 108 * 4, 4)
                        alias_count = struct.unpack("<I", child_memory("xkb_key_alias_count", 0, 4))[0]
                        custom_alpha_type_id = child_memory("xkb_group_types", 25 * 4, 1)[0]
                        custom_alpha_name = child_memory("xkb_type_names", 6 * 64, 64).split(bytes([0]), 1)[0]
                        custom_alpha_mask = struct.unpack("<I", child_memory("xkb_type_modifiers", 6 * 4, 4))[0]
                        custom_alpha_map_count = child_memory("xkb_type_map_counts", 6, 1)[0]
                        custom_alpha_map_mask = struct.unpack("<I", child_memory("xkb_type_map_masks", 6 * 128, 4))[0]
                        custom_alpha_map_level = child_memory("xkb_type_map_levels", 6 * 32, 1)[0]
                        custom_type_id = child_memory("xkb_group_types", 58 * 4, 1)[0]
                        custom_type_name = child_memory("xkb_type_names", 7 * 64, 64).split(bytes([0]), 1)[0]
                        custom_type_mask = struct.unpack("<I", child_memory("xkb_type_modifiers", 7 * 4, 4))[0]
                        custom_map_count = child_memory("xkb_type_map_counts", 7, 1)[0]
                        custom_map_masks = struct.unpack(
                            "<9I", child_memory("xkb_type_map_masks", 7 * 128, 36)
                        )
                        custom_map_levels = child_memory("xkb_type_map_levels", 7 * 32, 9)
                        implicit_type_id = child_memory("xkb_group_types", 57 * 4, 1)[0]
                        implicit_type_name = child_memory("xkb_type_names", 8 * 64, 64).split(bytes([0]), 1)[0]
                        implicit_type_mask = struct.unpack("<I", child_memory("xkb_type_modifiers", 8 * 4, 4))[0]
                        implicit_map_count = child_memory("xkb_type_map_counts", 8, 1)[0]
                        implicit_map_mask = struct.unpack("<I", child_memory("xkb_type_map_masks", 8 * 128, 4))[0]
                        implicit_map_level = child_memory("xkb_type_map_levels", 8 * 32, 1)[0]
                        ab05_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 56 * 4, 4))[0]
                        ab05_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 56 * 4, 4))[0]
                        ab06_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 57 * 4, 4))[0]
                        ab06_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 57 * 4, 4))[0]
                        indirect_type_id = child_memory("xkb_group_types", 55 * 4, 1)[0]
                        indirect_type_name = child_memory("xkb_type_names", 9 * 64, 64).split(bytes([0]), 1)[0]
                        indirect_type_mask = struct.unpack("<I", child_memory("xkb_type_modifiers", 9 * 4, 4))[0]
                        indirect_map_count = child_memory("xkb_type_map_counts", 9, 1)[0]
                        indirect_map_mask = struct.unpack("<I", child_memory("xkb_type_map_masks", 9 * 128, 4))[0]
                        indirect_map_level = child_memory("xkb_type_map_levels", 9 * 32, 1)[0]
                        ralt_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", (108 * 32 + 1) * 4, 4))[0]
                        rctl_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", (105 * 32 + 2) * 4, 4))[0]
                        ad12_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", (35 * 32 + 8) * 4, 4))[0]
                        ralt_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 108 * 4, 4))[0]
                        ralt_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 108 * 4, 4))[0]
                        ralt_map_kind = child_memory("xkb_key_real_map_kinds", 108, 1)[0]
                        ralt_map_target = struct.unpack("<I", child_memory("xkb_key_real_map_targets", 108 * 4, 4))[0]
                        rctl_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 105 * 4, 4))[0]
                        rctl_map_kind = child_memory("xkb_key_real_map_kinds", 105, 1)[0]
                        rctl_map_target = struct.unpack("<I", child_memory("xkb_key_real_map_targets", 105 * 4, 4))[0]
                        ad12_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 35 * 4, 4))[0]
                        rctl_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 105 * 4, 4))[0]
                        ad12_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 35 * 4, 4))[0]
                        ab03_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 54 * 4, 4))[0]
                        lvl3_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 200 * 4, 4))[0]
                        lvl2_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 201 * 4, 4))[0]
                        grp2_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 202 * 4, 4))[0]
                        grpany_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 208 * 4, 4))[0]
                        grpany_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 208 * 4, 4))[0]
                        grpany_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", (208 * 32 + 8) * 4, 4))[0]
                        ralt_explicit_virtual = child_memory("xkb_key_virtual_explicit", 108, 1)[0]
                        compat_rule_count = struct.unpack("<I", child_memory("xkb_compat_rule_count", 0, 4))[0]
                        compat_scope_level1 = child_memory("xkb_compat_rules", 4 * 16 + 13, 1)[0]
                        compat_scope_any = child_memory("xkb_compat_rules", 5 * 16 + 13, 1)[0]
                        compat_scope_default_any = child_memory("xkb_compat_rules", 13 * 16 + 13, 1)[0]
                        tie_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 203 * 4, 4))[0]
                        all_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 204 * 4, 4))[0]
                        exact_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 205 * 4, 4))[0]
                        group_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 206 * 4, 4))[0]
                        next_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 207 * 4, 4))[0]
                        implicit_exact_real_mask = struct.unpack("<I", child_memory("xkb_key_real_masks", 209 * 4, 4))[0]
                        implicit_exact_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 209 * 4, 4))[0]
                        implicit_exact_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", 209 * 32 * 4, 4))[0]
                        implicit_exact_predicate = child_memory("xkb_compat_rules", 12 * 16 + 12, 1)[0]
                        tie_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 203 * 4, 4))[0]
                        all_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 204 * 4, 4))[0]
                        exact_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 205 * 4, 4))[0]
                        group_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 206 * 4, 4))[0]
                        next_virtual_map = struct.unpack("<I", child_memory("xkb_key_virtual_maps", 207 * 4, 4))[0]
                        group_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", (206 * 32) * 4, 4))[0]
                        next_raw_keysym = struct.unpack("<I", child_memory("xkb_keysym_levels", (207 * 32) * 4, 4))[0]
                        virtual_count = struct.unpack("<I", child_memory("xkb_virtual_count", 0, 4))[0]
                        level_three_mask = struct.unpack("<I", child_memory("xkb_level_three_mask", 0, 4))[0]
                        num_lock_mask = struct.unpack("<I", child_memory("xkb_num_lock_mask", 0, 4))[0]
                        virtual_masks = struct.unpack("<24I", child_memory("xkb_virtual_masks", 0, 96))
                        repeat_default = struct.unpack("<I", child_memory("xkb_compat_default_repeat", 0, 4))[0]
                        repeat_values = (
                            child_memory("xkb_key_repeat_flags", 10, 1)[0],
                            child_memory("xkb_key_repeat_flags", 210, 4),
                        )
                        repeat_explicit = child_memory("xkb_key_repeat_explicit", 210, 4)
                        repeat_symbol_less = child_memory("xkb_key_repeat_flags", 214, 1)[0]
                        preserve_type_id = child_memory("xkb_group_types", 38 * 4, 1)[0]
                        consumed_type_id = child_memory("xkb_group_types", 52 * 4, 1)[0]
                        preserve_map_masks = struct.unpack(
                            "<4I", child_memory("xkb_type_map_masks", 10 * 128, 16)
                        )
                        preserve_map_levels = child_memory(
                            "xkb_type_map_levels", 10 * 32, 4
                        )
                        preserve_map_values = struct.unpack(
                            "<4I", child_memory("xkb_type_map_preserves", 10 * 128, 16)
                        )
                        consumed_map_values = struct.unpack(
                            "<4I", child_memory("xkb_type_map_preserves", 11 * 128, 16)
                        )
                        shift_preserve_type_id = child_memory("xkb_group_types", 114 * 4, 1)[0]
                        shift_consumed_type_id = child_memory("xkb_group_types", 113 * 4, 1)[0]
                        shift_preserve_type_mask = struct.unpack(
                            "<I", child_memory("xkb_type_modifiers", 12 * 4, 4)
                        )[0]
                        shift_consumed_type_mask = struct.unpack(
                            "<I", child_memory("xkb_type_modifiers", 13 * 4, 4)
                        )[0]
                        shift_preserve_map_masks = struct.unpack(
                            "<2I", child_memory("xkb_type_map_masks", 12 * 128, 8)
                        )
                        shift_consumed_map_masks = struct.unpack(
                            "<2I", child_memory("xkb_type_map_masks", 13 * 128, 8)
                        )
                        shift_preserve_values = struct.unpack(
                            "<2I", child_memory("xkb_type_map_preserves", 12 * 128, 8)
                        )
                        shift_consumed_values = struct.unpack(
                            "<2I", child_memory("xkb_type_map_preserves", 13 * 128, 8)
                        )
                    finally:
                        os.close(mem_fd)
                    if ready != 1 or key_name != b"AD01" or key_type != bytes([3]):
                        raise AssertionError(
                            "XKB parser did not build the expected AD01 metadata: "
                            f"ready={ready}, key_name={key_name!r}, key_type={key_type!r}"
                        )
                    if levels[:4] != b'aA@"' or levels[8:10] != b'qQ':
                        raise AssertionError(
                            "XKB parser produced incorrect Group1/Group2 level cells: "
                            f"{levels!r}"
                        )
                    if (
                        custom_alpha_type_id != 6
                        or custom_alpha_name != b"CUSTOM_ALPHA"
                        or custom_alpha_mask != 1
                        or custom_alpha_map_count != 1
                        or custom_alpha_map_mask != 1
                        or custom_alpha_map_level != 2
                        or custom_type_id != 7
                        or custom_type_name != b"CUSTOM_EIGHT_LEVEL"
                        or custom_type_mask != 0x80000023
                        or custom_map_count != 9
                        or custom_map_masks != (0, 1, 32, 33, 2, 3, 34, 35, 0x80000000)
                        or custom_map_levels != bytes((1, 2, 3, 4, 5, 6, 7, 8, 8))
                        or implicit_type_id != 8
                        or implicit_type_name != b"CUSTOM_IMPLICIT"
                        or implicit_type_mask != 80
                        or implicit_map_count != 1
                        or implicit_map_mask != 80
                        or implicit_map_level != 2
                        or ab05_real_mask != 16
                        or ab05_virtual_map != 8
                        or ab06_real_mask != 64
                        or ab06_virtual_map != 8
                        or indirect_type_id != 9
                        or indirect_type_name != b"CUSTOM_INDIRECT"
                        or indirect_type_mask != 8
                        or indirect_map_count != 1
                        or indirect_map_mask != 8
                        or indirect_map_level != 2
                        or ralt_raw_keysym != 0xffe9
                        or rctl_raw_keysym != 0xffe9
                        or ad12_raw_keysym != 0xffe9
                        or ralt_real_mask != 8
                        or ralt_virtual_map != 16
                        or ralt_map_kind != 2
                        or ralt_map_target != 0xffe9
                        or rctl_real_mask != 0
                        or rctl_map_kind != 0
                        or rctl_map_target != 0
                        or ad12_real_mask != 0
                        or rctl_virtual_map != 64
                        or ad12_virtual_map != 64
                        or ab03_virtual_map != 256
                        or lvl3_virtual_map != 128
                        or lvl2_virtual_map != (1 << 16)
                        or grp2_virtual_map != (1 << 16)
                        or grpany_real_mask != 16
                         or grpany_virtual_map != (1 << 14)
                         or grpany_raw_keysym != 0xff7e
                         or compat_scope_level1 != 1
                         or compat_scope_any != 0
                         or compat_scope_default_any != 0
                         or ralt_explicit_virtual != 1
                        or tie_real_mask != 4
                        or all_real_mask != 1
                        or exact_real_mask != 8
                        or group_real_mask != 16
                        or next_real_mask != 128
                        or tie_virtual_map != (1 << 9)
                        or all_virtual_map != (1 << 11)
                        or exact_virtual_map != (1 << 13)
                        or group_virtual_map != (1 << 14)
                        or next_virtual_map != (1 << 15)
                        or implicit_exact_real_mask != 16
                        or implicit_exact_virtual_map != (1 << 17)
                        or implicit_exact_raw_keysym != 0xffe3
                        or implicit_exact_predicate != 4
                        or group_raw_keysym != 0xff7e
                        or next_raw_keysym != 0xfe08
                         or compat_rule_count != 15
                         or repeat_default != 0
                         or repeat_values != (1, bytes((0, 1, 0, 1)))
                         or repeat_explicit != bytes((0, 0, 1, 1))
                         or repeat_symbol_less != 0
                         or preserve_type_id != 10
                         or consumed_type_id != 11
                         or preserve_map_masks != (0, 1, 4, 5)
                         or preserve_map_levels != bytes((1, 2, 3, 4))
                         or preserve_map_values != (0, 0, 4, 4)
                         or consumed_map_values != (0, 0, 0, 0)
                         or shift_preserve_type_id != 12
                         or shift_consumed_type_id != 13
                         or shift_preserve_type_mask != 1
                         or shift_consumed_type_mask != 1
                         or shift_preserve_map_masks != (0, 1)
                         or shift_consumed_map_masks != (0, 1)
                         or shift_preserve_values != (0, 1)
                         or shift_consumed_values != (0, 0)
                    ):
                        raise AssertionError(
                            "custom XKB type mapping was not parsed exactly: "
                            + repr({
                                "alpha_type_id": custom_alpha_type_id,
                                "alpha_name": custom_alpha_name,
                                "alpha_mask": custom_alpha_mask,
                                "alpha_map": (custom_alpha_map_count, custom_alpha_map_mask, custom_alpha_map_level),
                                "type_id": custom_type_id,
                                "name": custom_type_name,
                                "mask": custom_type_mask,
                                "count": custom_map_count,
                                "maps": custom_map_masks,
                                "levels": custom_map_levels,
                                "implicit": {
                                    "type_id": implicit_type_id,
                                    "name": implicit_type_name,
                                    "type_mask": implicit_type_mask,
                                    "map": (implicit_map_count, implicit_map_mask, implicit_map_level),
                                    "type_mask": implicit_type_mask,
                                    "real_key_masks": (ab05_real_mask, ab06_real_mask),
                                    "key_vmods": (ab05_virtual_map, ab06_virtual_map),
                                    "indirect": {
                                        "type_id": indirect_type_id,
                                        "name": indirect_type_name,
                                        "mask": indirect_type_mask,
                                        "map": (indirect_map_count, indirect_map_mask, indirect_map_level),
                                        "ralt": (ralt_raw_keysym, ralt_real_mask, ralt_virtual_map, ralt_map_kind, ralt_map_target),
                                        "rctl": (rctl_raw_keysym, rctl_real_mask, rctl_map_kind, rctl_map_target),
                                        "ad12": (ad12_raw_keysym, ad12_real_mask),
                                        "compat_virtual_maps": {
                                            "rctl": rctl_virtual_map,
                                            "ad12": ad12_virtual_map,
                                            "ab03": ab03_virtual_map,
                                            "level1": lvl3_virtual_map,
                                            "level2": lvl2_virtual_map,
                                            "group2": grp2_virtual_map,
                                            "ralt_explicit": ralt_explicit_virtual,
                                            "rule_count": compat_rule_count,
                                            "repeat_policy": (repeat_default, repeat_values, repeat_explicit),
                                            "predicate_specificity": {
                                                "real_masks": (tie_real_mask, all_real_mask, exact_real_mask),
                                                "virtual_maps": (tie_virtual_map, all_virtual_map, exact_virtual_map),
                                                "group_keysyms": (group_raw_keysym, next_raw_keysym),
                                                "group_masks": (group_real_mask, next_real_mask),
                                                "implicit_exact": {
                                                    "real_mask": implicit_exact_real_mask,
                                                    "virtual_map": implicit_exact_virtual_map,
                                                    "keysym": implicit_exact_raw_keysym,
                                                    "predicate": implicit_exact_predicate,
                                                },
                                            },
                                        },
                                    },
                                },
                            })
                        )
                    expected_virtual_masks = (128, 16, 192, 80, 8, 0, 0, 128, 8, 4, 0, 1, 0, 8, 16, 128) + (128, 16) + (0,) * 5 + (0x80000000,)
                    if (
                        (virtual_count, level_three_mask, num_lock_mask) != (24, 128, 16)
                        or virtual_masks != expected_virtual_masks
                    ):
                        raise AssertionError(
                            "XKB virtual modifier encodings were not retained independently of declaration indices: "
                            + repr({
                                "count": virtual_count,
                                "LevelThree": level_three_mask,
                                "NumLock": num_lock_mask,
                                "masks": virtual_masks,
                            })
                        )
                    if ae01_name != b"AE01" or ae01_levels[:2] != b"1!":
                        raise AssertionError(
                            "XKB shorthand number-row parse failed: "
                            f"name={ae01_name!r}, levels={ae01_levels!r}"
                        )
                    if ae02_name != b"AE02" or ae02_levels[:2] != b"2@":
                        raise AssertionError(
                            "XKB shorthand AE02 parse failed: "
                            f"name={ae02_name!r}, levels={ae02_levels!r}"
                        )
                    if (
                        key_name != b"AD01"
                        or ad02_name != b"AD02"
                        or ad02_levels[:2] != b"wW"
                        or ralt_name != b"RALT"
                        or alias_count != 5
                    ):
                        raise AssertionError(
                            "XKB key aliases overwrote canonical names or failed symbol lookup: "
                            + repr({
                                "AD01": key_name,
                                "AD02": ad02_name,
                                "AD02_levels": ad02_levels[:2],
                                "RALT": ralt_name,
                                "alias_count": alias_count,
                            })
                        )
                    observations.append(
                        "XKB keycodes preserve canonical names, retain alias lookups, and parse symbols addressed through LatW"
                    )
                    observations.append(
                        "XKB compatibility defaults an omitted matching operator to Exactly(mask) and matches only the exact modifier map"
                    )
                    observations.append(
                        "XKB parser exported AD01 keycode 24 with alphabetic/LevelThree flags and the expected Group1/Group2 symbols"
                    )
                if sparse_keymap_test:
                    nm_text = subprocess.check_output(
                        ["nm", "-n", binary], text=True
                    )
                    ready_address = None
                    ready_address = None
                    complete_address = None
                    for line in nm_text.splitlines():
                        fields = line.split()
                        if len(fields) != 3:
                            continue
                        if fields[2] == "xkb_keymap_ready":
                            ready_address = int(fields[0], 16)
                        elif fields[2] == "keymap_processing_complete":
                            complete_address = int(fields[0], 16)
                    if ready_address is None or complete_address is None:
                        raise AssertionError("XKB parser state symbols missing")
                    mem_fd = os.open(f"/proc/{child.pid}/mem", os.O_RDONLY)
                    try:
                        complete_deadline = time.monotonic() + 3.0
                        parser_complete = struct.unpack(
                            "<I", os.pread(mem_fd, 4, complete_address)
                        )[0]
                        while parser_complete != 1 and time.monotonic() < complete_deadline:
                            time.sleep(0.001)
                            parser_complete = struct.unpack(
                                "<I", os.pread(mem_fd, 4, complete_address)
                            )[0]
                        if parser_complete != 1:
                            raise AssertionError("sparse XKB parser did not finish processing")
                        parser_ready = struct.unpack(
                            "<I", os.pread(mem_fd, 4, ready_address)
                        )[0]
                    finally:
                        os.close(mem_fd)
                    if parser_ready != 0:
                        raise AssertionError(
                            "sparse punctuation-only XKB map was incorrectly activated"
                        )
                    observations.append(
                        "sparse punctuation-only XKB map was rejected and US-QWERTY fallback stayed active"
                    )

                observations.append(
                    "wl_keyboard.keymap SCM_RIGHTS FD was received, validated, and mapped read-only with MAP_PRIVATE"
                )

                keyboard_events = b""
                if advertised_seat_version >= 4:
                    # Use a non-default compositor policy to prove the client
                    # consumes wl_keyboard.repeat_info rather than constants.
                    keyboard_events += wire_message(keyboard_object_id, 5, struct.pack("<ii", 10, 180))
                keyboard_events += wire_message(keyboard_object_id, 1, struct.pack("<III", 1001, 8, 0))
                client.sendall(keyboard_events)

                if font_parser_test:
                    nm_text = subprocess.check_output(["nm", "-n", binary], text=True)
                    font_symbols = {}
                    expected_names = {
                        "font_loaded", "font_file_map", "font_file_size",
                        "font_units_per_em", "font_num_glyphs", "font_ascent",
                        "font_descent", "font_line_gap", "font_num_hmetrics", "font_index_to_loc_format",
                        "font_cmap_format", "font_probe_A_glyph", "font_probe_A_advance",
                        "font_probe_j_raster_result", "font_probe_j_raster_width",
                        "font_probe_j_raster_height", "font_probe_j_raster_pixels",
                        "font_probe_A_outline_result", "font_probe_A_contours",
                        "font_probe_A_points", "font_probe_A_last_x", "font_probe_A_last_y",
                        "font_probe_empty_result", "font_probe_empty_contours",
                        "font_probe_empty_points", "font_probe_oob_result",
                        "font_probe_composite_result", "font_probe_composite_contours",
                        "font_probe_composite_points", "font_probe_composite_first_x",
                        "font_probe_composite_first_y", "font_probe_composite_last_x",
                        "font_probe_composite_last_y", "font_probe_nested_result",
                        "font_probe_nested_contours", "font_probe_nested_points",
                        "font_probe_nested_last_x", "font_probe_nested_last_y",
                        "font_probe_pointmatch_result", "font_probe_pointmatch_contours",
                        "font_probe_pointmatch_points", "font_probe_pointmatch_last_x",
                        "font_probe_pointmatch_last_y", "font_probe_cycle_result",
                        "font_probe_anisotropic_result", "font_probe_anisotropic_contours",
                        "font_probe_anisotropic_points", "font_probe_anisotropic_last_x",
                        "font_probe_anisotropic_last_y", "font_probe_matrix_result",
                        "font_probe_matrix_contours", "font_probe_matrix_points",
                        "font_probe_matrix_last_x", "font_probe_matrix_last_y",
                        "font_probe_byte_result", "font_probe_byte_contours",
                        "font_probe_byte_points", "font_probe_byte_first_x",
                        "font_probe_byte_first_y", "font_probe_byte_last_x",
                        "font_probe_byte_last_y",
                        "font_probe_raster_result", "font_probe_raster_width",
                        "font_probe_raster_height", "font_probe_raster_pixels",
                        "font_probe_curve_result", "font_probe_curve_width",
                        "font_probe_curve_height", "font_probe_curve_pixels",
                        "font_probe_advance_A", "font_probe_advance_B", "font_probe_advance_space",
                        "doc_cursor", "doc_length", "doc_line_count", "doc_line_index_base", "pointer_x", "pointer_y",
                        "window_doc_pixel_width", "window_doc_line_height", "window_doc_visible_rows",
                        "doc_line_index_valid", "doc_line_index_columns",
                    }
                    for symbol_line in nm_text.splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in expected_names:
                            font_symbols[fields[2]] = int(fields[0], 16)
                    if set(font_symbols) != expected_names:
                        raise AssertionError("font parser state symbols missing: " + repr(font_symbols))
                    with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                        fd = memory.fileno()
                        values = {}
                        for name, address in font_symbols.items():
                            size = 8 if name in {"font_file_map", "font_file_size", "doc_line_index_base"} else 4
                            raw = os.pread(fd, size, address)
                            values[name] = struct.unpack("<Q" if size == 8 else "<i", raw)[0]
                    expected = {
                        "font_loaded": 1,
                        "font_units_per_em": 1000,
                        "font_num_glyphs": 11,
                        "font_ascent": 850,
                        "font_descent": -250,
                        "font_line_gap": 100,
                        "font_num_hmetrics": 11,
                        "font_probe_advance_A": 8,
                        "font_probe_advance_B": 5,
                        "font_probe_advance_space": 3,
                        # A=8px, B=5px: clicking at x=27 is beyond B's midpoint
                        # (B starts at x=24), so the caret is before the third A.
                        "doc_cursor": 2,
                        "doc_length": 96,
                        "doc_line_count": 1,
                        "pointer_x": 27,
                        "pointer_y": 98,
                        "window_doc_pixel_width": 760,
                        "window_doc_line_height": 15,
                        "window_doc_visible_rows": 24,
                        "doc_line_index_valid": 1,
                        "doc_line_index_columns": 760,
                        "font_index_to_loc_format": 0,
                        "font_cmap_format": 4,
                        "font_probe_A_glyph": 1,
                        "font_probe_A_advance": 650,
                        "font_probe_A_outline_result": 0,
                        "font_probe_A_contours": 1,
                        "font_probe_A_points": 3,
                        "font_probe_A_last_x": 250,
                        "font_probe_A_last_y": 700,
                        "font_probe_empty_result": 0,
                        "font_probe_empty_contours": 0,
                        "font_probe_empty_points": 0,
                        "font_probe_oob_result": -1,
                        "font_probe_composite_result": 0,
                        "font_probe_composite_contours": 1,
                        "font_probe_composite_points": 3,
                        "font_probe_composite_first_x": 100,
                        "font_probe_composite_first_y": 200,
                        "font_probe_composite_last_x": 350,
                        "font_probe_composite_last_y": 900,
                        "font_probe_nested_result": 0,
                        "font_probe_nested_contours": 1,
                        "font_probe_nested_points": 3,
                        "font_probe_nested_last_x": 125,
                        "font_probe_nested_last_y": 460,
                        "font_probe_pointmatch_result": 0,
                        "font_probe_pointmatch_contours": 2,
                        "font_probe_pointmatch_points": 6,
                        "font_probe_pointmatch_last_x": -250,
                        "font_probe_pointmatch_last_y": 700,
                        "font_probe_cycle_result": -1,
                        "font_probe_anisotropic_result": 0,
                        "font_probe_anisotropic_contours": 1,
                        "font_probe_anisotropic_points": 3,
                        "font_probe_anisotropic_last_x": 125,
                        "font_probe_anisotropic_last_y": 1050,
                        "font_probe_matrix_result": 0,
                        "font_probe_matrix_contours": 1,
                        "font_probe_matrix_points": 3,
                        "font_probe_matrix_last_x": -700,
                        "font_probe_matrix_last_y": 250,
                        "font_probe_byte_result": 0,
                        "font_probe_byte_contours": 1,
                        "font_probe_byte_points": 3,
                        "font_probe_byte_first_x": -10,
                        "font_probe_byte_first_y": 5,
                        "font_probe_byte_last_x": 240,
                        "font_probe_byte_last_y": 705,
                    }
                    mismatch = {
                        name: (values.get(name), value)
                        for name, value in expected.items()
                        if values.get(name) != value
                    }
                    index_errors = {}
                    line_record = None
                    if values.get("doc_line_index_base"):
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as index_memory:
                            line_record = struct.unpack(
                                "<4I",
                                os.pread(index_memory.fileno(), 16, values["doc_line_index_base"])
                            )
                    if line_record is None or line_record != (96, 2, 96, 2):
                        index_errors["single_line_pixel_wrap_record"] = line_record
                    raster_errors = {}
                    for name in (
                        "font_probe_raster_width", "font_probe_raster_height",
                        "font_probe_raster_pixels", "font_probe_curve_width",
                        "font_probe_curve_height", "font_probe_curve_pixels",
                    ):
                        if values.get(name, 0) <= 0:
                            raster_errors[name] = values.get(name)
                    if values.get("font_probe_raster_result") != 0 or values.get("font_probe_curve_result") != 0:
                        raster_errors["results"] = (
                            values.get("font_probe_raster_result"),
                            values.get("font_probe_curve_result"),
                        )
                    if (
                        values.get("font_probe_j_raster_result") != 0
                        or values.get("font_probe_j_raster_width", 0) <= 0
                        or not (32 < values.get("font_probe_j_raster_height", 0) <= 64)
                        or values.get("font_probe_j_raster_pixels", 0) <= 0
                    ):
                        raster_errors["32px_lowercase_j_descender"] = {
                            name: values.get(name)
                            for name in (
                                "font_probe_j_raster_result", "font_probe_j_raster_width",
                                "font_probe_j_raster_height", "font_probe_j_raster_pixels",
                            )
                        }
                    if (
                        not values["font_file_map"] or not values["font_file_size"]
                        or mismatch or index_errors or raster_errors
                    ):
                        raise AssertionError(
                            "synthetic TrueType outline/rasterization validation failed: "
                            + repr({
                                "mismatch": mismatch,
                                "index_errors": index_errors,
                                "raster_errors": raster_errors,
                                "line_record": line_record,
                                "state": values,
                            })
                        )
                    if not antialiased_ink_present(12, 88, 24, 16):
                        raise AssertionError(
                            "synthetic TrueType glyph A was rasterized but not painted into the Wayland framebuffer"
                        )
                    if not antialiased_ink_present(30, 92, 2, 12):
                        raise AssertionError(
                            "third A was not painted at x=29 after the 5px B advance"
                        )
                    if not antialiased_ink_present(12, 106, 20, 16):
                        raise AssertionError(
                            "last A was not painted on the second visual row after pixel-width wrapping"
                        )
                    observations.append(
                        "explicit NEKOEDIT_FONT path validated SFNT outlines, 8px/5px glyph advances, a 3px hmtx-mapped space, OS/2 USE_TYPO_METRICS line pitch, pixel-width wrapping and indexed row counts, proportional pointer hit-testing, straight and quadratic rasterization, a 32px lowercase j descender requiring a mask taller than 32px, and compositor-visible glyph positions"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                document_symbols = {}
                for symbol_line in subprocess.check_output(["nm", "-n", binary], text=True).splitlines():
                    fields = symbol_line.split()
                    if len(fields) == 3 and fields[2] in {
                        "doc_length", "doc_buffer", "doc_capacity", "doc_cursor",
                        "doc_gap_start", "doc_gap_end", "doc_storage_error",
                        "doc_line_index_base", "doc_line_index_bytes",
                        "doc_line_index_capacity", "doc_line_count",
                        "doc_line_index_valid", "doc_line_index_columns",
                        "doc_view_top_row", "doc_view_left_px", "doc_wrap_enabled",
                        "doc_total_visual_rows", "doc_scroll_thumb_height",
                        "window_doc_pixel_width", "settings_menu_open",
                        "doc_selection_active", "context_menu_open", "context_menu_x",
                        "context_menu_y",
                    }:
                        document_symbols[fields[2]] = int(fields[0], 16)

                def read_document_state() -> dict[str, object]:
                    with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                        fd = memory.fileno()
                        state: dict[str, object] = {}
                        qword_names = {"doc_buffer", "doc_line_index_base", "doc_line_index_bytes"}
                        for name in document_symbols:
                            size = 8 if name in qword_names else 4
                            raw = os.pread(fd, size, document_symbols[name])
                            state[name] = struct.unpack("<Q" if size == 8 else "<I", raw)[0]
                        pointer = state["doc_buffer"]
                        state["doc_buffer_pointer"] = pointer
                        state["doc_buffer"] = os.pread(fd, 64, pointer) if pointer else b""
                        if pointer:
                            prefix = os.pread(fd, state["doc_gap_start"], pointer)
                            suffix_length = state["doc_length"] - state["doc_gap_start"]
                            suffix = os.pread(fd, suffix_length, pointer + state["doc_gap_end"])
                            state["doc_contents"] = prefix + suffix
                        else:
                            state["doc_contents"] = b""
                        index_pointer = state.get("doc_line_index_base", 0)
                        line_count = state.get("doc_line_count", 0)
                        if index_pointer and line_count:
                            raw_records = os.pread(fd, line_count * 16, index_pointer)
                            if len(raw_records) != line_count * 16:
                                raise AssertionError("short read from document line-index mapping")
                            state["doc_line_index_records"] = [
                                struct.unpack_from("<IIII", raw_records, index * 16)
                                for index in range(line_count)
                            ]
                        else:
                            state["doc_line_index_records"] = []
                        return state

                child_symbol_addresses: dict[str, int] = {}

                def child_u32(name: str) -> int:
                    if name not in child_symbol_addresses:
                        for symbol_line in subprocess.check_output(
                            ["nm", "-n", binary], text=True
                        ).splitlines():
                            fields = symbol_line.split()
                            if len(fields) == 3 and fields[2] == name:
                                child_symbol_addresses[name] = int(fields[0], 16)
                                break
                    if name not in child_symbol_addresses:
                        raise AssertionError("child state symbol missing: " + name)
                    with open(
                        f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0
                    ) as memory:
                        raw = os.pread(memory.fileno(), 4, child_symbol_addresses[name])
                    if len(raw) != 4:
                        raise AssertionError("short child state read for " + name)
                    return struct.unpack("<I", raw)[0]

                def child_u32_at(name: str, byte_offset: int) -> int:
                    if name not in child_symbol_addresses:
                        # Reuse the same nm-derived symbol cache as child_u32.
                        child_u32(name)
                    with open(
                        f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0
                    ) as memory:
                        raw = os.pread(
                            memory.fileno(), 4, child_symbol_addresses[name] + byte_offset
                        )
                    if len(raw) != 4:
                        raise AssertionError(
                            f"short child state read for {name}+{byte_offset}"
                        )
                    return struct.unpack("<I", raw)[0]

                def expect_buffer_attach(label: str, skip_cursor_shape: bool = False) -> int:
                    # A redraw may lazily create slot one before attaching it.
                    # Track protocol object IDs and byte offsets rather than
                    # assuming every frame reuses the first wl_buffer.
                    message = recv_wayland_message(client)
                    while True:
                        if (
                            skip_cursor_shape
                            and message[0] == child_u32("cursor_shape_device")
                            and message[1] == 1
                        ):
                            if message[3] or len(message[2]) != 8:
                                raise AssertionError(f"{label}: malformed cursor-shape update {message!r}")
                            message = recv_wayland_message(client)
                            continue
                        if message[0:2] != (11, 0):
                            break
                        if len(message[2]) != 24 or message[3]:
                            raise AssertionError(f"{label}: malformed wl_buffer.create_buffer: {message!r}")
                        new_id, offset, width, height, stride, pixel_format = struct.unpack("<6I", message[2])
                        if (
                            new_id == 0
                            or offset not in (0, expected_size)
                            or width == 0
                            or height == 0
                            or stride != width * 4
                            or stride * height > expected_size
                            or pixel_format != 1
                        ):
                            raise AssertionError(
                                f"{label}: invalid SHM buffer slot descriptor: "
                                f"{(new_id, offset, width, height, stride, pixel_format)!r}"
                            )
                        known_buffer_offsets[new_id] = offset
                        message = recv_wayland_message(client)
                    if message[0:2] != (8, 1) or len(message[2]) != 12 or message[3]:
                        raise AssertionError(f"{label}: expected wl_surface.attach, got {message!r}")
                    attached_id, attach_x, attach_y = struct.unpack("<III", message[2])
                    if attached_id not in known_buffer_offsets or (attach_x, attach_y) != (0, 0):
                        raise AssertionError(
                            f"{label}: attached an unknown buffer or nonzero origin: "
                            f"{(attached_id, attach_x, attach_y)!r}"
                        )
                    active_buffer["id"] = attached_id
                    active_buffer["offset"] = known_buffer_offsets[attached_id]
                    return attached_id

                def expect_buffer_frame(label: str, skip_cursor_shape: bool = False) -> int:
                    attached_id = expect_buffer_attach(label, skip_cursor_shape=skip_cursor_shape)
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        f"{label} damage",
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    return attached_id



                if seat_hotplug_ime_test:
                    # This scenario combines the real opt-in text-input-v3
                    # lifecycle with seat removal. The IME owns a visible
                    # preedit when the physical keyboard disappears.
                    def wait_hotplug_state(name: str, expected: int, timeout: float = 3.0) -> None:
                        deadline = time.monotonic() + timeout
                        actual = child_u32(name)
                        while actual != expected and time.monotonic() < deadline:
                            time.sleep(0.005)
                            actual = child_u32(name)
                        if actual != expected:
                            raise AssertionError(
                                f"IME hotplug state {name}: expected {expected}, got {actual}"
                            )

                    def expect_hotplug_frame(label: str) -> None:
                        expect_buffer_frame(label)

                    def expect_ime_state_update(label: str) -> None:
                        expect_message(
                            client, (test_text_input_id, 4, struct.pack("<I", 0)),
                            f"{label} text-change cause",
                        )
                        surrounding = recv_wayland_message(client)
                        if surrounding[0:2] != (test_text_input_id, 3) or surrounding[3]:
                            raise AssertionError(
                                f"{label}: expected set_surrounding_text, got {surrounding!r}"
                            )
                        rectangle = recv_wayland_message(client)
                        if rectangle[0:2] != (test_text_input_id, 6) or len(rectangle[2]) != 16 or rectangle[3]:
                            raise AssertionError(
                                f"{label}: expected set_cursor_rectangle, got {rectangle!r}"
                            )
                        expect_message(client, (test_text_input_id, 7, b""), f"{label} state commit")

                    def preedit_event(value: bytes, cursor_begin: int, cursor_end: int) -> bytes:
                        encoded = value + b"\0"
                        payload = struct.pack("<I", len(encoded)) + encoded
                        payload += b"\0" * (-len(encoded) % 4)
                        payload += struct.pack("<ii", cursor_begin, cursor_end)
                        return wire_message(test_text_input_id, 2, payload)

                    # The keyboard enter has already caused a queued redraw.
                    client.sendall(wire_message(active_buffer["id"], 0))
                    expect_hotplug_frame("keyboard-focus redraw")
                    client.sendall(
                        wire_message(active_buffer["id"], 0)
                        + wire_message(test_text_input_id, 0, struct.pack("<I", 8))
                    )
                    expect_message(client, (test_text_input_id, 1, b""), "enable text input for the editor")
                    expect_message(
                        client, (test_text_input_id, 5, struct.pack("<II", 0, 0)),
                        "set normal content type",
                    )
                    expect_ime_state_update("initial IME focus")
                    expect_hotplug_frame("text-input enable redraw")

                    # A matching done acknowledges the first committed state.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(wire_message(test_text_input_id, 5, struct.pack("<I", serial)))
                    client.sendall(wire_message(active_buffer["id"], 0))
                    expect_hotplug_frame("initial text-input done redraw")

                    preedit_text = b"abc"
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        preedit_event(preedit_text, 1, 2)
                        + wire_message(test_text_input_id, 5, struct.pack("<I", serial))
                    )
                    expect_ime_state_update("active preedit")
                    client.sendall(wire_message(active_buffer["id"], 0))
                    expect_hotplug_frame("active preedit redraw")

                    if (
                        child_u32("text_input_enabled") != 1
                        or child_u32("text_input_preedit_length") != len(preedit_text)
                        or child_u32("doc_length") != 0
                        or not rendered_color_present(24, 92, 8, 12, 3200, 0xff5e81ac)
                    ):
                        raise AssertionError(
                            "IME hotplug fixture did not establish a visible, uncommitted preedit"
                        )

                    # Drain the shared buffer and frame callback before
                    # removing the keyboard so the disable-triggered clear
                    # must be presented immediately by the seat event handler.
                    client.sendall(wire_message(active_buffer["id"], 0))
                    wait_hotplug_state("buffer_busy", 0)
                    wait_hotplug_state("frame_callback_id", 0)
                    previous_frame_requests = frame_callback_stats["requested"]

                    client.sendall(wire_message(13, 0, struct.pack("<I", 1)))
                    expect_message(
                        client, (16, 0, b""), "release keyboard with active IME preedit"
                    )
                    expect_message(
                        client, (test_text_input_id, 2, b""), "disable text input after keyboard removal"
                    )
                    expect_message(
                        client, (test_text_input_id, 7, b""), "commit text-input disable after keyboard removal"
                    )
                    expect_hotplug_frame("keyboard-removal preedit clear")

                    wait_hotplug_state("keyboard_focused", 0)
                    wait_hotplug_state("text_input_enabled", 0)
                    wait_hotplug_state("text_input_preedit_length", 0)
                    wait_hotplug_state("text_input_preedit_cursor_begin", 0xffffffff)
                    wait_hotplug_state("text_input_preedit_cursor_end", 0xffffffff)
                    wait_hotplug_state("frame_callback_id", 0)
                    wait_hotplug_state("buffer_busy", 1)
                    wait_hotplug_state("redraw_pending", 0)
                    if (
                        frame_callback_stats["requested"] != previous_frame_requests + 1
                        or frame_callback_stats["completed"] != frame_callback_stats["requested"]
                        or not frame_callback_stats["ids"]
                        or rendered_color_present(24, 92, 8, 12, 3200, 0xff5e81ac)
                    ):
                        raise AssertionError(
                            "keyboard removal did not complete exactly one frame with the IME preedit cleared: "
                            + repr(frame_callback_stats)
                        )
                    if child_u32("doc_length") != 0:
                        raise AssertionError("uncommitted IME preedit leaked into the document on keyboard removal")

                    observations.append(
                        "keyboard hotplug while IME preedit was active sent text-input disable+commit, "
                        "cleared transient preedit without committing it, and immediately redrew the surface"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if text_input_test:
                    def expect_frame(label: str) -> None:
                        expect_buffer_frame(label)

                    def release_frame(label: str) -> None:
                        client.sendall(wire_message(active_buffer["id"], 0))
                        expect_frame(label)

                    def expect_state(
                        expected_text: bytes, expected_cursor: int, label: str,
                        expected_anchor: int | None = None,
                        expected_rectangle: tuple[int, int, int, int] | None = None,
                        *, expected_cause: int = 0,
                    ) -> tuple[int, int, int, int]:
                        cause_message = recv_wayland_message(client)
                        if cause_message[0:2] != (18, 4) or len(cause_message[2]) != 4 or cause_message[3]:
                            raise AssertionError(f"{label}: expected set_text_change_cause before surrounding text, got {cause_message!r}")
                        actual_cause = struct.unpack("<I", cause_message[2])[0]
                        if actual_cause != expected_cause:
                            raise AssertionError(
                                f"{label}: expected text change cause {expected_cause}, got {actual_cause}"
                            )
                        message = recv_wayland_message(client)
                        if message[0:2] != (18, 3) or message[3]:
                            raise AssertionError(f"{label}: unexpected surrounding-text request {message!r}")
                        payload = message[2]
                        string_length = struct.unpack_from("<I", payload)[0]
                        padded_length = (string_length + 3) & ~3
                        if string_length == 0 or len(payload) != 4 + padded_length + 8:
                            raise AssertionError(f"{label}: malformed surrounding-text payload {payload!r}")
                        value = payload[4 : 4 + string_length]
                        cursor, anchor = struct.unpack_from("<II", payload, 4 + padded_length)
                        anchor_expected = (
                            expected_cursor if expected_anchor is None else expected_anchor
                        )
                        if value != expected_text + b"\0" or (cursor, anchor) != (
                            expected_cursor, anchor_expected
                        ):
                            raise AssertionError(
                                f"{label}: expected text/cursor {expected_text!r}/{expected_cursor}, "
                                f"got {value!r}/{cursor}/{anchor}"
                            )
                        rectangle = recv_wayland_message(client)
                        if rectangle[0:2] != (18, 6) or len(rectangle[2]) != 16 or rectangle[3]:
                            raise AssertionError(f"{label}: malformed cursor rectangle {rectangle!r}")
                        rectangle_values = struct.unpack("<4i", rectangle[2])
                        if (
                            expected_rectangle is not None
                            and rectangle_values != expected_rectangle
                        ):
                            raise AssertionError(
                                f"{label}: expected cursor rectangle {expected_rectangle}, "
                                f"got {rectangle_values}"
                            )
                        expect_message(client, (18, 7, b""), f"{label} state commit")
                        return rectangle_values

                    # The keyboard is focused, but the IME must remain off until
                    # text-input.enter identifies this surface as its text target.
                    client.sendall(wire_message(active_buffer["id"], 0))
                    expect_buffer_frame("keyboard-focus redraw")
                    client.sendall(wire_message(active_buffer["id"], 0))
                    client.sendall(wire_message(18, 0, struct.pack("<I", 8)))
                    expect_message(client, (18, 1, b""), "enable text input")
                    expect_message(
                        client, (18, 5, struct.pack("<II", 0, 0)), "set normal content type"
                    )
                    expect_state(b"", 0, "initial text-input state")
                    expect_frame("text-input enable redraw")

                    # A matching empty done acknowledges serial 1 without
                    # triggering another state commit and a feedback loop.
                    client.sendall(wire_message(18, 5, struct.pack("<I", 1)))
                    release_frame("initial done redraw")
                    def preedit_event(value: bytes, cursor_begin: int, cursor_end: int) -> bytes:
                        # Wayland strings include the trailing NUL in their length
                        # and are padded to a 4-byte boundary before following fields.
                        payload = struct.pack("<I", len(value)) + value
                        payload += b"\0" * (-len(value) % 4)
                        payload += struct.pack("<ii", cursor_begin, cursor_end)
                        return wire_message(18, 2, payload)

                    preedit = b"abc\0"
                    client.sendall(
                        wire_message(
                            18, 2,
                            struct.pack("<I", len(preedit)) + preedit
                            + struct.pack("<ii", 1, 2),
                        )
                        + wire_message(18, 5, struct.pack("<I", 1))
                    )
                    expect_state(
                        b"", 0, "preedit cursor rectangle",
                        expected_rectangle=(24, 92, 1, 12),
                    )
                    release_frame("preedit redraw")
                    if not rendered_color_present(24, 92, 8, 12, 3200, 0xff5e81ac):
                        raise AssertionError(
                            "cursor_begin/cursor_end preedit selection was not painted behind its glyph"
                        )
                    if child_u32("text_input_preedit_length") != 3:
                        raise AssertionError("preedit_string was not retained until done")
                    if child_u32("text_input_preedit_cursor_begin") != 1:
                        raise AssertionError("preedit cursor byte offset was not preserved")
                    if child_u32("doc_length") != 0:
                        raise AssertionError("preedit text was incorrectly committed to the document")

                    # Mutter 46.0-46.2 sent cursor_end as a character index
                    # while cursor_begin was already a byte offset. Accept only
                    # the collapsed-caret legacy pattern (2, 1) for a two-byte
                    # character, and normalize it to the protocol byte pair (2, 2).
                    legacy_anchor_text = "é".encode("utf-8")
                    legacy_anchor = legacy_anchor_text + bytes((0,))
                    client.sendall(preedit_event(legacy_anchor, 2, 1))
                    legacy_deadline = time.monotonic() + 2.0
                    while (
                        child_u32("text_input_pending_preedit_length") != len(legacy_anchor_text)
                        and time.monotonic() < legacy_deadline
                    ):
                        time.sleep(0.005)
                    legacy_pending = {
                        "length": child_u32("text_input_pending_preedit_length"),
                        "cursor_begin": child_u32("text_input_pending_preedit_cursor_begin"),
                        "cursor_end": child_u32("text_input_pending_preedit_cursor_end"),
                    }
                    if legacy_pending != {
                        "length": len(legacy_anchor_text), "cursor_begin": 2, "cursor_end": 2
                    }:
                        raise AssertionError(
                            "legacy Mutter character-index anchor was not repaired narrowly: "
                            + repr(legacy_pending)
                        )

                    # A valid multibyte preedit followed by an invalid replacement in
                    # the same done batch must retain the last valid candidate. Cursor
                    # indices are UTF-8 byte offsets, and the range may be reversed.
                    multibyte_preedit_text = "aé中".encode("utf-8")
                    multibyte_preedit = multibyte_preedit_text + bytes((0,))
                    invalid_preedit = "é".encode("utf-8") + bytes((0,))
                    client.sendall(
                        preedit_event(multibyte_preedit, 3, 1)
                        + preedit_event(invalid_preedit, 1, 1)
                    )
                    pending_deadline = time.monotonic() + 2.0
                    while (
                        child_u32("text_input_pending_preedit_length") != len(multibyte_preedit_text)
                        and time.monotonic() < pending_deadline
                    ):
                        time.sleep(0.005)
                    pending_values = {
                        "length": child_u32("text_input_pending_preedit_length"),
                        "cursor_begin": child_u32("text_input_pending_preedit_cursor_begin"),
                        "cursor_end": child_u32("text_input_pending_preedit_cursor_end"),
                        "flags": child_u32("text_input_pending_flags"),
                        "commit_serial": child_u32("text_input_commit_serial"),
                        "text_input_object": child_u32("text_input_object"),
                        "text_input_enabled": child_u32("text_input_enabled"),
                        "text_input_entered": child_u32("text_input_entered"),
                        "last_object": child_u32("last_object"),
                        "last_opcode": child_u32("last_opcode"),
                        "last_size": child_u32("last_size"),
                        "event_payload_words": [
                            child_u32_at("event_payload", offset) for offset in (0, 4, 8, 12, 16)
                        ],
                    }
                    if (
                        pending_values["length"] != len(multibyte_preedit_text)
                        or pending_values["cursor_begin"] != 3
                        or pending_values["cursor_end"] != 1
                    ):
                        raise AssertionError(
                            "valid preedit candidate was not retained after rejecting a malformed cursor offset: "
                            + repr(pending_values)
                        )
                    # Take the serial after the candidate events have been consumed.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(wire_message(18, 5, struct.pack("<I", serial)))
                    reversed_range_rect = expect_state(
                        b"", 0, "reversed multibyte preedit cursor range"
                    )
                    release_frame("reversed multibyte preedit redraw")
                    preedit_word0 = struct.pack(
                        "<I", child_u32("text_input_preedit_buffer")
                    )
                    preedit_word2 = struct.pack(
                        "<I", child_u32_at("text_input_preedit_buffer", 2)
                    )
                    actual_preedit = preedit_word0 + preedit_word2[2:4]
                    if (
                        child_u32("text_input_preedit_length") != len(multibyte_preedit_text)
                        or actual_preedit != multibyte_preedit_text
                    ):
                        raise AssertionError(
                            "a later invalid preedit event overwrote the preceding valid pending preedit"
                        )
                    if reversed_range_rect[0] <= 24:
                        raise AssertionError(
                            "preedit cursor_begin=3 was treated as a character count instead of a UTF-8 byte offset"
                        )

                    # The same highlight range in forward order must occupy the
                    # same glyph span, while cursor_begin moves the IME caret.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        preedit_event(multibyte_preedit, 1, 3)
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    forward_range_rect = expect_state(
                        b"", 0, "forward multibyte preedit cursor range"
                    )
                    release_frame("forward multibyte preedit redraw")
                    highlight_width = reversed_range_rect[0] - forward_range_rect[0]
                    if (
                        highlight_width <= 0
                        or reversed_range_rect[1] != forward_range_rect[1]
                        or not rendered_color_present(
                            forward_range_rect[0], forward_range_rect[1],
                            highlight_width, 12, 3200, 0xff5e81ac
                        )
                    ):
                        raise AssertionError(
                            "forward/reversed UTF-8 preedit ranges did not paint the same selected scalar span"
                        )

                    # A (-1,-1) preedit cursor hides the IME cursor; the cursor
                    # rectangle therefore returns to the committed document caret.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        preedit_event(multibyte_preedit, -1, -1)
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    expect_state(
                        b"", 0, "hidden preedit cursor",
                        expected_rectangle=(16, 92, 1, 12),
                    )
                    release_frame("hidden preedit cursor redraw")
                    if child_u32("text_input_preedit_cursor_begin") != 0xffffffff:
                        raise AssertionError("preedit cursor (-1,-1) was not preserved as hidden")

                    # Mutter 46.0-46.2 calls set_preedit_text(NULL, 1, 1)
                    # for the hidden preedit. It sends a nullable string with
                    # byte offsets (0, 1), so normalize this exact empty range
                    # to (0, 0) and ensure it actually clears the prior text.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        preedit_event(b"", 0, 1)
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    expect_state(
                        b"", 0, "legacy Mutter null preedit reset",
                        expected_rectangle=(16, 92, 1, 12),
                    )
                    release_frame("legacy Mutter null preedit redraw")
                    if (
                        child_u32("text_input_preedit_length") != 0
                        or child_u32("text_input_preedit_cursor_begin") != 0
                        or child_u32("text_input_preedit_cursor_end") != 0
                    ):
                        raise AssertionError(
                            "legacy Mutter null-preedit anchor did not clear the active composition"
                        )

                    # An empty preedit with hidden cursor clears the previous composition.
                    empty_preedit = bytes((0,))
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        preedit_event(empty_preedit, -1, -1)
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    expect_state(b"", 0, "empty preedit reset")
                    release_frame("empty preedit reset redraw")
                    if child_u32("text_input_preedit_length") != 0:
                        raise AssertionError("empty preedit did not clear the active composition")

                    # Commit a multibyte UTF-8 string and verify the updated
                    # surrounding text and cursor are transmitted exactly once.
                    committed = "你好".encode("utf-8")
                    commit = committed + b"\0"
                    commit_payload = (
                        struct.pack("<I", len(commit)) + commit
                        + (b"\0" * (-len(commit) % 4))
                    )
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        wire_message(18, 3, commit_payload)
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    expect_state(committed, 6, "committed UTF-8 text")
                    release_frame("committed text redraw")
                    state = read_document_state()
                    if state["doc_contents"][: state["doc_length"]] != committed:
                        raise AssertionError(
                            f"IME commit did not insert exact UTF-8 bytes: {state['doc_contents']!r}"
                        )
                    if child_u32("text_input_preedit_length") != 0:
                        raise AssertionError("commit_string did not clear the previous preedit")

                    # Select the final UTF-8 scalar using Shift+Left, then send
                    # delete_surrounding_text(0, 0). The protocol requires an
                    # existing editor selection to be removed even with no
                    # additional surrounding bytes requested.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 7001, 7001, 42, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 7002, 7002, 105, 1))
                    )
                    expect_state(
                        committed, 3, "selected UTF-8 scalar", 6, expected_cause=1
                    )
                    release_frame("IME selection redraw")
                    if child_u32("doc_selection_active") != 1:
                        raise AssertionError("Shift+Left did not produce the expected active selection")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 7003, 7003, 105, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 7004, 7004, 42, 0))
                    )
                    client.sendall(
                        wire_message(18, 4, struct.pack("<II", 0, 0))
                        + wire_message(18, 5, struct.pack("<I", child_u32("text_input_commit_serial")))
                    )
                    expect_state("你".encode("utf-8"), 3, "selected-text deletion")
                    release_frame("selected-text deletion redraw")
                    state = read_document_state()
                    if state["doc_contents"][: state["doc_length"]] != "你".encode("utf-8"):
                        raise AssertionError(
                            "delete_surrounding_text(0, 0) did not remove the active selection"
                        )

                    # Ask to delete one byte from inside the remaining
                    # three-byte scalar. The client must expand the range to
                    # a UTF-8 boundary instead of leaving a broken sequence.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        wire_message(18, 4, struct.pack("<II", 1, 0))
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    expect_state(b"", 0, "delete-surrounding update")
                    release_frame("delete-surrounding redraw")
                    if child_u32("doc_length") != 0:
                        raise AssertionError("delete_surrounding_text did not remove the requested bytes")

                    # An out-of-range request on an empty document is clamped
                    # to the available bytes and remains a no-op.
                    serial = child_u32("text_input_commit_serial")
                    client.sendall(
                        wire_message(18, 4, struct.pack("<II", 1, 0))
                        + wire_message(18, 5, struct.pack("<I", serial))
                    )
                    release_frame("invalid delete-surrounding redraw")
                    if child_u32("doc_length") != 0:
                        raise AssertionError("out-of-range IME deletion changed the document")

                    client.sendall(wire_message(18, 1, struct.pack("<I", 8)))
                    expect_message(client, (18, 2, b""), "disable text input after leave")
                    expect_message(client, (18, 7, b""), "commit disable state")
                    client.sendall(wire_message(active_buffer["id"], 0))
                    expect_buffer_frame("leave redraw")
                    observations.append(
                        "text-input-v3 enter/enable, surrounding-text state, serial-stable done, preedit staging, multibyte commit, delete-surrounding, disable/leave and redraw verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                def wait_child_u32(name: str, expected: int, label: str, timeout: float = 3.0) -> int:
                    deadline = time.monotonic() + timeout
                    actual = child_u32(name)
                    while actual != expected and time.monotonic() < deadline:
                        time.sleep(0.005)
                        actual = child_u32(name)
                    if actual != expected:
                        raise AssertionError(
                            f"{label}: expected {name}={expected}, got {actual}; "
                            f"frame_callback_stats={frame_callback_stats!r}"
                        )
                    return actual

                def wait_buffer_idle(label: str, timeout: float = 3.0) -> None:
                    # A queued redraw waits for both SHM release and frame done.
                    original_timeout = client.gettimeout()
                    deadline = time.monotonic() + timeout
                    try:
                        while True:
                            if child_u32("buffer_busy") == 0:
                                if child_u32("frame_callback_id") == 0:
                                    return
                                time.sleep(0.005)
                                continue
                            remaining = deadline - time.monotonic()
                            if remaining <= 0:
                                raise AssertionError(
                                    f"{label}: buffer did not become idle; "
                                    f"buffer_busy={child_u32('buffer_busy')}"
                                )
                            client.settimeout(remaining)
                            try:
                                message = recv_wayland_message(client)
                            except socket.timeout:
                                continue
                            if (
                                message[0] == child_u32("cursor_shape_device")
                                and message[1] == 1
                            ):
                                if message[3] or len(message[2]) != 8:
                                    raise AssertionError(
                                        f"{label}: malformed cursor-shape update {message!r}"
                                    )
                                continue
                            while message[0:2] == (11, 0):
                                if len(message[2]) != 24 or message[3]:
                                    raise AssertionError(
                                        f"{label}: malformed queued wl_buffer.create_buffer {message!r}"
                                    )
                                message = recv_wayland_message(client)
                            if (
                                message[0:2] != (8, 1)
                                or len(message[2]) != 12
                                or message[3]
                            ):
                                raise AssertionError(
                                    f"{label}: unexpected queued redraw request {message!r}"
                                )
                            attached_id, attach_x, attach_y = struct.unpack("<III", message[2])
                            if attached_id not in known_buffer_offsets or (attach_x, attach_y) != (0, 0):
                                raise AssertionError(
                                    f"{label}: queued redraw attached an unknown buffer or nonzero origin: "
                                    f"{(attached_id, attach_x, attach_y)!r}"
                                )
                            expect_message(
                                client,
                                (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                                f"{label} queued redraw damage",
                            )
                            expect_message(
                                client, (8, 6, b""), f"{label} queued redraw commit"
                            )
                            client.sendall(buffer_release_message())
                    finally:
                        client.settimeout(original_timeout)

                def key_step(
                    serial: int, code: int, label: str, auto_confirm: bool = True
                ) -> None:
                    # This helper models a tap, not a held key. Queue key-up
                    # with key-down so slow frame acknowledgement cannot let
                    # the 300 ms repeat timer fire an extra editing action.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial, serial, code, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial + 1, serial + 1, code, 0)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    client.sendall(buffer_release_message())
                    # A key release can race a coalesced redraw behind the frame
                    # just committed. Drain that bounded follow-up rather than
                    # polling memory while leaving its wl_surface.frame request
                    # unread on the socket.
                    original_timeout = client.gettimeout()
                    settle_deadline = time.monotonic() + 3.0
                    followup_frames = 0
                    quiet_since = None
                    try:
                        while time.monotonic() < settle_deadline:
                            callback_id = child_u32("frame_callback_id")
                            busy_slots = child_u32("buffer_busy")
                            redraw_pending = child_u32("redraw_pending")
                            # recv_wayland_message sends callback.done as soon as
                            # it reads wl_surface.commit. The child may not have
                            # consumed that event yet, so a nonzero callback ID
                            # with no mock-side pending callback is not a new frame.
                            if callback_id != 0 or busy_slots != 0:
                                quiet_since = None
                                time.sleep(0.002)
                                continue
                            if redraw_pending:
                                quiet_since = None
                                if followup_frames >= 2:
                                    raise AssertionError(
                                        f"{label}: more than two follow-up frames were queued"
                                    )
                                # Let the event-loop branch handling callback.done
                                # enter present_buffer before waiting on the socket.
                                time.sleep(0.002)
                                client.settimeout(max(0.05, settle_deadline - time.monotonic()))
                                try:
                                    expect_buffer_frame(f"{label} queued follow-up redraw")
                                except Exception as error:
                                    raise AssertionError(
                                        f"{label}: queued redraw failed; "
                                        f"callback={child_u32('frame_callback_id')}, "
                                        f"stage={child_u32('present_buffer_stage')}, "
                                        f"busy={child_u32('buffer_busy')}, "
                                        f"redraw={child_u32('redraw_pending')}, "
                                        f"stats={frame_callback_stats!r}"
                                    ) from error
                                client.sendall(buffer_release_message())
                                followup_frames += 1
                                continue
                            if quiet_since is None:
                                quiet_since = time.monotonic()
                            elif time.monotonic() - quiet_since >= 0.025:
                                break
                            time.sleep(0.002)
                        else:
                            raise AssertionError(
                                f"{label}: frame/buffer gates did not settle; "
                                f"callback={child_u32('frame_callback_id')}, "
                                f"busy={child_u32('buffer_busy')}, "
                                f"redraw={child_u32('redraw_pending')}, "
                                f"stats={frame_callback_stats!r}"
                            )
                    finally:
                        client.settimeout(original_timeout)
                    wait_child_u32("repeat_keycode", 0, f"{label} key release")
                    if auto_confirm and child_u32("save_confirm_open") == 1:
                        key_step(
                            serial + 2, 28, label + " — confirm pending save",
                            auto_confirm=False,
                        )

                def workflow_redraw(label: str) -> None:
                    expect_buffer_attach(label, skip_cursor_shape=True)
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")

                def workflow_click(x: int, y: int, serial: int, label: str) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    workflow_redraw(label)
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                        )
                        + buffer_release_message()
                    )
                    if child_u32("save_confirm_open") == 1:
                        key_step(serial + 5, 28, label + " — confirm pending save")

                def workflow_settings_click(design_x: int, design_y: int, serial: int, label: str) -> None:
                    panel_x = child_u32("settings_panel_x")
                    panel_y = child_u32("settings_panel_y")
                    panel_width = child_u32("settings_panel_width")
                    panel_height = child_u32("settings_panel_height")
                    surface_x = panel_x + (design_x - 160) * panel_width // 256
                    surface_y = panel_y + (design_y - 32) * panel_height // 192
                    workflow_click(surface_x, surface_y, serial, label)

                def workflow_axis(axis: int, value: int, serial: int, label: str) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 4, struct.pack("<IIi", serial, axis, value))
                    )
                    workflow_redraw(label)
                    client.sendall(buffer_release_message())

                def workflow_horizontal_scrollbar_drag(
                    start_x: int, start_y: int, end_x: int, end_y: int,
                    serial: int, label: str
                ) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1))
                    )
                    workflow_redraw(f"{label}: press")
                    client.sendall(buffer_release_message())
                    if child_u32("doc_hscroll_drag") != 1:
                        raise AssertionError(f"{label}: bottom thumb did not enter drag state")
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256))
                    )
                    workflow_redraw(f"{label}: drag")
                    client.sendall(buffer_release_message())
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0))
                    )
                    workflow_redraw(f"{label}: release")
                    client.sendall(buffer_release_message())

                if frame_callback_order_test:
                    wait_buffer_idle("startup idle before frame-order test")
                    baseline_requested = frame_callback_stats["requested"]
                    baseline_completed = frame_callback_stats["completed"]
                    if frame_callback_stats["pending"]:
                        raise AssertionError(
                            f"startup left frame callbacks pending: {frame_callback_stats!r}"
                        )
                    frame_callback_stats["defer"] = True
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1400, 1400, 30, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1401, 1401, 30, 0))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)),
                        "first paced frame attach",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "first paced frame damage",
                    )
                    expect_message(client, (8, 6, b""), "first paced frame commit")
                    if len(frame_callback_stats["pending"]) != 1:
                        raise AssertionError(
                            f"first edit did not create exactly one callback: {frame_callback_stats!r}"
                        )
                    callback_id = frame_callback_stats["pending"][0]
                    wait_child_u32("frame_callback_id", callback_id, "first frame callback ID")
                    wait_child_u32("buffer_busy", 1, "first frame buffer ownership")

                    # Deliver release before callback.done, then edit again.
                    # The client must coalesce the edit without submitting early.
                    client.sendall(buffer_release_message())
                    wait_child_u32("buffer_busy", 0, "release before callback")
                    wait_child_u32("frame_callback_id", callback_id, "callback retained after release")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1402, 1402, 48, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1403, 1403, 48, 0))
                    )
                    wait_child_u32("doc_length", 2, "second edit during outstanding callback")
                    wait_child_u32("redraw_pending", 1, "redraw queued behind callback")
                    if child_u32("frame_callback_id") != callback_id:
                        raise AssertionError("second edit replaced the outstanding frame callback")
                    readable, _, _ = select.select([client], [], [], 0.05)
                    if readable:
                        unexpected = recv_wayland_message(client)
                        raise AssertionError(
                            "surface request was sent before wl_callback.done: "
                            f"{unexpected!r}"
                        )

                    frame_callback_stats["defer"] = False
                    frame_callback_stats["pending"].remove(callback_id)
                    frame_callback_stats["completed"] += 1
                    client.sendall(wire_message(callback_id, 0, struct.pack("<I", 1)))
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)),
                        "coalesced frame attach after callback",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "coalesced frame damage after callback",
                    )
                    expect_message(client, (8, 6, b""), "coalesced frame commit after callback")
                    if len(frame_callback_stats["ids"]) != baseline_requested + 2:
                        raise AssertionError(
                            f"coalesced redraw did not request one follow-up callback: {frame_callback_stats!r}"
                        )
                    second_callback_id = frame_callback_stats["ids"][baseline_requested + 1]
                    if second_callback_id == callback_id:
                        raise AssertionError("frame callback object ID was reused")
                    client.sendall(buffer_release_message())
                    wait_child_u32("frame_callback_id", 0, "follow-up frame callback")
                    wait_child_u32("buffer_busy", 0, "follow-up buffer release")
                    wait_child_u32("redraw_pending", 0, "coalesced redraw consumed")
                    if (
                        frame_callback_stats["requested"] != baseline_requested + 2
                        or frame_callback_stats["completed"] != baseline_completed + 2
                        or frame_callback_stats["pending"]
                    ):
                        raise AssertionError(
                            f"frame callback lifecycle was inconsistent: {frame_callback_stats!r}"
                        )
                    observations.append("release-before-frame-done ordering and redraw coalescing verified")
                    client.sendall(wire_message(10, 1))
                    return

                if buffer_pool_test:
                    wait_buffer_idle("startup idle before two-slot buffer test")
                    baseline_requested = frame_callback_stats["requested"]
                    baseline_completed = frame_callback_stats["completed"]
                    if frame_callback_stats["pending"]:
                        raise AssertionError(
                            f"startup left frame callbacks pending: {frame_callback_stats!r}"
                        )
                    if child_u32("window_buffer_slot_ids") != client_buffer_id:
                        raise AssertionError("initial buffer is not registered in slot zero")
                    if child_u32_at("window_buffer_slot_ids", 4) != 0:
                        raise AssertionError("second slot was allocated before it was needed")

                    # Hold the first buffer after its frame callback completes.
                    # A later edit must allocate slot one instead of modifying
                    # storage that the compositor still owns.
                    frame_callback_stats["defer"] = True
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1600, 1600, 30, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1601, 1601, 30, 0))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)),
                        "first slot attach while slot zero is idle",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "first slot damage",
                    )
                    expect_message(client, (8, 6, b""), "first slot commit")
                    first_callback_id = frame_callback_stats["pending"][-1]
                    wait_child_u32("frame_callback_id", first_callback_id, "first pool callback")
                    wait_child_u32("buffer_busy", 1, "first pool slot ownership")
                    frame_callback_stats["pending"].remove(first_callback_id)
                    frame_callback_stats["completed"] += 1
                    client.sendall(wire_message(first_callback_id, 0, struct.pack("<I", 1)))
                    wait_child_u32("frame_callback_id", 0, "first pool callback completion")
                    wait_child_u32("buffer_busy", 1, "first slot remains compositor-owned after frame done")

                    # The callback is complete but slot zero is not released.
                    # The next edit must create an independent second offset.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1602, 1602, 48, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1603, 1603, 48, 0))
                    )
                    create_slot1 = recv_wayland_message(client)
                    if create_slot1[:2] != (11, 0) or len(create_slot1[2]) != 24 or create_slot1[3]:
                        raise AssertionError(f"second slot creation request is malformed: {create_slot1!r}")
                    slot1_id, slot1_offset, slot1_width, slot1_height, slot1_stride, slot1_format = struct.unpack("<6I", create_slot1[2])
                    if (slot1_offset, slot1_width, slot1_height, slot1_stride, slot1_format) != (
                        expected_size, 800, initial_height, 3200, 1
                    ):
                        raise AssertionError(
                            "second slot has incorrect pool offset or geometry: "
                            f"{(slot1_offset, slot1_width, slot1_height, slot1_stride, slot1_format)!r}"
                        )
                    if slot1_id in (0, client_buffer_id):
                        raise AssertionError(f"second slot received a reused object ID: {slot1_id}")
                    expect_message(
                        client, (8, 1, struct.pack("<III", slot1_id, 0, 0)),
                        "second slot attach while slot zero is still busy",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "second slot damage",
                    )
                    expect_message(client, (8, 6, b""), "second slot commit")
                    second_callback_id = frame_callback_stats["pending"][-1]
                    wait_child_u32("frame_callback_id", second_callback_id, "second pool callback")
                    wait_child_u32("buffer_busy", 2, "both pool slots owned")
                    if child_u32_at("window_buffer_slot_ids", 4) != slot1_id:
                        raise AssertionError("the second slot object ID was not retained")
                    if (
                        child_u32_at("window_buffer_slot_busy", 0) != 1
                        or child_u32_at("window_buffer_slot_busy", 4) != 1
                    ):
                        raise AssertionError("both independently attached slots must be marked busy")
                    if struct.unpack_from("<I", pixels, expected_size)[0] != 0xFF78A9D4:
                        raise AssertionError("second-slot rendering did not use its own SHM offset")

                    # A preferred-scale change starts a new buffer generation.
                    # Neither old slot may be destroyed/reused until both
                    # release, even when frame.done arrives between them.
                    client.sendall(wire_message(8, 2, struct.pack("<I", 2)))
                    wait_child_u32("window_buffer_scale", 2, "preferred 2x scale event")
                    wait_child_u32("window_resize_pending", 1, "2x generation waits for releases")
                    client.sendall(wire_message(client_buffer_id, 0))
                    wait_child_u32("buffer_busy", 1, "first release leaves slot one owned")
                    wait_child_u32("window_buffer_slot_busy", 0, "slot zero release state")
                    if child_u32_at("window_buffer_slot_busy", 4) != 1:
                        raise AssertionError("slot one release state changed before its release event")
                    readable, _, _ = select.select([client], [], [], 0.05)
                    if readable:
                        unexpected = recv_wayland_message(client)
                        raise AssertionError(
                            "old generation was replaced before every buffer release: "
                            f"{unexpected!r}"
                        )

                    frame_callback_stats["pending"].remove(second_callback_id)
                    frame_callback_stats["completed"] += 1
                    client.sendall(wire_message(second_callback_id, 0, struct.pack("<I", 2)))
                    wait_child_u32("frame_callback_id", 0, "second pool callback completion")
                    wait_child_u32("buffer_busy", 1, "scale replacement remains gated by slot one")
                    if child_u32("window_resize_pending") != 1:
                        raise AssertionError("frame.done incorrectly cleared the pending buffer generation")
                    readable, _, _ = select.select([client], [], [], 0.05)
                    if readable:
                        unexpected = recv_wayland_message(client)
                        raise AssertionError(
                            "frame completion incorrectly substituted for wl_buffer.release: "
                            f"{unexpected!r}"
                        )

                    frame_callback_stats["defer"] = False
                    client.sendall(wire_message(slot1_id, 0))
                    expect_message(client, (client_buffer_id, 0, b""), "destroy released slot zero")
                    expect_message(client, (slot1_id, 0, b""), "destroy released slot one")
                    create_scaled = recv_wayland_message(client)
                    if create_scaled[:2] != (11, 0) or len(create_scaled[2]) != 24 or create_scaled[3]:
                        raise AssertionError(f"scaled buffer creation request is malformed: {create_scaled!r}")
                    scaled_id, scaled_offset, scaled_width, scaled_height, scaled_stride, scaled_format = struct.unpack("<6I", create_scaled[2])
                    if (scaled_offset, scaled_width, scaled_height, scaled_stride, scaled_format) != (0, 1600, 960, 6400, 1):
                        raise AssertionError(
                            "new generation buffer has incorrect offset or geometry: "
                            f"{(scaled_offset, scaled_width, scaled_height, scaled_stride, scaled_format)!r}"
                        )
                    if scaled_id in (0, client_buffer_id, slot1_id):
                        raise AssertionError(f"new generation reused a live buffer object ID: {scaled_id}")
                    expect_message(
                        client, (8, 8, struct.pack("<i", 2)), "apply new generation surface scale"
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", scaled_id, 0, 0)),
                        "attach new generation slot zero",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                        "damage new generation in logical coordinates",
                    )
                    expect_message(client, (8, 6, b""), "commit new 2x generation")
                    wait_child_u32("window_buffer_id", scaled_id, "new generation buffer ID")
                    wait_child_u32("window_buffer_created_scale", 2, "new generation scale")
                    wait_child_u32("buffer_busy", 1, "new generation slot ownership")
                    wait_child_u32("frame_callback_id", 0, "new generation callback completion")
                    client.sendall(wire_message(scaled_id, 0))
                    wait_child_u32("buffer_busy", 0, "new generation release")
                    if child_u32_at("window_buffer_slot_ids", 4) != 0:
                        raise AssertionError("the retired second slot survived the generation swap")
                    if (
                        child_u32_at("window_buffer_slot_busy", 0) != 0
                        or child_u32_at("window_buffer_slot_busy", 4) != 0
                    ):
                        raise AssertionError("new generation slot ownership did not return to idle")
                    wait_child_u32("redraw_pending", 0, "no stale redraw after generation swap")
                    if (
                        frame_callback_stats["requested"] != baseline_requested + 3
                        or frame_callback_stats["completed"] != baseline_completed + 3
                        or frame_callback_stats["pending"]
                    ):
                        raise AssertionError(
                            f"two-slot frame callback accounting is inconsistent: {frame_callback_stats!r}"
                        )
                    observations.append(
                        "lazy two-slot SHM allocation, independent release tracking, separate frame pacing, "
                        "and all-slot scale-generation replacement verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if horizontal_scroll_test:
                    state = read_document_state()
                    if state["doc_wrap_enabled"] != 1 or state["doc_line_index_records"][0][1] <= 1:
                        raise AssertionError(
                            f"long-line fixture should start with soft wrapping enabled: {state!r}"
                        )
                    workflow_click(200, 20, 3100, "open Settings for wrap toggle")
                    if read_document_state()["settings_menu_open"] != 1:
                        raise AssertionError("Settings did not open for the wrap-lines test")
                    workflow_settings_click(200, 124, 3110, "disable Wrap Lines")
                    state = read_document_state()
                    if (
                        state["doc_wrap_enabled"] != 0
                        or state["doc_line_index_records"][0][1] != 1
                        or state["doc_total_visual_rows"] != 1
                        or state["doc_scroll_thumb_height"] != 0
                        or state["settings_menu_open"] != 1
                    ):
                        raise AssertionError(
                            f"disabling Wrap Lines did not produce one horizontally scrollable row: {state!r}"
                        )
                    key_step(3120, 107, "End moves to the end of the unwrapped line")
                    state = read_document_state()
                    if state["doc_cursor"] != 200 or state["doc_view_left_px"] <= 0:
                        raise AssertionError(
                            f"caret did not horizontally follow End on a long line: {state!r}"
                        )
                    before_left = state["doc_view_left_px"]
                    workflow_axis(1, -14 * 256, 3130, "horizontal wheel scrolls left")
                    state = read_document_state()
                    if state["doc_view_left_px"] != max(0, before_left - 14):
                        raise AssertionError(
                            f"horizontal wheel did not move the no-wrap viewport left by 14px: "
                            f"before={before_left}, after={state['doc_view_left_px']}"
                        )
                    thumb_width = child_u32("doc_hscroll_thumb_width")
                    thumb_left = child_u32("doc_hscroll_thumb_left")
                    if thumb_width <= 0:
                        raise AssertionError("bottom horizontal thumb is missing despite document overflow")
                    rail_y = child_u32("window_doc_bottom") + 7
                    drag_start_x = thumb_left + max(1, thumb_width // 2)
                    drag_end_x = 48 + child_u32("window_doc_pixel_width") - 2
                    workflow_horizontal_scrollbar_drag(
                        drag_start_x, rail_y, drag_end_x, rail_y,
                        3135, "drag bottom horizontal scrollbar to the right"
                    )
                    dragged_state = read_document_state()
                    if dragged_state["doc_view_left_px"] <= state["doc_view_left_px"]:
                        raise AssertionError(
                            "dragging bottom scrollbar did not advance the document viewport: "
                            f"before={state['doc_view_left_px']}, after={dragged_state['doc_view_left_px']}"
                        )
                    before_shift_wheel = dragged_state["doc_view_left_px"]
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 3141, 3141, 42, 1))
                    )
                    workflow_axis(0, -14 * 256, 3142, "Shift+vertical wheel scrolls horizontally")
                    after_shift_wheel = read_document_state()["doc_view_left_px"]
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 3144, 3144, 42, 0))
                        + buffer_release_message()
                    )
                    if after_shift_wheel != max(0, before_shift_wheel - 14):
                        raise AssertionError(
                            "Shift+vertical wheel did not scroll the no-wrap viewport left by 14px: "
                            f"before={before_shift_wheel}, after={after_shift_wheel}"
                        )
                    state = read_document_state()
                    if state["settings_menu_open"] != 1:
                        raise AssertionError(
                            "Settings unexpectedly closed during horizontal scrolling: " + repr(state)
                        )
                    workflow_click(200, 20, 3145, "close Settings before document pointer hit-testing")
                    if read_document_state()["settings_menu_open"] != 0:
                        raise AssertionError("clicking Settings did not close the menu before document pointer hit-testing")
                    workflow_click(58, 98, 3150, "pointer hit-testing with horizontal offset")
                    state = read_document_state()
                    if not (50 <= state["doc_cursor"] <= 150):
                        raise AssertionError(
                            f"pointer hit-testing ignored the horizontal viewport offset: {state!r}"
                        )
                    workflow_click(200, 20, 3160, "open Settings after horizontal hit-testing")
                    if read_document_state()["settings_menu_open"] != 1:
                        raise AssertionError("Settings did not open after document hit-testing")
                    workflow_settings_click(200, 124, 3170, "re-enable Wrap Lines")
                    state = read_document_state()
                    if (
                        state["doc_wrap_enabled"] != 1
                        or state["doc_line_index_records"][0][1] <= 1
                        or state["doc_view_left_px"] != 0
                        or state["settings_menu_open"] != 1
                    ):
                        raise AssertionError(
                            f"re-enabling Wrap Lines did not restore wrapping and reset horizontal scroll: {state!r}"
                        )
                    key_step(3180, 1, "close Settings after wrap test")
                    observations.append(
                        "Wrap Lines toggle, unwrapped line indexing, caret-following scroll, horizontal wheel, bottom thumb drag, Shift+wheel and offset pointer hit-testing verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                cursor_feedback_state = {"shape": 1, "enter_serial": 777}

                def workflow_window_click(
                    x: int, serial: int, request_opcode: int, label: str,
                    y: int = 20, request_payload: bytes = b"",
                    cursor_shape: int = 1,
                ) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                    )
                    if cursor_shape_supported and cursor_shape != cursor_feedback_state["shape"]:
                        expect_message(
                            client, (18, 1, struct.pack("<II", cursor_feedback_state["enter_serial"], cursor_shape)),
                            f"{label}: resize cursor shape",
                        )
                        cursor_feedback_state["shape"] = cursor_shape
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (10, request_opcode, request_payload),
                        f"{label}: xdg_toplevel request"
                    )
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                        )
                    )
                    # A real xdg_toplevel.resize may remove pointer focus and later
                    # re-enter the resized surface with a fresh enter serial.
                    if request_opcode in (5, 6):
                        enter_serial = serial + 6
                        client.sendall(
                            wire_message(pointer_object_id, 1, struct.pack("<II", serial + 5, 8))
                            + wire_message(pointer_object_id, 0,
                                struct.pack("<IIii", enter_serial, 8, x * 256, y * 256),
                            )
                        )
                        if cursor_shape_supported:
                            expect_message(
                                client, (18, 1, struct.pack("<II", enter_serial, cursor_shape)),
                                f"{label}: cursor shape after resize focus returns",
                            )
                        cursor_feedback_state["enter_serial"] = enter_serial
                        cursor_feedback_state["shape"] = cursor_shape

                def workflow_scrollbar_drag(
                    start_x: int, start_y: int, end_x: int, end_y: int,
                    serial: int, label: str
                ) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1))
                    )
                    workflow_redraw(f"{label}: press")
                    client.sendall(buffer_release_message())
                    press_state = picker_state()
                    if press_state.get("picker_scroll_drag") != 1:
                        raise AssertionError(
                            f"{label}: scrollbar press did not start a drag; state={press_state!r}"
                        )
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256))
                    )
                    try:
                        workflow_redraw(f"{label}: drag")
                    except Exception as error:
                        raise AssertionError(
                            f"{label}: pointer motion did not redraw; state={picker_state()!r}"
                        ) from error
                    # Release the frame drawn after motion before requesting the
                    # second redraw caused by releasing the scrollbar grab.
                    client.sendall(buffer_release_message())
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0))
                    )
                    workflow_redraw(f"{label}: release")
                    client.sendall(buffer_release_message())

                def workflow_editor_scrollbar_drag(
                    start_x: int, start_y: int, end_x: int, end_y: int,
                    serial: int, label: str
                ) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1))
                    )
                    workflow_redraw(f"{label}: press")
                    client.sendall(buffer_release_message())
                    press_state = picker_state()
                    if press_state.get("doc_scroll_drag") != 1:
                        raise AssertionError(
                            f"{label}: editor scrollbar press did not start a drag; state={press_state!r}"
                        )
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256))
                    )
                    try:
                        workflow_redraw(f"{label}: drag")
                    except Exception as error:
                        raise AssertionError(
                            f"{label}: editor scrollbar motion did not redraw; state={picker_state()!r}"
                        ) from error
                    client.sendall(buffer_release_message())
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0))
                    )
                    workflow_redraw(f"{label}: release")
                    client.sendall(buffer_release_message())

                def workflow_shortcut(serial: int, code: int, label: str, shift: bool = False) -> None:
                    events = wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial, serial, 29, 1))
                    if shift:
                        events += wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial + 1, serial + 1, 42, 1)
                        )
                    modifier_state = 4 | (1 if shift else 0)
                    events += wire_message(keyboard_object_id, 4,
                        struct.pack("<IIIII", serial + 20, modifier_state, 0, 0, 0)
                    )
                    events += wire_message(keyboard_object_id, 3,
                        struct.pack("<IIII", serial + (2 if shift else 1),
                                    serial + (2 if shift else 1), code, 1)
                    )
                    client.sendall(events)
                    workflow_redraw(label)
                    releases = wire_message(keyboard_object_id, 3,
                        struct.pack("<IIII", serial + 3, serial + 3, code, 0)
                    )
                    if shift:
                        releases += wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial + 4, serial + 4, 42, 0)
                        )
                    releases += wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial + 5, serial + 5, 29, 0)
                    )
                    releases += wire_message(keyboard_object_id, 4,
                        struct.pack("<IIIII", serial + 21, 0, 0, 0, 0)
                    )
                    client.sendall(releases + buffer_release_message())
                    if child_u32("save_confirm_open") == 1:
                        key_step(serial + 6, 28, label + " — confirm pending save")
                if find_replace_test:
                    initial = read_document_state()
                    if initial["doc_contents"] != b"one fish two fish":
                        raise AssertionError("find/replace fixture contents mismatch")
                    workflow_shortcut(1860, 102, "Ctrl+Home establishes search fixture start")
                    workflow_shortcut(1870, 33, "Ctrl+F opens Find")
                    if child_u32("find_replace_mode") != 1:
                        raise AssertionError("Ctrl+F did not open Find mode")
                    for index, code in enumerate((33, 23, 31, 35)):
                        key_step(1880 + index * 3, code, f"enter Find query character {index + 1}")
                    key_step(1900, 28, "Enter selects first Find match")
                    start = min(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    end = max(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    if (start, end) != (4, 8) or child_u32("find_status") != 1:
                        raise AssertionError(
                            f"Find did not select the first fish: range=({start},{end}), "
                            f"status={child_u32('find_status')}"
                        )
                    # The selected result stays blue; every other literal
                    # occurrence must also receive the amber search highlight.
                    highlight_color = 0xFF8F7834
                    other_match_pixels = sum(
                        1
                        for y in range(90, 116)
                        for x in range(85, 260)
                        if struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0] == highlight_color
                    )
                    if other_match_pixels < 4:
                        raise AssertionError(
                            "Find selected the first match but did not paint the other occurrence: "
                            f"visible amber pixels={other_match_pixels}"
                        )
                    key_step(1910, 61, "F3 selects the next Find match")
                    start = min(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    end = max(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    if (start, end) != (13, 17):
                        raise AssertionError(f"F3 did not select the next fish: range=({start},{end})")
                    key_step(1915, 1, "Escape closes Find before opening Replace")
                    workflow_shortcut(1920, 35, "Ctrl+H opens Find/Replace")
                    if child_u32("find_replace_mode") != 2:
                        raise AssertionError("Ctrl+H did not open Find/Replace mode")
                    key_step(1930, 15, "Tab focuses replacement field")
                    for index, code in enumerate((31, 35, 30, 19, 37)):
                        key_step(1940 + index * 3, code, f"enter replacement character {index + 1}")
                    workflow_shortcut(1960, 28, "Ctrl+Enter replaces the current match")
                    state = read_document_state()
                    if state["doc_contents"] != b"one fish two shark":
                        raise AssertionError(
                            f"Replace Current produced unexpected bytes: {state['doc_contents']!r}"
                        )
                    if child_u32("find_status") != 3:
                        raise AssertionError("Replace Current did not report a replacement")
                    panel_x = child_u32("find_panel_x")
                    panel_y = child_u32("find_panel_y")
                    panel_width = child_u32("find_panel_width")
                    panel_height = child_u32("find_panel_height")
                    all_x = panel_x + 316 * panel_width // 448
                    all_y = panel_y + 164 * panel_height // 192
                    workflow_click(all_x, all_y, 1990, "Replace All replaces remaining matches")
                    state = read_document_state()
                    if state["doc_contents"] != b"one shark two shark":
                        raise AssertionError(
                            f"Replace All produced unexpected bytes: {state['doc_contents']!r}"
                        )
                    if child_u32("find_replace_count") != 1 or child_u32("find_status") != 4:
                        raise AssertionError(
                            "Replace All did not report one replacement: "
                            f"count={child_u32('find_replace_count')}, status={child_u32('find_status')}"
                        )
                    key_step(2010, 1, "Escape closes Find/Replace")
                    if child_u32("find_replace_mode") != 0:
                        raise AssertionError("Escape did not close Find/Replace")
                    observations.append(
                        "Ctrl+F/Find query editing, Enter/F3 navigation, Ctrl+H replacement editing, "
                        "Replace Current, Replace All, and Escape verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if line_navigation_test:
                    initial = read_document_state()
                    if initial["doc_contents"] != b"first\nsecond\nthird":
                        raise AssertionError("line navigation fixture contents mismatch")
                    workflow_shortcut(2020, 102, "Ctrl+Home establishes paragraph-navigation start")
                    workflow_shortcut(2030, 108, "Ctrl+Down moves to the second logical line")
                    if child_u32("doc_cursor") != 6:
                        raise AssertionError(f"Ctrl+Down did not move to byte 6: {child_u32('doc_cursor')}")
                    workflow_shortcut(2040, 108, "Ctrl+Down moves to the third logical line")
                    if child_u32("doc_cursor") != 13:
                        raise AssertionError(f"second Ctrl+Down did not move to byte 13: {child_u32('doc_cursor')}")
                    workflow_shortcut(2050, 103, "Ctrl+Up moves to the previous logical line")
                    if child_u32("doc_cursor") != 6:
                        raise AssertionError(f"Ctrl+Up did not return to byte 6: {child_u32('doc_cursor')}")
                    workflow_shortcut(2060, 103, "Ctrl+Shift+Up selects the previous logical line", shift=True)
                    if (
                        child_u32("doc_cursor") != 0
                        or child_u32("doc_selection_anchor") != 6
                        or child_u32("doc_selection_active") != 1
                    ):
                        raise AssertionError(
                            "Ctrl+Shift+Up did not select the previous logical line: "
                            f"anchor={child_u32('doc_selection_anchor')}, cursor={child_u32('doc_cursor')}, "
                            f"active={child_u32('doc_selection_active')}"
                        )
                    workflow_shortcut(2070, 107, "Ctrl+End moves to document end")
                    if child_u32("doc_cursor") != 18 or child_u32("doc_selection_active") != 0:
                        raise AssertionError("Ctrl+End failed after paragraph selection")
                    workflow_shortcut(2080, 103, "Ctrl+Up returns to the second line")
                    if child_u32("doc_cursor") != 6:
                        raise AssertionError("Ctrl+Up did not return to the second line from the end")
                    workflow_shortcut(2090, 103, "Ctrl+Up returns to the first line")
                    if child_u32("doc_cursor") != 0:
                        raise AssertionError("Ctrl+Up did not return to the document start")
                    workflow_shortcut(2100, 108, "Ctrl+Shift+Down selects the next logical line", shift=True)
                    if (
                        child_u32("doc_cursor") != 6
                        or child_u32("doc_selection_anchor") != 0
                        or child_u32("doc_selection_active") != 1
                    ):
                        raise AssertionError("Ctrl+Shift+Down did not extend selection to the next line")
                    observations.append(
                        "Ctrl+Up/Down logical-line navigation and Shift-extended paragraph selection verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if pointer_drag_test:
                    # A very long first line exercises no-wrap horizontal edge
                    # scrolling; following lines provide a vertical scroll range.
                    contents = (b"x" * 1800) + b"\n" + (b"line\n" * 120)
                    initial = read_document_state()
                    if initial["doc_contents"] != contents:
                        raise AssertionError("pointer drag fixture contents mismatch")

                    # A single-click selection is allowed to leave the surface.
                    # Simulate pointer_leave during the implicit grab, followed
                    # by motion below the bottom edge of the window.
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 3002, 20 * 256, 98 * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", 3003, 3004, 0x110, 1))
                    )
                    workflow_redraw("begin selection before leaving the window")
                    client.sendall(buffer_release_message())
                    if child_u32("pointer_button_down") != 1:
                        raise AssertionError("document press did not begin a selection drag")
                    client.sendall(
                        wire_message(pointer_object_id, 1, struct.pack("<II", 3005, 8))
                        + wire_message(pointer_object_id, 2, struct.pack("<Iii", 3006, 40 * 256, 520 * 256))
                    )
                    workflow_redraw("drag below the bottom edge while pointer focus is outside")
                    immediate_top = child_u32("doc_view_top_row")
                    if immediate_top <= 0 or child_u32("doc_selection_active") != 1:
                        raise AssertionError(
                            "dragging beyond the bottom edge did not scroll and extend selection: "
                            f"top={immediate_top}, cursor={child_u32('doc_cursor')}, "
                            f"active={child_u32('doc_selection_active')}"
                        )
                    # Free the just-presented buffer, then leave the pointer
                    # stationary outside. The independent drag timer must keep
                    # advancing the viewport until button release.
                    client.sendall(buffer_release_message())
                    time.sleep(0.25)
                    continued_top = child_u32("doc_view_top_row")
                    if continued_top <= immediate_top:
                        raise AssertionError(
                            "edge auto-scroll stopped when the pointer became stationary: "
                            f"initial={immediate_top}, after_timer={continued_top}"
                        )
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", 3010, 3011, 0x110, 0))
                        + buffer_release_message()
                    )
                    wait_child_u32(
                        "pointer_button_down", 0, "selection release must clear drag state"
                    )
                    # The timer's last coalesced frame is delivered after the
                    # released buffer is returned. Drain it before interacting
                    # with Settings so the test never confuses two commits.
                    ready, _, _ = select.select([client], [], [], 0.2)
                    if ready:
                        workflow_redraw("flush final auto-scroll frame")
                        client.sendall(buffer_release_message())

                    # Return pointer focus, turn wrapping off, then drag past the
                    # right edge. The horizontal viewport must follow the drag.
                    client.sendall(
                        wire_message(pointer_object_id, 0, struct.pack("<Iiii", 3020, 8, 20 * 256, 16 * 256))
                    )
                    workflow_click(200, 16, 3030, "open Settings before horizontal drag test")
                    workflow_settings_click(200, 124, 3040, "disable Wrap Lines before horizontal drag")
                    if child_u32("doc_wrap_enabled") != 0:
                        raise AssertionError("Settings did not disable Wrap Lines for horizontal drag test")
                    # Settings intentionally stays open after toggling. The
                    # first click outside its panel closes it; a second press
                    # can then begin a real document selection drag.
                    workflow_click(20, 98, 3980, "close persistent Settings before document drag")

                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 4002, 20 * 256, 98 * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", 4003, 4004, 0x110, 1))
                    )
                    workflow_redraw("begin horizontal selection drag")
                    client.sendall(buffer_release_message())
                    client.sendall(
                        wire_message(pointer_object_id, 1, struct.pack("<II", 4005, 8))
                        + wire_message(pointer_object_id, 2, struct.pack("<Iii", 4006, 900 * 256, 98 * 256))
                    )
                    workflow_redraw("drag beyond the right edge with Wrap Lines disabled")
                    horizontal_left = child_u32("doc_view_left_px")
                    if horizontal_left <= 0 or child_u32("doc_selection_active") != 1:
                        raise AssertionError(
                            "no-wrap selection did not horizontally auto-scroll beyond the right edge: "
                            f"left={horizontal_left}, active={child_u32('doc_selection_active')}"
                        )
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", 3060, 3061, 0x110, 0))
                        + buffer_release_message()
                        + wire_message(10, 1)
                    )
                    observations.append(
                        "selection auto-scroll follows pointer_leave and stationary edge holds; horizontal dragging scrolls with Wrap Lines disabled"
                    )
                    return

                if word_navigation_test:
                    initial = read_document_state()
                    if initial["doc_contents"] != b"one two three":
                        raise AssertionError("word navigation fixture contents mismatch")
                    workflow_shortcut(1690, 102, "Ctrl+Home establishes a known starting caret")
                    if child_u32("doc_cursor") != 0:
                        raise AssertionError("Ctrl+Home did not establish the beginning of the word fixture")
                    workflow_shortcut(1700, 106, "Ctrl+Right moves to the next word start")
                    if child_u32("doc_cursor") != 4:
                        raise AssertionError(f"Ctrl+Right did not stop at second word: {child_u32('doc_cursor')}")
                    workflow_shortcut(1710, 106, "Ctrl+Right skips the current word and separator")
                    if child_u32("doc_cursor") != 8:
                        raise AssertionError(f"second Ctrl+Right did not stop at third word: {child_u32('doc_cursor')}")
                    workflow_shortcut(1720, 105, "Ctrl+Shift+Left selects the previous word", shift=True)
                    if (
                        child_u32("doc_selection_active") != 1
                        or child_u32("doc_selection_anchor") != 8
                        or child_u32("doc_cursor") != 4
                    ):
                        raise AssertionError(
                            "Ctrl+Shift+Left did not select the prior word: "
                            f"anchor={child_u32('doc_selection_anchor')}, cursor={child_u32('doc_cursor')}, "
                            f"active={child_u32('doc_selection_active')}"
                        )
                    workflow_shortcut(1730, 102, "Ctrl+Home returns to document start")
                    if child_u32("doc_cursor") != 0 or child_u32("doc_selection_active") != 0:
                        raise AssertionError("Ctrl+Home did not move to document start and clear selection")
                    workflow_shortcut(1740, 107, "Ctrl+End moves to document end")
                    if child_u32("doc_cursor") != len(b"one two three"):
                        raise AssertionError("Ctrl+End did not move to document end")
                    workflow_click(58, 98, 1800, "first click before double-click word selection")
                    workflow_click(58, 98, 1810, "double-click selects the word under the pointer")
                    start = min(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    end = max(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    if child_u32("doc_selection_active") != 1 or (start, end) != (4, 7):
                        raise AssertionError(
                            "double-click did not select the full second word: "
                            f"range=({start},{end}), active={child_u32('doc_selection_active')}"
                        )

                    # Begin another double-click but keep its second press held.
                    # Dragging that active word selection must extend by whole
                    # words, rather than dropping back to character selection.
                    workflow_click(58, 98, 1820, "word-drag first click")
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 1832, 58 * 256, 98 * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", 1833, 1834, 0x110, 1))
                    )
                    workflow_redraw("word-drag double-click press")
                    client.sendall(buffer_release_message())
                    if child_u32("pointer_button_down") != 1 or child_u32("doc_word_drag_active") != 1:
                        raise AssertionError("double-click did not retain the pointer grab for word dragging")
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 1840, 100 * 256, 98 * 256))
                    )
                    workflow_redraw("extend word selection through the third word")
                    start = min(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    end = max(child_u32("doc_selection_anchor"), child_u32("doc_cursor"))
                    if (start, end) != (4, 13):
                        raise AssertionError(
                            f"dragging a double-click selection did not extend by whole words: ({start},{end})"
                        )
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", 1843, 1844, 0x110, 0))
                        + buffer_release_message()
                    )
                    wait_child_u32("pointer_button_down", 0, "word-drag release")
                    wait_child_u32("doc_word_drag_active", 0, "word-drag mode release")

                    # Repeat in reverse: start on the final word and drag to the
                    # first word; the fixed edge remains the original word end.
                    workflow_click(100, 98, 1850, "reverse word-drag first click")
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 1862, 100 * 256, 98 * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", 1863, 1864, 0x110, 1))
                    )
                    workflow_redraw("reverse word-drag double-click press")
                    client.sendall(buffer_release_message())
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", 1870, 20 * 256, 98 * 256))
                    )
                    workflow_redraw("extend word selection backwards to the first word")
                    if child_u32("doc_selection_anchor") != 13 or child_u32("doc_cursor") != 0:
                        raise AssertionError(
                            "reverse word dragging did not retain the original right edge: "
                            f"anchor={child_u32('doc_selection_anchor')}, cursor={child_u32('doc_cursor')}"
                        )
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", 1873, 1874, 0x110, 0))
                        + buffer_release_message()
                    )
                    wait_child_u32("pointer_button_down", 0, "reverse word-drag release")
                    observations.append(
                        "Ctrl word navigation, double-click word selection, and forward/reverse whole-word drag selection verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                evdev = {
                    "a": 30, "b": 48, "c": 46, "d": 32, "e": 18, "f": 33,
                    "g": 34, "h": 35, "i": 23, "j": 36, "k": 37, "l": 38,
                    "m": 50, "n": 49, "o": 24, "p": 25, "q": 16, "r": 19,
                    "s": 31, "t": 20, "u": 22, "v": 47, "w": 17, "x": 45,
                    "y": 21, "z": 44, "0": 11, "1": 2, "2": 3, "3": 4,
                    "4": 5, "5": 6, "6": 7, "7": 8, "8": 9, "9": 10,
                    ".": 52, "/": 53, "-": 12,
                }

                if history_test:
                    initial_history = read_document_state()
                    if initial_history["doc_contents"] != b"abc":
                        raise AssertionError(
                            "history test did not start with b'abc': "
                            + repr(initial_history["doc_contents"])
                        )
                    workflow_shortcut(2000, 30, "Ctrl+A before replacing selection")
                    key_step(2010, 44, "replace selected text with z")
                    replaced = read_document_state()["doc_contents"]
                    if replaced != b"z":
                        raise AssertionError("typing did not replace the active selection: " + repr(replaced))
                    workflow_shortcut(2020, 44, "Ctrl+Z undo replacement")
                    undone = read_document_state()["doc_contents"]
                    if undone != b"abc":
                        raise AssertionError("Ctrl+Z did not restore the pre-edit document: " + repr(undone))
                    workflow_shortcut(2030, 21, "Ctrl+Y redo replacement")
                    redone = read_document_state()["doc_contents"]
                    if redone != b"z":
                        raise AssertionError("Ctrl+Y did not restore the edited document: " + repr(redone))
                    if child_u32("doc_cursor") != 1 or child_u32("doc_selection_active") != 0:
                        raise AssertionError("redo did not restore the post-edit caret/selection state")
                    workflow_shortcut(2040, 44, "Ctrl+Z before new branch")
                    if read_document_state()["doc_contents"] != b"abc":
                        raise AssertionError("second Ctrl+Z did not restore the original bytes")
                    if child_u32("doc_cursor") != 3:
                        raise AssertionError("undo did not restore the pre-edit caret offset")
                    if child_u32("doc_selection_active") != 1:
                        raise AssertionError("undo did not restore the pre-edit active selection")
                    key_step(2045, 106, "Right Arrow collapses the restored selection")
                    if child_u32("doc_selection_active") != 0:
                        raise AssertionError("Right Arrow did not collapse the restored selection")
                    key_step(2050, 16, "type q after undo to create a new history branch")
                    branch_state = read_document_state()["doc_contents"]
                    if branch_state != b"abcq":
                        raise AssertionError("new edit after undo produced unexpected bytes: " + repr(branch_state))
                    # Redo has been invalidated by the new edit. A no-op shortcut
                    # must not trigger a compositor frame commit.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 2060, 2060, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 2061, 2061, 21, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 2062, 2062, 21, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 2063, 2063, 29, 0))
                    )
                    ready, _, _ = select.select([client], [], [], 0.05)
                    if ready:
                        unexpected = recv_wayland_message(client)
                        raise AssertionError("redo remained available after a new edit: " + repr(unexpected[:3]))
                    client.sendall(buffer_release_message())
                    if read_document_state()["doc_contents"] != b"abcq":
                        raise AssertionError("stale redo changed document contents after a new edit")

                    # Exercise the visible History tab and its controls, not
                    # only the keyboard shortcuts and the lower-level journal.
                    workflow_click(240, 60, 2070, "open the History tab")
                    if child_u32("history_tab_open") != 1:
                        raise AssertionError("clicking the History tab did not switch pages")
                    # workflow_click() has already waited for the tab redraw.
                    if child_u32("history_search_match_count") != 1:
                        raise AssertionError(
                            "History search did not find the one edited source document: "
                            + str(child_u32("history_search_match_count"))
                        )
                    workflow_click(350, 185, 2075, "focus the History search field")
                    if child_u32("history_search_focus") != 1:
                        raise AssertionError("History search field did not receive keyboard focus")
                    if child_u32("history_search_caret_x") != 60:
                        raise AssertionError("focused empty History filter did not show its insertion caret")

                    # The filter accepts the full 127-byte query. Its visible
                    # slice must scroll to keep the caret inside the field.
                    for index in range(127):
                        key_step(2076 + index * 2, 44, "type long non-matching History query")
                    if child_u32("history_search_length") != 127:
                        raise AssertionError("History filter stopped accepting input before its query limit")
                    if child_u32("history_search_match_count") != 0:
                        raise AssertionError("non-matching History query did not filter every result")
                    if child_u32("history_search_display_start") == 0:
                        raise AssertionError("long History query did not horizontally scroll its visible text")
                    caret_x = child_u32("history_search_caret_x")
                    if not 60 < caret_x < 640:
                        raise AssertionError(
                            f"long History query caret escaped the visible search field: x={caret_x}"
                        )
                    workflow_shortcut(2340, 30, "Ctrl+A clears the complete History filter")
                    if (
                        child_u32("history_search_length") != 0
                        or child_u32("history_search_display_start") != 0
                        or child_u32("history_search_caret_x") != 60
                        or child_u32("history_search_match_count") != 1
                    ):
                        raise AssertionError("clearing the History filter did not restore the unfiltered result")

                    # Browse is a separate explicit action; it opens the native
                    # document picker without making the filter field inert.
                    workflow_click(700, 185, 2370, "History Browse opens the document picker")
                    if child_u32("picker_mode") != 1:
                        raise AssertionError("History Browse did not open the Open picker")
                    key_step(2372, 1, "Escape closes the History Browse picker")
                    if child_u32("picker_mode") != 0 or child_u32("history_tab_open") != 1:
                        raise AssertionError("closing the History Browse picker did not return to History")
                    workflow_click(350, 185, 2376, "refocus History search after Browse")
                    history_query_codes = (49, 18, 37, 24, 18, 32, 23, 20,
                                           12, 35, 23, 31, 20, 24, 19, 21)
                    for index, code in enumerate(history_query_codes):
                        key_step(2380 + index * 2, code,
                                 f"History search query character {index + 1}")
                    if child_u32("history_search_match_count") != 1:
                        raise AssertionError("History filter did not match the source document path")
                    workflow_click(100, 345, 2430, "Open Selected button opens the highlighted history")
                    if read_document_state()["doc_contents"] != b"abcq":
                        raise AssertionError("opening a History search result did not restore the edited document")
                    if child_u32("history_tab_open") != 1:
                        raise AssertionError("opening a History search result left the History page")
                    workflow_click(100, 434, 2470, "History page Undo button")
                    if read_document_state()["doc_contents"] != b"abc":
                        raise AssertionError("History page Undo button did not undo the latest edit")
                    workflow_click(300, 434, 2480, "History page Redo button")
                    if read_document_state()["doc_contents"] != b"abcq":
                        raise AssertionError("History page Redo button did not redo the latest edit")

                    # Export must open the existing native Save picker in
                    # history-export mode; Escape safely returns to the page.
                    workflow_click(480, 434, 2490, "History page Export button")
                    if child_u32("picker_mode") != 2 or child_u32("history_export_mode") != 1:
                        raise AssertionError("History Export did not open its Save picker")
                    key_step(2500, 1, "Escape cancels History export")
                    if child_u32("picker_mode") != 0 or child_u32("history_export_mode") != 0:
                        raise AssertionError("cancelling History Export did not close the picker cleanly")

                    # Delete removes only the journal. The document stays
                    # intact; the host-side journal test separately checks
                    # that the deleted journal exposes zero Undo/Redo records.
                    workflow_click(660, 434, 2520, "History page Delete Selected History button")
                    if read_document_state()["doc_contents"] != b"abcq":
                        raise AssertionError("History Delete modified document bytes")
                    if child_u32("history_search_match_count") != 0:
                        raise AssertionError("History Delete did not remove the selected journal from search results")
                    observations.append(
                        "History tab filtering, Browse picker, Open Selected, responsive Undo/Redo/Export/Delete controls, and selected-history removal verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if clipboard_test:
                    original_clipboard = b"copy me\n"
                    initial_state = read_document_state()
                    if initial_state["doc_contents"] != original_clipboard:
                        raise AssertionError(
                            "clipboard test did not start with its original document bytes: "
                            + repr(initial_state["doc_contents"])
                        )

                    def clipboard_string(value: str) -> bytes:
                        encoded = value.encode("ascii") + b"\0"
                        return struct.pack("<I", len(encoded)) + encoded + (b"\0" * (-len(encoded) % 4))

                    def ctrl_event(serial: int, code: int, down: bool) -> bytes:
                        return wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial, serial, code, int(down))
                        )

                    def clipboard_combo(serial: int, code: int, label: str, redraw: bool) -> None:
                        client.sendall(ctrl_event(serial, 29, True) + ctrl_event(serial + 1, code, True))
                        if redraw:
                            workflow_redraw(label)
                        client.sendall(
                            ctrl_event(serial + 3, code, False)
                            + ctrl_event(serial + 4, 29, False)
                        )
                        if redraw:
                            client.sendall(buffer_release_message())

                    def receive_source_bytes(source_id: int, label: str) -> bytes:
                        read_fd, write_fd = os.pipe()
                        try:
                            transfer = wire_message(
                                source_id, 1, clipboard_string("text/plain;charset=utf-8")
                            )
                            client.sendmsg(
                                [transfer],
                                [(socket.SOL_SOCKET, socket.SCM_RIGHTS, struct.pack("i", write_fd))],
                            )
                        finally:
                            os.close(write_fd)
                        received = bytearray()
                        deadline = time.monotonic() + 4
                        try:
                            while time.monotonic() < deadline:
                                readable, _, _ = select.select([read_fd], [], [], max(0, deadline - time.monotonic()))
                                if not readable:
                                    break
                                chunk = os.read(read_fd, 4096)
                                if not chunk:
                                    break
                                received.extend(chunk)
                        finally:
                            os.close(read_fd)
                        result = bytes(received)
                        if result != original_clipboard:
                            raise AssertionError(
                                f"{label}: clipboard source snapshot changed: {result!r}"
                            )
                        return result

                    def expect_source_creation(source_id: int, serial: int, label: str) -> None:
                        expect_message(
                            client, (17, 0, struct.pack("<I", source_id)),
                            f"{label}: create data source",
                        )
                        expect_message(
                            client,
                            (source_id, 0, clipboard_string("text/plain;charset=utf-8")),
                            f"{label}: offer UTF-8 text MIME",
                        )
                        expect_message(
                            client, (source_id, 0, clipboard_string("text/plain")),
                            f"{label}: offer plain text MIME",
                        )
                        expect_message(
                            client, (18, 1, struct.pack("<II", source_id, serial)),
                            f"{label}: set clipboard selection",
                        )

                    def context_right_click(x: int, y: int, serial: int, label: str) -> None:
                        client.sendall(
                            wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                            + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x111, 1)
                            )
                        )
                        workflow_redraw(label)
                        client.sendall(
                            wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x111, 0)
                            ) + buffer_release_message()
                        )
                        if child_u32("context_menu_open") != 1:
                            raise AssertionError(f"{label}: right-click did not open the context menu")
                        if (
                            child_u32("context_menu_x") != x
                            or child_u32("context_menu_y") != y
                        ):
                            raise AssertionError(
                                f"{label}: menu anchor changed unexpectedly: "
                                f"{child_u32('context_menu_x')}, {child_u32('context_menu_y')}"
                            )

                    def context_menu_item(
                        x: int, y: int, serial: int, label: str
                    ) -> int:
                        # wl_data_source is a client-created object: capture
                        # the dense allocator before the menu click. Frame
                        # callbacks use that same protocol object namespace.
                        source_id = child_u32("next_client_object_id")
                        client.sendall(
                            wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                            + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                            )
                        )
                        expect_source_creation(source_id, serial + 1, label)
                        workflow_redraw(label)
                        client.sendall(
                            wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                            ) + buffer_release_message()
                        )
                        if child_u32("context_menu_open") != 0:
                            raise AssertionError(f"{label}: selected menu item did not dismiss the menu")
                        return source_id

                    if context_menu_test:
                        # Escape dismisses without changing document state.
                        context_right_click(220, 120, 2400, "right-click opens context menu")
                        key_step(2410, 1, "Escape dismisses the context menu")
                        if child_u32("context_menu_open") != 0:
                            raise AssertionError("Escape left the context menu open")

                        workflow_shortcut(2430, 30, "Ctrl+A before context-menu Copy")
                        context_right_click(220, 120, 2460, "reopen context menu for Copy")
                        if child_u32("doc_selection_active") != 1:
                            raise AssertionError("opening the context menu discarded the active selection")
                        copy_source_id = context_menu_item(
                            235, 133, 2480, "context-menu Copy"
                        )
                        if read_document_state()["doc_contents"] != original_clipboard:
                            raise AssertionError("context-menu Copy modified document bytes")
                        if child_u32("doc_selection_active") != 1:
                            raise AssertionError("context-menu Copy cleared the selection")
                        receive_source_bytes(copy_source_id, "context-menu Copy")
                        observations.append(
                            "right-click opens a positioned menu, Escape closes it, and Copy preserves selection/document bytes"
                        )

                        # Cut publishes an immutable clipboard snapshot before deletion.
                        context_right_click(220, 120, 2500, "reopen context menu for Cut")
                        cut_source_id = context_menu_item(
                            235, 185, 2520, "context-menu Cut"
                        )
                        client.sendall(wire_message(copy_source_id, 2))
                        expect_message(
                            client, (copy_source_id, 1, b""),
                            "retire copied context-menu source",
                        )
                        cut_state = read_document_state()
                        if cut_state["doc_contents"] != b"":
                            raise AssertionError(
                                "context-menu Cut did not delete the selection: "
                                + repr(cut_state["doc_contents"])
                            )
                        if child_u32("doc_selection_active") != 0:
                            raise AssertionError("context-menu Cut left a stale selection active")
                        receive_source_bytes(cut_source_id, "context-menu Cut after deletion")
                        observations.append(
                            "context-menu Cut publishes an independent clipboard snapshot and deletes the selected bytes"
                        )

                        # A new external owner replaces Cut's source; then Paste receives asynchronously.
                        client.sendall(wire_message(cut_source_id, 2))
                        expect_message(
                            client, (cut_source_id, 1, b""),
                            "retire cut context-menu source",
                        )
                        external_offer = 0xFF000020
                        client.sendall(
                            wire_message(18, 0, struct.pack("<I", external_offer))
                            + wire_message(external_offer, 0, clipboard_string("text/plain;charset=utf-8"))
                            + wire_message(external_offer, 0, clipboard_string("text/plain"))
                            + wire_message(18, 5, struct.pack("<I", external_offer))
                        )
                        context_right_click(220, 120, 2550, "open context menu for Paste")
                        client.sendall(
                            wire_message(pointer_object_id, 2, struct.pack("<Iii", 2570, 235 * 256, 159 * 256))
                            + wire_message(pointer_object_id, 3, struct.pack("<IIII", 2571, 2572, 0x110, 1)
                            )
                        )
                        paste_request = recv_wayland_message(client)
                        if paste_request[:3] != (
                            external_offer, 1, clipboard_string("text/plain;charset=utf-8")
                        ) or len(paste_request[3]) != 1:
                            raise AssertionError(
                                "context-menu Paste did not request the preferred UTF-8 MIME with one pipe FD: "
                                + repr(paste_request[:3])
                                + repr(paste_request[3])
                            )
                        paste_fd = paste_request[3][0]
                        workflow_redraw("context-menu Paste starts asynchronous transfer")
                        client.sendall(
                            wire_message(pointer_object_id, 3, struct.pack("<IIII", 2573, 2574, 0x110, 0)
                            ) + buffer_release_message()
                        )
                        pasted = b"pasted from context menu\n"
                        try:
                            os.write(paste_fd, pasted)
                        finally:
                            os.close(paste_fd)
                        workflow_redraw("context-menu Paste completes asynchronous transfer")
                        client.sendall(buffer_release_message())
                        paste_state = read_document_state()
                        if paste_state["doc_contents"] != pasted:
                            raise AssertionError(
                                "context-menu Paste did not insert external clipboard bytes: "
                                + repr(paste_state["doc_contents"])
                            )
                        workflow_shortcut(2590, 44, "Ctrl+Z undoes context-menu Paste")
                        if read_document_state()["doc_contents"] != b"":
                            raise AssertionError("Ctrl+Z did not undo context-menu Paste")
                        workflow_shortcut(2610, 21, "Ctrl+Y redoes context-menu Paste")
                        if read_document_state()["doc_contents"] != pasted:
                            raise AssertionError("Ctrl+Y did not redo context-menu Paste")

                        # An outside click dismisses but does not click through.
                        context_right_click(220, 120, 2630, "reopen menu for outside-click dismissal")
                        client.sendall(
                            wire_message(pointer_object_id, 2, struct.pack("<Iii", 2640, 400 * 256, 70 * 256))
                            + wire_message(pointer_object_id, 3, struct.pack("<IIII", 2641, 2642, 0x110, 1)
                            )
                        )
                        workflow_redraw("outside click dismisses context menu")
                        client.sendall(
                            wire_message(pointer_object_id, 3, struct.pack("<IIII", 2643, 2644, 0x110, 0)
                            ) + buffer_release_message()
                        )
                        if child_u32("context_menu_open") != 0:
                            raise AssertionError("outside click did not dismiss the context menu")
                        if read_document_state()["doc_contents"] != pasted:
                            raise AssertionError("outside click changed the document")
                        observations.append(
                            "context-menu Paste uses asynchronous Wayland receive and supports Undo/Redo; outside click dismisses without click-through"
                        )
                        client.sendall(wire_message(10, 1))
                        return

                    # Select all, then test Ctrl+C through the actual Wayland
                    # data-source protocol and an SCM_RIGHTS transfer pipe.
                    workflow_shortcut(1900, 30, "Ctrl+A before clipboard copy")
                    first_source_id = child_u32("next_client_object_id")
                    clipboard_combo(1910, 46, "Ctrl+C", redraw=False)
                    expect_source_creation(first_source_id, 1911, "Ctrl+C")
                    receive_source_bytes(first_source_id, "Ctrl+C")
                    second_source_id = child_u32("next_client_object_id")
                    clipboard_combo(1915, 46, "Ctrl+C repeated", redraw=False)
                    expect_source_creation(second_source_id, 1916, "repeated Ctrl+C")
                    client.sendall(wire_message(first_source_id, 2))
                    expect_message(
                        client, (first_source_id, 1, b""),
                        "destroy the replaced first Ctrl+C source",
                    )
                    receive_source_bytes(second_source_id, "repeated Ctrl+C")
                    history_directory = os.path.join(runtime_dir, ".nekoedit")
                    history_files = [
                        name for name in os.listdir(history_directory)
                        if name.endswith(".history")
                    ] if os.path.isdir(history_directory) else []
                    if history_files:
                        raise AssertionError(
                            "Ctrl+C created an unnecessary history journal: "
                            + repr(history_files)
                        )
                    observations.append(
                        "repeated Ctrl+C replaced the previous source without creating a .history file"
                    )

                    # Ctrl+X must publish its own snapshot before deleting the
                    # selection, and that snapshot must survive the deletion.
                    cut_source_id = child_u32("next_client_object_id")
                    client.sendall(ctrl_event(1930, 29, True) + ctrl_event(1931, 45, True))
                    expect_source_creation(cut_source_id, 1931, "Ctrl+X")
                    workflow_redraw("Ctrl+X removes the selected document bytes")
                    client.sendall(
                        ctrl_event(1933, 45, False) + ctrl_event(1934, 29, False)
                        + buffer_release_message()
                    )
                    cut_state = read_document_state()
                    if cut_state["doc_contents"] != b"":
                        raise AssertionError(
                            "Ctrl+X did not delete the active selection: "
                            + repr(cut_state["doc_contents"])
                        )
                    client.sendall(wire_message(second_source_id, 2))
                    expect_message(
                        client, (second_source_id, 1, b""),
                        "destroy the replaced repeated Ctrl+C source",
                    )
                    receive_source_bytes(cut_source_id, "Ctrl+X after document deletion")
                    observations.append("Ctrl+X deleted the selection only after publishing an independent snapshot")

                    # Replacing the selection retires both old source objects;
                    # the client must destroy them rather than retaining them.
                    client.sendall(wire_message(cut_source_id, 2))
                    expect_message(
                        client, (cut_source_id, 1, b""), "destroy retired Ctrl+X source"
                    )

                    external_offer = 0xFF000020
                    client.sendall(
                        wire_message(18, 0, struct.pack("<I", external_offer))
                        + wire_message(external_offer, 0, clipboard_string("text/plain;charset=utf-8"))
                        + wire_message(external_offer, 0, clipboard_string("text/plain"))
                        + wire_message(18, 5, struct.pack("<I", external_offer))
                    )
                    clipboard_combo(1950, 47, "Ctrl+V", redraw=False)
                    paste_request = recv_wayland_message(client)
                    if paste_request[:3] != (
                        external_offer, 1, clipboard_string("text/plain;charset=utf-8")
                    ) or len(paste_request[3]) != 1:
                        raise AssertionError(
                            "Ctrl+V did not request the preferred UTF-8 MIME with one pipe FD: "
                            + repr(paste_request[:3])
                            + repr(paste_request[3])
                        )
                    paste_fd = paste_request[3][0]
                    pasted = b"pasted from another Wayland client\n"
                    try:
                        os.write(paste_fd, pasted)
                    finally:
                        os.close(paste_fd)
                    workflow_redraw("Ctrl+V finishes asynchronous clipboard paste")
                    client.sendall(buffer_release_message())
                    paste_state = read_document_state()
                    if paste_state["doc_contents"] != pasted:
                        raise AssertionError(
                            "Ctrl+V did not insert external clipboard bytes at the document caret: "
                            + repr(paste_state["doc_contents"])
                        )
                    observations.append("Ctrl+V received an external Wayland MIME offer asynchronously and inserted its text")

                    # The receive completes later than the Ctrl+V key event.
                    # Its inserted bytes must still be one ordinary Undo/Redo
                    # record, rather than escaping the edit journal.
                    workflow_shortcut(1970, 44, "Ctrl+Z undo asynchronous clipboard paste")
                    undo_paste_state = read_document_state()
                    if undo_paste_state["doc_contents"] != b"":
                        raise AssertionError(
                            "Ctrl+Z did not undo the asynchronous external paste: "
                            + repr(undo_paste_state["doc_contents"])
                        )
                    workflow_shortcut(1980, 21, "Ctrl+Y redo asynchronous clipboard paste")
                    redo_paste_state = read_document_state()
                    if redo_paste_state["doc_contents"] != pasted:
                        raise AssertionError(
                            "Ctrl+Y did not redo the asynchronous external paste: "
                            + repr(redo_paste_state["doc_contents"])
                        )
                    observations.append("asynchronous external paste was recorded as one Undo/Redo action")

                    # The 10 MiB transfer must not execute the single-byte
                    # index/history path millions of times. Keep this in the
                    # same scenario so the real Wayland pipe and event loop
                    # are exercised, not only a helper-level unit test.
                    workflow_shortcut(1990, 44, "Ctrl+Z clear the small clipboard paste")
                    if read_document_state()["doc_contents"] != b"":
                        raise AssertionError("could not clear the small paste before the large-paste test")

                    clipboard_combo(2000, 47, "Ctrl+V 10 MiB clipboard paste", redraw=False)
                    large_paste_request = recv_wayland_message(client)
                    if large_paste_request[:3] != (
                        external_offer, 1, clipboard_string("text/plain;charset=utf-8")
                    ) or len(large_paste_request[3]) != 1:
                        raise AssertionError(
                            "large Ctrl+V did not request UTF-8 clipboard bytes with one pipe FD: "
                            + repr(large_paste_request[:3])
                            + repr(large_paste_request[3])
                        )
                    large_paste_fd = large_paste_request[3][0]
                    large_line = (b"clipboard bulk paste 0123456789abcdef" * 4) + b"\n"
                    large_size = 10 * 1024 * 1024
                    large_pasted = (
                        large_line * ((large_size + len(large_line) - 1) // len(large_line))
                    )[:large_size]
                    large_paste_started = time.monotonic()
                    written = 0
                    try:
                        while written < len(large_pasted):
                            try:
                                amount = os.write(
                                    large_paste_fd, large_pasted[written:written + 65536]
                                )
                            except BlockingIOError:
                                _readable, writable, _exceptional = select.select(
                                    [], [large_paste_fd], [], 5
                                )
                                if not writable:
                                    raise AssertionError(
                                        "large clipboard pipe remained non-writable"
                                    )
                                continue
                            if amount <= 0:
                                raise AssertionError("large clipboard pipe stopped accepting data")
                            written += amount
                    finally:
                        os.close(large_paste_fd)
                    workflow_redraw("Ctrl+V completes the 10 MiB clipboard paste")
                    client.sendall(buffer_release_message())
                    large_paste_elapsed_ms = (time.monotonic() - large_paste_started) * 1000
                    large_paste_state = read_document_state()
                    if large_paste_state["doc_contents"] != large_pasted:
                        raise AssertionError(
                            "10 MiB clipboard paste changed bytes or order: "
                            f"{len(large_paste_state['doc_contents'])} != {len(large_pasted)}"
                        )
                    if (
                        large_paste_state["doc_cursor"] != 0
                        or large_paste_state["doc_view_top_row"] != 0
                        or child_u32("doc_scroll_thumb_top") != 92
                        or child_u32("doc_scroll_thumb_height") <= 0
                    ):
                        raise AssertionError(
                            "10 MiB clipboard paste did not keep the caret and scrollbar "
                            "anchored at the document start: "
                            + repr({
                                key: large_paste_state.get(key)
                                for key in (
                                    "doc_cursor", "doc_view_top_row",
                                    "doc_scroll_thumb_top", "doc_scroll_thumb_height",
                                )
                            })
                        )
                    expected_large_lines = large_pasted.count(b"\n") + 1
                    if (
                        large_paste_state["doc_line_index_valid"] != 1
                        or large_paste_state["doc_line_count"] != expected_large_lines
                        or sum(record[0] for record in large_paste_state["doc_line_index_records"])
                        != len(large_pasted)
                    ):
                        raise AssertionError(
                            "10 MiB clipboard paste produced an invalid line index: "
                            f"valid={large_paste_state['doc_line_index_valid']} "
                            f"lines={large_paste_state['doc_line_count']} "
                            f"expected={expected_large_lines}"
                        )
                    workflow_shortcut(2010, 44, "Ctrl+Z undo the 10 MiB clipboard paste")
                    if read_document_state()["doc_contents"] != b"":
                        raise AssertionError("Ctrl+Z did not undo the complete 10 MiB paste")
                    workflow_shortcut(2020, 21, "Ctrl+Y redo the 10 MiB clipboard paste")
                    redo_large_state = read_document_state()
                    if redo_large_state["doc_contents"] != large_pasted:
                        raise AssertionError("Ctrl+Y did not redo the complete 10 MiB paste")
                    if (
                        redo_large_state["doc_cursor"] != 0
                        or redo_large_state["doc_view_top_row"] != 0
                        or child_u32("doc_scroll_thumb_top") != 92
                    ):
                        raise AssertionError(
                            "Redo did not restore the paste-start caret and viewport: "
                            + repr({
                                key: redo_large_state.get(key)
                                for key in (
                                    "doc_cursor", "doc_view_top_row", "doc_scroll_thumb_top",
                                )
                            })
                        )
                    observations.append(
                        "10 MiB asynchronous clipboard paste preserved every byte and line-index record; "
                        f"bulk Undo/Redo passed in {large_paste_elapsed_ms:.1f} ms"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if clipboard_persistence_test:
                    expected_clipboard = b"keep me after close\n"
                    state = read_document_state()
                    if state["doc_contents"] != expected_clipboard:
                        raise AssertionError(
                            "clipboard persistence test did not start with its document bytes: "
                            + repr(state["doc_contents"])
                        )

                    def clipboard_string(value: str) -> bytes:
                        encoded = value.encode("ascii") + b"\0"
                        return struct.pack("<I", len(encoded)) + encoded + (b"\0" * (-len(encoded) % 4))

                    def ctrl_event(serial: int, code: int, down: bool) -> bytes:
                        return wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial, serial, code, int(down))
                        )

                    def expect_source_creation(source_id: int, serial: int) -> None:
                        expect_message(
                            client, (17, 0, struct.pack("<I", source_id)),
                            "clipboard persistence: create data source",
                        )
                        expect_message(
                            client, (source_id, 0, clipboard_string("text/plain;charset=utf-8")),
                            "clipboard persistence: offer UTF-8 MIME",
                        )
                        expect_message(
                            client, (source_id, 0, clipboard_string("text/plain")),
                            "clipboard persistence: offer plain-text MIME",
                        )
                        expect_message(
                            client, (18, 1, struct.pack("<II", source_id, serial)),
                            "clipboard persistence: set selection",
                        )

                    workflow_shortcut(2190, 30, "Ctrl+A before persistent clipboard copy")
                    clipboard_source_id = child_u32("next_client_object_id")
                    client.sendall(
                        ctrl_event(2200, 29, True)
                        + ctrl_event(2201, 46, True)
                        + ctrl_event(2202, 46, False)
                        + ctrl_event(2203, 29, False)
                    )
                    expect_source_creation(clipboard_source_id, 2201)

                    # Close the editor window. The helper keeps only the
                    # clipboard data-device objects; it must destroy the
                    # inherited xdg toplevel/surface/buffer so no frozen
                    # editor window remains on the compositor.
                    client.sendall(wire_message(10, 1))
                    expect_message(client, (10, 0, b""), "clipboard helper destroys xdg_toplevel")
                    expect_message(client, (9, 0, b""), "clipboard helper destroys xdg_surface")
                    expect_message(client, (8, 0, b""), "clipboard helper destroys wl_surface")
                    expect_message(client, (client_buffer_id, 0, b""), "clipboard helper destroys wl_buffer")
                    read_fd, write_fd = os.pipe()
                    try:
                        transfer = wire_message(
                            clipboard_source_id, 1,
                            clipboard_string("text/plain;charset=utf-8")
                        )
                        client.sendmsg(
                            [transfer],
                            [(socket.SOL_SOCKET, socket.SCM_RIGHTS, struct.pack("i", write_fd))],
                        )
                    finally:
                        os.close(write_fd)

                    received = bytearray()
                    deadline = time.monotonic() + 5
                    try:
                        while time.monotonic() < deadline:
                            readable, _, _ = select.select(
                                [read_fd], [], [], max(0, deadline - time.monotonic())
                            )
                            if not readable:
                                break
                            chunk = os.read(read_fd, 4096)
                            if not chunk:
                                break
                            received.extend(chunk)
                    finally:
                        os.close(read_fd)
                    if bytes(received) != expected_clipboard:
                        raise AssertionError(
                            "post-exit helper did not serve the inherited clipboard snapshot: "
                            + repr(bytes(received))
                        )

                    # The compositor now reports another client owns the
                    # selection. The helper must release its socket and exit.
                    client.sendall(wire_message(18, 5, struct.pack("<I", 0)))
                    client.settimeout(5)
                    while True:
                        chunk = client.recv(1024)
                        if not chunk:
                            break
                    observations.append(
                        "clipboard helper served the selection after editor exit and exited after selection replacement"
                    )
                    return

                if line_index_test:
                    fixture = (
                        b"alpha\n"
                        + (b"x" * 100)
                        + b"\n\tz"
                    )

                    def assert_index(
                        label: str, expected_contents: bytes,
                        expected_spans: tuple[int, ...], expected_rows: tuple[int, ...],
                    ) -> None:
                        state = read_document_state()
                        if state["doc_contents"] != expected_contents:
                            raise AssertionError(
                                label + ": logical bytes changed: " + repr(state["doc_contents"])
                            )
                        records = state["doc_line_index_records"]
                        if (
                            state["doc_line_index_valid"] != 1
                            or state["doc_line_count"] != len(expected_spans)
                            or len(records) != len(expected_spans)
                        ):
                            raise AssertionError(label + ": index is not valid/current: " + repr(state))
                        actual_spans = tuple(record[0] for record in records)
                        actual_rows = tuple(record[1] for record in records)
                        if actual_spans != expected_spans or actual_rows != expected_rows:
                            raise AssertionError(
                                label + ": per-line metadata mismatch; "
                                + repr((actual_spans, actual_rows, state))
                            )
                        expected_byte_nodes = []
                        expected_row_nodes = []
                        for end in range(1, len(expected_spans) + 1):
                            lowbit = end & -end
                            expected_byte_nodes.append(sum(expected_spans[end - lowbit:end]))
                            expected_row_nodes.append(sum(expected_rows[end - lowbit:end]))
                        actual_byte_nodes = tuple(record[2] for record in records)
                        actual_row_nodes = tuple(record[3] for record in records)
                        if (
                            actual_byte_nodes != tuple(expected_byte_nodes)
                            or actual_row_nodes != tuple(expected_row_nodes)
                        ):
                            raise AssertionError(
                                label + ": Fenwick nodes mismatch; "
                                + repr((actual_byte_nodes, tuple(expected_byte_nodes),
                                        actual_row_nodes, tuple(expected_row_nodes)))
                            )
                        if sum(expected_spans) != len(expected_contents):
                            raise AssertionError(label + ": line spans do not cover the document")

                    pointer_state = read_document_state()
                    pointer_pixel = struct.unpack_from(
                        "<I", pixels, 104 * 800 * 4 + 96 * 4
                    )[0]
                    if pointer_state["doc_cursor"] != 16 or pointer_pixel != 0xFFFFFFFF:
                        raise AssertionError(
                            "indexed pointer hit-testing mismatch: "
                            + repr({"cursor": pointer_state["doc_cursor"],
                                    "pixel": hex(pointer_pixel), "expected_cursor": 16})
                        )
                    assert_index("initial rebuild", fixture, (6, 101, 2), (1, 2, 1))
                    key_step(1300, 30, "insert ordinary byte inside indexed long line")
                    after_insert = fixture[:16] + b"a" + fixture[16:]
                    assert_index("ordinary insertion", after_insert, (6, 102, 2), (1, 2, 1))
                    key_step(1302, 14, "Backspace ordinary byte inside indexed long line")
                    assert_index("ordinary deletion", fixture, (6, 101, 2), (1, 2, 1))
                    key_step(1304, 28, "split indexed long line with Enter")
                    split = fixture[:16] + b"\n" + fixture[16:]
                    assert_index("newline split", split, (6, 11, 91, 2), (1, 1, 1, 1))
                    key_step(1306, 14, "merge indexed logical lines with Backspace")
                    assert_index("newline merge", fixture, (6, 101, 2), (1, 2, 1))
                    workflow_shortcut(1310, 31, "save after indexed edit round-trip")
                    observations.append(
                        "document line index rebuilt from mixed hard/soft-wrapped lines; ordinary insertion/deletion point-updated Fenwick trees; Enter split and Backspace merge rebuilt line records and prefix trees"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if grapheme_test:
                    clusters = [
                        "e\u0301",             # base + combining acute
                        "A\u0308\u0323",       # multiple combining marks
                        "\U0001F44D\U0001F3FD", # emoji + skin-tone modifier
                        "\U0001F468\u200D\U0001F469\u200D\U0001F467\u200D\U0001F466", # family ZWJ
                        "\U0001F1FA\U0001F1F8", # first two regional indicators
                        "\U0001F1E8",           # third RI must begin a new cluster
                        "\u1100\u1161\u11A8",    # Hangul L + V + T
                        "\u0915\u094D\u0937",    # Indic consonant + linker + consonant
                        "\u0600A",               # Prepend + base
                        "A\u0903",              # SpacingMark
                        "\r\n",                 # CRLF is one grapheme
                        "Z",
                    ]
                    fixture = "".join(clusters).encode("utf-8")
                    offsets = [0]
                    for cluster in clusters:
                        offsets.append(offsets[-1] + len(cluster.encode("utf-8")))

                    state = read_document_state()
                    if (
                        state["doc_contents"] != fixture
                        or state["doc_cursor"] != 0
                        or state["doc_line_index_valid"] != 1
                        or state["doc_line_count"] != 2
                    ):
                        raise AssertionError(
                            "grapheme fixture did not initialize at byte zero with the expected line index: "
                            + repr(state)
                        )

                    # Right and Shift+Right semantics are validated at every
                    # expected UAX #29 boundary, including the odd RI run.
                    serial = 1400
                    for index, expected_offset in enumerate(offsets[1:], start=1):
                        key_step(serial, 106, "Right over grapheme " + str(index))
                        serial += 2
                        state = read_document_state()
                        if state["doc_cursor"] != expected_offset:
                            raise AssertionError(
                                "Right did not move to a complete grapheme boundary: "
                                + repr({"cluster": index, "cursor": state["doc_cursor"],
                                        "expected": expected_offset, "clusters": clusters})
                            )
                    for index, expected_offset in enumerate(reversed(offsets[:-1]), start=1):
                        key_step(serial, 105, "Left over grapheme " + str(index))
                        serial += 2
                        state = read_document_state()
                        if state["doc_cursor"] != expected_offset:
                            raise AssertionError(
                                "Left did not move to a complete grapheme boundary: "
                                + repr({"step": index, "cursor": state["doc_cursor"],
                                        "expected": expected_offset})
                            )

                    # Mouse hit-testing uses visual grapheme columns, not the
                    # number of UTF-8 bytes or scalar values.
                    workflow_click(24, 98, serial + 10, "pointer after first grapheme")
                    pointer_state = read_document_state()
                    if pointer_state["doc_cursor"] != offsets[1]:
                        raise AssertionError(
                            "pointer hit-testing did not land after the first grapheme: "
                            + repr({"cursor": pointer_state["doc_cursor"], "expected": offsets[1]})
                        )
                    serial += 20

                    # Clicking after the final visible grapheme on the first
                    # line must land before CRLF, never between CR and LF.
                    workflow_click(96, 98, serial, "pointer before CRLF line ending")
                    crlf_pointer_state = read_document_state()
                    if crlf_pointer_state["doc_cursor"] != offsets[10]:
                        raise AssertionError(
                            "pointer hit-testing exposed the interior of a CRLF cluster: "
                            + repr({"cursor": crlf_pointer_state["doc_cursor"],
                                    "expected": offsets[10]})
                        )
                    serial += 10
                    key_step(serial, 106, "Right across CRLF grapheme")
                    serial += 2
                    if read_document_state()["doc_cursor"] != offsets[11]:
                        raise AssertionError("Right did not cross CRLF as one grapheme")
                    key_step(serial, 105, "Left across CRLF grapheme")
                    serial += 2
                    if read_document_state()["doc_cursor"] != offsets[10]:
                        raise AssertionError("Left did not return to the boundary before CRLF")
                    workflow_click(24, 98, serial, "reset pointer after first grapheme")
                    serial += 10
                    reset_state = read_document_state()
                    if reset_state["doc_cursor"] != offsets[1]:
                        raise AssertionError(
                            "could not reset the grapheme deletion caret: "
                            + repr({"cursor": reset_state["doc_cursor"], "expected": offsets[1]})
                        )

                    # Backspace removes the entire preceding emoji modifier
                    # cluster, not just the modifier or base scalar.
                    target_cluster = 3
                    for index in range(target_cluster - 1):
                        key_step(serial, 106, "move to emoji modifier cluster")
                        serial += 2
                    before_delete = read_document_state()
                    if before_delete["doc_cursor"] != offsets[target_cluster]:
                        raise AssertionError(
                            "test did not reach the expected emoji cluster boundary: "
                            + repr({"cursor": before_delete["doc_cursor"],
                                    "expected": offsets[target_cluster]})
                        )
                    key_step(serial, 14, "Backspace entire emoji grapheme")
                    serial += 2
                    expected_after_backspace = (
                        clusters[0] + clusters[1] + "".join(clusters[3:])
                    ).encode("utf-8")
                    after_backspace = read_document_state()
                    if (
                        after_backspace["doc_contents"] != expected_after_backspace
                        or after_backspace["doc_cursor"] != offsets[2]
                    ):
                        raise AssertionError(
                            "Backspace did not remove the complete emoji modifier grapheme: "
                            + repr({"cursor": after_backspace["doc_cursor"],
                                    "contents": after_backspace["doc_contents"]})
                        )

                    # Delete at byte zero must remove the whole base-plus-mark
                    # cluster. Then CRLF Backspace must merge the indexed lines.
                    key_step(serial, 105, "return to document start")
                    serial += 2
                    key_step(serial, 105, "return to document start")
                    serial += 2
                    state = read_document_state()
                    if state["doc_cursor"] != 0:
                        raise AssertionError("Left did not return to the first grapheme boundary")
                    key_step(serial, 111, "Delete complete combining grapheme")
                    serial += 2
                    expected_after_delete = (
                        clusters[1] + "".join(clusters[3:])
                    ).encode("utf-8")
                    after_delete = read_document_state()
                    if (
                        after_delete["doc_contents"] != expected_after_delete
                        or after_delete["doc_cursor"] != 0
                    ):
                        raise AssertionError(
                            "Delete did not remove the entire combining grapheme: "
                            + repr({"cursor": after_delete["doc_cursor"],
                                    "contents": after_delete["doc_contents"]})
                        )

                    # Move to the final Z, then Backspace over the CRLF cluster.
                    remaining_clusters = clusters[1:2] + clusters[3:]
                    current_offsets = [0]
                    for cluster in remaining_clusters:
                        current_offsets.append(
                            current_offsets[-1] + len(cluster.encode("utf-8"))
                        )
                    state = read_document_state()
                    if state["doc_contents"] != expected_after_delete:
                        raise AssertionError("unexpected document state before CRLF merge")
                    for _ in remaining_clusters:
                        key_step(serial, 106, "move to final document grapheme")
                        serial += 2
                    final_state = read_document_state()
                    if final_state["doc_cursor"] != len(expected_after_delete):
                        raise AssertionError("could not reach the end of the grapheme fixture")
                    # One Left moves before Z, the next reaches the end of CRLF.
                    key_step(serial, 105, "Left before final Z")
                    serial += 2
                    key_step(serial, 14, "Backspace complete CRLF grapheme")
                    serial += 2
                    after_crlf = read_document_state()
                    expected_without_crlf = (
                        clusters[1] + "".join(clusters[3:-2]) + clusters[-1]
                    ).encode("utf-8")
                    if (
                        after_crlf["doc_contents"] != expected_without_crlf
                        or after_crlf["doc_line_count"] != 1
                    ):
                        raise AssertionError(
                            "Backspace did not delete CRLF atomically and merge indexed lines: "
                            + repr({"line_count": after_crlf["doc_line_count"],
                                    "contents": after_crlf["doc_contents"]})
                        )
                    observations.append(
                        "Unicode 18.0 grapheme navigation verified combining sequences, emoji modifiers and ZWJ family, RI pairing, Hangul, Indic conjuncts, Prepend, SpacingMark and CRLF; pointer hit-testing and whole-cluster Backspace/Delete passed"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if punctuation_render_test:
                    # Every printable ASCII punctuation character must have
                    # its own bitmap, rather than silently falling back to '?'.
                    punctuation_chars = "!\"#$%&'()*+,-./:;<=>?@[\]^_" + chr(96) + "{|}~"
                    question_bitmap = (14, 17, 1, 2, 4, 0, 4)

                    def glyph_bitmap(cell_index: int) -> tuple[int, ...]:
                        rows = []
                        for row in range(7):
                            bits = 0
                            for column in range(5):
                                pixel = struct.unpack_from(
                                    "<I",
                                    pixels,
                                    (92 + row) * 800 * 4
                                    + (16 + cell_index * 8 + column) * 4,
                                )[0]
                                if pixel == 0xFFD8DEE9:
                                    bits |= 1 << (4 - column)
                            rows.append(bits)
                        return tuple(rows)

                    for index, character in enumerate(punctuation_chars):
                        bitmap = glyph_bitmap(index + 1)
                        if not any(bitmap):
                            raise AssertionError(
                                f"printable ASCII punctuation {character!r} rendered as a blank cell"
                            )
                        if character != "?" and bitmap == question_bitmap:
                            raise AssertionError(
                                f"printable ASCII punctuation {character!r} fell back to the '?' glyph"
                            )
                    observations.append(
                        "all 32 printable ASCII punctuation glyphs rendered without question-mark fallback"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if compose_locale_test:
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("valid optional Compose pack was not activated")
                    key_step(4100, 46, "optional locale starts Compose pair")
                    key_step(4102, 24, "optional locale buffers o")
                    if child_u32("doc_compose_first") != ord("o") or child_u32("doc_length") != 0:
                        raise AssertionError("optional locale did not buffer its first input")
                    key_step(4104, 23, "optional locale resolves o i to a two-scalar output")
                    expected = bytes.fromhex("e29883efb88f")
                    actual = read_document_state()["doc_contents"]
                    if actual != expected or child_u32("doc_compose_active") != 0:
                        raise AssertionError("multi-scalar output mismatch: " + repr(actual))
                    key_step(4110, 46, "optional locale starts three-input Compose")
                    key_step(4112, 21, "optional locale buffers y")
                    key_step(4114, 22, "optional locale buffers u")
                    key_step(4116, 23, "optional locale resolves y u i")
                    expected += bytes.fromhex("e29885")
                    actual = read_document_state()["doc_contents"]
                    if actual != expected:
                        raise AssertionError("three-input mapping mismatch: " + repr(actual))
                    before = child_u32("doc_length")
                    key_step(4120, 46, "optional locale starts four-input Compose")
                    key_step(4122, 17, "optional locale buffers w")
                    key_step(4124, 18, "optional locale buffers e")
                    key_step(4126, 19, "optional locale buffers r")
                    if child_u32("doc_compose_third") != ord("r") or child_u32("doc_length") != before:
                        raise AssertionError("four-input prefix was not buffered")
                    key_step(4128, 20, "optional locale resolves w e r t")
                    expected += bytes.fromhex("f09f9982")
                    actual = read_document_state()["doc_contents"]
                    if actual != expected:
                        raise AssertionError("four-input mapping mismatch: " + repr(actual))
                    key_step(4130, 46, "optional locale starts unknown pair")
                    key_step(4132, 25, "optional locale buffers p")
                    key_step(4134, 25, "unknown locale pair falls back literally")
                    expected += b"pp"
                    actual = read_document_state()["doc_contents"]
                    if actual != expected:
                        raise AssertionError("unknown input was not preserved: " + repr(actual))
                    before_cancel = child_u32("doc_length")
                    key_step(4140, 46, "optional locale starts Escape-cancel sequence")
                    key_step(4142, 17, "optional locale buffers w before Escape")
                    key_step(4144, 18, "optional locale buffers e before Escape")
                    key_step(4146, 19, "optional locale buffers r before Escape")
                    key_step(4148, 1, "Escape cancels buffered locale inputs")
                    if child_u32("doc_compose_active") != 0 or child_u32("doc_compose_third") != 0 or child_u32("doc_length") != before_cancel:
                        raise AssertionError("Escape did not clear the locale Compose prefix")
                    key_step(4150, 46, "optional locale starts Backspace-cancel sequence")
                    key_step(4152, 17, "optional locale buffers w before Backspace")
                    key_step(4154, 18, "optional locale buffers e before Backspace")
                    key_step(4156, 19, "optional locale buffers r before Backspace")
                    key_step(4158, 14, "Backspace cancels buffered locale inputs")
                    if (
                        child_u32("doc_compose_active") != 0
                        or child_u32("doc_compose_first") != 0
                        or child_u32("doc_compose_second") != 0
                        or child_u32("doc_compose_third") != 0
                        or child_u32("doc_compose_fourth") != 0
                        or child_u32("doc_length") != before_cancel
                    ):
                        raise AssertionError("Backspace did not clear the locale Compose state")
                    # Kind-1 records accept two or three marks plus the final
                    # base scalar through actual Wayland/XKB keyboard events.
                    chain_start = child_u32("doc_length")
                    key_step(4160, 33, "dead-chain starts with acute")
                    if child_u32("doc_compose_first") != 0x0301 or child_u32("doc_length") != chain_start:
                        raise AssertionError("first dead mark was not buffered")
                    key_step(4162, 230, "dead-chain buffers caron")
                    if (
                        child_u32("doc_compose_first") != 0x0301
                        or child_u32("doc_compose_second") != 0x030c
                        or child_u32("doc_compose_third") != 0
                        or child_u32("doc_pending_dead_mark") != 0x030c
                        or child_u32("doc_length") != chain_start
                    ):
                        raise AssertionError("two-mark dead-key prefix was not buffered")
                    key_step(4164, 34, "dead-chain base resolves the three-input locale rule")
                    expected += bytes.fromhex("f09f9982")
                    if (
                        read_document_state()["doc_contents"] != expected
                        or child_u32("doc_pending_dead_mark") != 0
                        or child_u32("doc_compose_first") != 0
                    ):
                        raise AssertionError("two-mark dead-key rule did not resolve atomically")
                    key_step(4170, 33, "three-mark chain buffers acute")
                    key_step(4172, 229, "three-mark chain buffers macron")
                    key_step(4174, 230, "three-mark chain buffers caron")
                    if (
                        child_u32("doc_compose_first") != 0x0301
                        or child_u32("doc_compose_second") != 0x0304
                        or child_u32("doc_compose_third") != 0x030c
                        or child_u32("doc_pending_dead_mark") != 0x030c
                    ):
                        raise AssertionError("three dead marks did not occupy the pending slots")
                    key_step(4176, 34, "three-mark chain resolves the four-input locale rule")
                    expected += bytes.fromhex("e29883efb88f")
                    if read_document_state()["doc_contents"] != expected:
                        raise AssertionError("three-mark dead-key output mismatch")
                    # Unknown chains fall back to base + combining marks in order.
                    key_step(4180, 33, "fallback chain buffers acute")
                    key_step(4182, 231, "fallback chain buffers belowdot")
                    key_step(4184, 34, "fallback chain inserts base and both marks")
                    expected += b"g\xcc\x81\xcc\xa3"
                    if read_document_state()["doc_contents"] != expected:
                        raise AssertionError("unknown dead-key chain was not preserved literally")
                    # Seven marks are buffered; only the eighth dead action
                    # flushes them literally and starts a fresh one-mark chain.
                    for timestamp, keycode, description in (
                        (4190, 33, "acute"), (4192, 229, "macron"),
                        (4194, 230, "caron"), (4196, 33, "acute"),
                        (4198, 230, "caron"), (4200, 229, "macron"),
                        (4202, 33, "final acute"),
                    ):
                        key_step(timestamp, keycode, "seven-mark maximum buffers " + description)
                    key_step(4204, 231, "eighth dead action flushes the old chain")
                    expected += bytes.fromhex("cc81cc84cc8ccc81cc8ccc84cc81")
                    if (
                        read_document_state()["doc_contents"] != expected
                        or child_u32("doc_compose_first") != 0x0323
                        or child_u32("doc_pending_dead_mark") != 0x0323
                        or child_u32("doc_compose_second") != 0
                    ):
                        raise AssertionError("eighth dead action did not flush seven marks and restart cleanly")
                    key_step(4206, 34, "new chain resolves as a single-mark fallback")
                    expected += bytes.fromhex("67cca3")
                    if read_document_state()["doc_contents"] != expected:
                        raise AssertionError("overflow fallback did not preserve both sequences")
                    before_chain_cancel = child_u32("doc_length")
                    key_step(4210, 33, "Escape test arms acute")
                    key_step(4212, 229, "Escape test appends macron")
                    key_step(4214, 1, "Escape cancels the full dead-key chain")
                    if (
                        child_u32("doc_pending_dead_mark") != 0
                        or any(child_u32(name) for name in (
                            "doc_compose_first", "doc_compose_second",
                            "doc_compose_third", "doc_compose_fourth",
                        ))
                        or child_u32("doc_length") != before_chain_cancel
                    ):
                        raise AssertionError("Escape left part of the dead-key chain pending")
                    key_step(4220, 33, "Backspace test arms acute")
                    key_step(4222, 230, "Backspace test appends caron")
                    key_step(4224, 14, "Backspace cancels the full dead-key chain")
                    if (
                        child_u32("doc_pending_dead_mark") != 0
                        or any(child_u32(name) for name in (
                            "doc_compose_first", "doc_compose_second",
                            "doc_compose_third", "doc_compose_fourth",
                        ))
                        or child_u32("doc_length") != before_chain_cancel
                    ):
                        raise AssertionError("Backspace left part of the dead-key chain pending")
                    # Exercise a full eight-input dead-key record through physical
                    # XKB events: seven combining marks followed by the base scalar.
                    chain8_start = child_u32("doc_length")
                    for timestamp, keycode, description in (
                        (4300, 33, "acute"), (4302, 230, "caron"),
                        (4304, 229, "macron"), (4306, 33, "acute"),
                        (4308, 230, "caron"), (4310, 229, "macron"),
                        (4312, 33, "final acute"),
                    ):
                        key_step(timestamp, keycode, "seven-mark chain buffers " + description)
                    if (
                        child_u32("doc_compose_first") != 0x0301
                        or child_u32("doc_compose_second") != 0x030c
                        or child_u32("doc_compose_third") != 0x0304
                        or child_u32("doc_compose_fourth") != 0x0301
                        or child_u32("doc_compose_fifth") != 0x030c
                        or child_u32("doc_compose_sixth") != 0x0304
                        or child_u32("doc_compose_seventh") != 0x0301
                        or child_u32("doc_pending_dead_mark") != 0x0301
                        or child_u32("doc_length") != chain8_start
                    ):
                        raise AssertionError("seven dead-key marks did not remain buffered in order")
                    key_step(4314, 34, "seven-mark chain resolves the eight-input dead-key rule")
                    expected += bytes.fromhex("e29883efb88f")
                    if (
                        read_document_state()["doc_contents"] != expected
                        or child_u32("doc_pending_dead_mark") != 0
                        or any(child_u32(name) for name in (
                            "doc_compose_first", "doc_compose_second", "doc_compose_third",
                            "doc_compose_fourth", "doc_compose_fifth", "doc_compose_sixth",
                            "doc_compose_seventh", "doc_compose_eighth",
                        ))
                    ):
                        raise AssertionError("seven-mark dead-key rule did not resolve and clear all eight slots")
                    observations.append("validated optional locale pack: Multi_key pair/triple/four-input; one-to-seven-mark dead-key records; literal fallback, eight-action overflow, Escape and Backspace")
                    client.sendall(wire_message(10, 1))
                    return



                elif compose_locale_finnish_test:
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("fi_FI.utf8 did not normalize to the installed fi_FI.UTF-8 pack")
                    if (
                        child_u32_at("xkb_unicode_levels", 232 * 128) != 0x110002
                        or child_u32_at("xkb_unicode_levels", 45 * 128) != 0x043A
                    ):
                        raise AssertionError("Finnish dead-key fixture did not map dead_apostrophe and Cyrillic_ka")
                    key_step(6100, 46, "Finnish locale starts Compose")
                    key_step(6102, 33, "Finnish locale buffers f")
                    key_step(6104, 23, "Finnish locale resolves f i to the fi ligature")
                    if read_document_state()["doc_contents"] != bytes.fromhex("efac81"):
                        raise AssertionError("Finnish fi ligature did not produce U+FB01")

                    before_fi_dead = child_u32("doc_length")
                    key_step(6106, 224, "Finnish locale dead_acute arms its combining mark")
                    if (
                        child_u32("doc_pending_dead_mark") != 0x0301
                        or child_u32("doc_length") != before_fi_dead
                    ):
                        raise AssertionError("Finnish dead_acute did not arm without inserting text")
                    key_step(6108, 37, "Finnish dead_acute plus Cyrillic_ka resolves to U+045C")
                    fi_after_dead = read_document_state()["doc_contents"]
                    fi_locale_output = child_u32_at("compose_locale_output", 0)
                    if (
                        fi_after_dead != bytes.fromhex("efac81d19c")
                        or child_u32("doc_pending_dead_mark") != 0
                        or fi_locale_output != 0x045C
                    ):
                        raise AssertionError(
                            "Finnish locale dead-key rule did not insert U+045C after the fi ligature: "
                            f"actual={fi_after_dead.hex()}, "
                            f"pending=U+{child_u32('doc_pending_dead_mark'):04X}, "
                            f"locale_output=U+{fi_locale_output:04X}"
                        )
                    observations.append(
                        "fi_FI.utf8 alias loaded the actual Finnish pack; Multi_key f i produced U+FB01 and dead_acute + Cyrillic_ka produced locale rule U+045C"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif compose_locale_serbian_test:
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("sr_RS.utf8 did not normalize to the installed sr_RS.UTF-8 pack")
                    if (
                        child_u32_at("xkb_unicode_levels", 232 * 128) != 0x110002
                        or child_u32_at("xkb_unicode_levels", 45 * 128) != 0x043A
                    ):
                        raise AssertionError("Serbian dead-key fixture did not map dead_apostrophe and Cyrillic_ka")
                    key_step(6200, 46, "Serbian locale starts Compose")
                    key_step(6202, 41, "Serbian locale buffers grave accent")
                    key_step(6204, 30, "Serbian locale resolves Cyrillic a with combining grave")
                    if read_document_state()["doc_contents"] != bytes.fromhex("d0b0cc80"):
                        raise AssertionError("Serbian Cyrillic accent did not produce U+0430 U+0300")

                    before_sr_dead = child_u32("doc_length")
                    key_step(6206, 224, "Serbian locale dead_acute arms its combining mark")
                    if (
                        child_u32("doc_pending_dead_mark") != 0x0301
                        or child_u32("doc_length") != before_sr_dead
                    ):
                        raise AssertionError("Serbian dead_acute did not arm without inserting text")
                    key_step(6208, 37, "Serbian dead_acute plus Cyrillic_ka resolves to U+045C")
                    sr_after_dead = read_document_state()["doc_contents"]
                    sr_locale_output = child_u32_at("compose_locale_output", 0)
                    if (
                        sr_after_dead != bytes.fromhex("d0b0cc80d19c")
                        or child_u32("doc_pending_dead_mark") != 0
                        or sr_locale_output != 0x045C
                    ):
                        raise AssertionError(
                            "Serbian locale dead-key rule did not insert U+045C after the Cyrillic accent: "
                            f"actual={sr_after_dead.hex()}, "
                            f"pending=U+{child_u32('doc_pending_dead_mark'):04X}, "
                            f"locale_output=U+{sr_locale_output:04X}"
                        )
                    observations.append(
                        "sr_RS.utf8 alias loaded the actual Serbian pack; Multi_key grave + Cyrillic_a produced decomposed output and dead_acute + Cyrillic_ka produced locale rule U+045C"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif compose_locale_system_test:
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("LC_ALL pt_BR did not activate the installed pack")
                    key_step(5200, 46, "system locale starts Compose")
                    key_step(5202, 24, "system locale buffers o")
                    key_step(5204, 23, "system locale resolves o i")
                    if read_document_state()["doc_contents"] != bytes.fromhex("e29883efb88f"):
                        raise AssertionError("LC_ALL-selected pt_BR pack did not resolve Compose input")
                    observations.append(
                        "system character-locale precedence: LC_ALL selected pt_BR over LC_CTYPE/LANG and loaded its pack"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif compose_locale_c_fallback_test:
                    if child_u32("compose_locale_active") != 0:
                        raise AssertionError("LC_ALL=C did not select built-in en_US over lower-priority pt_BR")
                    observations.append(
                        "system locale C/C.UTF-8 fallback: LC_ALL=C overrides pt_BR LC_CTYPE/LANG and keeps built-in en_US"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif compose_locale_ctype_test or compose_locale_lang_test:
                    source = "LC_CTYPE" if compose_locale_ctype_test else "LANG"
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError(f"{source} did not activate the installed pt_BR pack")
                    key_step(5300, 46, f"{source} locale starts Compose")
                    key_step(5302, 24, f"{source} locale buffers o")
                    key_step(5304, 23, f"{source} locale resolves o i")
                    if read_document_state()["doc_contents"] != bytes.fromhex("e29883efb88f"):
                        raise AssertionError(f"{source}-selected pt_BR pack did not resolve Compose input")
                    observations.append(
                        f"system character-locale fallback: {source} selected the canonical pt_BR pack after higher-priority values were empty"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif compose_locale_saved_preference_test:
                    if child_u32("compose_locale_active") != 0:
                        raise AssertionError("saved en_US Settings choice did not override pt_BR system locale")
                    observations.append(
                        "saved Settings preference: explicit en_US overrides LC_ALL pt_BR and keeps built-in tables active"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif compose_locale_settings_test:
                    if child_u32("compose_locale_active") != 0:
                        raise AssertionError("built-in en_US was not active before the Settings choice")

                    def click_settings(x: int, y: int, serial: int, label: str) -> None:
                        wait_buffer_idle(f"{label} waits for the released buffer")
                        client.sendall(
                            wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                            + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1))
                        )
                        message = recv_wayland_message(client)
                        # A pointer move can update cursor feedback before the surface redraw.
                        if message[0:2] == (18, 1):
                            if message[3] or len(message[2]) != 8:
                                raise AssertionError(f"{label}: malformed cursor-shape request {message!r}")
                            enter_serial, shape = struct.unpack("<II", message[2])
                            if enter_serial != 777 or shape > 40:
                                raise AssertionError(f"{label}: invalid cursor-shape update {message!r}")
                            message = recv_wayland_message(client)
                        if message[0:2] == (11, 0):
                            while message[0:2] == (11, 0):
                                if len(message[2]) != 24 or message[3]:
                                    raise AssertionError(f"{label}: malformed wl_buffer.create_buffer {message!r}")
                                message = recv_wayland_message(client)
                        if message[0:2] != (8, 1) or len(message[2]) != 12 or message[3]:
                            raise AssertionError(f"{label} attach: unexpected request {message!r}")
                        attached_id, attach_x, attach_y = struct.unpack("<III", message[2])
                        if attached_id not in known_buffer_offsets or (attach_x, attach_y) != (0, 0):
                            raise AssertionError(f"{label} attach: unknown buffer or nonzero origin {message!r}")
                        expect_message(
                            client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)),
                            f"{label} damage",
                        )
                        expect_message(client, (8, 6, b""), f"{label} commit")
                        client.sendall(
                            wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0))
                            + buffer_release_message()
                        )
                        wait_buffer_idle(f"{label} waits for frame release")

                    def click_settings_design(dx: int, dy: int, serial: int, label: str) -> None:
                        panel_x = child_u32("settings_panel_x")
                        panel_y = child_u32("settings_panel_y")
                        panel_w = child_u32("settings_panel_width")
                        panel_h = child_u32("settings_panel_height")
                        sx = panel_x + ((dx - 160) * panel_w // 256)
                        sy = panel_y + ((dy - 32) * panel_h // 192)
                        click_settings(sx, sy, serial, label)

                    def click_picker_design(dx: int, dy: int, serial: int, label: str) -> None:
                        panel_x = child_u32("picker_panel_x")
                        panel_y = child_u32("picker_panel_y")
                        panel_w = child_u32("picker_panel_width")
                        panel_h = child_u32("picker_panel_height")
                        sx = panel_x + ((dx - 40) * panel_w // 720)
                        sy = panel_y + ((dy - 36) * panel_h // 408)
                        click_settings(sx, sy, serial, label)

                    click_settings(180, 10, 5000, "open Settings dropdown")
                    click_settings_design(200, 200, 5010, "open installed locale dropdown")
                    if child_u32("settings_locale_dropdown_open") != 1:
                        raise AssertionError("Settings Locale did not open its dropdown")
                    if child_u32("picker_mode") != 0:
                        raise AssertionError("installed locale dropdown unexpectedly opened the file picker")
                    if child_u32("picker_entry_count") != 2:
                        raise AssertionError("installed locale dropdown did not discover both installed packs")
                    key_step(5012, 1, "dismiss locale dropdown with Escape")
                    if child_u32("settings_locale_dropdown_open") != 0 or child_u32("settings_menu_open") != 1:
                        raise AssertionError("Escape did not dismiss only the locale dropdown")
                    click_settings_design(200, 200, 5014, "reopen locale dropdown after Escape")
                    click_settings_design(200, 112, 5020, "select alphabetically first installed locale")
                    if child_u32("settings_locale_dropdown_open") != 0:
                        raise AssertionError("selecting a locale did not close the dropdown")
                    if child_u32("picker_mode") != 0:
                        raise AssertionError("selecting an installed locale left the file picker open")
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("Settings did not activate the selected generic locale pack")
                    if child_u32("doc_length") != 0:
                        raise AssertionError("changing the locale changed document contents")

                    # aa_TEST sorts before pt_BR, proving the dropdown resolves
                    # each installed filename rather than hard-coding a locale.
                    key_step(5030, 46, "generic locale starts Compose")
                    key_step(5032, 24, "generic locale buffers o")
                    key_step(5034, 23, "generic locale resolves o i")
                    if read_document_state()["doc_contents"] != bytes.fromhex("e29885"):
                        raise AssertionError("Settings-selected aa_TEST pack did not insert its distinct output")

                    click_settings(180, 10, 5040, "reopen Settings for keyboard locale navigation")
                    click_settings_design(200, 200, 5050, "open locale dropdown for keyboard navigation")
                    key_step(5052, 103, "move locale highlight up to built-in en_US")
                    if child_u32("settings_locale_dropdown_selected") != 0:
                        raise AssertionError("Up did not move the locale highlight to built-in en_US")
                    key_step(5054, 108, "move locale highlight down to aa_TEST")
                    key_step(5056, 108, "move locale highlight down to pt_BR")
                    if child_u32("settings_locale_dropdown_selected") != 2:
                        raise AssertionError("Down did not navigate to the second installed locale")
                    key_step(5058, 28, "activate pt_BR from the keyboard dropdown")
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("Enter did not activate the highlighted installed locale")
                    if child_u32("settings_locale_dropdown_open") != 0 or child_u32("picker_mode") != 0:
                        raise AssertionError("keyboard locale selection did not close without opening a file picker")
                    key_step(5060, 46, "keyboard-selected pt_BR starts Compose")
                    key_step(5062, 18, "keyboard-selected pt_BR buffers e")
                    key_step(5064, 18, "keyboard-selected pt_BR resolves e e")
                    if child_u32("doc_compose_active") != 0:
                        raise AssertionError("successful pt_BR Multi_key composition left Compose state active")
                    pt_after_multi = read_document_state()["doc_contents"]
                    pt_tag_bytes = bytes(
                        child_u32_at("compose_locale_current_tag", i) & 0xFF
                        for i in range(32)
                    ).split(bytes((0,)), 1)[0]
                    pt_keymap_values = (
                        child_u32_at("xkb_unicode_levels", 54 * 128),
                        child_u32_at("xkb_unicode_levels", 26 * 128),
                    )
                    pt_locale_output = tuple(
                        child_u32_at("compose_locale_output", i) for i in range(2)
                    )
                    if pt_after_multi != bytes.fromhex("e29885c68f"):
                        raise AssertionError(
                            "keyboard-selected pt_BR e e did not append U+018F after aa_TEST: "
                            f"actual={pt_after_multi.hex()}, locale={pt_tag_bytes!r}, "
                            f"active={child_u32('compose_locale_active')}, "
                            f"keymap(Multi_key,e)={[hex(v) for v in pt_keymap_values]}, "
                            f"locale_output={[hex(v) for v in pt_locale_output]}, "
                            f"compose_first=U+{child_u32('doc_compose_first'):04X}, "
                            f"compose_second=U+{child_u32('doc_compose_second'):04X}, "
                            f"compose_active={child_u32('doc_compose_active')}, "
                            f"cursor={child_u32('doc_cursor')}, length={child_u32('doc_length')}"
                        )

                    before_pt_dead = child_u32("doc_length")
                    key_step(5066, 33, "pt_BR dead_acute arms its combining mark")
                    if child_u32("doc_pending_dead_mark") != 0x301 or child_u32("doc_length") != before_pt_dead:
                        raise AssertionError("pt_BR dead_acute did not arm without inserting text")
                    key_step(5068, 232, "pt_BR dead_acute plus c uses its locale-specific cedilla rule")
                    actual_pt_dead = read_document_state()["doc_contents"]
                    pending_after_pt_dead = child_u32("doc_pending_dead_mark")
                    locale_output_first = child_u32_at("compose_locale_output", 0)
                    if pending_after_pt_dead != 0 or actual_pt_dead != bytes.fromhex("e29885c68fc3a7"):
                        raise AssertionError(
                            "pt_BR dead-key pack rule did not insert ç after the locale Compose result: "
                            f"actual={actual_pt_dead.hex()}, pending=U+{pending_after_pt_dead:04X}, "
                            f"locale_output[0]=U+{locale_output_first:04X}, "
                            f"compose_active={child_u32('doc_compose_active')}"
                        )

                    click_settings(180, 10, 5070, "reopen Settings to choose Base")
                    click_settings_design(200, 200, 5080, "open locale dropdown for Base")
                    click_settings_design(200, 96, 5090, "select built-in en_US from dropdown")
                    if child_u32("compose_locale_active") != 0:
                        raise AssertionError("Settings dropdown did not return to built-in en_US")
                    preference_path = os.path.join(runtime_dir, ".nekoedit", "preferences")
                    with open(preference_path, "r", encoding="utf-8") as preference_file:
                        saved = preference_file.read()
                    if "compose_locale=en_US.UTF-8\n" not in saved:
                        raise AssertionError("built-in locale choice was not persisted")
                    observations.append(
                        "Settings installed-locale dropdown dynamically lists generic packs, selects aa_TEST, and persists built-in en_US without opening a file picker"
                    )

                    # Remove the pre-seeded pt_BR install so Add Pack must copy
                    # and validate the user's source file from the picker.
                    installed_path = os.path.join(runtime_dir, ".nekoedit", "locales", "pt_BR.UTF-8.nlp")
                    os.unlink(installed_path)
                    click_settings(180, 10, 5070, "reopen Settings for Add Pack")
                    click_settings_design(282, 200, 5080, "open Add Pack picker")
                    if child_u32("picker_mode") != 4:
                        raise AssertionError("Settings Add did not open locale-pack picker mode")
                    click_picker_design(200, 160, 5090, "select the .nlp source pack")
                    key_step(5100, 28, "install selected locale pack")
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("Add Pack did not activate the installed pt_BR pack")
                    if not os.path.isfile(installed_path):
                        raise AssertionError("Add Pack did not create the installed .nlp file")
                    installed_mode = os.stat(installed_path).st_mode & 0o777
                    if installed_mode != 0o600:
                        raise AssertionError(f"installed locale file permissions were {oct(installed_mode)}")
                    if not os.path.isfile(os.path.join(runtime_dir, "pt_BR.UTF-8.nlp")):
                        raise AssertionError("Add Pack unexpectedly consumed the user's source file")
                    with open(preference_path, "r", encoding="utf-8") as preference_file:
                        saved_after_install = preference_file.read()
                    if "compose_locale=pt_BR.UTF-8\n" not in saved_after_install:
                        raise AssertionError("Add Pack did not persist the new locale choice")
                    if child_u32("picker_entry_count") != 2:
                        raise AssertionError("successful Add did not refresh the installed-locale list")
                    if child_u32("settings_locale_dropdown_selected") != 2:
                        raise AssertionError("refreshed dropdown did not locate the newly installed pt_BR pack")
                    observations.append("Settings Add Pack copied/validated pt_BR, preserved the source, and refreshed the dynamic installed-locale list")

                    click_settings(180, 10, 5110, "reopen Settings to choose installed pt_BR")
                    click_settings_design(200, 200, 5120, "open refreshed locale dropdown")
                    if child_u32("picker_entry_count") != 2 or child_u32("settings_locale_dropdown_selected") != 2:
                        raise AssertionError("reopened locale dropdown did not retain the newly installed pt_BR entry")
                    click_settings_design(200, 128, 5130, "select newly installed pt_BR from dropdown")
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("dropdown did not activate the newly installed pt_BR pack")
                    if child_u32("picker_mode") != 0:
                        raise AssertionError("choosing pt_BR reopened a file picker")
                    key_step(5140, 46, "selected pt_BR locale starts Compose")
                    key_step(5142, 18, "selected pt_BR locale buffers e")
                    key_step(5144, 18, "selected pt_BR locale resolves e e")
                    if read_document_state()["doc_contents"] != bytes.fromhex("e29885c68fc3a7c68f"):
                        raise AssertionError("dropdown-selected pt_BR did not append its upstream e e mapping through the installed pack")

                    click_settings(180, 10, 5150, "reopen Settings for Remove Pack")
                    click_settings_design(332, 200, 5160, "request Remove Pack confirmation")
                    if child_u32("save_confirm_open") != 1:
                        raise AssertionError("Remove Pack did not request confirmation")
                    click_settings(300, 272, 5170, "confirm Remove Pack")
                    if os.path.exists(installed_path):
                        raise AssertionError("Remove Pack did not delete the validated installed file")
                    if child_u32("compose_locale_active") != 0:
                        raise AssertionError("Remove Pack did not restore embedded en_US")
                    with open(preference_path, "r", encoding="utf-8") as preference_file:
                        saved_after_remove = preference_file.read()
                    if "compose_locale=en_US.UTF-8\n" not in saved_after_remove:
                        raise AssertionError("Remove Pack did not persist the en_US fallback")
                    if child_u32("picker_entry_count") != 1:
                        raise AssertionError("Remove did not refresh the dropdown's installed-locale list")
                    if child_u32("settings_locale_dropdown_selected") != 0:
                        raise AssertionError("Remove did not reset the refreshed selection to built-in en_US")
                    observations.append("Settings Remove Pack requires confirmation, refreshes the locale list, deletes the validated pack, restores en_US, and persists the fallback")

                    # Import a raw user .XCompose file through the new native Settings action.
                    # This must not invoke the optional host-side Python converter.
                    native_source = os.path.join(runtime_dir, "nekoedit-test.XCompose")
                    native_source_text = (
                        "# in-app native XCompose import test\n"
                        '<Multi_key> <o> <c> : "Neko"\n'
                        '<Multi_key> <t> <e> <s> <t> : "TEST"\n'
                        '<dead_acute> <a> : "á"\n'
                    )
                    with open(native_source, "w", encoding="utf-8") as native_file:
                        native_file.write(native_source_text)
                    native_source_bytes = native_source_text.encode("utf-8")

                    click_settings(180, 10, 5180, "reopen Settings for raw XCompose import")
                    click_settings_design(392, 200, 5190, "open Import XCompose picker")
                    if child_u32("picker_mode") != 6:
                        raise AssertionError("Settings Import did not open raw XCompose picker mode")
                    click_picker_design(200, 160, 5200, "select the raw .XCompose file")
                    key_step(5210, 28, "import selected raw .XCompose file")
                    native_pack_path = os.path.join(
                        runtime_dir, ".nekoedit", "locales", "nekoedit-test.UTF-8.nlp"
                    )
                    if child_u32("compose_locale_active") != 1:
                        raise AssertionError("native XCompose Import did not activate the generated locale")
                    if child_u32("picker_mode") != 0:
                        raise AssertionError("successful native XCompose Import did not close the picker")
                    if not os.path.isfile(native_pack_path):
                        raise AssertionError("native XCompose Import did not create the separate NLP1 pack")
                    if os.stat(native_pack_path).st_mode & 0o777 != 0o600:
                        raise AssertionError("native XCompose Import did not create a private 0600 pack")
                    with open(native_source, "rb") as native_file:
                        if native_file.read() != native_source_bytes:
                            raise AssertionError("native XCompose Import modified the selected source file")
                    with open(preference_path, "r", encoding="utf-8") as preference_file:
                        imported_preference = preference_file.read()
                    if "compose_locale=nekoedit-test.UTF-8\n" not in imported_preference:
                        raise AssertionError("native XCompose Import did not persist its locale choice")
                    observations.append(
                        "Settings Import converted a raw .XCompose file natively, preserved the source, and installed a separate private NLP1 pack"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                elif unicode_keyboard_test:
                    if compose_locale_invalid_test and child_u32("compose_locale_active") != 0:
                        raise AssertionError("CRC-invalid locale pack was not rejected")
                    # Inspect the parser's scalar table before exercising
                    # modifiers and insertion. Layout index is keycode*16+level.
                    alias_scalars = (
                        child_u32_at("xkb_unicode_levels", 39 * 128),
                        child_u32_at("xkb_unicode_levels", 39 * 128 + 4),
                        child_u32_at("xkb_unicode_levels", 40 * 128),
                        child_u32_at("xkb_unicode_levels", 41 * 128),
                        child_u32_at("xkb_unicode_levels", 52 * 128),
                        child_u32_at("xkb_unicode_levels", 53 * 128),
                        child_u32_at("xkb_unicode_levels", 54 * 128),
                    )
                    extended_alias_scalars = tuple(
                        child_u32_at("xkb_unicode_levels", keycode * 128)
                        for keycode in range(220, 233)
                    )
                    expected_extended_alias_scalars = (
                        0x0627, 0x05D0, 0x0E01, 0x3131, 0x0531, 0x10D0,
                        0x30A1, 0x0D85, 0x28FF, 0x1E9E, 0x2039, 0x0037, 0x110002,
                    )
                    if (
                        alias_scalars != (0x20AC, 0x00E9, 0x2014, 0x110002, 0x03B1, 0x044F, 0x110007)
                        or extended_alias_scalars != expected_extended_alias_scalars
                    ):
                        raise AssertionError(
                            "X.Org named Unicode keysyms did not map to their expected Unicode scalars: "
                            + repr({"existing": alias_scalars, "extended": extended_alias_scalars})
                        )
                    dead_action_markers = tuple(
                        child_u32_at("xkb_unicode_levels", keycode * 128)
                        for keycode in (237, 238, 239)
                    )
                    if dead_action_markers != (0x110008, 0x11000D, 0x110012):
                        raise AssertionError(
                            "additional XKB dead keys did not resolve to their combining-mark actions: "
                            + repr(dead_action_markers)
                        )
                    # AC01 is XKB keycode 38 (evdev 30). The first level
                    # produces U+00E9 and Shift selects supplementary U+1F600.
                    key_step(1500, 30, "XKB U00E9 inserts a two-byte UTF-8 scalar")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1502, 1, 0, 0, 0))
                    )
                    key_step(1510, 30, "XKB U1F600 inserts a four-byte UTF-8 scalar")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1520, 0, 0, 0, 0))
                    )
                    key_step(1530, 31, "named EuroSign inserts U+20AC")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1540, 1, 0, 0, 0))
                    )
                    key_step(1550, 31, "named eacute inserts U+00E9")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1560, 0, 0, 0, 0))
                    )
                    key_step(1570, 32, "named emdash inserts U+2014")
                    key_step(1572, 44, "Greek_alpha inserts U+03B1")
                    key_step(1574, 45, "Cyrillic_ya inserts U+044F")
                    before_compose = child_u32("doc_length")
                    key_step(1576, 46, "Multi_key starts a Compose sequence")
                    if child_u32("doc_compose_active") != 1:
                        raise AssertionError("Multi_key did not activate Compose state")
                    key_step(1578, 24, "Compose buffers the first symbol o")
                    if (
                        child_u32("doc_compose_active") != 1
                        or child_u32("doc_compose_first") != ord("o")
                        or child_u32("doc_length") != before_compose
                    ):
                        raise AssertionError("Compose did not buffer its first symbol without inserting it")
                    key_step(1579, 18, "Compose o e inserts the œ ligature")
                    if (
                        child_u32("doc_compose_active") != 0
                        or child_u32("doc_compose_first") != 0
                        or child_u32("doc_length") != before_compose + 2
                    ):
                        raise AssertionError("Compose o e did not resolve to one two-byte UTF-8 scalar")
                    # New default-table entries: punctuation, quotation, and
                    # a non-ASCII Latin character. These are verified as UTF-8
                    # document insertions, independently of font glyph coverage.
                    before_pair = child_u32("doc_length")
                    key_step(1580, 46, "Multi_key starts ellipsis composition")
                    key_step(1581, 225, "Compose buffers period")
                    key_step(1582, 225, "Compose period period inserts ellipsis")
                    if child_u32("doc_length") != before_pair + 3:
                        raise AssertionError("period period did not insert U+2026")

                    before_pair = child_u32("doc_length")
                    key_step(1583, 46, "Multi_key starts capital sharp-S composition")
                    key_step(1584, 226, "Compose buffers capital S")
                    key_step(1585, 226, "Compose capital S capital S inserts ẞ")
                    if child_u32("doc_length") != before_pair + 3:
                        raise AssertionError("capital S capital S did not insert U+1E9E")

                    before_pair = child_u32("doc_length")
                    key_step(1586, 46, "Multi_key starts angle quotation composition")
                    key_step(1587, 225, "Compose buffers period for angle quotation")
                    key_step(1588, 227, "Compose period greater inserts single right angle quote")
                    if child_u32("doc_length") != before_pair + 3:
                        raise AssertionError("period greater did not insert U+203A")

                    # Three-symbol sequences hold the second input only
                    # when it prefixes one of the shipped X.Org Compose triples.
                    before_triple = child_u32("doc_length")
                    key_step(1589, 46, "Multi_key starts an en-dash sequence")
                    key_step(1590, 228, "Compose buffers first minus")
                    key_step(1591, 228, "Compose buffers second minus as a triple prefix")
                    if (
                        child_u32("doc_compose_active") != 1
                        or child_u32("doc_compose_first") != ord("-")
                        or child_u32("doc_compose_second") != ord("-")
                        or child_u32("doc_length") != before_triple
                    ):
                        raise AssertionError("Compose did not retain its recognized three-key prefix")
                    key_step(1592, 225, "Compose minus minus period inserts en dash")
                    if child_u32("doc_compose_active") != 0 or child_u32("doc_length") != before_triple + 3:
                        raise AssertionError("minus minus period did not insert U+2013")

                    before_triple = child_u32("doc_length")
                    key_step(1593, 46, "Multi_key starts an em-dash sequence")
                    key_step(1594, 228, "Compose buffers first minus for em dash")
                    key_step(1595, 228, "Compose buffers second minus for em dash")
                    key_step(1596, 228, "Compose minus minus minus inserts em dash")
                    if child_u32("doc_compose_active") != 0 or child_u32("doc_length") != before_triple + 3:
                        raise AssertionError("minus minus minus did not insert U+2014")

                    before_fallback = child_u32("doc_length")
                    key_step(1600, 46, "Multi_key starts a literal-fallback sequence")
                    key_step(1601, 17, "Compose buffers w as its first symbol")
                    key_step(1602, 17, "unknown Compose w w pair preserves both symbols")
                    if (
                        child_u32("doc_compose_active") != 0
                        or child_u32("doc_length") != before_fallback + 2
                    ):
                        raise AssertionError("unsupported Compose pair did not preserve both literal symbols")
                    client.sendall(buffer_release_message())
                    unicode_state = read_document_state()
                    expected_unicode = (
                        b"\xc3\xa9\xf0\x9f\x98\x80"
                        b"\xe2\x82\xac\xc3\xa9\xe2\x80\x94"
                        b"\xce\xb1\xd1\x8f\xc5\x93"
                        b"\xe2\x80\xa6\xe1\xba\x9e\xe2\x80\xba"
                        b"\xe2\x80\x93\xe2\x80\x94ww\xc3\xa9g\xcc\x81"
                    )
                    before_dead_key = child_u32("doc_length")
                    key_step(1610, 33, "named dead_acute arms an acute accent")
                    if child_u32("doc_pending_dead_mark") != 0x301 or child_u32("doc_length") != before_dead_key:
                        raise AssertionError("dead_acute inserted bytes instead of arming an accent")
                    key_step(1620, 18, "dead_acute plus e composes to eacute")
                    if child_u32("doc_pending_dead_mark") != 0:
                        raise AssertionError("successful dead-key composition did not clear pending state")
                    if child_u32("doc_length") != before_dead_key + 2:
                        raise AssertionError("dead_acute + e did not insert one composed UTF-8 character")
                    key_step(1630, 33, "dead_acute arms combining-mark fallback")
                    key_step(1640, 34, "unsupported dead-key pair preserves base and combining mark")
                    composed_state = read_document_state()
                    if composed_state.get("doc_contents") != expected_unicode:
                        raise AssertionError(
                            "dead-key composition/fallback produced unexpected UTF-8: "
                            f"{composed_state.get('doc_contents')!r}"
                        )
                    length_before_cancel = child_u32("doc_length")
                    key_step(1650, 33, "dead_acute can be canceled")
                    key_step(1660, 14, "Backspace cancels a pending dead key")
                    if child_u32("doc_pending_dead_mark") != 0 or child_u32("doc_length") != length_before_cancel:
                        raise AssertionError("Backspace deleted document text instead of canceling the pending accent")
                    key_step(1670, 33, "dead_acute arms Escape cancellation")
                    key_step(1680, 1, "Escape cancels a pending dead key")
                    if child_u32("doc_pending_dead_mark") != 0 or child_u32("doc_length") != length_before_cancel:
                        raise AssertionError("Escape changed document text instead of canceling the pending accent")
                    key_step(1690, 46, "Multi_key arms Compose Escape cancellation")
                    key_step(1700, 17, "Compose buffers w before Escape")
                    if child_u32("doc_compose_active") != 1:
                        raise AssertionError("Compose state was not active before Escape cancellation")
                    key_step(1710, 1, "Escape cancels a pending Compose sequence")
                    if child_u32("doc_compose_active") != 0 or child_u32("doc_compose_first") != 0 or child_u32("doc_length") != length_before_cancel:
                        raise AssertionError("Escape did not cancel Compose without inserting or deleting text")
                    key_step(1700, 46, "Multi_key arms Compose Backspace cancellation")
                    key_step(1710, 228, "Compose buffers first minus before Backspace")
                    key_step(1720, 228, "Compose buffers second minus before Backspace")
                    if child_u32("doc_compose_second") != ord("-"):
                        raise AssertionError("Compose triple prefix was not pending before Backspace")
                    key_step(1730, 14, "Backspace cancels a buffered Compose triple prefix")
                    if (
                        child_u32("doc_compose_active") != 0
                        or child_u32("doc_compose_first") != 0
                        or child_u32("doc_compose_second") != 0
                        or child_u32("doc_length") != length_before_cancel
                    ):
                        raise AssertionError("Backspace did not cancel the buffered Compose prefix")

                    # Additional common two-symbol pairs exercise degree,
                    # paragraph, registered, and Scandinavian-letter output.
                    added_compose = (
                        (24, 24, b"\xc2\xb0", "o o -> degree sign"),
                        (25, 25, b"\xc2\xb6", "p p -> paragraph sign"),
                        (19, 24, b"\xc2\xae", "r o -> registered sign"),
                        (53, 24, b"\xc3\xb8", "/ o -> ø"),
                    )
                    for index, (first, second, encoded, label) in enumerate(added_compose):
                        serial = 1730 + index * 10
                        key_step(serial, 46, f"Multi_key starts {label}")
                        key_step(serial + 2, first, f"Compose first symbol for {label}")
                        key_step(serial + 4, second, f"Compose resolves {label}")
                        expected_unicode += encoded
                    expanded_compose_state = read_document_state()
                    if expanded_compose_state.get("doc_contents") != expected_unicode:
                        raise AssertionError(
                            "expanded Compose pairs produced unexpected UTF-8: "
                            + repr(expanded_compose_state.get("doc_contents"))
                        )

                    # Exercise non-Latin and recent named keysyms through the
                    # real keyboard-event path, not only parser memory.
                    extended_typed = (
                        (212, b"\xd8\xa7", "Arabic alef U+0627"),
                        (213, b"\xd7\x90", "Hebrew alef U+05D0"),
                        (214, b"\xe0\xb8\x81", "Thai ko kai U+0E01"),
                        (215, b"\xe3\x84\xb1", "Hangul kiyeok U+3131"),
                        (216, b"\xd4\xb1", "Armenian ayb U+0531"),
                        (217, b"\xe1\x83\x90", "Georgian an U+10D0"),
                        (218, b"\xe3\x82\xa1", "Katakana small a U+30A1"),
                        (219, b"\xe0\xb6\x85", "Sinhala a U+0D85"),
                        (220, b"\xe2\xa3\xbf", "Braille pattern dots-12345678 U+28FF"),
                        (221, b"\xe1\xba\x9e", "German capital sharp S U+1E9E"),
                        (222, b"\xe2\x80\xb9", "single left angle quote U+2039"),
                        (223, b"7", "XF86 phone numeric 7"),
                    )
                    for index, (evdev_code, encoded, label) in enumerate(extended_typed):
                        key_step(1800 + index * 2, evdev_code, f"named {label} inserts UTF-8")
                        expected_unicode += encoded
                    if read_document_state().get("doc_contents") != expected_unicode:
                        raise AssertionError(
                            "expanded X.Org named-keysyms did not insert the expected UTF-8: "
                            + repr(read_document_state().get("doc_contents"))
                        )
                    apostrophe_length = child_u32("doc_length")
                    key_step(1830, 224, "new dead_apostrophe keysym arms the acute action")
                    if child_u32("doc_pending_dead_mark") != 0x301 or child_u32("doc_length") != apostrophe_length:
                        raise AssertionError("dead_apostrophe did not enter the existing acute-mark path")
                    key_step(1832, 18, "dead_apostrophe plus e composes to eacute")
                    expected_unicode += b"\xc3\xa9"
                    if read_document_state().get("doc_contents") != expected_unicode:
                        raise AssertionError(
                            "dead_apostrophe composition produced unexpected UTF-8: "
                            + repr(read_document_state().get("doc_contents"))
                        )
                    # Extended dead-key actions share the pending-mark path.
                    macron_length = child_u32("doc_length")
                    key_step(1840, 229, "dead_macron arms U+0304")
                    if child_u32("doc_pending_dead_mark") != 0x304 or child_u32("doc_length") != macron_length:
                        raise AssertionError("dead_macron did not arm the combining macron")
                    key_step(1842, 18, "dead_macron plus e composes to U+0113")
                    expected_unicode += b"\xc4\x93"

                    caron_length = child_u32("doc_length")
                    key_step(1850, 230, "dead_caron arms U+030C")
                    if child_u32("doc_pending_dead_mark") != 0x30C or child_u32("doc_length") != caron_length:
                        raise AssertionError("dead_caron did not arm the combining caron")
                    key_step(1852, 18, "dead_caron plus e composes to U+011B")
                    expected_unicode += b"\xc4\x9b"

                    fallback_length = child_u32("doc_length")
                    key_step(1860, 231, "dead_belowdot arms U+0323")
                    if child_u32("doc_pending_dead_mark") != 0x323 or child_u32("doc_length") != fallback_length:
                        raise AssertionError("dead_belowdot did not arm the combining dot below")
                    key_step(1862, 17, "dead_belowdot plus w uses combining fallback")
                    expected_unicode += b"w\xcc\xa3"
                    final_dead_state = read_document_state()
                    if final_dead_state.get("doc_contents") != expected_unicode:
                        raise AssertionError(
                            "expanded dead-key composition/fallback produced unexpected UTF-8: "
                            + repr(final_dead_state.get("doc_contents"))
                        )
                    observations.append(
                        "XKB Uxxxx scalars, full X.Org Unicode-annotated keysym aliases, Arabic/Hebrew/Thai/Hangul/Armenian/Georgian/Kana/Sinhala/Braille, xorgproto 2026.1 names, dead_apostrophe, macron, caron, and below-dot composition verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if right_alt_compose_test:
                    if child_u32("keymap_format") != 1:
                        raise AssertionError("Right Alt Compose fixture did not activate the parsed XKB keymap")
                    key_step(900, 100, "Right Alt mapped to Multi_key")
                    if child_u32("doc_compose_active") != 1 or child_u32("doc_length") != 0:
                        raise AssertionError(
                            "Right Alt Multi_key was consumed as a modifier instead of starting Compose: "
                            + repr({
                                "compose_active": child_u32("doc_compose_active"),
                                "doc_length": child_u32("doc_length"),
                            })
                        )
                    key_step(902, 1, "Escape cancels Right Alt Compose")
                    if child_u32("doc_compose_active") != 0 or child_u32("doc_length") != 0:
                        raise AssertionError("Escape did not cancel the Right Alt Compose sequence")
                    observations.append(
                        "Right Alt mapped to Multi_key reaches Compose dispatch and Escape cancels it cleanly"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if right_alt_level3_test:
                    if child_u32("keymap_format") != 1:
                        raise AssertionError("Right Alt LevelThree fixture did not activate the parsed XKB keymap")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1000, 1000, 100, 1))
                    )
                    key_step(1002, 16, "Right Alt mapped to ISO_Level3_Shift")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1004, 1004, 100, 0))
                        + buffer_release_message()
                    )
                    contents = read_document_state()["doc_contents"]
                    if contents != b"@":
                        raise AssertionError(
                            "Right Alt mapped to ISO_Level3_Shift did not select LevelThree: "
                            + repr(contents)
                        )
                    observations.append(
                        "Right Alt mapped to ISO_Level3_Shift activates LevelThree and selects the expected third-level symbol"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if keyboard_layout_test:
                    # XKB keycode 24 is evdev 16. Group 1 maps it to 'a',
                    # Shift maps it to 'A', and Group 2 remaps it to 'q'.
                    key_step(1000, 16, "XKB group-one base symbol")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1001, 1, 0, 0, 0))
                    )
                    key_step(1002, 16, "XKB alphabetic Shift level")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1003, 0, 0, 0, 1))
                    )
                    key_step(1004, 16, "XKB second layout group")
                    # This fixture maps RALT to NoSymbol/Alt_L, not
                    # ISO_Level3_Shift. Use the compositor's Mod5 state instead
                    # of assuming evdev keycode 100 is always LevelThree.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1005, 128, 0, 0, 0))
                    )
                    key_step(1006, 16, "XKB FOUR_LEVEL_ALPHABETIC compositor Mod5 symbol")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1007, 0, 0, 0, 0))
                        + buffer_release_message()
                    )
                    # LevelThree is commonly a virtual modifier resolved to
                    # real Mod5 by the compositor. It must work even when a
                    # different physical key generated that modifier state.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1010, 0, 0, 0, 0))
                        + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1011, 128, 0, 0, 0))
                    )
                    key_step(1012, 16, "XKB LevelThree from compositor Mod5 mask")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1014, 0, 0, 0, 0))
                    )
                    # Verify every remaining ASCII letter using its evdev
                    # position and the parsed XKB keycode/symbol entries.
                    key_step(1020, 17, "XKB letter w")
                    key_step(1022, 18, "XKB letter e")
                    key_step(1024, 19, "XKB letter r")
                    key_step(1026, 20, "XKB letter t")
                    key_step(1028, 21, "XKB letter y")
                    key_step(1030, 22, "XKB letter u")
                    key_step(1032, 23, "XKB letter i")
                    key_step(1034, 24, "XKB letter o")
                    key_step(1036, 25, "XKB letter p")
                    key_step(1038, 30, "XKB letter a")
                    key_step(1040, 31, "XKB letter s")
                    key_step(1042, 32, "XKB letter d")
                    key_step(1044, 33, "XKB letter f")
                    key_step(1046, 34, "XKB letter g")
                    key_step(1048, 35, "XKB letter h")
                    key_step(1050, 36, "XKB letter j")
                    key_step(1052, 37, "XKB letter k")
                    key_step(1054, 38, "XKB letter l")
                    key_step(1056, 44, "XKB letter z")
                    key_step(1058, 45, "XKB letter x")
                    key_step(1060, 46, "XKB letter c")
                    key_step(1062, 47, "XKB letter v")
                    key_step(1064, 48, "XKB letter b")
                    key_step(1066, 49, "XKB letter n")
                    key_step(1068, 50, "XKB letter m")
                    # Verify the common separate Caps/Shift type: Caps alone
                    # selects level 4, Shift+Caps level 1, LevelThree level 3,
                    # Shift+LevelThree level 4, and Caps+LevelThree level 3.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1070, 0, 0, 2, 0))
                    )
                    key_step(1072, 21, "SEPARATE type Caps selects level 4")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1074, 1, 0, 2, 0))
                    )
                    key_step(1076, 21, "SEPARATE type Shift+Caps selects level 1")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1078, 0, 0, 0, 0))
                        + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1080, 128, 0, 0, 0))
                    )
                    key_step(1082, 21, "SEPARATE type LevelThree selects level 3")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1084, 129, 0, 0, 0))
                    )
                    key_step(1086, 21, "SEPARATE type Shift+LevelThree selects level 4")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1088, 128, 0, 2, 0))
                    )
                    key_step(1090, 21, "SEPARATE type Caps+LevelThree selects level 3")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1092, 129, 0, 2, 0))
                    )
                    key_step(1094, 21, "SEPARATE type Shift+Caps+LevelThree selects level 3")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1096, 0, 0, 0, 0))
                    )
                    # The normal xkbcomp output uses shorthand arrays for
                    # number-row keys. Depress Shift and verify all twelve
                    # shifted digit-row/punctuation symbols.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1100, 1, 0, 0, 0))
                    )
                    key_step(1120, 2, "XKB shifted number-row key 2")
                    key_step(1122, 3, "XKB shifted number-row key 3")
                    key_step(1124, 4, "XKB shifted number-row key 4")
                    key_step(1126, 5, "XKB shifted number-row key 5")
                    key_step(1128, 6, "XKB shifted number-row key 6")
                    key_step(1130, 7, "XKB shifted number-row key 7")
                    key_step(1132, 8, "XKB shifted number-row key 8")
                    key_step(1134, 9, "XKB shifted number-row key 9")
                    key_step(1136, 10, "XKB shifted number-row key 10")
                    key_step(1138, 11, "XKB shifted number-row key 11")
                    key_step(1140, 12, "XKB shifted number-row key 12")
                    key_step(1142, 13, "XKB shifted number-row key 13")
                    # Cover the shifted punctuation rows as real key events,
                    # not just the embedded glyph table. Shift remains active.
                    key_step(1144, 41, "XKB shifted grave/tilde key")
                    key_step(1146, 26, "XKB shifted bracket-left/brace-left key")
                    key_step(1148, 27, "XKB shifted bracket-right/brace-right key")
                    key_step(1150, 39, "XKB shifted semicolon/colon key")
                    key_step(1152, 40, "XKB shifted apostrophe/quote key")
                    key_step(1154, 51, "XKB shifted comma/less-than key")
                    key_step(1156, 52, "XKB shifted period/greater-than key")
                    key_step(1158, 53, "XKB shifted slash/question key")
                    key_step(1160, 83, "XKB ONE_LEVEL keypad key ignores Shift")
                    # Canonical KEYPAD is controlled by Shift XOR NumLock:
                    # either alone selects level 2; both select level 1.
                    key_step(1162, 82, "XKB KEYPAD Shift selects numeric level")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1164, 0, 0, 16, 0))
                    )
                    key_step(1166, 82, "XKB KEYPAD NumLock selects numeric level")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1168, 1, 0, 16, 0))
                    )
                    key_step(1170, 82, "XKB KEYPAD Shift cancels NumLock")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1172, 0, 0, 0, 0))
                    )
                    # This name is intentionally unlike every conventional type.
                    # The exact parsed map must choose all eight XKB levels.
                    # A key assigned an arbitrary type name still counts as
                    # alphabetic for keymap usability, and its declared Shift
                    # map must select Level2 instead of a name-derived family.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1174, 1, 0, 0, 0))
                    )
                    key_step(1175, 17, "CUSTOM_ALPHA Shift selects its declared Level2")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1177, 0, 0, 0, 0))
                    )
                    custom_states = (
                        (0, 0, "base"),
                        (1, 0, "Shift"),
                        (32, 0, "Mod3"),
                        (33, 0, "Shift+Mod3"),
                        (0, 2, "Lock"),
                        (1, 2, "Shift+Lock"),
                        (32, 2, "Mod3+Lock"),
                        (33, 2, "Shift+Mod3+Lock"),
                        (0, 0x80000000, "V23 bit31"),
                    )
                    custom_serial = 1180
                    for depressed, locked, label in custom_states:
                        client.sendall(
                            wire_message(keyboard_object_id, 4,
                                struct.pack("<IIIII", custom_serial, depressed, 0, locked, 0)
                            )
                        )
                        key_step(
                            custom_serial + 1, 50,
                            "CUSTOM_EIGHT_LEVEL " + label + " selects its declared Level"
                        )
                        custom_serial += 10
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", custom_serial, 0, 0, 0, 0))
                    )
                    # The key's virtualModifiers entry plus modifier_map Mod4
                    # must produce effective V03=Mod4 and select Level2.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", custom_serial + 2, 80, 0, 0, 0))
                    )
                    key_step(custom_serial + 3, 49, "implicit V03 from modifier_map selects CUSTOM_IMPLICIT Level2")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", custom_serial + 5, 0, 0, 0, 0))
                    )
                    # Alt_L is resolved indirectly to RALT (Group1/Level1);
                    # the lower keycode RCTL only has it on Level2, while
                    # AD12 has it in Group2. None { <RALT> } above must not
                    # delete the keysym-kind binding.
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", custom_serial + 7, 8, 0, 0, 0))
                    )
                    key_step(custom_serial + 8, 47, "indirect Alt_L modifier_map selects CUSTOM_INDIRECT Level2")
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", custom_serial + 10, 0, 0, 0, 0))
                    )
                    workflow_shortcut(1300, 31, "Ctrl+S saves XKB-translated text")

                    workflow_shortcut(1380, 30, "preserved Control keeps Ctrl+A active")
                    if child_u32("doc_selection_active") != 1:
                        raise AssertionError(
                            "XKB preserve[Control] did not keep Ctrl+A available as a shortcut"
                        )
                    key_step(1390, 106, "collapse selection after preserved Ctrl+A")
                    if child_u32("doc_selection_active") != 0:
                        raise AssertionError("Right did not collapse the preserved Ctrl+A selection")

                    consumed_before = read_document_state()
                    workflow_shortcut(1400, 44, "consumed Control suppresses Ctrl+Z")
                    consumed_after = read_document_state()
                    if (
                        len(consumed_after["doc_contents"])
                        != len(consumed_before["doc_contents"]) + 3
                        or not consumed_after["doc_contents"].endswith(b"\xe2\x82\xac")
                    ):
                        raise AssertionError(
                            "consumed Control did not select AB01's third-level EuroSign: "
                            + repr(consumed_after["doc_contents"][-12:])
                        )
                    observations.append(
                        "XKB preserve[] keeps Control available to shortcuts while an unpreserved Control map consumes it"
                    )

                    workflow_shortcut(
                        1410, 105,
                        "consumed Shift is removed from Ctrl+Shift+Left shortcut state",
                        shift=True,
                    )
                    wait_child_u32("ctrl_down", 0, "consumed-Shift shortcut Control release")
                    wait_child_u32("shift_down", 0, "consumed-Shift shortcut Shift release")
                    if child_u32("doc_selection_active") != 0:
                        raise AssertionError(
                            "an unpreserved Shift map incorrectly retained Shift-selection behavior"
                        )

                    workflow_shortcut(
                        1420, 106,
                        "preserved Shift remains available to Ctrl+Shift+Right",
                        shift=True,
                    )
                    wait_child_u32("ctrl_down", 0, "preserved-Shift shortcut Control release")
                    wait_child_u32("shift_down", 0, "preserved-Shift shortcut Shift release")
                    if child_u32("doc_selection_active") != 1:
                        raise AssertionError(
                            "preserve[Shift] did not retain Shift-selection behavior"
                        )
                    key_step(1430, 106, "collapse selection after preserved Shift check")
                    if child_u32("doc_selection_active") != 0:
                        raise AssertionError("Right did not collapse the preserved Shift selection")
                    observations.append(
                        "XKB consumed Shift is filtered from shortcuts while preserve[Shift] keeps it"
                    )

                    # Give the initial insertion a generous deterministic window.
                    # Repeat-enabled cases shorten this delay again while the key
                    # is held, verifying wl_keyboard.repeat_info reconfiguration.
                    client.sendall(
                        wire_message(keyboard_object_id, 5, struct.pack("<ii", 10, 1200))
                    )

                    def check_key_repeat_policy(
                        keycode: int, serial: int, should_repeat: bool, label: str
                    ) -> None:
                        before_cursor = child_u32("doc_cursor")
                        client.sendall(
                            wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial, serial, keycode, 1)
                            )
                        )
                        workflow_redraw(label + " initial key press")
                        client.sendall(buffer_release_message())
                        wait_child_u32(
                            "doc_cursor", before_cursor + 1,
                            label + " initial symbol insertion",
                        )
                        if should_repeat:
                            wait_child_u32(
                                "repeat_keycode", keycode,
                                label + " starts the XKB-permitted repeat timer",
                            )
                            # Reconfigure an already-held repeat key. The client
                            # must restart its timer with the compositor's new delay.
                            client.sendall(
                                wire_message(keyboard_object_id, 5, struct.pack("<ii", 10, 180))
                            )
                            repeat_deadline = time.monotonic() + 1.5
                            while (
                                child_u32("doc_cursor") <= before_cursor + 1
                                and time.monotonic() < repeat_deadline
                            ):
                                time.sleep(0.005)
                            if child_u32("doc_cursor") <= before_cursor + 1:
                                raise AssertionError(
                                    label + " was marked repeatable but no repeated edit arrived"
                                )
                            workflow_redraw(label + " repeated key")
                            client.sendall(buffer_release_message())
                        else:
                            if child_u32("repeat_keycode") != 0:
                                raise AssertionError(
                                    label + " incorrectly started a repeat timer: "
                                    + str(child_u32("repeat_keycode"))
                                )
                            # The compositor's test policy is 180 ms before
                            # repeat. Hold beyond that delay and verify the
                            # repeat-disabled key produced only its first symbol.
                            time.sleep(0.4)
                            if child_u32("doc_cursor") != before_cursor + 1:
                                raise AssertionError(
                                    label + " repeated despite XKB repeat=False: "
                                    + str(child_u32("doc_cursor"))
                                )
                        client.sendall(
                            wire_message(keyboard_object_id, 3,
                                struct.pack("<IIII", serial + 1, serial + 1, keycode, 0),
                            )
                            + buffer_release_message()
                        )
                        wait_child_u32(
                            "repeat_keycode", 0, label + " key release cancels repeat"
                        )

                    # These keycodes are mapped in the custom fixture:
                    # RPT0 inherits interpret.repeat=False (Mod1),
                    # RPT1 overrides it to True (Mod2),
                    # RPT2 explicitly overrides compat True with key repeat=False,
                    # and RPT3 explicitly overrides the default False with True.
                    check_key_repeat_policy(202, 1320, False, "RPT0 inherited compatibility repeat=False")
                    check_key_repeat_policy(203, 1330, True, "RPT1 compatibility repeat=True")
                    check_key_repeat_policy(204, 1340, False, "RPT2 explicit key repeat=False")
                    check_key_repeat_policy(205, 1350, True, "RPT3 explicit key repeat=True")

                    # RPT4 is a defined keycode with no Group1/Level1 symbol.
                    # The fallback interpretation therefore must not enable it.
                    before_symbol_less_cursor = child_u32("doc_cursor")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1360, 1360, 206, 1))
                    )
                    wait_child_u32("keyboard_serial", 1360, "symbol-less RPT4 keydown")
                    time.sleep(0.4)
                    if (
                        child_u32("repeat_keycode") != 0
                        or child_u32("doc_cursor") != before_symbol_less_cursor
                    ):
                        raise AssertionError(
                            "symbol-less RPT4 unexpectedly inserted text or started repeat"
                        )
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1361, 1361, 206, 0))
                        + buffer_release_message()
                    )
                    wait_child_u32("keyboard_serial", 1361, "symbol-less RPT4 keyup")
                    wait_child_u32("repeat_keycode", 0, "symbol-less RPT4 release")

                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "XKB exact type maps, compositor-owned modifiers, compatibility and explicit per-key repeat precedence, symbol-less key policy, keydown timer gating, and repeated edits verified"
                    )
                    return

                def workflow_type_path(value: str, serial: int) -> int:
                    for character in value:
                        if character not in evdev:
                            raise AssertionError(f"test path uses unsupported key: {character!r}")
                        key_step(serial, evdev[character], f"path character {character!r}")
                        serial += 2
                    return serial


                if font_picker_test:
                    # Open the picker with the synthetic font active. The name
                    # field must use hmtx advances for both pointer mapping and
                    # the visible caret, and the file row must align with its
                    # selected background band.
                    font_picker_symbols = {}
                    wanted = {
                        "picker_mode", "picker_focus", "picker_name_length",
                        "picker_name_cursor", "picker_name_view_start",
                        "picker_name_buffer", "picker_ui_font_size", "ui_transform_font_size", "picker_selected",
                        "picker_panel_width", "picker_panel_height", "picker_panel_x", "picker_panel_y",
                        "doc_font_size", "ui_font_size", "window_doc_line_height", "settings_menu_open",
                        "settings_panel_x", "settings_panel_y", "settings_panel_width", "settings_panel_height", "settings_ui_font_size",
                        "find_panel_x", "find_panel_y", "find_panel_width", "find_panel_height", "find_ui_font_size",
                        "doc_line_index_base", "doc_line_count", "doc_line_index_valid",
                        "font_loaded", "font_units_per_em", "font_num_glyphs",
                        "font_probe_A_advance", "font_file_map", "picker_error",
                    }
                    for symbol_line in subprocess.check_output(["nm", "-n", binary], text=True).splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in wanted:
                            font_picker_symbols[fields[2]] = int(fields[0], 16)
                    if set(font_picker_symbols) != wanted:
                        raise AssertionError(f"picker font-test symbols missing: {font_picker_symbols!r}")

                    def picker_u32(name: str) -> int:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            raw = os.pread(memory.fileno(), 4, font_picker_symbols[name])
                        return struct.unpack("<I", raw)[0]

                    def picker_bytes(name: str, length: int) -> bytes:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            raw = os.pread(memory.fileno(), length, font_picker_symbols[name])
                        return raw.split(bytes((0,)), 1)[0]

                    def picker_u64(name: str) -> int:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            raw = os.pread(memory.fileno(), 8, font_picker_symbols[name])
                        return struct.unpack("<Q", raw)[0]

                    def settings_click(design_x: int, design_y: int, serial: int, label: str) -> None:
                        panel_x = picker_u32("settings_panel_x")
                        panel_y = picker_u32("settings_panel_y")
                        panel_width = picker_u32("settings_panel_width")
                        panel_height = picker_u32("settings_panel_height")
                        surface_x = panel_x + (design_x - 160) * panel_width // 256
                        surface_y = panel_y + (design_y - 32) * panel_height // 192
                        workflow_click(surface_x, surface_y, serial, label)

                    workflow_click(120, 12, 2600, "font picker: open File menu")
                    workflow_click(120, 44, 2610, "font picker: open Open dialog")
                    if picker_u32("picker_mode") != 1:
                        raise AssertionError("font picker test could not open the Open dialog")
                    if (
                        picker_u32("picker_ui_font_size") != 10
                        or picker_u32("ui_transform_font_size") != 10
                        or picker_u32("picker_panel_width") != 744
                        or picker_u32("picker_panel_height") != 424
                        or picker_u32("picker_panel_x") != 28
                        or picker_u32("picker_panel_y") != 28
                    ):
                        raise AssertionError(
                            "normal-size picker should follow the 10px UI font and use the centered 744x424 panel: "
                            f"font={picker_u32('picker_ui_font_size')}, "
                            f"panel=({picker_u32('picker_panel_x')},{picker_u32('picker_panel_y')},"
                            f"{picker_u32('picker_panel_width')},{picker_u32('picker_panel_height')})"
                        )

                    # The title must sit comfortably inside the transformed header.
                    # O's top-row second pixel is known in the embedded fallback face.
                    title_y = 28 + ((40 - 36) * 424 // 408)
                    title_ink_rows = [
                        y for y in range(title_y, title_y + 10)
                        for x in range(32, 110)
                        if struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0]
                        == 0xFFD8DEE9
                    ]
                    location_label_y = 28 + ((62 - 36) * 424 // 408)
                    location_ink_rows = [
                        y for y in range(location_label_y, location_label_y + 10)
                        for x in range(48, 124)
                        if struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0]
                        == 0xFFD8DEE9
                    ]
                    if (
                        not title_ink_rows
                        or not location_ink_rows
                        or min(title_ink_rows) < title_y
                        or min(title_ink_rows) >= title_y + 3
                        or max(title_ink_rows) >= min(location_ink_rows)
                    ):
                        raise AssertionError(
                            f"picker title/Location labels overlap or are misplaced: "
                            f"title_rows={title_ink_rows!r}, location_rows={location_ink_rows!r}"
                        )

                    # Leave breathing room between the Bytes label and its value.
                    # "Bytes " uses the mapped 4px B, four 8px fallback
                    # glyphs and its 3px SPACE. The document's "9" count starts
                    # at x=527; its central lit pixel on row 3 is x=529.
                    bytes_gap_pixel = struct.unpack_from(
                        "<I", pixels, 469 * 800 * 4 + 524 * 4
                    )[0]
                    bytes_value_pixel = struct.unpack_from(
                        "<I", pixels, 469 * 800 * 4 + 529 * 4
                    )[0]
                    if bytes_gap_pixel != 0xFF343D4B or bytes_value_pixel != 0xFFD8DEE9:
                        raise AssertionError(
                            f"byte-count label/value spacing mismatch: "
                            f"gap={hex(bytes_gap_pixel)}, value={hex(bytes_value_pixel)}"
                        )

                    # Bitmap-fallback labels and TrueType field contents share a
                    # baseline; the Search label starts on the transformed 368px row.
                    search_label_y = 28 + ((368 - 36) * 424 // 408)
                    if not antialiased_ink_present(44, search_label_y, 72, 10):
                        raise AssertionError(
                            f"Search label is not visible at its transformed baseline: y={search_label_y}"
                        )

                    # Focus accents are underlines at the bottom of each field,
                    # not rules overlaid on the top edge.
                    workflow_click(200, 90, 2615, "focus picker path field")
                    path_top_y = 28 + ((80 - 36) * 424 // 408)
                    path_bottom_y = 28 + ((107 - 36) * 424 // 408)
                    path_top_pixel = struct.unpack_from(
                        "<I", pixels, path_top_y * 800 * 4 + 200 * 4
                    )[0]
                    path_underline_pixel = struct.unpack_from(
                        "<I", pixels, path_bottom_y * 800 * 4 + 200 * 4
                    )[0]
                    if path_top_pixel != 0xFF252A33 or path_underline_pixel != 0xFF78A9D4:
                        raise AssertionError(
                            f"path-field underline geometry mismatch: top={hex(path_top_pixel)}, "
                            f"bottom={hex(path_underline_pixel)}"
                        )

                    workflow_click(200, 378, 2620, "focus filename search field")
                    # The fixture maps uppercase A/B to distinct 7px/4px advances.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 2628, 2628, 42, 1))
                        + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 2629, 1, 0, 0, 0))
                    )
                    key_step(2630, 30, "type uppercase A in font picker field")
                    key_step(2632, 48, "type uppercase B in font picker field")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 2634, 2634, 42, 0))
                        + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 2635, 0, 0, 0, 0))
                        + buffer_release_message()
                    )
                    name = picker_bytes("picker_name_buffer", 64)
                    cursor = picker_u32("picker_name_cursor")
                    if name != b"AB" or cursor != 2 or picker_u32("picker_focus") != 2:
                        raise AssertionError(
                            f"font picker input state mismatch: name={name!r}, cursor={cursor}, "
                            f"focus={picker_u32('picker_focus')}"
                        )

                    # Synthetic hmtx: A=650/1000em and B=400/1000em.
                    # At a 10px rendered em these round to 7px + 4px.
                    expected_caret_x_design = 176 + ((650 * 10 + 500) // 1000) + ((400 * 10 + 500) // 1000)
                    expected_caret_x = 28 + ((expected_caret_x_design - 40) * 744 // 720)
                    caret_y = 28 + ((365 - 36) * 424 // 408)
                    focus_top_y = 28 + ((360 - 36) * 424 // 408)
                    focus_bottom_y = 28 + ((387 - 36) * 424 // 408)
                    caret_pixel = struct.unpack_from("<I", pixels, caret_y * 800 * 4 + expected_caret_x * 4)[0]
                    focus_top_pixel = struct.unpack_from("<I", pixels, focus_top_y * 800 * 4 + 200 * 4)[0]
                    focus_line_pixel = struct.unpack_from("<I", pixels, focus_bottom_y * 800 * 4 + 200 * 4)[0]
                    if (
                        caret_pixel != 0xFFF0F3F7
                        or focus_top_pixel != 0xFF252A33
                        or focus_line_pixel != 0xFF78A9D4
                    ):
                        raise AssertionError(
                            f"font picker caret/focus geometry mismatch: caret=({expected_caret_x},{hex(caret_pixel)}), "
                            f"top={hex(focus_top_pixel)}, underline={hex(focus_line_pixel)}"
                        )

                    # Use the same proportional 10px metrics for pointer hit-testing.
                    workflow_click(186, 378, 2640, "proportional click after second glyph")
                    if picker_u32("picker_name_cursor") != 2:
                        raise AssertionError(
                            f"picker hit-testing did not use proportional advances: cursor={picker_u32('picker_name_cursor')}"
                        )

                    # Select row 1 (the fixture file named AB, after nested-dir).
                    workflow_click(110, 160, 2650, "select AB row in Open picker")
                    if picker_u32("picker_selected") != 1 or picker_u32("picker_focus") != 0:
                        raise AssertionError("picker row click did not select the expected AB entry")
                    selected_row_top = 28 + ((160 - 36) * 424 // 408)
                    selected_row_height = (16 * 424 + 408 - 1) // 408
                    selected_row_bottom = selected_row_top + selected_row_height
                    top_fill = struct.unpack_from(
                        "<I", pixels, selected_row_top * 800 * 4 + 58 * 4
                    )[0]
                    bottom_fill = struct.unpack_from(
                        "<I", pixels, (selected_row_bottom - 1) * 800 * 4 + 58 * 4
                    )[0]
                    if top_fill != 0xFF414B5A or bottom_fill != 0xFF414B5A:
                        raise AssertionError(
                            f"selected row highlight is not aligned to its transformed 16px row: "
                            f"{hex(top_fill)}/{hex(bottom_fill)}"
                        )
                    # Inspect pixels above the selected band as well as inside it.
                    # Comparing against the actual row background makes this a real
                    # containment check rather than a range check over the band itself.
                    glyph_rows = []
                    for y in range(selected_row_top - 2, selected_row_bottom):
                        expected_background = (
                            0xFF414B5A
                            if selected_row_top <= y < selected_row_bottom
                            else 0xFF252A33
                        )
                        for x in range(94, 110):
                            pixel = struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0]
                            if pixel != expected_background:
                                glyph_rows.append(y)
                    if not glyph_rows or min(glyph_rows) < selected_row_top or max(glyph_rows) >= selected_row_bottom:
                        raise AssertionError(
                            f"AB filename glyphs escaped their selected row: "
                            f"band=({selected_row_top},{selected_row_bottom}), ink_rows={glyph_rows!r}"
                        )
                    # Close the picker and exercise runtime document typography.
                    key_step(2670, 1, "close picker before changing document font size")
                    if picker_u32("picker_mode") != 0:
                        raise AssertionError("Escape did not close the Open picker")
                    if picker_u32("doc_font_size") != 12 or picker_u32("window_doc_line_height") != 15:
                        raise AssertionError("synthetic font should start at 12px with a 15px metric-derived line pitch")

                    serial = 2700
                    if picker_u32("ui_font_size") != 10:
                        raise AssertionError("UI font size must start at its independent 10px default")
                    workflow_click(200, 20, serial, "open Settings for document font-size adjustment")
                    serial += 10
                    if picker_u32("settings_menu_open") != 1:
                        raise AssertionError("Settings did not remain open after opening")
                    for index in range(10):
                        workflow_settings_click(400, 76, serial, f"increase document font size {index + 1} without closing Settings")
                        serial += 10
                        if picker_u32("settings_menu_open") != 1:
                            raise AssertionError("document font-size adjustment unexpectedly closed Settings")
                    if (
                        picker_u32("doc_font_size") != 32
                        or picker_u32("window_doc_line_height") != 39
                        or picker_u32("doc_line_index_valid") != 1
                    ):
                        raise AssertionError(
                            "font-size increase did not update em size, vertical metrics, and line index: "
                            f"size={picker_u32('doc_font_size')}, "
                            f"line_height={picker_u32('window_doc_line_height')}, "
                            f"index_valid={picker_u32('doc_line_index_valid')}"
                        )
                    line_base = picker_u64("doc_line_index_base")
                    with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                        large_size_record = struct.unpack("<4I", os.pread(memory.fileno(), 16, line_base))
                    if large_size_record[0:2] != (96, 3):
                        raise AssertionError(
                            f"font-size change did not rewrap the document index: {large_size_record!r}"
                        )

                    for index in range(10):
                        workflow_settings_click(360, 76, serial, f"decrease document font size {index + 1} without closing Settings")
                        serial += 10
                        if picker_u32("settings_menu_open") != 1:
                            raise AssertionError("document font-size decrease unexpectedly closed Settings")
                    if (
                        picker_u32("doc_font_size") != 12
                        or picker_u32("window_doc_line_height") != 15
                        or picker_u32("doc_line_index_valid") != 1
                    ):
                        raise AssertionError(
                            "font-size decrease did not restore default metrics: "
                            f"size={picker_u32('doc_font_size')}, "
                            f"line_height={picker_u32('window_doc_line_height')}, "
                            f"index_valid={picker_u32('doc_line_index_valid')}"
                        )
                    line_base = picker_u64("doc_line_index_base")
                    with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                        default_size_record = struct.unpack("<4I", os.pread(memory.fileno(), 16, line_base))
                    if default_size_record[0:2] != (96, 2):
                        raise AssertionError(
                            f"restoring the 12px em did not restore the visual-row index: {default_size_record!r}"
                        )

                    if picker_u32("doc_font_size") != 12:
                        raise AssertionError("UI font-size controls must not modify document font size")
                    for index in range(6):
                        settings_click(400, 100, serial, f"increase independent UI font size {index + 1}")
                        serial += 10
                        if picker_u32("settings_menu_open") != 1:
                            raise AssertionError("UI font-size increase unexpectedly closed Settings")
                    if picker_u32("ui_font_size") != 16 or picker_u32("doc_font_size") != 12:
                        raise AssertionError("UI font size did not reach 16px independently of document size")
                    if (
                        picker_u32("settings_panel_width") != 256
                        or picker_u32("settings_panel_height") != 192
                        or picker_u32("find_panel_width") != 448
                        or picker_u32("find_panel_height") != 192
                    ):
                        raise AssertionError(
                            "Settings and Find panels must retain their design dimensions when UI text grows: "
                            f"settings=({picker_u32('settings_panel_width')}, {picker_u32('settings_panel_height')}), "
                            f"find=({picker_u32('find_panel_width')}, {picker_u32('find_panel_height')})"
                        )
                    if picker_u32("settings_ui_font_size") != 16 or picker_u32("find_ui_font_size") != 16:
                        raise AssertionError(
                            "both overlay glyph sizes must follow the selected 16px UI font without enlarging panels: "
                            f"settings={picker_u32('settings_ui_font_size')}, "
                            f"find={picker_u32('find_ui_font_size')}"
                        )
                    for name in ("settings_panel", "find_panel"):
                        x = picker_u32(f"{name}_x")
                        y = picker_u32(f"{name}_y")
                        width = picker_u32(f"{name}_width")
                        height = picker_u32(f"{name}_height")
                        if abs((2 * x + width) - 800) > 1 or abs((2 * y + height) - 480) > 1:
                            raise AssertionError(
                                f"{name} is not centered in the 800x480 surface: "
                                f"x={x}, y={y}, width={width}, height={height}"
                            )
                    for index in range(6):
                        settings_click(360, 100, serial, f"decrease independent UI font size {index + 1}")
                        serial += 10
                        if picker_u32("settings_menu_open") != 1:
                            raise AssertionError("UI font-size decrease unexpectedly closed Settings")
                    if picker_u32("ui_font_size") != 10 or picker_u32("doc_font_size") != 12:
                        raise AssertionError("UI font size did not return to 10px independently")
                    # Re-open the picker at the enlarged UI setting. Its text
                    # should use the exact selected size when the window has room.
                    for index in range(6):
                        settings_click(400, 100, serial, f"raise UI font for picker follow-through {index + 1}")
                        serial += 10
                    workflow_click(120, 12, serial, "open File menu at 16px UI size")
                    serial += 10
                    workflow_click(120, 44, serial, "open picker at 16px UI size")
                    serial += 10
                    if picker_u32("picker_ui_font_size") != 16 or picker_u32("ui_transform_font_size") != 16:
                        raise AssertionError(
                            f"picker did not follow 16px UI preference: picker={picker_u32('picker_ui_font_size')}, "
                            f"transform={picker_u32('ui_transform_font_size')}"
                        )
                    # Larger UI text must still fit wholly inside the 16px
                    # directory row; the selected background is the clip oracle.
                    workflow_click(110, 160, serial, "select AB row at 16px UI size")
                    serial += 10
                    large_row_top = 28 + ((160 - 36) * 424 // 408)
                    large_row_bottom = large_row_top + ((16 * 424 + 407) // 408)
                    large_row_ink = []
                    for y in range(large_row_top - 2, large_row_bottom + 2):
                        for x in range(84, 122):
                            pixel = struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0]
                            if pixel not in (0xFF414B5A, 0xFF252A33):
                                large_row_ink.append(y)
                    if (
                        picker_u32("picker_selected") != 1
                        or not large_row_ink
                        or min(large_row_ink) < large_row_top
                        or max(large_row_ink) >= large_row_bottom
                    ):
                        raise AssertionError(
                            f"16px picker text escaped its 16px row: "
                            f"band=({large_row_top},{large_row_bottom}), ink={large_row_ink!r}, "
                            f"selected={picker_u32('picker_selected')}"
                        )
                    key_step(serial, 1, "close picker after UI font inheritance check")
                    serial += 10
                    workflow_click(200, 20, serial, "open Settings after picker font test")
                    serial += 10
                    for index in range(6):
                        settings_click(360, 100, serial, f"restore default UI font {index + 1}")
                        serial += 10
                    key_step(serial, 1, "close Settings after font-size adjustments")
                    if picker_u32("settings_menu_open") != 0:
                        raise AssertionError("Escape did not close Settings after adjustment")

                    # Font selection must be transactional. A malformed TTF
                    # cannot unmap or corrupt the currently-rendered face.
                    original_font_map = picker_u64("font_file_map")
                    original_advance = picker_u32("font_probe_A_advance")
                    original_glyph_region = bytes(
                        pixels[88 * 800 * 4 + 12 * 4 : 104 * 800 * 4 + 36 * 4]
                    )
                    workflow_click(200, 20, serial, "open Settings for runtime font selection")
                    serial += 10
                    settings_click(200, 148, serial, "open the font-file picker")
                    serial += 10
                    if picker_u32("picker_mode") != 3:
                        raise AssertionError("Settings did not open the dedicated font picker")
                    workflow_click(200, 378, serial, "focus font picker Search field")
                    serial += 10
                    serial = workflow_type_path("bad", serial)
                    key_step(serial, 15, "accept malformed TTF suggestion")
                    serial += 2
                    key_step(serial, 28, "reject malformed font without losing active face")
                    serial += 2
                    if (
                        picker_u32("picker_mode") != 3
                        or picker_u32("picker_error") != 4
                        or picker_u32("font_loaded") != 1
                        or picker_u32("font_units_per_em") != 1000
                        or picker_u32("font_probe_A_advance") != original_advance
                        or picker_u64("font_file_map") != original_font_map
                    ):
                        raise AssertionError(
                            "invalid runtime font replacement changed the active face or closed the picker: "
                            f"mode={picker_u32('picker_mode')}, error={picker_u32('picker_error')}, "
                            f"loaded={picker_u32('font_loaded')}, upem={picker_u32('font_units_per_em')}, "
                            f"A={picker_u32('font_probe_A_advance')}, map={picker_u64('font_file_map')}"
                        )
                    key_step(serial, 1, "cancel font picker after rejected candidate")
                    serial += 2
                    workflow_click(200, 20, serial, "reopen Settings for valid font replacement")
                    serial += 10
                    settings_click(200, 148, serial, "reopen font-file picker")
                    serial += 10
                    workflow_click(200, 378, serial, "focus font Search field for alternate face")
                    serial += 10
                    serial = workflow_type_path("alt", serial)
                    key_step(serial, 15, "accept alternate TTF suggestion")
                    serial += 2
                    key_step(serial, 28, "load alternate TrueType face")
                    serial += 2
                    if (
                        picker_u32("picker_mode") != 0
                        or picker_u32("font_loaded") != 1
                        or picker_u32("font_units_per_em") != 1000
                        or picker_u32("font_probe_A_advance") != 550
                        or picker_u64("font_file_map") == original_font_map
                        or picker_u32("doc_line_index_valid") != 1
                        or picker_u32("window_doc_line_height") != 15
                    ):
                        raise AssertionError(
                            "valid runtime font replacement did not commit new metrics and rebuild document layout: "
                            f"mode={picker_u32('picker_mode')}, loaded={picker_u32('font_loaded')}, "
                            f"upem={picker_u32('font_units_per_em')}, A={picker_u32('font_probe_A_advance')}, "
                            f"map={picker_u64('font_file_map')}, line={picker_u32('window_doc_line_height')}, "
                            f"index={picker_u32('doc_line_index_valid')}"
                        )
                    alternate_glyph_region = bytes(
                        pixels[88 * 800 * 4 + 12 * 4 : 104 * 800 * 4 + 36 * 4]
                    )
                    if alternate_glyph_region == original_glyph_region:
                        raise AssertionError(
                            "same glyph ID/size reused the old face's cached A bitmap after font replacement"
                        )
                    observations.append(
                        "runtime font picker filters .ttf files; malformed face rollback preserves old map/metrics; valid face switch clears glyph cache and rebuilds document layout"
                    )
                    observations.append(
                        "picker inherits UI typography; title/Location non-overlap; persistent-open Settings; independent 12–32px document and 8–16px UI font sizing verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if file_workflow:
                    # The File control must remain available in the compact editor header.
                    file_pixels = [
                        struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0]
                        for y in range(12, 20) for x in range(112, 144)
                    ]
                    if 0xFFD8DEE9 not in file_pixels:
                        raise AssertionError("the File menu control was not rendered in the header")
                    observations.append("visible File menu header control")

                    picker_symbols = {}
                    for symbol_line in subprocess.check_output(["nm", "-n", binary], text=True).splitlines():
                        fields = symbol_line.split()
                        if len(fields) == 3 and fields[2] in {"picker_mode", "picker_focus", "picker_dir_fd", "picker_error", "picker_entry_count", "picker_selected", "picker_scroll", "picker_scroll_drag", "picker_scroll_thumb_top", "picker_scroll_thumb_height", "pointer_x", "pointer_y", "pointer_inside", "picker_path_length", "picker_path_cursor", "picker_path_buffer", "picker_current_path", "picker_name_length", "picker_name_cursor", "picker_name_match", "picker_suggestion_count", "picker_suggestion_selected", "picker_suggestion_indices", "picker_edit_select_all", "picker_name_buffer", "picker_last_click_index", "window_width", "window_height", "window_buffer_width", "window_buffer_height", "window_stride", "window_buffer_id", "window_is_maximized", "window_status_top", "window_status_bytes_x", "window_status_mode_x", "window_doc_pixel_width", "window_doc_visible_rows", "doc_capacity", "doc_gap_start", "doc_gap_end", "doc_storage_error", "doc_view_top_row", "doc_scroll_drag", "doc_scroll_drag_offset", "doc_scroll_thumb_top", "doc_scroll_thumb_height", "doc_total_visual_rows", "doc_wheel_remainder",
                        "doc_hscroll_drag", "doc_hscroll_thumb_left", "doc_hscroll_thumb_width", "doc_hscroll_drag_offset", "window_doc_bottom", "picker_panel_x", "picker_panel_y", "picker_panel_width", "picker_panel_height", "path_prompt_x", "path_prompt_y", "path_prompt_width", "path_prompt_height", "picker_last_click_time", "doc_length", "doc_cursor", "doc_buffer", "current_file_path", "current_path_buffer", "picker_target_buffer", "doc_save_error", "doc_line_index_base", "doc_line_index_bytes", "doc_line_index_capacity", "doc_line_count", "doc_line_index_valid", "doc_line_index_columns", "window_surface_width", "window_surface_height", "window_ui_scale_120"}:
                            picker_symbols[fields[2]] = int(fields[0], 16)

                    def picker_state() -> dict[str, object]:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            fd = memory.fileno()
                            result: dict[str, object] = {}
                            for name, address in picker_symbols.items():
                                if name == "doc_buffer":
                                    pointer = struct.unpack("<Q", os.pread(fd, 8, address))[0]
                                    result["doc_buffer_pointer"] = pointer
                                    result[name] = os.pread(fd, 64, pointer) if pointer else b""
                                elif name in {"doc_line_index_base", "doc_line_index_bytes"}:
                                    result[name] = struct.unpack("<Q", os.pread(fd, 8, address))[0]
                                elif name in {"picker_name_buffer", "picker_path_buffer", "picker_current_path", "current_path_buffer", "picker_target_buffer"}:
                                    size = 64 if name == "picker_name_buffer" else 256
                                    result[name] = os.pread(fd, size, address).split(b"\0", 1)[0]
                                elif name == "picker_suggestion_indices":
                                    result[name] = struct.unpack("<5I", os.pread(fd, 20, address))
                                elif name == "current_file_path":
                                    pointer = struct.unpack("<Q", os.pread(fd, 8, address))[0]
                                    result[name] = pointer
                                    result["active_path"] = os.pread(fd, 4096, pointer).split(b"\0", 1)[0] if pointer else b""
                                else:
                                    result[name] = struct.unpack("<i", os.pread(fd, 4, address))[0]
                            pointer = result.get("doc_buffer_pointer", 0)
                            if pointer:
                                length = result.get("doc_length", 0)
                                gap_start = result.get("doc_gap_start", 0)
                                gap_end = result.get("doc_gap_end", 0)
                                prefix = os.pread(fd, gap_start, pointer)
                                suffix = os.pread(fd, max(0, length - gap_start), pointer + gap_end)
                                result["doc_contents"] = prefix + suffix
                            index_pointer = result.get("doc_line_index_base", 0)
                            line_count = result.get("doc_line_count", 0)
                            if index_pointer and line_count:
                                raw_index = os.pread(fd, line_count * 16, index_pointer)
                                result["doc_line_index_records"] = [
                                    struct.unpack_from("<IIII", raw_index, index * 16)
                                    for index in range(min(line_count, len(raw_index) // 16))
                                ]
                            else:
                                result["doc_line_index_records"] = []
                            return result

                    initial_editor_state = picker_state()
                    if (
                        initial_editor_state.get("window_width") != 800
                        or initial_editor_state.get("window_height") != 480
                        or initial_editor_state.get("window_buffer_width") != 800
                        or initial_editor_state.get("window_buffer_height") != 480
                        or initial_editor_state.get("window_stride") != 3200
                        or initial_editor_state.get("doc_scroll_thumb_height") != 0
                        or initial_editor_state.get("doc_view_top_row") != 0
                        or initial_editor_state.get("window_doc_pixel_width") != 760
                    ):
                        raise AssertionError(
                            f"an empty document should not expose an active editor scrollbar: {initial_editor_state!r}"
                        )

                    def assert_picker(label: str) -> None:
                        panel_pixel = struct.unpack_from("<I", pixels, 70 * 800 * 4 + 40 * 4)[0]
                        path_pixel = struct.unpack_from("<I", pixels, 75 * 800 * 4 + 60 * 4)[0]
                        if panel_pixel != 0xFF1F242D or path_pixel != 0xFF252A33:
                            raise AssertionError(
                                f"{label}: native picker not rendered; pixels="
                                f"{hex(panel_pixel)}/{hex(path_pixel)}, state={picker_state()!r}"
                            )

                    def open_picker_from_menu(serial: int, label: str) -> None:
                        workflow_click(120, 12, serial, f"{label}: open File menu")
                        workflow_click(120, 44, serial + 10, f"{label}: select File > Open")
                        assert_picker(label)

                    def save_picker_from_menu(serial: int, label: str) -> None:
                        workflow_click(120, 12, serial, f"{label}: open File menu")
                        workflow_click(120, 92, serial + 10, f"{label}: select File > Save As")
                        assert_picker(label)

                    def workflow_picker_click(x: int, y: int, serial: int, label: str) -> None:
                        screen_x = 28 + ((x - 40) * 744 // 720)
                        screen_y = 28 + ((y - 36) * 424 // 408)
                        workflow_click(screen_x, screen_y, serial, label)

                    def workflow_picker_scrollbar_drag(
                        start_x: int, start_y: int, end_x: int, end_y: int,
                        serial: int, label: str
                    ) -> None:
                        start_screen = (
                            28 + ((start_x - 40) * 744 // 720),
                            28 + ((start_y - 36) * 424 // 408),
                        )
                        end_screen = (
                            28 + ((end_x - 40) * 744 // 720),
                            28 + ((end_y - 36) * 424 // 408),
                        )
                        workflow_scrollbar_drag(
                            start_screen[0], start_screen[1],
                            end_screen[0], end_screen[1], serial, label
                        )

                    def double_click_picker_row(x: int, y: int, serial: int, label: str) -> int:
                        workflow_picker_click(x, y, serial, f"{label}: first click")
                        workflow_picker_click(x, y, serial + 10, f"{label}: second click")
                        return serial + 20

                    # Ctrl+S on Untitled opens the directory picker in Save mode.
                    key_step(2000, evdev["h"], "type first Untitled character")
                    key_step(2002, evdev["i"], "type second Untitled character")
                    workflow_shortcut(2010, 31, "Ctrl+S opens Save picker for Untitled")
                    assert_picker("Untitled Ctrl+S")
                    serial = workflow_type_path("created.txz", 2020)
                    key_step(serial, 14, "Save picker filename Backspace")
                    key_step(serial + 2, evdev["t"], "correct Save picker filename")
                    key_step(serial + 4, 28, "confirm Untitled Save")
                    with open(os.path.join(runtime_dir, "created.txt"), "rb") as saved:
                        if saved.read() != b"hi":
                            raise AssertionError("Ctrl+S on Untitled did not create the selected file")
                    observations.append("Ctrl+S on Untitled opened the native Save picker and created a relative file")

                    # Save now targets the successfully selected filename.
                    key_step(serial + 6, evdev["c"], "edit named document")
                    workflow_shortcut(serial + 8, 31, "Ctrl+S saves named document")
                    with open(os.path.join(runtime_dir, "created.txt"), "rb") as saved:
                        if saved.read() != b"hic":
                            raise AssertionError("Ctrl+S did not update the active named file")

                    # Browse into the directory entry, reveal a hidden file, and
                    # double-click it. Directories are listed before files.
                    open_picker_from_menu(2100, "Open picker")
                    serial = double_click_picker_row(120, 152, 2120, "enter nested directory")
                    small_directory_state = picker_state()
                    small_directory_pixel = struct.unpack_from(
                        "<I", pixels, 200 * 800 * 4 + 726 * 4
                    )[0]
                    if (
                        small_directory_state.get("picker_entry_count", 999) > 13
                        or small_directory_state.get("picker_scroll_thumb_height") != 0
                        or small_directory_pixel != 0xFF252A33
                    ):
                        raise AssertionError(
                            "a directory that fits its visible rows must not draw a scrollbar: "
                            f"state={small_directory_state!r}, pixel={hex(small_directory_pixel)}"
                        )
                    workflow_picker_click(730, 200, serial, "click empty scrollbar gutter with no overflow")
                    no_scroll_drag_state = picker_state()
                    if no_scroll_drag_state.get("picker_scroll_drag") != 0:
                        raise AssertionError(
                            f"non-scrollable directory started a scrollbar drag: {no_scroll_drag_state!r}"
                        )
                    serial += 10
                    workflow_picker_click(650, 124, serial, "show hidden files")
                    serial += 10
                    serial = double_click_picker_row(160, 152, serial, "open hidden file")
                    # H's first glyph row lights columns 0 and 4; the caret overlays column 0.
                    hidden_state = picker_state()
                    hidden_path = os.path.join(runtime_dir, "nested-dir", ".hidden-note").encode()
                    if (
                        hidden_state.get("active_path") != hidden_path
                        or hidden_state.get("doc_length") != 1
                        or hidden_state.get("doc_buffer", b"")[:1] != b"H"
                        or struct.unpack_from("<I", pixels, 92 * 800 * 4 + 20 * 4)[0] != 0xFFD8DEE9
                    ):
                        raise AssertionError(f"double-clicking a hidden file did not open its document; state={hidden_state!r}")
                    observations.append("directory entry navigation, hidden-file toggle, and double-click Open verified")

                    # Open again, enter the directory, go Up, re-enter it, then
                    # open the ordinary file from the visible list.
                    open_picker_from_menu(2200, "directory navigation picker")
                    serial = double_click_picker_row(120, 152, 2220, "enter nested directory again")
                    workflow_picker_click(78, 124, serial, "navigate Up to parent directory")
                    serial += 10
                    serial = double_click_picker_row(120, 152, serial, "re-enter nested directory")
                    serial = double_click_picker_row(160, 184, serial, "open inside.txt after the hidden and empty-file rows")
                    # Verify the exact selected document: H and N share the same
                    # first-row edge pixels, and the caret overlays column 0.
                    nested_file = os.path.join(runtime_dir, "nested-dir", "inside.txt")
                    nested_state = picker_state()
                    if (
                        nested_state.get("active_path") != nested_file.encode()
                        or nested_state.get("doc_length") != 1
                        or nested_state.get("doc_buffer", b"")[:1] != b"N"
                        or struct.unpack_from("<I", pixels, 92 * 800 * 4 + 20 * 4)[0] != 0xFFD8DEE9
                    ):
                        raise AssertionError(f"directory picker did not open inside.txt; state={nested_state!r}")
                    observations.append("Up navigation and a second nested-file Open verified")

                    # Replace the opened document and validate Ctrl+S against
                    # the actual selected file path.
                    workflow_shortcut(serial, 30, "Ctrl+A before nested-file edit")
                    key_step(serial + 8, evdev["z"], "replace nested document")
                    workflow_shortcut(serial + 10, 31, "Ctrl+S after nested Open")
                    with open(nested_file, "rb") as saved:
                        saved_bytes = saved.read()
                    if saved_bytes != b"z":
                        raise AssertionError(
                            "Ctrl+S after picker Open did not save the nested file; "
                            f"disk={saved_bytes!r}, state={picker_state()!r}"
                        )

                    # Exercise File > Save as well.
                    key_step(serial + 16, evdev["a"], "append before File > Save")
                    workflow_click(120, 12, serial + 20, "reopen File menu")
                    workflow_click(120, 68, serial + 30, "select File > Save")
                    with open(nested_file, "rb") as saved:
                        if saved.read() != b"za":
                            raise AssertionError("File > Save did not write the active document")

                    # File > Save As uses the picker and returns to its starting
                    # working directory; relative names stay relative to that directory.
                    save_picker_from_menu(serial + 40, "menu Save As picker")
                    serial = workflow_type_path("menu-saveas.txt", serial + 60)
                    key_step(serial, 28, "confirm menu Save As")
                    menu_saveas = os.path.join(runtime_dir, "menu-saveas.txt")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"za":
                            raise AssertionError("menu Save As did not create its selected destination")
                    key_step(serial + 2, evdev["b"], "edit after menu Save As")
                    workflow_shortcut(serial + 4, 31, "Ctrl+S after menu Save As")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zab":
                            raise AssertionError("Ctrl+S did not use the path selected by Save As")
                    os.chmod(menu_saveas, 0o640)

                    # Ctrl+Shift+S accepts an absolute filename.
                    absolute_path = absolute_file_path
                    workflow_shortcut(serial + 10, 31, "Ctrl+Shift+S opens Save picker", shift=True)
                    assert_picker("Ctrl+Shift+S picker")
                    serial = workflow_type_path(absolute_path, serial + 20)
                    key_step(serial, 28, "confirm absolute Save As")
                    with open(absolute_path, "rb") as saved:
                        if saved.read() != b"zab":
                            raise AssertionError("Save As did not create the selected absolute path")
                    key_step(serial + 2, evdev["c"], "edit absolute-path document")
                    workflow_shortcut(serial + 4, 31, "Ctrl+S after absolute Save As")
                    with open(absolute_path, "rb") as saved:
                        if saved.read() != b"zabc":
                            raise AssertionError("Ctrl+S did not use the absolute Save As path")

                    # Existing files require a second confirmation before replace.
                    workflow_shortcut(serial + 10, 31, "Save As before overwrite confirmation", shift=True)
                    serial = workflow_type_path("menu-saveas.txt", serial + 20)
                    key_step(serial, 28, "request overwrite confirmation")
                    if struct.unpack_from("<I", pixels, 176 * 800 * 4 + 184 * 4)[0] != 0xFF343D4B:
                        raise AssertionError("existing target did not display the overwrite confirmation")
                    key_step(serial + 2, evdev["n"], "decline overwrite")
                    key_step(serial + 4, 1, "close picker after declining overwrite")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zab":
                            raise AssertionError("declining overwrite changed the existing file")

                    workflow_shortcut(serial + 10, 31, "Save As before confirmed overwrite", shift=True)
                    serial = workflow_type_path("menu-saveas.txt", serial + 20)
                    key_step(serial, 28, "request second overwrite confirmation")
                    key_step(serial + 2, evdev["y"], "confirm overwrite with Y")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zabc":
                            raise AssertionError("confirmed overwrite did not replace the existing file")
                    overwritten_mode = os.stat(menu_saveas).st_mode & 0o7777
                    if overwritten_mode != 0o640:
                        raise AssertionError(
                            f"Save As overwrite changed existing target mode: expected 0o640, got {overwritten_mode:#06o}"
                        )
                    observations.append("Save As overwrite confirmation, cancellation, and mode preservation verified")

                    # A failed Save As must preserve the previously active path.
                    workflow_shortcut(serial + 4, 31, "Ctrl+Shift+S before failed Save As", shift=True)
                    serial = workflow_type_path("/no-such-nekoedit-directory/save.txt", serial + 14)
                    key_step(serial, 28, "confirm failed Save As")
                    key_step(serial + 2, 1, "Escape failed Save As picker")
                    key_step(serial + 4, evdev["d"], "edit after failed Save As")
                    workflow_shortcut(serial + 6, 31, "save to prior path after failed Save As")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zabcd":
                            raise AssertionError("failed Save As changed the active document path")

                    # Failed and oversized Open operations must keep the current
                    # document/path intact. Escape dismisses each error.
                    workflow_shortcut(serial + 12, 24, "Ctrl+O before missing-file Open")
                    serial = workflow_type_path("missing-file.txt", serial + 22)
                    key_step(serial, 28, "confirm missing-file Open")
                    key_step(serial + 2, 1, "Escape failed Open picker")
                    key_step(serial + 4, evdev["e"], "edit after failed Open")
                    workflow_shortcut(serial + 6, 31, "save after failed Open")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zabcde":
                            raise AssertionError("failed Open changed the active document or save path")

                    # Escape from Save As must not alter the active destination.
                    workflow_shortcut(serial + 12, 31, "Ctrl+Shift+S before cancellation", shift=True)
                    serial = workflow_type_path("cancelled.txt", serial + 22)
                    key_step(serial, 1, "Escape cancels Save As picker")
                    key_step(serial + 2, evdev["g"], "edit after cancelling Save As")
                    workflow_shortcut(serial + 4, 31, "save after cancelled Save As")
                    with open(menu_saveas, "rb") as saved:
                        cancelled_save_bytes = saved.read()
                    if cancelled_save_bytes != b"zabcdeg":
                        raise AssertionError(
                            "cancelled Save As changed the active destination: "
                            f"expected {b'zabcdef'!r}, got {cancelled_save_bytes!r}; state={picker_state()!r}"
                        )
                    if os.path.exists(os.path.join(runtime_dir, "cancelled.txt")):
                        raise AssertionError("Escape unexpectedly created the cancelled Save As path")
                    observations.append("missing Open rollback, failed Save As rollback, and Escape cancellation verified")

                    # A zero-byte text file must replace the current document
                    # with an actually empty buffer and commit its own exact path.
                    workflow_shortcut(serial + 10, 24, "Ctrl+O before zero-byte file")
                    open_picker_from_menu(serial + 20, "zero-byte file picker")
                    serial = double_click_picker_row(120, 152, serial + 40, "enter directory for zero-byte file")
                    # With dotfiles hidden, aaa.txt sorts before empty.txt;
                    # select row 1 to catch accidental row-zero/stale selection.
                    workflow_picker_click(160, 168, serial, "select zero-byte empty.txt from second file row")
                    workflow_picker_click(716, 410, serial + 10, "Open selected zero-byte empty.txt")
                    empty_file = os.path.join(runtime_dir, "nested-dir", "empty.txt")
                    empty_state = picker_state()
                    if (
                        empty_state.get("active_path") != empty_file.encode()
                        or empty_state.get("doc_length") != 0
                        or empty_state.get("doc_save_error") != 0
                    ):
                        raise AssertionError(
                            "opening a zero-byte file did not activate an empty document; "
                            f"state={empty_state!r}"
                        )
                    key_step(serial + 20, evdev["e"], "type into opened zero-byte document")
                    workflow_shortcut(serial + 22, 31, "Ctrl+S saves zero-byte file after typing")
                    with open(empty_file, "rb") as saved:
                        if saved.read() != b"e":
                            raise AssertionError(
                                "saving after opening a zero-byte file wrote to the wrong target "
                                "or retained stale document bytes"
                            )
                    observations.append(
                        "zero-byte file Open reset the document, activated the exact path, and saved back to that file"
                    )

                    # Restore a zero-byte on-disk fixture before repeating Open.
                    with open(empty_file, "wb") as empty_document:
                        empty_document.write(b"")
                    # Repeat the zero-byte Open through the double-click route.
                    workflow_shortcut(serial + 30, 24, "Ctrl+O before double-click empty file")
                    open_picker_from_menu(serial + 40, "double-click empty-file picker")
                    serial = double_click_picker_row(120, 152, serial + 60, "enter nested directory for double-click empty file")
                    serial = double_click_picker_row(160, 168, serial, "double-click empty.txt from second file row")
                    empty_state = picker_state()
                    if (
                        empty_state.get("active_path") != empty_file.encode()
                        or empty_state.get("doc_length") != 0
                    ):
                        raise AssertionError(
                            "double-clicking a zero-byte file opened the wrong document; "
                            f"state={empty_state!r}"
                        )
                    observations.append(
                        "double-click Open of a zero-byte file also activated the exact empty document"
                    )

                    # A no-match query belongs to its original directory. If it
                    # survives navigation, Open can mistake it for a literal name
                    # and load a same-named file from the newly opened directory.
                    open_picker_from_menu(serial + 10, "directory-scoped search regression")
                    serial = workflow_type_path("stale.txt", serial + 30)
                    stale_search_state = picker_state()
                    if (
                        stale_search_state.get("picker_name_buffer") != b"stale.txt"
                        or stale_search_state.get("picker_name_match") != 0
                        or stale_search_state.get("picker_selected") != -1
                    ):
                        raise AssertionError(
                            f"stale-query fixture did not begin as an unmatched root search: {stale_search_state!r}"
                        )
                    original_path = os.fsencode(runtime_dir)
                    path_end_x = 64 + min(len(original_path), 82) * 8
                    workflow_picker_click(path_end_x, 84, serial + 10, "focus location before directory-scoped search check")
                    serial = workflow_type_path("/nested-dir", serial + 20)
                    key_step(serial, 28, "navigate after unmatched search query")
                    serial += 2
                    stale_path_state = picker_state()
                    if (
                        stale_path_state.get("picker_current_path")
                        != os.path.join(runtime_dir, "nested-dir").encode()
                        or stale_path_state.get("picker_name_length") != 0
                        or stale_path_state.get("picker_name_buffer") != b""
                        or stale_path_state.get("picker_name_match") != 0
                        or stale_path_state.get("picker_selected") != -1
                    ):
                        raise AssertionError(
                            f"directory navigation retained a stale search query/selection: {stale_path_state!r}"
                        )
                    workflow_picker_click(716, 410, serial + 10, "Open with no selected row after search navigation")
                    no_selection_state = picker_state()
                    if (
                        no_selection_state.get("picker_mode") != 1
                        or no_selection_state.get("active_path") != empty_file.encode()
                        or no_selection_state.get("doc_length") != 0
                    ):
                        raise AssertionError(
                            "Open without a selected row loaded a stale literal filename instead of "
                            f"leaving the picker active: {no_selection_state!r}"
                        )
                    workflow_picker_click(160, 168, serial + 20, "select empty.txt after stale-query rejection")
                    workflow_picker_click(716, 410, serial + 30, "Open exact empty.txt after stale-query rejection")
                    recovered_empty_state = picker_state()
                    if (
                        recovered_empty_state.get("picker_mode") != 0
                        or recovered_empty_state.get("active_path") != empty_file.encode()
                        or recovered_empty_state.get("doc_length") != 0
                    ):
                        raise AssertionError(
                            f"explicit selection after stale-query rejection opened the wrong file: {recovered_empty_state!r}"
                        )
                    serial += 40
                    observations.append(
                        "directory navigation clears Open-mode search state; list-focused Open rejects stale/literal query text and only opens an explicitly selected row"
                    )

                    # Exercise mouse-wheel scrolling and the draggable scrollbar
                    # in a directory with more than two viewport pages.
                    open_picker_from_menu(serial + 10, "scrollable directory picker")
                    scroll_state = picker_state()
                    if scroll_state.get("picker_entry_count", 0) < 30:
                        raise AssertionError(
                            f"scroll fixture did not create enough entries: {scroll_state!r}"
                        )
                    workflow_axis(0, 48 * 256, serial + 30, "mouse wheel scroll down three rows")
                    scroll_state = picker_state()
                    if scroll_state.get("picker_scroll") != 3:
                        raise AssertionError(
                            f"vertical mouse wheel did not advance the picker by three rows: {scroll_state!r}"
                        )
                    thumb_top = scroll_state["picker_scroll_thumb_top"]
                    thumb_height = scroll_state["picker_scroll_thumb_height"]
                    thumb_center = thumb_top + thumb_height // 2
                    workflow_picker_scrollbar_drag(
                        730, thumb_center, 730, 339, serial + 40,
                        "drag picker scrollbar thumb to bottom"
                    )
                    scroll_state = picker_state()
                    expected_max_scroll = scroll_state["picker_entry_count"] - 13
                    if scroll_state.get("picker_scroll") != expected_max_scroll:
                        raise AssertionError(
                            f"dragging the picker scrollbar did not reach the last rows: {scroll_state!r}"
                        )
                    workflow_axis(0, -16 * 256, serial + 50, "mouse wheel scroll up one row")
                    scroll_state = picker_state()
                    if scroll_state.get("picker_scroll") != expected_max_scroll - 1:
                        raise AssertionError(
                            f"mouse wheel up did not move the picker toward earlier rows: {scroll_state!r}"
                        )
                    observations.append(
                        "Wayland vertical-axis wheel scrolling, proportional scrollbar, and thumb dragging verified"
                    )

                    # Editable path field: insert in the middle, remove it again,
                    # then append a subdirectory and navigate using the edited path.
                    open_picker_from_menu(serial + 60, "editable path field")
                    original_path = os.fsencode(runtime_dir)
                    workflow_picker_click(96, 84, serial + 80, "place path caret in the middle")
                    key_step(serial + 90, evdev["x"], "insert into middle of path")
                    path_state = picker_state()
                    expected_inserted_path = original_path[:4] + b"x" + original_path[4:]
                    if (
                        path_state.get("picker_path_buffer") != expected_inserted_path
                        or path_state.get("picker_path_cursor") != 5
                    ):
                        raise AssertionError(
                            f"path insertion did not occur at the mouse cursor: {path_state!r}"
                        )
                    key_step(serial + 92, 14, "Backspace removes middle path insertion")
                    path_state = picker_state()
                    if path_state.get("picker_path_buffer") != original_path:
                        raise AssertionError(
                            f"Backspace at the path cursor did not restore the path: {path_state!r}"
                        )
                    # Click at the visible end of the path, append /nested-dir,
                    # and commit with Enter.
                    path_end_x = 64 + min(len(original_path), 82) * 8
                    workflow_picker_click(path_end_x, 84, serial + 100, "place path caret at the end")
                    serial = workflow_type_path("/nested-dir", serial + 110)
                    key_step(serial, 28, "navigate using edited path field")
                    nested_path_state = picker_state()
                    expected_nested_path = os.path.join(runtime_dir, "nested-dir").encode()
                    if nested_path_state.get("picker_current_path") != expected_nested_path:
                        raise AssertionError(
                            f"edited path field did not navigate to nested-dir: {nested_path_state!r}"
                        )
                    observations.append(
                        "path field supports mouse-positioned insertion, Backspace, and Enter navigation"
                    )

                    # Filename prefix search selects a matching regular file.
                    # Clicking inside the name field moves the cursor; insertion
                    # and Backspace must preserve the match after restoring text.
                    for offset, character in enumerate("empty"):
                        key_step(serial + 2 + offset * 2, evdev[character], f"filename prefix search {character!r}")
                    name_state = picker_state()
                    if (
                        name_state.get("picker_name_buffer") != b"empty"
                        or name_state.get("picker_name_match") != 1
                        or name_state.get("picker_selected") < 0
                    ):
                        raise AssertionError(f"filename prefix search did not select empty.txt: {name_state!r}")
                    workflow_picker_click(192, 374, serial + 20, "place search-field cursor after two characters")
                    key_step(serial + 30, evdev["x"], "insert inside filename search")
                    name_state = picker_state()
                    if (
                        name_state.get("picker_name_buffer") != b"emxpty"
                        or name_state.get("picker_name_match") != 0
                        or name_state.get("picker_selected") != -1
                    ):
                        raise AssertionError(f"filename insertion did not invalidate the stale match: {name_state!r}")
                    key_step(serial + 32, 14, "Backspace restores filename prefix")
                    name_state = picker_state()
                    if (
                        name_state.get("picker_name_buffer") != b"empty"
                        or name_state.get("picker_name_match") != 1
                        or name_state.get("picker_selected") < 0
                    ):
                        raise AssertionError(f"filename Backspace did not restore the prefix match: {name_state!r}")
                    key_step(serial + 34, 102, "Home moves filename cursor to the start")
                    key_step(serial + 36, 106, "Right moves filename cursor forward")
                    key_step(serial + 38, 107, "End moves filename cursor to the end")
                    key_step(serial + 40, 105, "Left moves filename cursor back one")
                    name_state = picker_state()
                    if name_state.get("picker_name_cursor") != 4:
                        raise AssertionError(f"Home/End/Left did not position the filename cursor: {name_state!r}")
                    key_step(serial + 42, 102, "Home before forward Delete")
                    key_step(serial + 44, 111, "Delete removes the character at the filename cursor")
                    name_state = picker_state()
                    if (
                        name_state.get("picker_name_buffer") != b"mpty"
                        or name_state.get("picker_name_match") != 0
                        or name_state.get("picker_selected") != -1
                    ):
                        raise AssertionError(f"forward Delete did not update filename search state: {name_state!r}")
                    workflow_shortcut(serial + 46, 30, "Ctrl+A selects filename search text")
                    name_state = picker_state()
                    if name_state.get("picker_edit_select_all") != 1:
                        raise AssertionError(f"Ctrl+A did not select the filename field: {name_state!r}")
                    serial = workflow_type_path("empty", serial + 56)
                    name_state = picker_state()
                    if (
                        name_state.get("picker_name_buffer") != b"empty"
                        or name_state.get("picker_name_match") != 1
                        or name_state.get("picker_selected") < 0
                    ):
                        raise AssertionError(f"typing after Ctrl+A did not replace and rematch the text: {name_state!r}")
                    key_step(serial, 28, "Enter opens the matched empty.txt search result")
                    search_open_state = picker_state()
                    if (
                        search_open_state.get("active_path") != empty_file.encode()
                        or search_open_state.get("doc_length") != 0
                    ):
                        raise AssertionError(
                            f"filename search opened the wrong file: {search_open_state!r}"
                        )
                    observations.append(
                        "path/name fields support cursor placement, middle insertion, Backspace, Home/End-ready editing, Ctrl+A replacement, and filename prefix search"
                    )

                    # A partial filename now opens a visible, selectable list
                    # of file recommendations rather than only highlighting an
                    # invisible first prefix match.
                    open_picker_from_menu(serial + 10, "filename autocomplete suggestions")
                    # Exercise directory-list keyboard navigation in
                    # both directions before activating the selected row.
                    key_step(serial + 30, 108, "Down selects the first directory row")
                    list_navigation_state = picker_state()
                    if (
                        list_navigation_state.get("picker_focus") != 0
                        or list_navigation_state.get("picker_selected") != 0
                    ):
                        raise AssertionError(
                            f"Down did not select the first directory row: {list_navigation_state!r}"
                        )
                    key_step(serial + 32, 108, "Down advances to the next directory-list row")
                    list_navigation_state = picker_state()
                    if list_navigation_state.get("picker_selected") != 1:
                        raise AssertionError(
                            f"Down did not advance to the second directory-list row: {list_navigation_state!r}"
                        )
                    key_step(serial + 34, 103, "Up returns to the first directory-list row")
                    list_navigation_state = picker_state()
                    if (
                        list_navigation_state.get("picker_focus") != 0
                        or list_navigation_state.get("picker_selected") != 0
                    ):
                        raise AssertionError(
                            f"Up did not return to the first directory row: {list_navigation_state!r}"
                        )
                    key_step(serial + 36, 28, "Enter opens the selected directory row")
                    serial += 38
                    autocomplete_directory_state = picker_state()
                    expected_autocomplete_directory = os.path.join(
                        runtime_dir, "nested-dir"
                    ).encode()
                    if autocomplete_directory_state.get("picker_current_path") != expected_autocomplete_directory:
                        raise AssertionError(
                            "autocomplete fixture did not enter nested-dir: "
                            f"{autocomplete_directory_state!r}"
                        )
                    serial = workflow_type_path("prefill-", serial + 10)
                    suggestion_state = picker_state()
                    if (
                        suggestion_state.get("picker_name_buffer") != b"prefill-"
                        or suggestion_state.get("picker_focus") != 2
                        or suggestion_state.get("picker_suggestion_count") != 2
                        or suggestion_state.get("picker_suggestion_selected") != 0
                        or suggestion_state.get("picker_selected") != suggestion_state.get("picker_suggestion_indices", ())[0]
                    ):
                        raise AssertionError(
                            f"filename autocomplete did not show both matching files: {suggestion_state!r}"
                        )
                    # The dropdown overlays the lower list area and is rendered
                    # with a distinct dark panel above the Search field.
                    # The panel's two-pixel left border remains visible
                    # beside the highlighted first suggestion. Probe it in
                    # surface coordinates after the picker transform.
                    popup_pixel = struct.unpack_from(
                        "<I", pixels, 272 * 800 * 4 + 160 * 4
                    )[0]
                    if popup_pixel != 0xFF171C24:
                        raise AssertionError(
                            f"filename recommendation popup was not visible: {hex(popup_pixel)}"
                        )
                    key_step(serial + 2, 108, "Down selects the second filename recommendation")
                    suggestion_state = picker_state()
                    if (
                        suggestion_state.get("picker_suggestion_selected") != 1
                        or suggestion_state.get("picker_selected") != suggestion_state.get("picker_suggestion_indices", (0, 0))[1]
                    ):
                        raise AssertionError(
                            f"Down did not highlight the second filename recommendation: {suggestion_state!r}"
                        )
                    key_step(serial + 4, 28, "Enter opens the selected filename recommendation")
                    suggestion_open_state = picker_state()
                    expected_suggestion_path = os.path.join(
                        runtime_dir, "nested-dir", "prefill-beta.txt"
                    ).encode()
                    if (
                        suggestion_open_state.get("active_path") != expected_suggestion_path
                        or suggestion_open_state.get("doc_length") != 1
                        or suggestion_open_state.get("doc_buffer", b"")[:1] != b"B"
                    ):
                        raise AssertionError(
                            f"autocomplete opened the wrong recommendation: {suggestion_open_state!r}"
                        )
                    observations.append(
                        "partial filename input renders multiple autocomplete recommendations; mouse/keyboard selection is supported and Enter opens the highlighted exact file"
                    )

                    # Exercise a realistic multi-line document above 10 MiB.
                    # The elapsed key_step includes file loading, index creation,
                    # the first redraw, and the frame presented by the mock server.
                    large_open_start = serial + 12
                    workflow_shortcut(large_open_start, 24, "Ctrl+O before large-file Open")
                    large_open_serial = workflow_type_path("oversized.txt", large_open_start + 10)
                    large_open_started = time.perf_counter()
                    key_step(large_open_serial, 28, "Open 11 MiB multi-line text document")
                    large_open_elapsed_ms = (time.perf_counter() - large_open_started) * 1000.0
                    large_open_state = picker_state()
                    large_path = os.path.join(runtime_dir, "oversized.txt").encode()
                    expected_line_count = large_expected.count(b"\n") + 1
                    if (
                        large_open_state.get("active_path") != large_path
                        or large_open_state.get("doc_length") != len(large_expected)
                        or large_open_state.get("doc_contents") != large_expected
                        or large_open_state.get("doc_capacity", 0) < len(large_expected)
                        or large_open_state.get("doc_gap_start") != len(large_expected)
                        or large_open_state.get("doc_line_count") != expected_line_count
                        or len(large_open_state.get("doc_line_index_records", ())) != expected_line_count
                    ):
                        raise AssertionError(
                            "11 MiB Open did not commit the complete document and line index: "
                            + repr({
                                key: large_open_state.get(key)
                                for key in (
                                    "doc_length", "doc_capacity", "doc_gap_start",
                                    "doc_line_count", "doc_line_index_valid",
                                )
                            })
                        )
                    workflow_shortcut(
                        large_open_serial + 4, 31, "Ctrl+S saves the 11 MiB document"
                    )
                    with open(os.path.join(runtime_dir, "oversized.txt"), "rb") as saved:
                        if saved.read() != large_expected:
                            raise AssertionError("Ctrl+S did not serialize the complete 11 MiB document")
                    observations.append(
                        f"native picker Open and Ctrl+S save verified for an 11 MiB / "
                        f"{expected_line_count:,}-line document "
                        f"({large_open_elapsed_ms:.1f} ms through first presented redraw)"
                    )
                    print(
                        f"Large-document Open/index/first-frame: "
                        f"{len(large_expected):,} bytes, {expected_line_count:,} lines, "
                        f"{large_open_elapsed_ms:.1f} ms"
                    )
                    serial = large_open_serial + 42

                    # The 11 MiB multi-line document wraps into roughly twice
                    # as many visual rows as logical lines. Verify editor
                    # scrolling is independent of the picker's scroll model.
                    editor_scroll_state = picker_state()
                    if (
                        editor_scroll_state.get("doc_total_visual_rows", 0)
                            <= editor_scroll_state.get("window_doc_visible_rows", 0)
                        or editor_scroll_state.get("doc_scroll_thumb_height", 0) <= 0
                    ):
                        index_debug_keys = (
                            "doc_total_visual_rows", "window_doc_visible_rows",
                            "doc_scroll_thumb_height", "doc_line_index_valid",
                            "doc_line_index_columns", "doc_line_index_capacity",
                            "doc_line_count", "doc_line_index_records",
                        )
                        index_debug = {
                            key: editor_scroll_state.get(key)
                            for key in index_debug_keys
                        }
                        raise AssertionError(
                            "large wrapped document did not expose an editor scrollbar: "
                            + repr(index_debug)
                        )
                    scrollbar_x = editor_scroll_state["window_width"] - 21
                    thumb_top = editor_scroll_state["doc_scroll_thumb_top"]
                    thumb_height = editor_scroll_state["doc_scroll_thumb_height"]
                    thumb_pixel = struct.unpack_from(
                        "<I", pixels,
                        (thumb_top + thumb_height // 2) * 800 * 4 + scrollbar_x * 4
                    )[0]
                    if thumb_pixel != 0xFF78A9D4:
                        raise AssertionError(
                            f"editor scrollbar thumb was not rendered at its computed position: {thumb_pixel:#010x}"
                        )
                    workflow_axis(0, 42 * 256, large_open_serial + 6, "editor wheel scrolls down three visual rows")
                    editor_scroll_state = picker_state()
                    if editor_scroll_state.get("doc_view_top_row") != 3:
                        raise AssertionError(
                            f"editor wheel did not advance the visual viewport by three rows: {editor_scroll_state!r}"
                        )
                    max_scroll_rows = (
                        editor_scroll_state["doc_total_visual_rows"]
                        - editor_scroll_state["window_doc_visible_rows"]
                    )
                    thumb_travel = (
                        editor_scroll_state["window_doc_bottom"]
                        - 92
                        - editor_scroll_state["doc_scroll_thumb_height"]
                    )
                    expected_thumb_top = 92 + (
                        editor_scroll_state["doc_view_top_row"] * thumb_travel
                        // max_scroll_rows
                    )
                    if editor_scroll_state.get("doc_scroll_thumb_top") != expected_thumb_top:
                        raise AssertionError(
                            "editor wheel placed the thumb outside its proportional integer geometry: "
                            + repr({
                                "view_top_row": editor_scroll_state.get("doc_view_top_row"),
                                "total_visual_rows": editor_scroll_state.get("doc_total_visual_rows"),
                                "thumb_top": editor_scroll_state.get("doc_scroll_thumb_top"),
                                "expected_thumb_top": expected_thumb_top,
                                "thumb_travel": thumb_travel,
                                "max_scroll_rows": max_scroll_rows,
                            })
                        )
                    thumb_top = editor_scroll_state["doc_scroll_thumb_top"]
                    thumb_height = editor_scroll_state["doc_scroll_thumb_height"]
                    track_height = editor_scroll_state["window_status_top"] - 92
                    bottom_center = 92 + track_height - thumb_height // 2
                    workflow_editor_scrollbar_drag(
                        scrollbar_x, thumb_top + thumb_height // 2,
                        scrollbar_x, bottom_center, large_open_serial + 16,
                        "drag editor scrollbar to document bottom"
                    )
                    editor_scroll_state = picker_state()
                    expected_editor_max = (
                        editor_scroll_state["doc_total_visual_rows"]
                        - editor_scroll_state["window_doc_visible_rows"]
                    )
                    if editor_scroll_state.get("doc_view_top_row") != expected_editor_max:
                        raise AssertionError(
                            f"editor scrollbar drag did not reach the final visual rows: {editor_scroll_state!r}"
                        )
                    workflow_axis(0, -14 * 256, large_open_serial + 26, "editor wheel scrolls up one visual row")
                    editor_scroll_state = picker_state()
                    if editor_scroll_state.get("doc_view_top_row") != expected_editor_max - 1:
                        raise AssertionError(
                            f"editor wheel-up did not move toward the document start: {editor_scroll_state!r}"
                        )
                    observations.append(
                        "editor scrollbar visibility, proportional thumb rendering, pointer drag, and wheel scrolling verified"
                    )

                    # Minimize is a real xdg_toplevel request, not a decorative
                    # titlebar control. The normal buffer remains valid after it.
                    workflow_window_click(708, serial + 10, 13, "minimize")
                    window_state = picker_state()
                    if (
                        window_state.get("window_width") != 800
                        or window_state.get("window_height") != 480
                        or window_state.get("window_buffer_id") != 12
                    ):
                        raise AssertionError(f"minimize changed client buffer geometry: {window_state!r}")
                    observations.append("titlebar Minimize emits xdg_toplevel.set_minimized")

                    # Maximize: the compositor configures a larger surface. The
                    # client must ack, destroy the released old buffer, create
                    # a correctly sized buffer from the retained shm pool, and
                    # repaint it using the new stride.
                    workflow_window_click(740, serial + 20, 9, "maximize")
                    # The new buffer is allocated only when the release/configure
                    # sequence reaches window_apply_pending_resize. Earlier file
                    # workflow frames have already consumed many dense client IDs.
                    maximized_buffer_id = child_u32("next_client_object_id")
                    # Mutter may emit multiple toplevel configures before the
                    # surface configure; the final width/height/state apply.
                    client.sendall(
                        buffer_release_message()
                        + wire_message(10, 0, struct.pack("<iiIII", 1024, 768, 8, 1, 4))
                        + wire_message(10, 0, struct.pack("<iiIII", 1920, 1080, 8, 1, 4))
                        + wire_message(9, 0, struct.pack("<I", 1235))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1235)), "ack maximized configure"
                    )
                    expect_message(client, (client_buffer_id, 0, b""), "destroy released pre-maximize buffer")
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", maximized_buffer_id, 0, 1920, 1080, 7680, 1)),
                        "create maximized buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", maximized_buffer_id, 0, 0)),
                        "attach maximized buffer",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 1920, 1080)),
                        "damage maximized surface",
                    )
                    expect_message(client, (8, 6, b""), "commit maximized surface")
                    max_state = picker_state()
                    if (
                        max_state.get("window_surface_width") != 1920
                        or max_state.get("window_surface_height") != 1080
                        or max_state.get("window_ui_scale_120") != 240
                        or max_state.get("window_width") != 960
                        or max_state.get("window_height") != 540
                        or max_state.get("window_buffer_width") != 1920
                        or max_state.get("window_buffer_height") != 1080
                        or max_state.get("window_stride") != 7680
                        or max_state.get("window_buffer_id") != maximized_buffer_id
                        or max_state.get("window_is_maximized") != 1
                        or max_state.get("window_status_top") != 520
                        or max_state.get("window_status_bytes_x") != 580
                        or max_state.get("window_status_mode_x") != 904
                        or max_state.get("window_doc_pixel_width") != 920
                        or max_state.get("window_doc_visible_rows") != 35
                        or max_state.get("picker_panel_x") != 108
                        or max_state.get("picker_panel_y") != 58
                        or max_state.get("picker_panel_width") != 744
                        or max_state.get("picker_panel_height") != 424
                        or max_state.get("path_prompt_x") != 128
                        or max_state.get("path_prompt_y") != 178
                        or max_state.get("path_prompt_width") != 704
                        or max_state.get("path_prompt_height") != 176
                    ):
                        raise AssertionError(f"maximized configure was not applied: {max_state!r}")
                    max_close_pixel = struct.unpack_from("<I", pixels, 8 * 7680 + 1880 * 4)[0]
                    if max_close_pixel != 0xFF754B52:
                        raise AssertionError(
                            f"window controls did not follow the maximized width: {hex(max_close_pixel)}"
                        )
                    if not rendered_color_present(1160, 1052, 96, 14, 7680, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not follow the maximized width")
                    if not rendered_color_present(1808, 1052, 80, 14, 7680, 0xFFD8DEE9):
                        raise AssertionError("the mode footer label did not follow the maximized width")
                    observations.append(
                        "Maximize acknowledges compositor configure and reallocates/repaints the surface at its new dimensions"
                    )

                    # Restore: deliver the configure while buffer {maximized_buffer_id} is still
                    # compositor-owned. The client must ack but defer replacement.
                    # The maximized UI density is 2x: x=1800 maps to virtual x=900,
                    # the center of the scaled maximize/restore control (not Close).
                    workflow_window_click(1800, serial + 30, 10, "restore")
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiII", 800, 480, 4, 4))
                        + wire_message(9, 0, struct.pack("<I", 1236))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1236)), "ack restored configure"
                    )
                    restore_buffer_id = child_u32("next_client_object_id")
                    client.sendall(wire_message(maximized_buffer_id, 0))
                    expect_message(client, (maximized_buffer_id, 0, b""), "destroy released maximized buffer")
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", restore_buffer_id, 0, 800, 480, 3200, 1)),
                        "create restored buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", restore_buffer_id, 0, 0)),
                        "attach restored buffer",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)),
                        "damage restored surface",
                    )
                    expect_message(client, (8, 6, b""), "commit restored surface")
                    restored_state = picker_state()
                    if (
                        restored_state.get("window_width") != 800
                        or restored_state.get("window_height") != 480
                        or restored_state.get("window_buffer_width") != 800
                        or restored_state.get("window_buffer_height") != 480
                        or restored_state.get("window_stride") != 3200
                        or restored_state.get("window_buffer_id") != restore_buffer_id
                        or restored_state.get("window_is_maximized") != 0
                        or restored_state.get("window_status_top") != 460
                        or restored_state.get("window_status_bytes_x") != 480
                        or restored_state.get("window_status_mode_x") != 744
                        or restored_state.get("window_doc_pixel_width") != 760
                        or restored_state.get("window_doc_visible_rows") != 30
                        or restored_state.get("picker_panel_x") != 28
                        or restored_state.get("picker_panel_y") != 28
                        or restored_state.get("picker_panel_width") != 744
                        or restored_state.get("picker_panel_height") != 424
                        or restored_state.get("path_prompt_x") != 48
                        or restored_state.get("path_prompt_y") != 148
                        or restored_state.get("path_prompt_width") != 704
                        or restored_state.get("path_prompt_height") != 176
                    ):
                        raise AssertionError(f"restore configure was not applied: {restored_state!r}")
                    if not rendered_color_present(480, 466, 48, 7, 3200, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not return to its restored-width anchor")
                    if not rendered_color_present(744, 466, 40, 7, 3200, 0xFFD8DEE9):
                        raise AssertionError("the mode footer label did not return to its restored-width anchor")
                    observations.append(
                        "Restore acknowledges the compositor's normal size and replaces the maximized buffer"
                    )

                    # Blank title-bar dragging uses the serial from the button press.
                    workflow_window_click(
                        320, serial + 50, 5, "titlebar move",
                        request_payload=struct.pack("<II", 13, serial + 51),
                    )

                    # The left edge requests a compositor-controlled interactive resize.
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial + 60, 10 * 256, 240 * 256))
                    )
                    if cursor_shape_supported and cursor_feedback_state["shape"] != 26:
                        expect_message(
                            client, (18, 1, struct.pack("<II", cursor_feedback_state["enter_serial"], 26)),
                            "left-edge resize cursor",
                        )
                        cursor_feedback_state["shape"] = 26
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 61, serial + 62, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (10, 6, struct.pack("<III", 13, serial + 61, 4)),
                        "left-edge interactive resize request",
                    )
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 63, serial + 64, 0x110, 0))
                        + wire_message(pointer_object_id, 1, struct.pack("<II", serial + 65, 8))
                    )
                    # The compositor may refocus the pointer after the interactive
                    # resize completes; the enter serial must be refreshed before
                    # the next cursor-shape request.
                    # Deliver a new size while the maximized replacement buffer is still busy.
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiIII", 720, 480, 8, 3, 4))
                        + wire_message(9, 0, struct.pack("<I", 1237))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1237)), "ack interactive-resize configure"
                    )
                    edge_buffer_id = child_u32("next_client_object_id")
                    client.sendall(wire_message(restore_buffer_id, 0))
                    expect_message(client, (restore_buffer_id, 0, b""), "destroy old buffer after edge resize")
                    expect_message(
                        client, (11, 0, struct.pack("<6I", edge_buffer_id, 0, 720, 480, 2880, 1)),
                        "create edge-resized buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", edge_buffer_id, 0, 0)), "attach edge-resized buffer"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 720, 480)), "damage edge-resized surface"
                    )
                    expect_message(client, (8, 6, b""), "commit edge-resized surface")
                    client.sendall(
                        wire_message(pointer_object_id, 0,
                            struct.pack("<IIii", serial + 66, 8, 10 * 256, 240 * 256),
                        )
                    )
                    if cursor_shape_supported:
                        expect_message(
                            client, (18, 1, struct.pack("<II", serial + 66, 26)),
                            "left-edge cursor after focus returns",
                        )
                    cursor_feedback_state["enter_serial"] = serial + 66
                    cursor_feedback_state["shape"] = 26
                    edge_state = picker_state()
                    if (
                        edge_state.get("window_surface_width") != 720
                        or edge_state.get("window_surface_height") != 480
                        or edge_state.get("window_width") != 800
                        or edge_state.get("window_height") != 533
                        or edge_state.get("window_ui_scale_120") != 108
                        or edge_state.get("window_buffer_width") != 720
                        or edge_state.get("window_buffer_height") != 480
                        or edge_state.get("window_stride") != 2880
                        or edge_state.get("window_buffer_id") != edge_buffer_id
                        or edge_state.get("window_is_maximized") != 0
                        or edge_state.get("window_status_top") != 513
                        or edge_state.get("window_doc_bottom") != 513
                        or edge_state.get("window_status_bytes_x") != 480
                        or edge_state.get("window_status_mode_x") != 744
                        or edge_state.get("window_doc_pixel_width") != 760
                        or edge_state.get("window_doc_visible_rows") != 35
                        or edge_state.get("picker_panel_x") != 28
                        or edge_state.get("picker_panel_y") != 54
                        or edge_state.get("picker_panel_width") != 744
                        or edge_state.get("picker_panel_height") != 424
                        or edge_state.get("path_prompt_x") != 48
                        or edge_state.get("path_prompt_y") != 174
                        or edge_state.get("path_prompt_width") != 704
                        or edge_state.get("path_prompt_height") != 176
                    ):
                        raise AssertionError(f"interactive resize configure was not applied: {edge_state!r}")
                    client.sendall(wire_message(edge_buffer_id, 0))
                    if not rendered_color_present(432, 467, 48, 7, 2880, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not follow the 720px resized width")
                    if not rendered_color_present(670, 467, 40, 7, 2880, 0xFFD8DEE9):
                        raise AssertionError("the mode footer label did not follow the 720px resized width")

                    # Probe every remaining edge and corner with coordinates
                    # deliberately inside the new 16-pixel grab band.
                    for index, (x, y, edges, label, cursor_shape) in enumerate((
                        (710, 240, 8, "right edge", 26),
                        (360, 10, 1, "top edge", 27),
                        (360, 470, 2, "bottom edge", 27),
                        (710, 10, 9, "top-right corner", 28),
                        (710, 470, 10, "bottom-right corner", 29),
                        (10, 10, 5, "top-left corner", 29),
                        (10, 470, 6, "bottom-left corner", 28),
                    )):
                        base_serial = serial + 80 + index * 10
                        workflow_window_click(
                            x, base_serial, 6, label, y=y,
                            request_payload=struct.pack("<III", 13, base_serial + 1, edges),
                            cursor_shape=cursor_shape,
                        )

                    # Exercise the centered picker after a non-identity width transform.
                    # This validates that the rendered Cancel button and pointer hit box
                    # still share the same design-space geometry.
                    def resized_ui_click(
                        x: int, y: int, click_serial: int, label: str,
                        buffer_id: int, width: int, height: int,
                    ) -> None:
                        client.sendall(
                            wire_message(pointer_object_id, 2, struct.pack("<Iii", click_serial, x * 256, y * 256))
                            + wire_message(pointer_object_id, 3, struct.pack("<IIII", click_serial + 1, click_serial + 2, 0x110, 1)
                            )
                        )
                        expect_message(
                            client, (8, 1, struct.pack("<III", buffer_id, 0, 0)),
                            f"{label}: attach",
                        )
                        expect_message(
                            client, (8, 2, struct.pack("<4I", 0, 0, width, height)),
                            f"{label}: damage",
                        )
                        expect_message(client, (8, 6, b""), f"{label}: commit")
                        client.sendall(
                            wire_message(pointer_object_id, 3, struct.pack("<IIII", click_serial + 3, click_serial + 4, 0x110, 0)
                            )
                            + wire_message(buffer_id, 0)
                        )

                    # Re-enter at a neutral title-bar location so cursor feedback
                    # has a fresh, valid enter serial before opening the picker.
                    resized_enter = serial + 150
                    client.sendall(
                        wire_message(pointer_object_id, 1, struct.pack("<II", resized_enter - 1, 8))
                        + wire_message(pointer_object_id, 0,
                            struct.pack("<IIii", resized_enter, 8, 120 * 256, 12 * 256),
                        )
                    )
                    if cursor_shape_supported and cursor_feedback_state["shape"] != 1:
                        expect_message(
                            client, (18, 1, struct.pack("<II", resized_enter, 1)),
                            "reset cursor before resized picker",
                        )
                    cursor_feedback_state["enter_serial"] = resized_enter
                    cursor_feedback_state["shape"] = 1

                    resized_ui_click(
                        120, 12, serial + 160, "open File menu at 720px", edge_buffer_id, 720, 480
                    )
                    resized_ui_click(
                        120, 48, serial + 170, "open picker at 720px", edge_buffer_id, 720, 480
                    )
                    picker_720 = picker_state()
                    if (
                        picker_720.get("picker_mode") != 1
                        or picker_720.get("picker_panel_x") != 28
                        or picker_720.get("picker_panel_y") != 54
                        or picker_720.get("picker_panel_width") != 744
                        or picker_720.get("picker_panel_height") != 424
                    ):
                        raise AssertionError(f"picker did not fit the 720x480 surface's virtual layout: {picker_720!r}")
                    cancel_x_720 = (28 + ((636 - 40) * 744 // 720)) * 9 // 10
                    cancel_y_720 = (54 + ((412 - 36) * 424 // 408)) * 9 // 10
                    cancel_pixel_x_720 = (28 + ((605 - 40) * 744 // 720)) * 9 // 10
                    cancel_pixel_y_720 = (54 + ((400 - 36) * 424 // 408)) * 9 // 10
                    if struct.unpack_from("<I", pixels, cancel_pixel_y_720 * 2880 + cancel_pixel_x_720 * 4)[0] != 0xFF414B5A:
                        raise AssertionError("resized picker Cancel button background was not drawn at its fitted location")
                    resized_ui_click(
                        cancel_x_720, cancel_y_720, serial + 180,
                        "cancel fitted picker at 720px", edge_buffer_id, 720, 480,
                    )
                    if picker_state().get("picker_mode") != 0:
                        raise AssertionError("the fitted 720px picker Cancel hit target did not close the picker")
                    observations.append(
                        "centered picker scales to a resized 720px-wide surface and its Cancel hit target matches the drawn button"
                    )

                    # Exercise the smallest compositor geometry NekoEdit advertises.
                    # The picker and path prompt must both fit within its 16px margins.
                    small_buffer_id = child_u32("next_client_object_id")
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiIII", 480, 360, 8, 3, 4))
                        + wire_message(9, 0, struct.pack("<I", 1238))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1238)), "ack minimum-size configure"
                    )
                    expect_message(
                        client, (edge_buffer_id, 0, b""), "destroy released 720px buffer"
                    )
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", small_buffer_id, 0, 480, 360, 1920, 1)),
                        "create minimum-size buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", small_buffer_id, 0, 0)),
                        "attach minimum-size buffer",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 480, 360)),
                        "damage minimum-size surface",
                    )
                    expect_message(client, (8, 6, b""), "commit minimum-size surface")
                    small_state = picker_state()
                    if (
                        small_state.get("window_surface_width") != 480
                        or small_state.get("window_surface_height") != 360
                        or small_state.get("window_width") != 640
                        or small_state.get("window_height") != 480
                        or small_state.get("window_ui_scale_120") != 90
                        or small_state.get("window_status_top") != 460
                        or small_state.get("window_status_bytes_x") != 380
                        or small_state.get("window_status_mode_x") != 584
                        or small_state.get("window_doc_pixel_width") != 600
                        or small_state.get("window_doc_visible_rows") != 30
                        or small_state.get("picker_panel_x") != 16
                        or small_state.get("picker_panel_y") != 28
                        or small_state.get("picker_panel_width") != 608
                        or small_state.get("picker_panel_height") != 424
                        or small_state.get("path_prompt_x") != 16
                        or small_state.get("path_prompt_y") != 148
                        or small_state.get("path_prompt_width") != 608
                        or small_state.get("path_prompt_height") != 176
                        or small_state.get("window_buffer_id") != small_buffer_id
                    ):
                        raise AssertionError(f"minimum-size layout geometry is inconsistent: {small_state!r}")
                    if not rendered_color_present(285, 350, 48, 7, 1920, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not fit the minimum width")
                    if not rendered_color_present(438, 350, 40, 7, 1920, 0xFFD8DEE9):
                        raise AssertionError("the mode footer label did not fit the minimum width")
                    client.sendall(wire_message(small_buffer_id, 0))

                    small_enter = serial + 190
                    client.sendall(
                        wire_message(pointer_object_id, 1, struct.pack("<II", small_enter - 1, 8))
                        + wire_message(pointer_object_id, 0,
                            struct.pack("<IIii", small_enter, 8, 90 * 256, 9 * 256),
                        )
                    )
                    if cursor_shape_supported:
                        expect_message(
                            client, (18, 1, struct.pack("<II", small_enter, 1)),
                            "apply default cursor at minimum size",
                        )
                    cursor_feedback_state["enter_serial"] = small_enter
                    cursor_feedback_state["shape"] = 1
                    resized_ui_click(
                        90, 9, serial + 200, "open File menu at minimum size", small_buffer_id, 480, 360
                    )
                    resized_ui_click(
                        90, 36, serial + 210, "open picker at minimum size", small_buffer_id, 480, 360
                    )
                    picker_small = picker_state()
                    if picker_small.get("picker_mode") != 1:
                        raise AssertionError(f"picker did not open at minimum size: {picker_small!r}")
                    cancel_x_small = (16 + ((636 - 40) * 608 // 720)) * 3 // 4
                    cancel_y_small = (28 + ((412 - 36) * 424 // 408)) * 3 // 4
                    cancel_pixel_x_small = (16 + ((605 - 40) * 608 // 720)) * 3 // 4
                    cancel_pixel_y_small = (28 + ((400 - 36) * 424 // 408)) * 3 // 4
                    if struct.unpack_from("<I", pixels, cancel_pixel_y_small * 1920 + cancel_pixel_x_small * 4)[0] != 0xFF414B5A:
                        raise AssertionError("minimum-size picker Cancel background was not drawn at its fitted location")
                    resized_ui_click(
                        cancel_x_small, cancel_y_small, serial + 220,
                        "cancel fitted picker at minimum size", small_buffer_id, 480, 360,
                    )
                    if picker_state().get("picker_mode") != 0:
                        raise AssertionError("the minimum-size picker Cancel hit target did not close the picker")
                    observations.append(
                        "picker, path-prompt geometry, footer, and mouse hit targets remain fitted at the 480x360 minimum size"
                    )

                    # The app's own Close control exits cleanly; no terminal
                    # shutdown or synthetic xdg_toplevel.close is required.
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial + 230, 452 * 256, 16 * 256))
                    )
                    if cursor_shape_supported and cursor_feedback_state["shape"] != 1:
                        expect_message(
                            client,
                            (18, 1, struct.pack("<II", cursor_feedback_state["enter_serial"], 1)),
                            "restore default cursor before titlebar Close",
                        )
                        cursor_feedback_state["shape"] = 1
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 121, serial + 122, 0x110, 1)
                        )
                    )
                    closed = client.recv(1)
                    if closed != b"":
                        raise AssertionError(
                            f"titlebar Close did not terminate the Wayland client: {closed!r}"
                        )
                    observations.append("titlebar Close closes the Wayland connection and exits the application")
                    return

                if sparse_keymap_test:
                    # The map has no usable alphabetic coverage, so its
                    # parser must leave the existing US evdev translator live.
                    key_step(1800, 30, "US fallback inserts a after sparse XKB rejection")
                    if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0] != 0xFFD8DEE9:
                        raise AssertionError(
                            "US-QWERTY fallback did not render the first a after sparse XKB rejection"
                        )
                    observations.append(
                        "punctuation-only XKB map rejected; US-QWERTY fallback inserted and rendered a"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if save_roundtrip and not (utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test or gap_buffer_test or dynamic_growth_test):
                    # Keep this path-specific test independent from the full
                    # empty-document editor interaction suite below.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1800, 1800, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1801, 1801, 30, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), "Ctrl+A attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "Ctrl+A damage"
                    )
                    expect_message(client, (8, 6, b""), "Ctrl+A commit")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1802, 1802, 30, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1803, 1803, 29, 0))
                        + buffer_release_message()
                    )
                    # Settings is a real upper-menu item. Verify the default-on
                    # save warning can be disabled and re-enabled in this session.
                    if child_u32("save_confirm_enabled") != 1:
                        raise AssertionError("save confirmation must default to enabled")
                    workflow_click(190, 20, 1750, "open Settings menu")
                    if child_u32("settings_menu_open") != 1:
                        raise AssertionError("Settings dropdown did not open")
                    workflow_settings_click(248, 56, 1754, "disable confirm-before-save")
                    if (
                        child_u32("save_confirm_enabled") != 0
                        or child_u32("settings_menu_open") != 0
                    ):
                        raise AssertionError("Settings toggle did not disable save confirmation")
                    workflow_click(190, 20, 1760, "reopen Settings menu")
                    workflow_settings_click(248, 56, 1764, "enable confirm-before-save")
                    if child_u32("save_confirm_enabled") != 1:
                        raise AssertionError("Settings toggle did not re-enable save confirmation")

                    key_step(1810, 44, "replace loaded text with z")
                    if os.path.exists(initial_file):
                        with open(initial_file, "rb") as saved_file:
                            before_save = saved_file.read()
                    if before_save != b"I":
                        raise AssertionError("test fixture changed before Ctrl+S confirmation")

                    # Ctrl+S must display the confirmation without writing the
                    # destination. Escape cancels; a second Enter accepts.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1820, 1820, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1821, 1821, 31, 1))
                    )
                    workflow_redraw("Ctrl+S confirmation dialog")
                    if child_u32("save_confirm_open") != 1:
                        raise AssertionError("Ctrl+S did not open the save confirmation")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"I":
                            raise AssertionError("file was written before save confirmation")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1822, 1822, 31, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1823, 1823, 29, 0))
                        + buffer_release_message()
                    )
                    key_step(1830, 1, "cancel save confirmation with Escape")
                    if child_u32("save_confirm_open") != 0:
                        raise AssertionError("Escape did not cancel the save confirmation")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"I":
                            raise AssertionError("cancelled save modified the destination")

                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1840, 1840, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1841, 1841, 31, 1))
                    )
                    workflow_redraw("reopen Ctrl+S confirmation")
                    if child_u32("save_confirm_open") != 1:
                        raise AssertionError("second Ctrl+S did not reopen confirmation")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1842, 1842, 31, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1843, 1843, 29, 0))
                        + buffer_release_message()
                    )
                    key_step(1850, 28, "accept save confirmation with Enter")
                    if child_u32("save_confirm_open") != 0:
                        raise AssertionError("Enter did not accept the save confirmation")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"z":
                            raise AssertionError("Enter did not write the accepted document")

                    # Verify the on-screen Cancel and Save buttons as well as
                    # the keyboard shortcuts used above.
                    key_step(1860, 30, "append a after the accepted save")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1870, 1870, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1871, 1871, 31, 1))
                    )
                    workflow_redraw("open save dialog for pointer Cancel")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1872, 1872, 31, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1873, 1873, 29, 0))
                        + buffer_release_message()
                    )
                    workflow_click(484, 272, 1880, "pointer Cancel save dialog")
                    if child_u32("save_confirm_open") != 0:
                        raise AssertionError("pointer Cancel did not close the save dialog")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"z":
                            raise AssertionError("pointer Cancel modified the destination")

                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1890, 1890, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1891, 1891, 31, 1))
                    )
                    workflow_redraw("open save dialog for pointer Save")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1892, 1892, 31, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1893, 1893, 29, 0))
                        + buffer_release_message()
                    )
                    workflow_click(316, 272, 1900, "pointer Save save dialog")
                    if child_u32("save_confirm_open") != 0:
                        raise AssertionError("pointer Save did not close the save dialog")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"za":
                            raise AssertionError("pointer Save did not write the confirmed document")
                    observations.append(
                        "Settings toggles confirm-before-save; Ctrl+S shows a default-on modal; "
                        "Escape and pointer Cancel leave the file untouched; Enter and pointer Save commit it"
                    )
                    client.sendall(wire_message(10, 1))
                    return
                    client.sendall(wire_message(10, 1))
                    return

                if dynamic_growth_test:
                    # An exact-capacity document starts with no free gap.
                    # Inserting at its beginning must grow and relocate the
                    # suffix without changing its logical contents.
                    before_growth = read_document_state()
                    if (
                        before_growth.get("doc_length") != 65536
                        or before_growth.get("doc_capacity") != 65536
                        or before_growth.get("doc_gap_start") != 65536
                        or before_growth.get("doc_gap_end") != 65536
                    ):
                        raise AssertionError(
                            f"exact-capacity initial document was not loaded contiguously: {before_growth!r}"
                        )
                    key_step(1240, 44, "insert z to grow an exhausted 64 KiB gap")
                    after_growth = read_document_state()
                    expected_contents = b"z" + (b"a" * 65536)
                    if (
                        after_growth.get("doc_length") != 65537
                        or after_growth.get("doc_capacity") != 131072
                        or after_growth.get("doc_gap_start") != 1
                        or after_growth.get("doc_gap_end") != 65536
                        or after_growth.get("doc_contents") != expected_contents
                        or after_growth.get("doc_storage_error") != 0
                    ):
                        raise AssertionError(
                            f"gap-buffer growth did not preserve prefix/suffix bytes: {after_growth!r}"
                        )
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1250, 1250, 29, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1251, 1251, 31, 1))
                    )
                    workflow_redraw("Ctrl+S after dynamic document growth")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1252, 1252, 31, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1253, 1253, 29, 0))
                        + buffer_release_message()
                    )
                    if child_u32("save_confirm_open") == 1:
                        key_step(1254, 28, "confirm save after dynamic document growth")
                    observations.append(
                        "exact 64 KiB document growth to 128 KiB, suffix relocation, logical-byte preservation, and confirmed split-gap save verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                if gap_buffer_test:
                    # Start after A + the two-byte é, then alternate the gap
                    # across a UTF-8 prefix and ASCII suffix. Insertions, cursor
                    # motion, Backspace, Delete, and selection deletion must all
                    # preserve the logical byte stream while storage is split.
                    key_step(1250, 45, "insert x after UTF-8 prefix")
                    key_step(1252, 105, "move left before inserted x")
                    key_step(1254, 21, "insert y before x and move the gap left")
                    key_step(1256, 106, "move right across x")
                    key_step(1258, 14, "Backspace deletes x from the suffix")
                    key_step(1260, 111, "Delete removes B after the gap")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1262, 1262, 42, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1263, 1263, 105, 1))
                    )
                    workflow_redraw("Shift+Left selects y across the gap")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1264, 1264, 105, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1265, 1265, 42, 0))
                        + buffer_release_message()
                    )
                    key_step(1266, 14, "Backspace removes the selected y")
                    workflow_shortcut(1270, 31, "Ctrl+S saves split gap-buffer segments")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "gap movement, insertion, Backspace, Delete, UTF-8 prefix reads, selection deletion, and two-segment save"
                    )
                    return

                if utf8_edit_test:
                    # UTF-8 fixture: A + U+00E9 (2 bytes) + U+20AC (3 bytes)
                    # + U+1F600 (4 bytes) + B. All cursor/edit operations must
                    # preserve complete scalar boundaries.
                    key_step(1300, 106, "Right over ASCII A")
                    key_step(1302, 106, "Right over two-byte UTF-8 character")
                    key_step(1304, 106, "Right over three-byte UTF-8 character")
                    key_step(1306, 106, "Right over four-byte UTF-8 character")
                    # Select the complete four-byte character with Shift+Left.
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1308, 1308, 42, 1))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1309, 1309, 105, 1))
                    )
                    workflow_redraw("Shift+Left selects complete four-byte character")
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1310, 1310, 105, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1311, 1311, 42, 0))
                        + buffer_release_message()
                    )
                    key_step(1312, 14, "Backspace removes selected four-byte character")
                    key_step(1314, 105, "Left over three-byte UTF-8 character")
                    key_step(1316, 106, "Right over three-byte UTF-8 character")
                    key_step(1318, 14, "Backspace removes three-byte character")
                    key_step(1320, 105, "Left over two-byte UTF-8 character")
                    key_step(1322, 106, "Right over two-byte UTF-8 character")
                    key_step(1324, 14, "Backspace removes two-byte character")
                    workflow_shortcut(1400, 31, "Ctrl+S saves UTF-8 boundary edits")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "Right/Left and Backspace handled 2-, 3-, and 4-byte UTF-8 scalars without splitting them"
                    )
                    return

                if utf8_delete_test:
                    # Delete-forward must remove one complete scalar at a time.
                    for index, serial in enumerate((1500, 1502, 1504, 1506)):
                        key_step(serial, 111, f"Delete-forward UTF-8 token {index + 1}")
                    workflow_shortcut(1600, 31, "Ctrl+S saves UTF-8 forward deletions")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "Delete-forward removed ASCII, 2-byte, 3-byte, and 4-byte UTF-8 scalars as complete units"
                    )
                    return

                if utf8_pointer_test:
                    # The visual column after A, é, €, and 😀 is byte offset
                    # 10, not offset 4. Pointer hit-testing must map that cell
                    # back to the byte boundary before B.
                    key_step(1900, 14, "Backspace at pointer-selected UTF-8 boundary")
                    workflow_shortcut(1910, 31, "Ctrl+S saves pointer-selected UTF-8 edit")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "pointer hit-testing mapped the visual cell after mixed-width UTF-8 code points to the correct byte boundary"
                    )
                    return

                if utf8_invalid_test:
                    # F0 28 8C 28 is malformed UTF-8. Invalid bytes must stay
                    # independently editable rather than swallowing adjacent
                    # printable ASCII bytes into a replacement sequence.
                    for index, serial in enumerate((1700, 1702, 1704, 1706, 1708, 1710)):
                        key_step(serial, 111, f"Delete malformed UTF-8 token {index + 1}")
                    workflow_shortcut(1800, 31, "Ctrl+S saves malformed-byte edits")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "malformed UTF-8 bytes remained individually editable and adjacent ASCII bytes were preserved"
                    )
                    return

                key_step(1002, 30, "insert a")
                if initial_preferred_buffer_scale > 1 or initial_preferred_buffer_transform != 0 or fractional_scale_test:
                    # Fractional raster scales move the exact physical sample
                    # point; inspect the first glyph cell in logical space
                    # rather than assuming its 1x pixel grid.
                    a_visible = antialiased_ink_present(16, 88, 8, 18)
                else:
                    a_pixel = struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0]
                    a_visible = a_pixel == 0xFFD8DEE9
                if not a_visible:
                    raise AssertionError("first key did not render an A glyph in its logical cell")
                if initial_preferred_buffer_scale > 1 or initial_preferred_buffer_transform != 0 or fractional_scale_test:
                    observations.append(
                        "integer/fractional scale plus buffer transforms preserved logical pointer hit-testing, caret placement, and glyph rasterization"
                    )
                    client.sendall(wire_message(10, 1))
                    return
                key_step(1003, 48, "insert b")
                key_step(1004, 105, "cursor left")
                key_step(1005, 14, "backspace")
                key_step(1006, 106, "cursor right")
                key_step(1007, 28, "insert newline")
                key_step(1008, 3, "insert digit 2")
                key_step(1009, 103, "cursor up")
                key_step(1010, 108, "cursor down")

                # Shift state comes from wl_keyboard.modifiers rather than
                # depending only on the physical Shift key event.
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1011, 1011, 42, 1))
                    + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1012, 1, 0, 0, 0))
                    + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1013, 1013, 2, 1))
                )
                expect_message(client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), "shifted key attach")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "shifted key damage")
                expect_message(client, (8, 6, b""), "shifted key commit")
                shifted_key_pixels = bytes(pixels)
                if read_document_state()["doc_contents"] != b"b\n2!":
                    raise AssertionError(
                        "Shift+1 fixture content changed before repeat: "
                        f"{read_document_state()['doc_contents']!r}"
                    )
                # Release the 1 key itself before releasing Shift. Omitting
                # this key-up leaves it held and appends repeat characters to
                # every later pointer/selection assertion.
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1014, 1014, 2, 0))
                    + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1015, 1015, 42, 0))
                    + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1016, 0, 0, 0, 0))
                    + buffer_release_message()
                )

                # The remaining document must be "b\n2!": Backspace removed
                # a, Enter and digit 2 formed the second line, and Shift+1
                # produced the exclamation mark.
                first_line = [
                    struct.unpack_from("<I", shifted_key_pixels, 92 * 800 * 4 + x * 4)[0]
                    for x in range(16, 24)
                ]
                if first_line[0] != 0xFFD8DEE9:
                    raise AssertionError(
                        "expected B glyph was not rendered at the first line; "
                        f"first pixels={[hex(value) for value in first_line]}"
                    )
                if struct.unpack_from("<I", shifted_key_pixels, 104 * 800 * 4 + 17 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("expected digit 2 was not rendered on the second line")
                if struct.unpack_from("<I", shifted_key_pixels, 104 * 800 * 4 + 26 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("Shift+1 did not render an exclamation mark")
                if struct.unpack_from("<I", shifted_key_pixels, 104 * 800 * 4 + 32 * 4)[0] != 0xFFFFFFFF:
                    raise AssertionError("document caret was not rendered after the shifted character")
                # The footer tracks the current logical caret position and byte count.
                if struct.unpack_from("<I", shifted_key_pixels, 466 * 800 * 4 + 41 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("status bar did not show logical line 2")
                if struct.unpack_from("<I", shifted_key_pixels, 466 * 800 * 4 + 100 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("status bar did not show logical column 3")
                observations.append(
                    "US-QWERTY insertion, cursor movement, Backspace, Enter, digit rendering, caret and live status verified"
                )

                shift_frame_pixels = bytearray(len(pixels))
                shift_frame_state = {}

                def key_step_shift(serial: int, code: int, label: str) -> None:
                    client.sendall(
                        wire_message(keyboard_object_id, 4, struct.pack("<IIIII", serial, 1, 0, 0, 0))
                        + wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial + 1, serial + 1, code, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    # Capture the modifier-held frame before key-up and buffer
                    # release can allow the compositor to receive another one.
                    shift_frame_pixels[:] = pixels
                    shift_frame_state.clear()
                    shift_frame_state.update({
                        "cursor": child_u32("doc_cursor"),
                        "length": child_u32("doc_length"),
                        "contents": read_document_state()["doc_contents"],
                    })
                    client.sendall(
                        wire_message(keyboard_object_id, 3, struct.pack("<IIII", serial + 2, serial + 2, code, 0)
                        )
                        + buffer_release_message()
                        + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", serial + 3, 0, 0, 0, 0))
                    )

                pointer_click_pixels = bytearray(len(pixels))

                def pointer_click(x: int, y: int, serial: int, label: str) -> None:
                    # This mock uses one active wl_buffer. Wait until the
                    # preceding release has been consumed before generating
                    # another pointer-driven frame.
                    wait_buffer_idle(f"{label} waits for prior buffer release")
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    # Inspect the exact frame rendered for this click before
                    # a release-triggered repaint can reuse the shared buffer.
                    pointer_click_pixels[:] = pixels
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                        )
                        + buffer_release_message()
                    )
                    wait_buffer_idle(f"{label} waits for click-frame release")

                def pointer_drag(
                    start_x: int, start_y: int, end_x: int, end_y: int,
                    serial: int, label: str
                ) -> None:
                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256)
                        )
                        + wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), f"{label} press attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} press damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} press commit")
                    client.sendall(buffer_release_message())

                    client.sendall(
                        wire_message(pointer_object_id, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), f"{label} motion attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} motion damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} motion commit")
                    client.sendall(
                        wire_message(pointer_object_id, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0)
                        )
                        + buffer_release_message()
                    )

                # Mouse movement followed by a click snaps to character
                # insertion boundaries across lines and between characters.
                pointer_click(22, 98, 1100, "mouse caret first line")
                first_line_caret = struct.unpack_from(
                    "<I", pointer_click_pixels, 92 * 800 * 4 + 24 * 4
                )[0]
                if first_line_caret != 0xFFFFFFFF:
                    raise AssertionError("mouse click did not place caret after first-line text")

                pointer_click(18, 110, 1110, "mouse caret second-line start")
                second_line_start = struct.unpack_from(
                    "<I", pointer_click_pixels, 104 * 800 * 4 + 16 * 4
                )[0]
                if second_line_start != 0xFFFFFFFF:
                    raise AssertionError("mouse click did not place caret at second-line start")

                pointer_click(26, 110, 1120, "mouse caret between characters")
                between_chars = struct.unpack_from(
                    "<I", pointer_click_pixels, 104 * 800 * 4 + 24 * 4
                )[0]
                if between_chars != 0xFFFFFFFF:
                    raise AssertionError("mouse click did not place caret between second-line characters")
                observations.append(
                    "mouse clicks placed the document caret on multiple lines and between characters"
                )

                # Drag backwards across both characters on line two. Selection
                # bounds must remain ordered even when the anchor is after the cursor.
                pointer_drag(32, 110, 16, 110, 1130, "reverse mouse drag selection")
                # Inspect each cell's trailing blank column so the
                # insertion caret and glyph strokes do not mask the highlight.
                for x in (23, 31):
                    selected_pixel = struct.unpack_from(
                        "<I", pixels, 104 * 800 * 4 + x * 4
                    )[0]
                    if selected_pixel != 0xFF5E81AC:
                        debug_names = {
                            "doc_selection_start", "doc_selection_end",
                            "doc_selection_anchor", "doc_cursor", "doc_selection_active",
                            "doc_length", "pointer_x", "pointer_y",
                            "doc_line_index_base", "doc_line_count", "doc_line_index_valid",
                            "doc_line_index_columns", "window_doc_pixel_width",
                            "font_loaded", "font_units_per_em", "font_num_glyphs",
                            "font_probe_advance_A", "font_probe_advance_B",
                        }
                        debug_addresses = {}
                        for debug_line in subprocess.check_output(["nm", "-n", binary], text=True).splitlines():
                            debug_fields = debug_line.split()
                            if len(debug_fields) == 3 and debug_fields[2] in debug_names:
                                debug_addresses[debug_fields[2]] = int(debug_fields[0], 16)
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as debug_memory:
                            debug_fd = debug_memory.fileno()
                            debug_state = {
                                name: struct.unpack("<q" if name == "doc_line_index_base" else "<i",
                                                    os.pread(debug_fd, 8 if name == "doc_line_index_base" else 4, address))[0]
                                for name, address in debug_addresses.items()
                            }
                            index_base = debug_state.get("doc_line_index_base", 0)
                            debug_state["line_records"] = [
                                struct.unpack("<4I", os.pread(debug_fd, 16, index_base + row * 16))
                                for row in range(min(debug_state.get("doc_line_count", 0), 3))
                            ] if index_base else []
                        raise AssertionError(
                            "drag selection did not highlight both selected characters; "
                            f"x={x}, pixel={hex(selected_pixel)}, state={debug_state!r}"
                        )

                # Typing replaces the selected byte range rather than inserting
                # beside it, and the highlight disappears after replacement.
                key_step(1136, 30, "replace selected text")
                replacement_pixel = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 17 * 4
                )[0]
                if replacement_pixel != 0xFFD8DEE9:
                    raise AssertionError("typing did not replace the selected text with an A glyph")
                cleared_pixel = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 25 * 4
                )[0]
                if cleared_pixel != 0xFF252A33:
                    raise AssertionError("selection highlight remained after replacing selected text")
                observations.append(
                    "mouse drag selection highlighted text in reverse direction and typing replaced the selection"
                )

                # Extend the next selection from the end of line one through
                # the character on line two, covering the selected newline.
                pointer_drag(24, 98, 24, 110, 1140, "multi-line mouse drag selection")
                newline_highlight = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 24 * 4
                )[0]
                second_line_highlight = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 23 * 4
                )[0]
                if newline_highlight != 0xFF5E81AC or second_line_highlight != 0xFF5E81AC:
                    raise AssertionError(
                        "multi-line drag did not highlight the newline and second-line text; "
                        f"newline={hex(newline_highlight)}, text={hex(second_line_highlight)}"
                    )

                key_step(1146, 30, "replace multi-line selection")
                merged_line_pixel = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 25 * 4
                )[0]
                cleared_second_line = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 17 * 4
                )[0]
                if merged_line_pixel != 0xFFD8DEE9:
                    raise AssertionError("multi-line selection replacement did not join text on one line")
                if cleared_second_line != 0xFF252A33:
                    raise AssertionError("multi-line selection replacement left stale text on the next line")
                observations.append(
                    "multi-line drag highlighted the newline and replaced the selected range across lines"
                )

                # The previous replacement leaves the single line "bA" with
                # the insertion point after A. Shift+Left extends and preserves
                # the anchor; an unshifted Right collapses to the far edge.
                key_step_shift(1150, 105, "Shift+Left select A")
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 31 * 4)[0] != 0xFF5E81AC:
                    raise AssertionError("Shift+Left did not highlight the preceding character")
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 23 * 4)[0] != 0xFF252A33:
                    raise AssertionError("Shift+Left selected more than one character on its first step")

                key_step_shift(1154, 105, "Shift+Left extend selection")
                for x in (23, 31):
                    pixel = struct.unpack_from("<I", pixels, 92 * 800 * 4 + x * 4)[0]
                    if pixel != 0xFF5E81AC:
                        raise AssertionError(
                            "repeated Shift+Left did not extend from the original anchor; "
                            f"x={x}, pixel={hex(pixel)}"
                        )

                key_step(1158, 106, "Right collapse keyboard selection")
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 23 * 4)[0] != 0xFF252A33:
                    raise AssertionError("Right did not clear the keyboard selection highlight")
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 32 * 4)[0] != 0xFFFFFFFF:
                    raise AssertionError("Right did not collapse the selection to its far edge")

                # Extend a selection across the newline with Shift+Up and
                # return to the anchor with Shift+Down.
                key_step(1162, 28, "append newline for vertical selection")
                key_step(1163, 46, "append c for vertical selection")
                key_step(1164, 32, "append d for vertical selection")
                key_step_shift(1168, 103, "Shift+Up select previous line")
                vertical_pixels = [
                    struct.unpack_from("<I", shift_frame_pixels, 92 * 800 * 4 + 39 * 4)[0],
                    struct.unpack_from("<I", shift_frame_pixels, 104 * 800 * 4 + 23 * 4)[0],
                    struct.unpack_from("<I", shift_frame_pixels, 104 * 800 * 4 + 31 * 4)[0],
                ]
                if vertical_pixels != [0xFF5E81AC] * 3:
                    raise AssertionError(
                        "Shift+Up did not select across the newline and previous line; "
                        f"pixels={[hex(x) for x in vertical_pixels]}"
                    )
                key_step_shift(1172, 108, "Shift+Down collapse vertical selection")
                if struct.unpack_from("<I", shift_frame_pixels, 92 * 800 * 4 + 39 * 4)[0] != 0xFF252A33:
                    raise AssertionError("Shift+Down back to the anchor did not clear selection")

                key_step_shift(1176, 102, "Shift+Home select to line start")
                if struct.unpack_from("<I", shift_frame_pixels, 104 * 800 * 4 + 31 * 4)[0] != 0xFF5E81AC:
                    raise AssertionError("Shift+Home did not select text to the start of the line")
                key_step_shift(1180, 107, "Shift+End collapse to line end")
                if struct.unpack_from("<I", shift_frame_pixels, 104 * 800 * 4 + 31 * 4)[0] != 0xFF252A33:
                    raise AssertionError("Shift+End did not clear selection after returning to its anchor")
                shift_end_caret_pixel = struct.unpack_from(
                    "<I", shift_frame_pixels, 104 * 800 * 4 + 32 * 4
                )[0]
                if shift_end_caret_pixel != 0xFFFFFFFF:
                    raise AssertionError(
                        "Shift+End did not leave the caret at the line end: "
                        f"pixel={hex(shift_end_caret_pixel)}, "
                        f"doc_cursor={shift_frame_state.get('cursor')}, "
                        f"doc_length={shift_frame_state.get('length')}, "
                        f"doc_bytes={shift_frame_state.get('contents', b'')[:24]!r}"
                    )
                observations.append(
                    "Shift+Arrow and Shift+Home/End selection, extension, collapse, and multi-line highlighting"
                )

                def expect_redraw(label: str) -> None:
                    expect_message(
                        client, (8, 1, struct.pack("<III", client_buffer_id, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")

                # Hold Left: the initial press acts immediately, then repeat
                # begins after the compositor-specified delay and continues at
                # roughly 30 Hz. Snapshot each rendered frame before releasing
                # the buffer, so a queued repeat redraw cannot overwrite it.
                repeat_started = time.monotonic()
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1200, 1200, 105, 1))
                )
                expect_redraw("initial held Left")
                caret = struct.unpack_from("<I", pixels, 104 * 800 * 4 + 24 * 4)[0]
                if caret != 0xFFFFFFFF:
                    raise AssertionError("initial Left press did not move the caret once")
                client.sendall(buffer_release_message())

                expect_redraw("first repeated Left")
                first_repeat_elapsed = time.monotonic() - repeat_started
                expected_delay = 0.18 if advertised_seat_version >= 4 else 0.30
                if first_repeat_elapsed < expected_delay - 0.04:
                    raise AssertionError(
                        "keyboard repeat started before the compositor/fallback delay; "
                        f"expected={expected_delay:.3f}s elapsed={first_repeat_elapsed:.3f}s"
                    )
                caret = struct.unpack_from("<I", pixels, 104 * 800 * 4 + 16 * 4)[0]
                if caret != 0xFFFFFFFF:
                    raise AssertionError("first repeated Left did not move the caret to line start")
                client.sendall(buffer_release_message())

                expect_redraw("second repeated Left")
                caret = struct.unpack_from("<I", pixels, 92 * 800 * 4 + 32 * 4)[0]
                if caret != 0xFFFFFFFF:
                    raise AssertionError("continued Left repeat did not cross to the previous line")
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1201, 1201, 105, 0))
                    + buffer_release_message()
                )

                # Backspace is repeatable too: after its immediate deletion,
                # the held key should delete the preceding character again.
                expected_repeat_rate = 10 if advertised_seat_version >= 4 else 30
                expected_repeat_delay_ms = 180 if advertised_seat_version >= 4 else 300
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1210, 1210, 14, 1))
                )
                expect_redraw("initial held Backspace")
                first_line_b = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 17 * 4
                )[0]
                if first_line_b != 0xFFD8DEE9:
                    raise AssertionError("initial Backspace removed more than one character")
                backspace_cursor_after_first_press = child_u32("doc_cursor")
                if (
                    child_u32("repeat_keycode") != 14
                    or child_u32("repeat_rate") != expected_repeat_rate
                    or child_u32("repeat_delay_ms") != expected_repeat_delay_ms
                ):
                    raise AssertionError(
                        "held Backspace did not arm the compositor-configured repeat timer: "
                        + repr({
                            "repeat_keycode": child_u32("repeat_keycode"),
                            "repeat_rate": child_u32("repeat_rate"),
                            "repeat_delay_ms": child_u32("repeat_delay_ms"),
                        })
                    )
                client.sendall(buffer_release_message())
                backspace_repeat_deadline = time.monotonic() + 2.0
                while (
                    child_u32("doc_cursor") >= backspace_cursor_after_first_press
                    and time.monotonic() < backspace_repeat_deadline
                ):
                    time.sleep(0.005)
                if child_u32("doc_cursor") >= backspace_cursor_after_first_press:
                    raise AssertionError(
                        "held Backspace timer expired without deleting the preceding character: "
                        + repr({
                            "doc_cursor": child_u32("doc_cursor"),
                            "repeat_keycode": child_u32("repeat_keycode"),
                            "repeat_rate": child_u32("repeat_rate"),
                        })
                    )
                expect_redraw("repeated Backspace")
                removed_b = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 17 * 4
                )[0]
                if removed_b != 0xFF252A33:
                    raise AssertionError(
                        "repeated Backspace changed document state but did not render the deleted character"
                    )
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1211, 1211, 14, 0))
                    + buffer_release_message()
                )

                # Delete-forward uses the same delayed repeat path.
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1220, 1220, 111, 1))
                )
                expect_redraw("initial held Delete")
                first_cell = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 20 * 4
                )[0]
                if first_cell != 0xFFD8DEE9:
                    raise AssertionError("initial Delete did not move the first character onto line one")
                delete_length_after_first_press = child_u32("doc_length")
                if (
                    child_u32("repeat_keycode") != 111
                    or child_u32("repeat_rate") != expected_repeat_rate
                    or child_u32("repeat_delay_ms") != expected_repeat_delay_ms
                ):
                    raise AssertionError(
                        "held Delete did not arm the compositor-configured repeat timer: "
                        + repr({
                            "repeat_keycode": child_u32("repeat_keycode"),
                            "repeat_rate": child_u32("repeat_rate"),
                            "repeat_delay_ms": child_u32("repeat_delay_ms"),
                        })
                    )
                client.sendall(buffer_release_message())
                delete_repeat_deadline = time.monotonic() + 2.0
                while (
                    child_u32("doc_length") >= delete_length_after_first_press
                    and time.monotonic() < delete_repeat_deadline
                ):
                    time.sleep(0.005)
                if child_u32("doc_length") >= delete_length_after_first_press:
                    raise AssertionError(
                        "held Delete timer expired without deleting the next character: "
                        + repr({
                            "doc_length": child_u32("doc_length"),
                            "repeat_keycode": child_u32("repeat_keycode"),
                            "repeat_rate": child_u32("repeat_rate"),
                        })
                    )
                expect_redraw("repeated Delete")
                next_glyph = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 20 * 4
                )[0]
                if next_glyph != 0xFF252A33:
                    raise AssertionError(
                        "repeated Delete changed document state but did not render the deleted character"
                    )
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1221, 1221, 111, 0))
                    + buffer_release_message()
                )

                observations.append(
                    "keyboard auto-repeat used the compositor/fallback delay and repeated Left, Backspace, and Delete while held"
                )

                # Insert enough characters to pass the 95-cell line width.
                # They must wrap onto a second visual row rather than being
                # silently consumed after the right edge.
                for index in range(100):
                    key_step(1300 + index * 2, 30, f"soft-wrap character {index + 1}")
                wrapped_first = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 17 * 4
                )[0]
                if wrapped_first != 0xFFD8DEE9:
                    raise AssertionError(
                        "characters typed beyond the right edge were not rendered on the next row; "
                        f"pixel={hex(wrapped_first)}"
                    )
                # Assert the caret is on the second visual row without
                # assuming a fixed cell column: the cursor x-coordinate is
                # determined by the actual wrapped-row width and insertion
                # offset, not by a magic pixel constant.
                wrapped_row_carets = [
                    candidate_x
                    for candidate_x in range(16, 800 - 1, 8)
                    if all(
                        struct.unpack_from(
                            "<I", pixels,
                            (104 + row) * 800 * 4 + candidate_x * 4
                        )[0] == 0xFFFFFFFF
                        for row in range(9)
                    )
                ]
                if not wrapped_row_carets:
                    debug_state = read_document_state()
                    caret_candidates = []
                    for candidate_y in range(92, initial_height - 9, 12):
                        for candidate_x in range(16, 800 - 1, 8):
                            if all(
                                struct.unpack_from(
                                    "<I", pixels,
                                    (candidate_y + row) * 800 * 4 + candidate_x * 4
                                )[0] == 0xFFFFFFFF
                                for row in range(9)
                            ):
                                caret_candidates.append((candidate_x, candidate_y))
                    modifier_state = {
                        name: child_u32(name)
                        for name in (
                            "keymap_format", "xkb_modifiers", "shift_down",
                            "caps_lock", "num_lock", "keyboard_group",
                            "repeat_keycode", "doc_selection_active",
                        )
                    }
                    raise AssertionError(
                        "caret did not follow the text onto its soft-wrapped row: "
                        + repr({
                            "wrapped_row_carets": wrapped_row_carets,
                            "cursor": debug_state.get("doc_cursor"),
                            "length": debug_state.get("doc_length"),
                            "contents": debug_state.get("doc_contents"),
                            "line_records": debug_state.get("doc_line_index_records"),
                            "total_visual_rows": debug_state.get("doc_total_visual_rows"),
                            "view_top": debug_state.get("doc_view_top_row"),
                            "caret_candidates": caret_candidates,
                            "modifier_state": modifier_state,
                        })
                    )

                # A click on the wrapped row must map back to the same visual
                # insertion point, not to a logical hard-newline-only row.
                pointer_click(40, 110, 1510, "click within soft-wrapped row")
                wrapped_click_caret = struct.unpack_from(
                    "<I", pointer_click_pixels, 104 * 800 * 4 + 40 * 4
                )[0]
                if wrapped_click_caret != 0xFFFFFFFF:
                    raise AssertionError("mouse hit testing did not account for soft-wrapped rows")

                # Add enough further lines to exceed the viewport. The active
                # caret row should scroll into view at the bottom instead of
                # becoming invisible below the window.
                for index in range(36):
                    key_step(1600 + index * 4, 28, f"append scroll line {index + 1}")
                    key_step(1602 + index * 4, 30, f"append scroll text {index + 1}")
                bottom_row_y = 92 + (30 - 1) * 12
                scrolled_glyph = struct.unpack_from(
                    "<I", pixels, bottom_row_y * 800 * 4 + 17 * 4
                )[0]
                if scrolled_glyph != 0xFFD8DEE9:
                    visible_carets = []
                    for candidate_y in range(92, 460 - 9, 12):
                        for candidate_x in range(16, 800 - 1, 8):
                            if all(
                                struct.unpack_from(
                                    "<I", pixels, (candidate_y + dy) * 800 * 4 + candidate_x * 4
                                )[0] == 0xFFFFFFFF
                                for dy in range(9)
                            ):
                                visible_carets.append((candidate_x, candidate_y))
                    sampled_rows = [
                        (candidate_y, hex(struct.unpack_from(
                            "<I", pixels, candidate_y * 800 * 4 + 17 * 4
                        )[0]))
                        for candidate_y in range(92, 460, 12)
                    ]
                    raise AssertionError(
                        "text/caret did not scroll into the visible bottom row after vertical overflow; "
                        f"pixel={hex(scrolled_glyph)}, visible_carets={visible_carets}, "
                        f"row_samples={sampled_rows}"
                    )
                bottom_caret = struct.unpack_from(
                    "<I", pixels, bottom_row_y * 800 * 4 + 24 * 4
                )[0]
                if bottom_caret != 0xFFFFFFFF:
                    raise AssertionError("caret was not kept visible after vertical scrolling")
                observations.append(
                    "long text soft-wrapped at the right edge, mouse hit testing followed wrapped rows, and the active line scrolled into view vertically"
                )

                # Ctrl+A selects the entire document, including content above
                # the scrolled viewport, while keeping the final caret visible.
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1700, 1700, 29, 1))
                    + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1701, 4, 0, 0, 0))
                    + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1702, 1702, 30, 1))
                )
                expect_redraw("Ctrl+A select all")
                selection_pixel = struct.unpack_from(
                    "<I", pixels, (bottom_row_y + 11) * 800 * 4 + 23 * 4
                )[0]
                if selection_pixel != 0xFF5E81AC:
                    raise AssertionError(
                        "Ctrl+A did not highlight the complete document through the visible final row; "
                        f"pixel={hex(selection_pixel)}"
                    )
                observations.append("Ctrl+A selected the complete document and rendered its visible selection")
                client.sendall(
                    buffer_release_message()
                    + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1703, 1703, 30, 0))
                    + wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1704, 1704, 29, 0))
                    + wire_message(keyboard_object_id, 4, struct.pack("<IIIII", 1705, 0, 0, 0, 0))
                )

                def caret_position(expected: tuple[int, int] | None = None) -> tuple[int, int]:
                    matches = []
                    for y in range(92, 460 - 9, 12):
                        for x in range(16, 800 - 1, 8):
                            if all(
                                struct.unpack_from("<I", pixels, (y + dy) * 800 * 4 + x * 4)[0]
                                == 0xFFFFFFFF
                                for dy in range(9)
                            ):
                                matches.append((x, y))
                    if expected is not None and expected in matches:
                        return expected
                    if expected is not None and matches:
                        # Glyph strokes can resemble the one-pixel caret. Prefer
                        # the candidate nearest the known row start for this test.
                        return min(matches, key=lambda point: (
                            abs(point[1] - expected[1]), abs(point[0] - expected[0])
                        ))
                    if matches:
                        return matches[0]
                    raise AssertionError("visible document caret could not be located")

                # A held printable key must insert the initial character and
                # then additional characters at the compositor's configured rate.
                before = caret_position()
                client.sendall(wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1710, 1710, 30, 1)))
                expect_redraw("initial held printable key")
                after_press = caret_position()
                # Ctrl+A left the complete document selected, so this first
                # character must replace it and restart at the document origin.
                if after_press != (24, 92):
                    raise AssertionError(
                        f"initial printable press did not replace the selection at document start: "
                        f"before={before}, after={after_press}"
                    )
                client.sendall(buffer_release_message())
                expect_redraw("first repeated printable key")
                after_repeat = caret_position()
                if after_repeat != (32, 92):
                    raise AssertionError(
                        f"held printable key did not repeat into the next cell: "
                        f"after_press={after_press}, after_repeat={after_repeat}"
                    )
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("repeated printable-key test did not render its first glyph")
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1711, 1711, 30, 0))
                    + buffer_release_message()
                )
                # Do not start another held key until the event loop has
                # processed this key-up; otherwise a pending repeat timeout
                # can race the next key's first frame.
                wait_child_u32("repeat_keycode", 0, "held printable key release")

                # Enter repeats as well; each timer tick advances one visual row.
                before_enter = caret_position()
                client.sendall(wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1720, 1720, 28, 1)))
                expect_redraw("initial held Enter")
                after_enter = caret_position((16, before_enter[1] + 12))
                if after_enter != (16, before_enter[1] + 12):
                    failure_state = read_document_state()
                    caret_candidates = [
                        (x, y)
                        for y in range(92, 460 - 9, 12)
                        for x in range(16, 800 - 1, 8)
                        if all(
                            struct.unpack_from("<I", pixels, (y + dy) * 800 * 4 + x * 4)[0]
                            == 0xFFFFFFFF
                            for dy in range(9)
                        )
                    ]
                    raise AssertionError(
                        "initial Enter did not move to the next row: "
                        f"before={before_enter}, after={after_enter}, "
                        f"doc_cursor={child_u32('doc_cursor')}, "
                        f"doc_length={child_u32('doc_length')}, "
                        f"repeat_keycode={child_u32('repeat_keycode')}, "
                        f"ctrl_down={child_u32('ctrl_down')}, "
                        f"text_input_object={child_u32('text_input_object')}, "
                        f"text_input_enabled={child_u32('text_input_enabled')}, "
                        f"doc_gap=({failure_state.get('doc_gap_start')},"
                        f"{failure_state.get('doc_gap_end')}), "
                        f"line_index_valid={failure_state.get('doc_line_index_valid')}, "
                        f"line_count={failure_state.get('doc_line_count')}, "
                        f"line_records={failure_state.get('doc_line_index_records')}, "
                        f"caret_candidates={caret_candidates}, "
                        f"doc_bytes={failure_state['doc_contents'][:24]!r}"
                    )
                after_enter_cursor = child_u32("doc_cursor")
                client.sendall(buffer_release_message())
                wait_child_u32(
                    "doc_cursor",
                    after_enter_cursor + 1,
                    "first repeated Enter insertion",
                )
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1721, 1721, 28, 0))
                )
                wait_child_u32(
                    "repeat_keycode", 0, "held Enter release after first repeat"
                )
                expect_redraw("first repeated Enter")
                after_enter_repeat = caret_position((16, after_enter[1] + 12))
                if after_enter_repeat != (16, after_enter[1] + 12):
                    raise AssertionError(
                        f"held Enter did not repeat: after_press={after_enter}, after_repeat={after_enter_repeat}"
                    )
                client.sendall(buffer_release_message())
                wait_child_u32(
                    "repeat_keycode", 0, "Enter release before starting Tab"
                )

                # Tab inserts four spaces per action, both on initial press and repeat.
                before_tab = caret_position()
                before_tab_cursor = child_u32("doc_cursor")
                client.sendall(wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1730, 1730, 15, 1)))
                # A delayed redraw from the preceding held Enter can otherwise
                # satisfy expect_redraw() before this Tab event is dispatched.
                # Synchronize on both its repeat state and actual document edit.
                wait_child_u32("repeat_keycode", 15, "initial held Tab key event")
                wait_child_u32(
                    "doc_cursor",
                    before_tab_cursor + 4,
                    "initial held Tab inserts four spaces",
                )
                expect_redraw("initial held Tab")
                after_tab = caret_position()
                if after_tab != (before_tab[0] + 32, before_tab[1]):
                    raise AssertionError(
                        f"initial Tab did not insert four spaces: before={before_tab}, after={after_tab}"
                    )
                after_tab_cursor = child_u32("doc_cursor")
                client.sendall(buffer_release_message())
                wait_child_u32(
                    "doc_cursor",
                    after_tab_cursor + 4,
                    "first repeated Tab insertion",
                )
                client.sendall(
                    wire_message(keyboard_object_id, 3, struct.pack("<IIII", 1731, 1731, 15, 0))
                )
                wait_child_u32(
                    "repeat_keycode", 0, "held Tab release after first repeat"
                )
                expect_redraw("first repeated Tab")
                after_tab_repeat = caret_position()
                if after_tab_repeat != (after_tab[0] + 32, after_tab[1]):
                    raise AssertionError(
                        f"held Tab did not repeat: after_press={after_tab}, after_repeat={after_tab_repeat}"
                    )
                client.sendall(buffer_release_message())
                wait_child_u32(
                    "repeat_keycode", 0, "legacy seat-v3 Tab release before close"
                )
                observations.append(
                    "printable characters, Enter, and Tab repeated while held; compositor repeat_info and legacy fallback were exercised"
                )

            finally:
                if pixels is not None:
                    pixels.close()
                os.close(shm_fd)

            if send_protocol_error:
                message = b"test compositor protocol error"
                encoded = message + b"\0"
                padded = encoded + b"\0" * (-len(encoded) % 4)
                payload = struct.pack("<II", 0, 1) + struct.pack("<I", len(encoded)) + padded
                client.sendall(wire_message(1, 0, payload))
            else:
                client.sendall(wire_message(10, 1))  # xdg_toplevel.close
        except Exception:
            errors.append(traceback.format_exc())
            # Do not leave the client blocked in poll() after the mock has
            # already failed; terminate it so the original compositor-side
            # assertion is reported instead of a misleading subprocess timeout.
            if process_holder:
                child = process_holder[0]
                if child.poll() is None:
                    child.terminate()
        finally:
            if client is not None:
                _FRAME_CALLBACK_STATES.pop(client, None)
                client.close()

    thread = threading.Thread(target=fake_compositor, daemon=True)
    thread.start()
    environment = os.environ.copy()
    environment.pop("NEKOEDIT_LOCALE", None)
    if compose_locale_test or compose_locale_invalid_test:
        environment["NEKOEDIT_LOCALE"] = "xx_TEST.UTF-8"
    if compose_locale_test:
        # The app-specific override must win even when the system locale differs.
        environment["LC_ALL"] = "pt_BR.UTF-8"
        environment["LC_CTYPE"] = "en_US.UTF-8"
        environment["LANG"] = "en_US.UTF-8"
    if compose_locale_settings_test:
        # This case must begin with the embedded default before clicking Settings.
        environment["LC_ALL"] = "C"
        environment["LC_CTYPE"] = "pt_BR.UTF-8"
        environment["LANG"] = "pt_BR.UTF-8"
    if compose_locale_system_test:
        # LC_ALL wins over both lower-priority character-locale variables.
        environment["LC_ALL"] = "pt_BR.UTF-8"
        environment["LC_CTYPE"] = "en_US.UTF-8"
        environment["LANG"] = "en_US.UTF-8"
    if compose_locale_c_fallback_test:
        environment["LC_ALL"] = "C"
        environment["LC_CTYPE"] = "pt_BR.UTF-8"
        environment["LANG"] = "pt_BR.UTF-8"
    if compose_locale_ctype_test:
        environment["LC_ALL"] = ""
        environment["LC_CTYPE"] = "pt_BR.utf8"
        environment["LANG"] = "en_US.UTF-8"
    if compose_locale_lang_test:
        environment["LC_ALL"] = ""
        environment["LC_CTYPE"] = ""
        environment["LANG"] = "pt_BR"
    if compose_locale_finnish_test:
        environment["LC_ALL"] = ""
        environment["LC_CTYPE"] = "fi_FI.utf8"
        environment["LANG"] = "en_US.UTF-8"
    if compose_locale_serbian_test:
        environment["LC_ALL"] = ""
        environment["LC_CTYPE"] = ""
        environment["LANG"] = "sr_RS.utf8"
    if compose_locale_saved_preference_test:
        environment["LC_ALL"] = "pt_BR.UTF-8"
        environment["LC_CTYPE"] = "pt_BR.UTF-8"
        environment["LANG"] = "pt_BR.UTF-8"
    # Never let a caller's shell opt-in leak into the default-path regression.
    environment.pop("NEKOEDIT_ENABLE_TEXT_INPUT", None)
    if text_input_test or text_input_opt_in_fallback_test or seat_hotplug_ime_test:
        environment["NEKOEDIT_ENABLE_TEXT_INPUT"] = "1"
    # Each mock receives an isolated HOME so preferences and journals never
    # enter the CI runner account. Only this test enables preferences to exercise
    # the default-on clipboard service setting.
    environment["HOME"] = runtime_dir
    if clipboard_persistence_test or compose_locale_settings_test or compose_locale_saved_preference_test:
        environment.pop("NEKOEDIT_DISABLE_PREFERENCES", None)
    else:
        environment["NEKOEDIT_DISABLE_PREFERENCES"] = "1"
    if font_test_path is not None:
        environment["NEKOEDIT_FONT"] = os.path.abspath(font_test_path)
        environment.pop("NEKOEDIT_DISABLE_FONT", None)
    else:
        environment["NEKOEDIT_DISABLE_FONT"] = "1"
    pass_fds = ()
    if use_wayland_socket:
        environment.pop("XDG_RUNTIME_DIR", None)
        environment.pop("WAYLAND_DISPLAY", None)
        environment["WAYLAND_SOCKET"] = str(client_endpoint.fileno())
        pass_fds = (client_endpoint.fileno(),)
    else:
        environment["XDG_RUNTIME_DIR"] = runtime_dir
        environment["WAYLAND_DISPLAY"] = display_name
        environment.pop("WAYLAND_SOCKET", None)
    try:
        command = [binary, initial_file] if initial_file is not None else [binary, "--backend=wayland"]
        process = subprocess.Popen(
            command,
            env=environment,
            pass_fds=pass_fds,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=runtime_dir if (file_workflow or compose_locale_settings_test) else None,
        )
        process_holder.append(process)
        if use_wayland_socket:
            # Popen has inherited the descriptor. Drop the parent's duplicate
            # so the compositor observes EOF when the child closes its socket.
            client_endpoint.close()
            client_endpoint = None
        # File and Settings-locale workflows include several sequential
        # picker/menu/install/import interactions. Keep a finite but generous
        # bound for slower hosted runners; regular keyboard/XKB cases retain
        # the shorter timeout.
        # The full default Wayland smoke scenario took 19.1s on the
        # preceding passing runner. Keep a bounded margin for runner variance;
        # fake-compositor socket deadlines still catch protocol stalls early.
        timeout_seconds = 90 if (file_workflow or compose_locale_settings_test) else 30
        try:
            stdout, stderr_bytes = process.communicate(timeout=timeout_seconds)
        except subprocess.TimeoutExpired:
            process.kill()
            stdout, stderr_bytes = process.communicate()
            thread.join(timeout=9)
            details = "\n".join(errors)
            raise AssertionError(
                f"NekoEdit exceeded the {timeout_seconds}s Wayland test timeout; "
                f"stderr={stderr_bytes.decode(errors='replace')!r}; "
                f"compositor_errors={details!r}"
            )
        result = subprocess.CompletedProcess(
            command, process.returncode, stdout, stderr_bytes
        )
    finally:
        thread.join(timeout=9)
        if server is not None:
            server.close()
        if client_endpoint is not None:
            client_endpoint.close()
        if absolute_file_path is not None:
            try:
                os.unlink(absolute_file_path)
            except FileNotFoundError:
                pass
        shutil.rmtree(runtime_dir, ignore_errors=True)

    if thread.is_alive():
        raise AssertionError("mock compositor did not finish the protocol exchange")
    stderr = result.stderr.decode(errors="replace")
    if errors:
        raise AssertionError(
            "mock compositor failed:\n" + "\n".join(errors)
            + f"\nNekoEdit exit status: {result.returncode}; stderr: {stderr!r}"
        )
    if compose_locale_settings_test:
        required_settings_observations = (
            "Settings installed-locale dropdown dynamically lists generic packs, selects aa_TEST, and persists built-in en_US without opening a file picker",
            "Settings Add Pack copied/validated pt_BR, preserved the source, and refreshed the dynamic installed-locale list",
            "Settings Remove Pack requires confirmation, refreshes the locale list, deletes the validated pack, restores en_US, and persists the fallback",
            "Settings Import converted a raw .XCompose file natively, preserved the source, and installed a separate private NLP1 pack",
        )
        missing_settings_observations = [
            expected for expected in required_settings_observations
            if expected not in observations
        ]
        if missing_settings_observations:
            raise AssertionError(
                "Settings locale selector scenario did not complete all checkpoints: "
                + repr(missing_settings_observations)
            )
    if disconnect_after_configure_ack:
        sentinel = b"PRIVATE_CONTENT_SENTINEL"
        if (
            result.returncode != 1
            or "NekoEdit: Wayland protocol or shared-memory setup failed." not in stderr
        ):
            raise AssertionError(
                "closed Wayland socket did not produce a controlled protocol-error exit: "
                f"status={result.returncode}, stderr={stderr!r}"
            )
        nul_present = b"\0" in result.stderr
        if len(result.stderr) > 512 or sentinel in result.stderr or nul_present:
            raise AssertionError(
                "closed-socket error output was unbounded, contained NUL bytes, or exposed document bytes: "
                f"stderr_length={len(result.stderr)}, nul_present={nul_present}, "
                f"sentinel_present={sentinel in result.stderr}"
            )
        print("Wayland closed-socket handling test passed without SIGPIPE termination.")
        return
    if send_protocol_error:
        if result.returncode == 0 or "test compositor protocol error" not in stderr:
            raise AssertionError(
                "NekoEdit did not report the compositor's wl_display.error: "
                f"status={result.returncode}, stderr={stderr!r}"
            )
        print("Wayland compositor protocol-error handling test passed.")
        return
    if result.returncode != 0:
        raise AssertionError(f"NekoEdit exited {result.returncode}: {stderr}")
    if verify_frame_callbacks:
        if (
            frame_callback_stats["requested"] < 1
            or frame_callback_stats["completed"] != frame_callback_stats["requested"]
            or frame_callback_stats["pending"]
        ):
            raise AssertionError(
                "frame callback lifecycle was incomplete: "
                f"{frame_callback_stats!r}"
            )
        observations.append(
            f"{frame_callback_stats['requested']} wl_surface.frame callbacks completed"
        )
    if save_roundtrip:
        with open(initial_file, "rb") as saved_file:
            saved_bytes = saved_file.read()
        if saved_bytes != expected_saved_bytes:
            raise AssertionError(
                f"Ctrl+S saved incorrect document bytes: expected {expected_saved_bytes!r}, got {saved_bytes!r}"
            )
        if initial_file_mode is not None:
            saved_mode = os.stat(initial_file).st_mode & 0o7777
            if saved_mode != initial_file_mode:
                raise AssertionError(
                    f"atomic save changed existing file mode: expected {initial_file_mode:#06o}, got {saved_mode:#06o}"
                )
    transport = "WAYLAND_SOCKET" if use_wayland_socket else "WAYLAND_DISPLAY"
    print(f"Wayland mock integration test passed using {transport} (registry, xdg-shell, memfd, pixels, close).")
    print("Verified: " + ", ".join(observations))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} PATH_TO_NEKOEDIT")
    run(sys.argv[1], verify_frame_callbacks=True)
    run(sys.argv[1], frame_callback_order_test=True)
    run(sys.argv[1], buffer_pool_test=True)
    # Exercise the optional text-input-v3/IME path independently of the
    # physical-keyboard fallback and without cursor-shape/clipboard globals.
    run(sys.argv[1], text_input_test=True, cursor_shape_supported=False)
    # An explicit text-input-v3 opt-in must remain harmless when the
    # compositor does not advertise the manager: no text-input object may be
    # created, and the full real-keymap typing/save scenario must still pass.
    fallback_fd, fallback_path = tempfile.mkstemp(prefix="nekoedit-text-input-fallback-")
    try:
        with os.fdopen(fallback_fd, "wb") as fallback_document:
            fallback_document.write(b"I")
        run(
            sys.argv[1],
            initial_file=fallback_path,
            save_roundtrip=True,
            expected_saved_bytes=b"IaAq@@wertyuiopasdfghjklzxcvbnm\"y@\"@@!@#$%^&*()_+~{}:\"<>?,77xWmM@\"qQ\xe2\x82\xac\xc3\xa9\xc3\xa9NV",
            keyboard_layout_test=True,
            text_input_opt_in_fallback_test=True,
        )
    finally:
        try:
            os.unlink(fallback_path)
        except FileNotFoundError:
            pass
    # A compositor disconnect immediately after xdg_surface.configure must
    # return a controlled protocol error rather than terminate via SIGPIPE.
    disconnect_fd, disconnect_path = tempfile.mkstemp(prefix="nekoedit-disconnect-")
    try:
        with os.fdopen(disconnect_fd, "wb") as disconnect_file:
            disconnect_file.write(b"PRIVATE_CONTENT_SENTINEL")
        run(
            sys.argv[1],
            initial_file=disconnect_path,
            disconnect_after_configure_ack=True,
        )
    finally:
        try:
            os.unlink(disconnect_path)
        except FileNotFoundError:
            pass
    # Test positional file loading and Ctrl+S using a temporary document.
    file_descriptor, file_path = tempfile.mkstemp(prefix="nekoedit-file-")
    try:
        with os.fdopen(file_descriptor, "wb") as initial_document:
            initial_document.write(b"I")
        os.chmod(file_path, 0o640)
        run(sys.argv[1], initial_file=file_path, save_roundtrip=True, expected_saved_bytes=b"za")
    finally:
        try:
            os.unlink(file_path)
        except FileNotFoundError:
            pass
    # Older wl_seat versions cannot send repeat_info; the client must retain
    # the 300 ms / 30 Hz compatibility fallback.
    run(sys.argv[1], use_wayland_socket=True, advertised_seat_version=3)
    run(sys.argv[1], send_protocol_error=True)
    # A punctuation-only map must not be accepted as a usable layout. The
    # client must retain the US fallback and still type an ordinary letter.
    run(sys.argv[1], sparse_keymap_test=True)
    # Parse a compact compiled-keymap-shaped XKB text-v1 fixture and verify
    # actual document bytes after group, Shift, and LevelThree translation.
    xkb_fd, xkb_path = tempfile.mkstemp(prefix="nekoedit-xkb-")
    try:
        with os.fdopen(xkb_fd, "wb") as xkb_document:
            xkb_document.write(b"I")
        run(
            sys.argv[1],
            initial_file=xkb_path,
            save_roundtrip=True,
            expected_saved_bytes=b"IaAq@@wertyuiopasdfghjklzxcvbnm\"y@\"@@!@#$%^&*()_+~{}:\"<>?,77xWmM@\"qQ\xe2\x82\xac\xc3\xa9\xc3\xa9NV",
            keyboard_layout_test=True,
            text_input_advertised=True,
        )
    finally:
        try:
            os.unlink(xkb_path)
        except FileNotFoundError:
            pass

    # The same physical evdev key follows its XKB symbol: Multi_key starts
    # Compose, while ISO_Level3_Shift still activates the LevelThree modifier.
    for test_flag, prefix in (
        ("right_alt_compose_test", "nekoedit-right-alt-compose-"),
        ("right_alt_level3_test", "nekoedit-right-alt-level3-"),
    ):
        right_alt_fd, right_alt_path = tempfile.mkstemp(prefix=prefix)
        try:
            with os.fdopen(right_alt_fd, "wb") as right_alt_document:
                right_alt_document.write(b"")
            run(
                sys.argv[1],
                initial_file=right_alt_path,
                **{test_flag: True},
            )
        finally:
            try:
                os.unlink(right_alt_path)
            except FileNotFoundError:
                pass

    # With no explicit interpret.repeat section default, the compatibility
    # default is still False. Re-run the fixture without that assignment.
    implicit_repeat_fd, implicit_repeat_path = tempfile.mkstemp(prefix="nekoedit-xkb-repeat-default-")
    try:
        with os.fdopen(implicit_repeat_fd, "wb") as implicit_repeat_document:
            implicit_repeat_document.write(b"I")
        run(
            sys.argv[1],
            initial_file=implicit_repeat_path,
            save_roundtrip=True,
            expected_saved_bytes=b"IaAq@@wertyuiopasdfghjklzxcvbnm\"y@\"@@!@#$%^&*()_+~{}:\"<>?,77xWmM@\"qQ\xe2\x82\xac\xc3\xa9\xc3\xa9NV",
            keyboard_layout_test=True,
            text_input_advertised=True,
            omit_compat_repeat_default=True,
        )
    finally:
        try:
            os.unlink(implicit_repeat_path)
        except FileNotFoundError:
            pass

    # Direct XKB Unicode keysyms must become valid UTF-8 in the document.
    unicode_fd, unicode_path = tempfile.mkstemp(prefix="nekoedit-unicode-keysyms-")
    try:
        with os.fdopen(unicode_fd, "wb") as unicode_document:
            unicode_document.write(b"")
        run(
            sys.argv[1],
            initial_file=unicode_path,
            unicode_keyboard_test=True,
        )
    finally:
        try:
            os.unlink(unicode_path)
        except FileNotFoundError:
            pass

    # CRC-invalid optional data must be rejected; built-in en_US remains usable.
    bad_locale_fd, bad_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-bad-")
    try:
        with os.fdopen(bad_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(sys.argv[1], initial_file=bad_locale_path,
            unicode_keyboard_test=True, compose_locale_invalid_test=True)
    finally:
        try: os.unlink(bad_locale_path)
        except FileNotFoundError: pass

    # Exercise an installed optional pack through real Wayland keyboard events.
    locale_fd, locale_path = tempfile.mkstemp(prefix="nekoedit-locale-valid-")
    try:
        with os.fdopen(locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(sys.argv[1], initial_file=locale_path,
            unicode_keyboard_test=True, compose_locale_test=True)
    finally:
        try: os.unlink(locale_path)
        except FileNotFoundError: pass



    # Exercise generic UTF-8 alias normalization with the actual Finnish data table.
    fi_locale_fd, fi_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-fi-")
    try:
        with os.fdopen(fi_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(sys.argv[1], initial_file=fi_locale_path, unicode_keyboard_test=True,
            compose_locale_finnish_test=True)
    finally:
        try: os.unlink(fi_locale_path)
        except FileNotFoundError: pass

    # Exercise Serbian Cyrillic Multi_key accent output from the actual locale table.
    sr_locale_fd, sr_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-sr-")
    try:
        with os.fdopen(sr_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(sys.argv[1], initial_file=sr_locale_path, unicode_keyboard_test=True,
            compose_locale_serbian_test=True)
    finally:
        try: os.unlink(sr_locale_path)
        except FileNotFoundError: pass

    # With no explicit NekoEdit override or saved preference, discover pt_BR from LC_ALL.
    system_locale_fd, system_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-system-")
    try:
        with os.fdopen(system_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(
            sys.argv[1],
            initial_file=system_locale_path,
            unicode_keyboard_test=True,
            compose_locale_system_test=True,
        )
    finally:
        try:
            os.unlink(system_locale_path)
        except FileNotFoundError:
            pass

    # A higher-priority C locale must suppress a pt_BR value in LC_CTYPE and LANG.
    c_locale_fd, c_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-c-")
    try:
        with os.fdopen(c_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(
            sys.argv[1],
            initial_file=c_locale_path,
            unicode_keyboard_test=True,
            compose_locale_c_fallback_test=True,
        )
    finally:
        try:
            os.unlink(c_locale_path)
        except FileNotFoundError:
            pass

    # LC_CTYPE controls character conversion when LC_ALL is empty. This also
    # tests the common pt_BR.utf8 spelling against the canonical pack filename.
    ctype_locale_fd, ctype_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-ctype-")
    try:
        with os.fdopen(ctype_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(
            sys.argv[1],
            initial_file=ctype_locale_path,
            unicode_keyboard_test=True,
            compose_locale_ctype_test=True,
        )
    finally:
        try:
            os.unlink(ctype_locale_path)
        except FileNotFoundError:
            pass

    # LANG is the fallback when both LC_ALL and LC_CTYPE are empty.
    lang_locale_fd, lang_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-lang-")
    try:
        with os.fdopen(lang_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(
            sys.argv[1],
            initial_file=lang_locale_path,
            unicode_keyboard_test=True,
            compose_locale_lang_test=True,
        )
    finally:
        try:
            os.unlink(lang_locale_path)
        except FileNotFoundError:
            pass

    # A saved en_US choice remains authoritative even under a pt_BR LC_ALL.
    saved_locale_fd, saved_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-saved-")
    try:
        with os.fdopen(saved_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(
            sys.argv[1],
            initial_file=saved_locale_path,
            unicode_keyboard_test=True,
            compose_locale_saved_preference_test=True,
        )
    finally:
        try:
            os.unlink(saved_locale_path)
        except FileNotFoundError:
            pass

    # Exercise the visible Settings locale selector against an installed pt_BR pack.
    print("Wayland: starting Settings locale selector scenario.")
    settings_locale_fd, settings_locale_path = tempfile.mkstemp(prefix="nekoedit-locale-settings-")
    try:
        with os.fdopen(settings_locale_fd, "wb") as locale_document:
            locale_document.write(b"")
        run(
            sys.argv[1],
            initial_file=settings_locale_path,
            unicode_keyboard_test=True,
            compose_locale_settings_test=True,
        )
    finally:
        try:
            os.unlink(settings_locale_path)
        except FileNotFoundError:
            pass
    print("Wayland: Settings locale selector scenario completed.")

    # Basic bounded snapshot undo/redo, including replacement of a selection.
    history_fd, history_path = tempfile.mkstemp(prefix="nekoedit-history-")
    try:
        with os.fdopen(history_fd, "wb") as history_document:
            history_document.write(b"abc")
        run(
            sys.argv[1],
            initial_file=history_path,
            history_test=True,
            cursor_shape_supported=False,
        )
    finally:
        try:
            os.unlink(history_path)
        except FileNotFoundError:
            pass

    # Wayland text clipboard interoperability: copy/cut immutable snapshots,
    # then paste a MIME offer from a separate compositor-side client.
    clipboard_fd, clipboard_path = tempfile.mkstemp(prefix="nekoedit-clipboard-")
    try:
        with os.fdopen(clipboard_fd, "wb") as clipboard_document:
            clipboard_document.write(b"copy me\n")
        run(
            sys.argv[1],
            initial_file=clipboard_path,
            clipboard_test=True,
            cursor_shape_supported=False,
        )
    finally:
        try:
            os.unlink(clipboard_path)
        except FileNotFoundError:
            pass

    # Exercise Copy/Paste/Cut through the in-surface menu and actual Wayland
    # data-device transfers, separately from keyboard shortcut coverage.
    context_menu_fd, context_menu_path = tempfile.mkstemp(prefix="nekoedit-context-menu-")
    try:
        with os.fdopen(context_menu_fd, "wb") as context_menu_document:
            context_menu_document.write(b"copy me\n")
        run(
            sys.argv[1],
            initial_file=context_menu_path,
            clipboard_test=True,
            context_menu_test=True,
            cursor_shape_supported=False,
        )
    finally:
        try:
            os.unlink(context_menu_path)
        except FileNotFoundError:
            pass

    # The bundled clipboard owner must serve the current selection after
    # the editor exits, then terminate when the compositor changes ownership.
    persistent_fd, persistent_path = tempfile.mkstemp(prefix="nekoedit-clipboard-persist-")
    try:
        with os.fdopen(persistent_fd, "wb") as persistent_file:
            persistent_file.write(b"keep me after close\n")
        run(
            sys.argv[1],
            initial_file=persistent_path,
            clipboard_persistence_test=True,
            cursor_shape_supported=False,
        )
    finally:
        try:
            os.unlink(persistent_path)
        except FileNotFoundError:
            pass

    # The embedded 5x7 renderer must cover every printable ASCII punctuation
    # character, not replace the unimplemented glyphs with '?'.
    punctuation_fd, punctuation_path = tempfile.mkstemp(prefix="nekoedit-punctuation-")
    try:
        with os.fdopen(punctuation_fd, "wb") as punctuation_file:
            punctuation_file.write(b"A!\"#$%&'()*+,-./:;<=>?@[\]^_")
            punctuation_file.write(bytes([96]) + b"{|}~")
        run(
            sys.argv[1],
            initial_file=punctuation_path,
            punctuation_render_test=True,
        )
    finally:
        try:
            os.unlink(punctuation_path)
        except FileNotFoundError:
            pass

    # UTF-8 code-point navigation/editing tests operate on files containing
    # two-, three-, and four-byte sequences and assert exact saved bytes.
    utf8_fixture = b"A\xc3\xa9\xe2\x82\xac\xf0\x9f\x98\x80B"
    for flag, expected in (
        ("utf8_edit_test", b"AB"),
        ("utf8_delete_test", b"B"),
    ):
        fd, utf8_path = tempfile.mkstemp(prefix="nekoedit-utf8-")
        try:
            with os.fdopen(fd, "wb") as document:
                document.write(utf8_fixture)
            run(
                sys.argv[1],
                initial_file=utf8_path,
                save_roundtrip=True,
                expected_saved_bytes=expected,
                **{flag: True},
            )
        finally:
            try:
                os.unlink(utf8_path)
            except FileNotFoundError:
                pass

    # Pointer hit-testing must translate visual code-point columns back to
    # byte offsets rather than assuming one byte per visible character.
    pointer_fd, pointer_path = tempfile.mkstemp(prefix="nekoedit-utf8-pointer-")
    try:
        with os.fdopen(pointer_fd, "wb") as document:
            document.write(utf8_fixture)
        run(
            sys.argv[1],
            initial_file=pointer_path,
            save_roundtrip=True,
            expected_saved_bytes=b"A\xc3\xa9\xe2\x82\xacB",
            utf8_pointer_test=True,
        )
    finally:
        try:
            os.unlink(pointer_path)
        except FileNotFoundError:
            pass

    # Move the gap between a mixed-width UTF-8 prefix and an ASCII suffix.
    # The final bytes verify both the logical editor view and two-segment save.
    gap_fd, gap_path = tempfile.mkstemp(prefix="nekoedit-gap-")
    try:
        with os.fdopen(gap_fd, "wb") as document:
            document.write(b"A\xc3\xa9BC")
        run(
            sys.argv[1],
            initial_file=gap_path,
            save_roundtrip=True,
            expected_saved_bytes=b"A\xc3\xa9C",
            gap_buffer_test=True,
        )
    finally:
        try:
            os.unlink(gap_path)
        except FileNotFoundError:
            pass

    # An exactly-full mapping forces the first new byte to grow the gap
    # and relocate the suffix while preserving both serialized segments.
    growth_fd, growth_path = tempfile.mkstemp(prefix="nekoedit-growth-")
    try:
        with os.fdopen(growth_fd, "wb") as growth_file:
            growth_file.write(b"a" * 65536)
        run(
            sys.argv[1],
            initial_file=growth_path,
            save_roundtrip=True,
            expected_saved_bytes=b"z" + (b"a" * 65536),
            dynamic_growth_test=True,
        )
    finally:
        try:
            os.unlink(growth_path)
        except FileNotFoundError:
            pass

    # Validate per-line byte spans, wrapped visual-row counts and both
    # Fenwick trees across ordinary edits and newline split/merge operations.
    index_fd, index_path = tempfile.mkstemp(prefix="nekoedit-line-index-")
    index_fixture = b"alpha\n" + (b"x" * 100) + b"\n\tz"
    try:
        with os.fdopen(index_fd, "wb") as index_file:
            index_file.write(index_fixture)
        run(
            sys.argv[1],
            initial_file=index_path,
            save_roundtrip=True,
            expected_saved_bytes=index_fixture,
            line_index_test=True,
        )
    finally:
        try:
            os.unlink(index_path)
        except FileNotFoundError:
            pass

    # Horizontal overflow is available by disabling soft wrapping in Settings.
    horizontal_fd, horizontal_path = tempfile.mkstemp(prefix="nekoedit-horizontal-")
    try:
        with os.fdopen(horizontal_fd, "wb") as horizontal_file:
            horizontal_file.write(b"A" * 200)
        run(
            sys.argv[1],
            initial_file=horizontal_path,
            horizontal_scroll_test=True,
            cursor_shape_supported=False,
        )
    finally:
        try:
            os.unlink(horizontal_path)
        except FileNotFoundError:
            pass

    # Unicode 18.0 extended-grapheme movement, hit-testing and deletion.
    grapheme_fd, grapheme_path = tempfile.mkstemp(prefix="nekoedit-graphemes-")
    grapheme_fixture = (
        "e\u0301"
        "A\u0308\u0323"
        "\U0001F44D\U0001F3FD"
        "\U0001F468\u200D\U0001F469\u200D\U0001F467\u200D\U0001F466"
        "\U0001F1FA\U0001F1F8"
        "\U0001F1E8"
        "\u1100\u1161\u11A8"
        "\u0915\u094D\u0937"
        "\u0600A"
        "A\u0903"
        "\r\n"
        "Z"
    ).encode("utf-8")
    try:
        with os.fdopen(grapheme_fd, "wb") as grapheme_file:
            grapheme_file.write(grapheme_fixture)
        run(
            sys.argv[1],
            initial_file=grapheme_path,
            grapheme_test=True,
        )
    finally:
        try:
            os.unlink(grapheme_path)
        except FileNotFoundError:
            pass

    # SFNT reader: use a deterministic tiny TrueType fixture so CI does not
    # depend on whichever fonts happen to be installed on the runner.
    font_fd, font_path = tempfile.mkstemp(prefix="nekoedit-sfnt-", suffix=".ttf")
    render_fd, render_path = tempfile.mkstemp(prefix="nekoedit-font-visible-", suffix=".txt")
    try:
        with os.fdopen(font_fd, "wb") as font_file:
            font_file.write(synthetic_true_type_font())
        with os.fdopen(render_fd, "wb") as render_file:
            render_file.write(b"AB" + (b"A" * 94))
        run(
            sys.argv[1],
            initial_file=render_path,
            font_parser_test=True,
            font_test_path=font_path,
        )
        # Exercise the TrueType rasterizer's surface-to-buffer pixel mapping.
        run(
            sys.argv[1],
            initial_file=render_path,
            font_parser_test=True,
            font_test_path=font_path,
            initial_preferred_buffer_transform=1,
        )
        # Reuse the same deterministic face to validate UI-sized glyph caching,
        # pixel-accurate field editing, and selected file-row geometry.
        run(
            sys.argv[1],
            initial_file=render_path,
            font_picker_test=True,
            font_test_path=font_path,
            file_workflow=True,
            initial_height=480,
        )
    finally:
        for path in (font_path, render_path):
            try:
                os.unlink(path)
            except FileNotFoundError:
                pass

    # Malformed sequences are treated as one-byte replacement units; editing
    # must not consume adjacent valid ASCII characters.
    invalid_fd, invalid_path = tempfile.mkstemp(prefix="nekoedit-invalid-utf8-")
    try:
        with os.fdopen(invalid_fd, "wb") as document:
            document.write(b"A\xf0(B\x8c(B")
        run(
            sys.argv[1],
            initial_file=invalid_path,
            save_roundtrip=True,
            expected_saved_bytes=b"B",
            utf8_invalid_test=True,
        )
    finally:
        try:
            os.unlink(invalid_path)
        except FileNotFoundError:
            pass

    # Compositors that do not advertise wp_cursor_shape_manager_v1 still get
    # the same edge hit-testing and xdg_toplevel.resize path without hover icons.
    run(sys.argv[1], cursor_shape_supported=False, file_workflow=True)
    # Full File menu, Open, Save, and Save As interaction tests on both
    # supported connection transports. The subprocess CWD is the fixture dir.
    run(sys.argv[1], file_workflow=True)
    run(sys.argv[1], use_wayland_socket=True, file_workflow=True)

    find_fd, find_path = tempfile.mkstemp(prefix="nekoedit-find-replace-")
    try:
        with os.fdopen(find_fd, "wb") as document:
            document.write(b"one fish two fish")
        run(sys.argv[1], initial_file=find_path, find_replace_test=True)
    finally:
        try:
            os.unlink(find_path)
        except FileNotFoundError:
            pass

    line_fd, line_path = tempfile.mkstemp(prefix="nekoedit-line-navigation-")
    try:
        with os.fdopen(line_fd, "wb") as document:
            document.write(b"first\nsecond\nthird")
        run(sys.argv[1], initial_file=line_path, line_navigation_test=True)
    finally:
        try:
            os.unlink(line_path)
        except FileNotFoundError:
            pass

    # Pointer selection must remain active through double-click word drags
    # and auto-scroll beyond all sides of the document viewport.
    drag_fd, drag_path = tempfile.mkstemp(prefix="nekoedit-pointer-drag-")
    drag_contents = (b"x" * 1800) + b"\n" + (b"line\n" * 120)
    try:
        with os.fdopen(drag_fd, "wb") as drag_file:
            drag_file.write(drag_contents)
        run(sys.argv[1], initial_file=drag_path, pointer_drag_test=True)
    finally:
        try:
            os.unlink(drag_path)
        except FileNotFoundError:
            pass

    word_fd, word_path = tempfile.mkstemp(prefix="nekoedit-word-navigation-")
    try:
        with os.fdopen(word_fd, "wb") as document:
            document.write(b"one two three")
        run(sys.argv[1], initial_file=word_path, word_navigation_test=True)
    finally:
        try:
            os.unlink(word_path)
        except FileNotFoundError:
            pass

    # Seat capability hotplug: v4 exercises protocol release, while v2
    # verifies the client abandons proxies without unsupported release opcodes.
    run(sys.argv[1], seat_hotplug_test=True, advertised_seat_version=4)
    run(sys.argv[1], seat_hotplug_test=True, advertised_seat_version=2)
    # Output discovery, per-output scale cache, surface membership, hotplug,
    # and version-gated wl_output.release.
    run(sys.argv[1], output_tracking_test=True)
    run(sys.argv[1], output_tracking_legacy_test=True)
    # Select 2/3 of the largest current logical output and scale the entire UI.
    run(sys.argv[1], window_initial_size_test=True)
    # The preferred scale arrives before the initial wl_buffer is created.
    run(sys.argv[1], initial_preferred_buffer_scale=2)
    # Fractional-scale-v1 pairs its 120ths preference with wp_viewporter.
    # The exact 120ths source raster keeps protocol buffer_scale=1 while the
    # viewport destination remains in logical surface units.
    run(sys.argv[1], fractional_scale_test=True, initial_preferred_fractional_scale=150)
    # The second startup sync must not consume a wl_keyboard.keymap event.
    # Keep this focused on descriptor/event dispatch; the full XKB layout test
    # remains a separate scenario so its shortcut assertions stay independent.
    run(sys.argv[1], fractional_scale_test=True, fractional_sync_keymap_test=True,
        initial_preferred_fractional_scale=150)
    run(sys.argv[1], fractional_scale_test=True, initial_preferred_fractional_scale=180,
        initial_preferred_buffer_transform=1, initial_height=481)
    run(sys.argv[1], fractional_scale_test=True, initial_preferred_fractional_scale=120)
    run(sys.argv[1], fractional_scale_test=True, initial_preferred_fractional_scale=90)
    run(sys.argv[1], fractional_scale_test=True, initial_preferred_fractional_scale=210)
    run(sys.argv[1], fractional_scale_test=True, initial_preferred_fractional_scale=180,
        seat_supported=False)
    # Exercise all seven non-normal preferred transform values before buffer attach.
    for preferred_transform in range(1, 8):
        run(sys.argv[1], initial_preferred_buffer_transform=preferred_transform)
    # Runtime scale and transform changes are release-gated in both directions.
    run(sys.argv[1], dpi_runtime_test=True)
    # Remove the keyboard while an opted-in text-input-v3 IME has visible preedit.
    run(sys.argv[1], seat_hotplug_ime_test=True, advertised_seat_version=4)
