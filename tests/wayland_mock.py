#!/usr/bin/env python3
"""Protocol-level smoke test for the raw Wayland bootstrap (no compositor needed).

Python is used only by this test harness; it is not part of NekoEdit's runtime.
"""
from __future__ import annotations

import mmap
import os
import select
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import time
import traceback


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
    if actual[:3] != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual[:3]!r}")
    return actual


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
    history_test: bool = False,
    horizontal_scroll_test: bool = False,
    word_navigation_test: bool = False,
    font_test_path: str | None = None,
    initial_height: int = 480,
    sparse_keymap_test: bool = False,
    expected_saved_bytes: bytes = b"z",
) -> None:
    # Resolve before file-workflow tests change the child process CWD.
    binary = os.path.abspath(binary)
    runtime_dir = tempfile.mkdtemp(prefix="nekoedit-wayland-")
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
        with open(os.path.join(runtime_dir, "oversized.txt"), "wb") as document:
            document.write(b"x" * 65537)
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
            client.settimeout(45 if file_workflow else 8)

            expect_message(client, (1, 1, struct.pack("<I", 2)), "get_registry")
            expect_message(client, (1, 0, struct.pack("<I", 3)), "initial sync")
            globals_payload = (
                registry_global(1, "wl_compositor")
                + registry_global(2, "wl_shm")
                + registry_global(3, "xdg_wm_base")
                + registry_global(4, "wl_seat", version=advertised_seat_version)
            )
            if cursor_shape_supported:
                globals_payload += registry_global(5, "wp_cursor_shape_manager_v1", version=1)
            if clipboard_test:
                globals_payload += registry_global(6, "wl_data_device_manager", version=1)
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
                    1,
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

            client.sendall(
                wire_message(10, 0, struct.pack("<iiI", 800, initial_height, 0))
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
            if (pool_id, buffer_size) != (11, expected_size):
                raise AssertionError(f"unexpected shm pool args: {(pool_id, buffer_size)!r}")
            shm_fd = pool[3][0]
            pixels = None
            try:
                if os.fstat(shm_fd).st_size != expected_size:
                    raise AssertionError("memfd size does not match requested shared buffer size")
                pixels = mmap.mmap(shm_fd, expected_size, access=mmap.ACCESS_READ)

                def rendered_color_present(
                    x: int, y: int, width: int, height: int, stride: int, color: int
                ) -> bool:
                    return any(
                        struct.unpack_from("<I", pixels, row * stride + column * 4)[0] == color
                        for row in range(y, y + height)
                        for column in range(x, x + width)
                    )

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
                def antialiased_ink_present(x: int, y: int, width: int, height: int) -> bool:
                    for row in range(y, y + height):
                        for column in range(x, x + width):
                            pixel = struct.unpack_from(
                                "<I", pixels, row * 800 * 4 + column * 4
                            )[0]
                            red, green, blue = (
                                (pixel >> 16) & 0xFF,
                                (pixel >> 8) & 0xFF,
                                pixel & 0xFF,
                            )
                            if red >= 128 and green >= 138 and blue >= 148:
                                return True
                    return False

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

                expect_message(
                    client,
                    (11, 0, struct.pack("<6I", 12, 0, 800, initial_height, 3200, 1)),
                    "create wl_buffer",
                )
                expect_message(client, (8, 1, struct.pack("<III", 12, 0, 0)), "attach buffer")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "damage surface")
                expect_message(client, (8, 6, b""), "initial map surface")
                observations.append("memfd+SCM_RIGHTS buffer verified")

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
                client.sendall(wire_message(13, 0, struct.pack("<I", 3)))
                expect_message(
                    client,
                    (13, 0, struct.pack("<I", 15)),
                    "get wl_pointer",
                )
                expect_message(
                    client,
                    (13, 1, struct.pack("<I", 16)),
                    "get wl_keyboard",
                )
                # Send pointer.enter only after get_pointer has created object 15,
                # and before callback 14 ends the client's initial seat roundtrip.
                client.sendall(
                    wire_message(15, 0, struct.pack("<IIii", 777, 8, 100 * 256, 110 * 256))
                    + wire_message(14, 0, struct.pack("<I", 2))
                )
                if cursor_shape_supported:
                    expect_message(
                        client,
                        (
                            2, 0,
                            struct.pack("<II", 5, 27)
                            + b"wp_cursor_shape_manager_v1\0"
                            + b"\0"
                            + struct.pack("<II", 1, 17),
                        ),
                        "bind cursor-shape manager",
                    )
                    expect_message(
                        client, (17, 1, struct.pack("<II", 18, 15)),
                        "get cursor-shape pointer (new device ID 18, wl_pointer ID 15)",
                    )
                    expect_message(
                        client, (18, 1, struct.pack("<II", 777, 1)),
                        "set initial default cursor shape",
                    )
                    observations.append("optional cursor-shape manager bound; startup pointer.enter retained and applied")
                if clipboard_test:
                    manager_name = b"wl_data_device_manager\0"
                    manager_padded = manager_name + (b"\0" * (-len(manager_name) % 4))
                    expect_message(
                        client,
                        (2, 0, struct.pack("<II", 6, len(manager_name)) + manager_padded + struct.pack("<II", 1, 17)),
                        "bind wl_data_device_manager",
                    )
                    expect_message(
                        client, (17, 1, struct.pack("<II", 18, 13)),
                        "get wl_data_device for the application seat",
                    )
                    observations.append("wl_data_device_manager bound; wl_data_device created for seat 13")
                observations.append("seat pointer and keyboard capability/object creation verified")

                # Release the initial buffer before sending a click. The client
                # must not rewrite the shared memory while the compositor owns it.
                client.sendall(
                    wire_message(12, 0)
                    + wire_message(
                        15, 2,
                        struct.pack(
                            "<Iii", 777,
                            (50 if utf8_pointer_test else (34 if gap_buffer_test else (18 if (utf8_edit_test or utf8_delete_test or utf8_invalid_test or dynamic_growth_test or grapheme_test) else (27 if font_parser_test else 98)))) * 256,
                            (98 if (utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test or gap_buffer_test or dynamic_growth_test or grapheme_test or font_parser_test) else 110) * 256,
                        ),
                    )
                    + wire_message(15, 3, struct.pack("<IIII", 778, 1000, 0x110, 1))
                )
                expect_message(client, (8, 1, struct.pack("<III", 12, 0, 0)), "redraw attach")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), "redraw damage")
                expect_message(client, (8, 6, b""), "redraw commit")
                if not (
                    sparse_keymap_test or punctuation_render_test or line_index_test or grapheme_test
                    or utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test
                    or gap_buffer_test or dynamic_growth_test or font_parser_test or font_picker_test
                    or clipboard_test or history_test or horizontal_scroll_test or word_navigation_test
                ):
                    if initial_file is None or os.path.getsize(initial_file) <= 1:
                        clicked_caret_column = os.path.getsize(initial_file) if initial_file else 0
                        clicked_caret_x = 16 + clicked_caret_column * 8
                        caret_visible = (
                            struct.unpack_from(
                                "<I", pixels, 92 * 800 * 4 + clicked_caret_x * 4
                            )[0] == 0xFFFFFFFF
                        )
                    else:
                        # For a longer launch-time document, verify that pointer
                        # hit testing leaves a visible caret near the clicked cell.
                        # This deliberately tolerates either side of a cell
                        # midpoint while keeping the original short-file assertion
                        # exact.
                        caret_visible = any(
                            all(
                                struct.unpack_from(
                                    "<I", pixels, (92 + row) * 800 * 4 + x * 4
                                )[0] == 0xFFFFFFFF
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
                    wire_message(15, 3, struct.pack("<IIII", 779, 1001, 0x110, 0))
                    + wire_message(12, 0)
                )  # release the initial document click and its buffer
                if keyboard_layout_test:
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
};
xkb_types "nekoedit-test" {
    type "ALPHABETIC" {
        modifiers = Shift+Lock;
        map[Shift] = Level2;
        map[Lock] = Level2;
    };
    type "FOUR_LEVEL" {
        modifiers = Shift+LevelThree;
        map[Shift] = Level2;
        map[LevelThree] = Level3;
        map[Shift+LevelThree] = Level4;
    };
};
xkb_symbols "nekoedit-test" {
    key <AD01> {
        type = "FOUR_LEVEL_ALPHABETIC",
        symbols[Group1] = [ a, A, at, quotedbl ],
        symbols[Group2] = [ q, Q ]
    };
    key <AC02> {
        type = "ALPHABETIC",
        symbols[Group1] = [ s, S ]
    };
    key <AD02> { [ w, W ] };
    key <AD03> { [ e, E ] };
    key <AD04> { [ r, R ] };
    key <AD05> { [ t, T ] };
    key <AD06> { [ y, Y ] };
    key <AD07> { [ u, U ] };
    key <AD08> { [ i, I ] };
    key <AD09> { [ o, O ] };
    key <AD10> { [ p, P ] };
    key <AC01> { [ a, A ] };
    key <AC03> { [ d, D ] };
    key <AC04> { [ f, F ] };
    key <AC05> { [ g, G ] };
    key <AC06> { [ h, H ] };
    key <AC07> { [ j, J ] };
    key <AC08> { [ k, K ] };
    key <AC09> { [ l, L ] };
    key <AB01> { [ z, Z ] };
    key <AB02> { [ x, X ] };
    key <AB03> { [ c, C ] };
    key <AB04> { [ v, V ] };
    key <AB05> { [ b, B ] };
    key <AB06> { [ n, N ] };
    key <AB07> { [ m, M ] };
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
    key <AD12> { [ bracketright, braceright ] };
    key <AC10> { [ semicolon, colon ] };
    key <AC11> { [ apostrophe, quotedbl ] };
    key <AB08> { [ comma, less ] };
    key <AB09> { [ period, greater ] };
    key <AB10> { [ slash, question ] };
    key <KPDL> {
        type = "ONE_LEVEL",
        symbols[Group1] = [ comma ]
    };
    key <AB09> { [ period, greater ] };
};
};
\0"""
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
                keymap_fd = os.memfd_create("nekoedit-test-keymap", 0)
                try:
                    os.write(keymap_fd, keymap_data)
                    keymap_event = wire_message(16, 0, struct.pack("<II", 1, len(keymap_data)))
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
                        "xkb_ascii_levels",
                        "xkb_key_types",
                        "xkb_keymap_ready",
                        "keymap_processing_complete",
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
                        ready = struct.unpack("<I", child_memory("xkb_keymap_ready", 0, 4))[0]
                        key_name = child_memory("xkb_key_names", 24 * 4, 4)
                        key_type = child_memory("xkb_key_types", 24, 1)
                        levels = child_memory("xkb_ascii_levels", 24 * 16, 16)
                        ae01_name = child_memory("xkb_key_names", 10 * 4, 4)
                        ae01_levels = child_memory("xkb_ascii_levels", 10 * 16, 16)
                        ae02_name = child_memory("xkb_key_names", 11 * 4, 4)
                        ae02_levels = child_memory("xkb_ascii_levels", 11 * 16, 16)
                    finally:
                        os.close(mem_fd)
                    if ready != 1 or key_name != b"AD01" or key_type != bytes([3]):
                        raise AssertionError(
                            "XKB parser did not build the expected AD01 metadata: "
                            f"ready={ready}, key_name={key_name!r}, key_type={key_type!r}"
                        )
                    if levels[:6] != b'aA@"qQ':
                        raise AssertionError(
                            "XKB parser produced incorrect Group1/Group2 levels: "
                            f"{levels!r}"
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
                    keyboard_events += wire_message(16, 5, struct.pack("<ii", 10, 180))
                keyboard_events += wire_message(16, 1, struct.pack("<III", 1001, 8, 0))
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

                def key_step(
                    serial: int, code: int, label: str, auto_confirm: bool = True
                ) -> None:
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", serial, serial, code, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    client.sendall(
                        wire_message(
                            16, 3, struct.pack("<IIII", serial + 1, serial + 1, code, 0)
                        )
                        + wire_message(12, 0)
                    )
                    if auto_confirm and child_u32("save_confirm_open") == 1:
                        key_step(
                            serial + 2, 28, label + " — confirm pending save",
                            auto_confirm=False,
                        )

                def workflow_redraw(label: str) -> None:
                    attach = (8, 1, struct.pack("<III", 12, 0, 0))
                    while True:
                        actual = recv_wayland_message(client)
                        # Pointer motion can change the optional cursor shape
                        # immediately before the surface redraw. Consume that
                        # protocol request without mistaking it for an attach.
                        if (
                            actual[0] == child_u32("cursor_shape_device")
                            and actual[1] == 1
                            and len(actual[2]) == 8
                            and not actual[3]
                        ):
                            continue
                        if actual[:3] != attach:
                            raise AssertionError(
                                f"{label} attach: expected {attach!r}, got {actual[:3]!r}"
                            )
                        break
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")

                def workflow_click(x: int, y: int, serial: int, label: str) -> None:
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                        + wire_message(
                            15, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    workflow_redraw(label)
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                        )
                        + wire_message(12, 0)
                    )
                    if child_u32("save_confirm_open") == 1:
                        key_step(serial + 5, 28, label + " — confirm pending save")

                def workflow_axis(axis: int, value: int, serial: int, label: str) -> None:
                    client.sendall(
                        wire_message(15, 4, struct.pack("<IIi", serial, axis, value))
                    )
                    workflow_redraw(label)
                    client.sendall(wire_message(12, 0))

                if horizontal_scroll_test:
                    state = read_document_state()
                    if state["doc_wrap_enabled"] != 1 or state["doc_line_index_records"][0][1] <= 1:
                        raise AssertionError(
                            f"long-line fixture should start with soft wrapping enabled: {state!r}"
                        )
                    workflow_click(200, 20, 3100, "open Settings for wrap toggle")
                    if read_document_state()["settings_menu_open"] != 1:
                        raise AssertionError("Settings did not open for the wrap-lines test")
                    workflow_click(200, 124, 3110, "disable Wrap Lines")
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
                    workflow_click(40, 98, 3140, "pointer hit-testing with horizontal offset")
                    state = read_document_state()
                    if not (50 <= state["doc_cursor"] <= 150):
                        raise AssertionError(
                            f"pointer hit-testing ignored the horizontal viewport offset: {state!r}"
                        )
                    workflow_click(200, 20, 3145, "reopen Settings after horizontal hit-testing")
                    if read_document_state()["settings_menu_open"] != 1:
                        raise AssertionError("Settings did not reopen after document hit-testing")
                    workflow_click(200, 124, 3150, "re-enable Wrap Lines")
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
                    key_step(3160, 1, "close Settings after wrap test")
                    observations.append(
                        "Wrap Lines toggle, unwrapped line indexing, caret-following scroll, horizontal wheel and offset pointer hit-testing verified"
                    )
                    client.sendall(wire_message(10, 1))
                    return

                cursor_feedback_state = {"shape": 1, "enter_serial": 777}
                resize_buffer_base = 17 + (2 if cursor_shape_supported else 0)

                def workflow_window_click(
                    x: int, serial: int, request_opcode: int, label: str,
                    y: int = 20, request_payload: bytes = b"",
                    cursor_shape: int = 1,
                ) -> None:
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                    )
                    if cursor_shape_supported and cursor_shape != cursor_feedback_state["shape"]:
                        expect_message(
                            client, (18, 1, struct.pack("<II", cursor_feedback_state["enter_serial"], cursor_shape)),
                            f"{label}: resize cursor shape",
                        )
                        cursor_feedback_state["shape"] = cursor_shape
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (10, request_opcode, request_payload),
                        f"{label}: xdg_toplevel request"
                    )
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                        )
                    )
                    # A real xdg_toplevel.resize may remove pointer focus and later
                    # re-enter the resized surface with a fresh enter serial.
                    if request_opcode in (5, 6):
                        enter_serial = serial + 6
                        client.sendall(
                            wire_message(15, 1, struct.pack("<II", serial + 5, 8))
                            + wire_message(
                                15, 0,
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
                        wire_message(15, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256))
                        + wire_message(15, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1))
                    )
                    workflow_redraw(f"{label}: press")
                    client.sendall(wire_message(12, 0))
                    press_state = picker_state()
                    if press_state.get("picker_scroll_drag") != 1:
                        raise AssertionError(
                            f"{label}: scrollbar press did not start a drag; state={press_state!r}"
                        )
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256))
                    )
                    try:
                        workflow_redraw(f"{label}: drag")
                    except Exception as error:
                        raise AssertionError(
                            f"{label}: pointer motion did not redraw; state={picker_state()!r}"
                        ) from error
                    # Release the frame drawn after motion before requesting the
                    # second redraw caused by releasing the scrollbar grab.
                    client.sendall(wire_message(12, 0))
                    client.sendall(
                        wire_message(15, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0))
                    )
                    workflow_redraw(f"{label}: release")
                    client.sendall(wire_message(12, 0))

                def workflow_editor_scrollbar_drag(
                    start_x: int, start_y: int, end_x: int, end_y: int,
                    serial: int, label: str
                ) -> None:
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256))
                        + wire_message(15, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1))
                    )
                    workflow_redraw(f"{label}: press")
                    client.sendall(wire_message(12, 0))
                    press_state = picker_state()
                    if press_state.get("doc_scroll_drag") != 1:
                        raise AssertionError(
                            f"{label}: editor scrollbar press did not start a drag; state={press_state!r}"
                        )
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256))
                    )
                    try:
                        workflow_redraw(f"{label}: drag")
                    except Exception as error:
                        raise AssertionError(
                            f"{label}: editor scrollbar motion did not redraw; state={picker_state()!r}"
                        ) from error
                    client.sendall(wire_message(12, 0))
                    client.sendall(
                        wire_message(15, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0))
                    )
                    workflow_redraw(f"{label}: release")
                    client.sendall(wire_message(12, 0))

                def workflow_shortcut(serial: int, code: int, label: str, shift: bool = False) -> None:
                    events = wire_message(16, 3, struct.pack("<IIII", serial, serial, 29, 1))
                    if shift:
                        events += wire_message(
                            16, 3, struct.pack("<IIII", serial + 1, serial + 1, 42, 1)
                        )
                    events += wire_message(
                        16, 3,
                        struct.pack("<IIII", serial + (2 if shift else 1),
                                    serial + (2 if shift else 1), code, 1)
                    )
                    client.sendall(events)
                    workflow_redraw(label)
                    releases = wire_message(
                        16, 3,
                        struct.pack("<IIII", serial + 3, serial + 3, code, 0)
                    )
                    if shift:
                        releases += wire_message(
                            16, 3, struct.pack("<IIII", serial + 4, serial + 4, 42, 0)
                        )
                    releases += wire_message(
                        16, 3,
                        struct.pack("<IIII", serial + 5, serial + 5, 29, 0)
                    )
                    client.sendall(releases + wire_message(12, 0))
                    if child_u32("save_confirm_open") == 1:
                        key_step(serial + 6, 28, label + " — confirm pending save")

                if word_navigation_test:
                    initial = read_document_state()
                    if initial["doc_contents"] != b"one two three":
                        raise AssertionError("word navigation fixture contents mismatch")
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
                    observations.append(
                        "Ctrl+Left/Right word navigation, Ctrl+Shift+Left selection, Ctrl+Home/End, and double-click word selection verified"
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
                        wire_message(16, 3, struct.pack("<IIII", 2060, 2060, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 2061, 2061, 21, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 2062, 2062, 21, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 2063, 2063, 29, 0))
                    )
                    ready, _, _ = select.select([client], [], [], 0.05)
                    if ready:
                        unexpected = recv_wayland_message(client)
                        raise AssertionError("redo remained available after a new edit: " + repr(unexpected[:3]))
                    client.sendall(wire_message(12, 0))
                    if read_document_state()["doc_contents"] != b"abcq":
                        raise AssertionError("stale redo changed document contents after a new edit")
                    # Ctrl+Shift+Z is also a conventional redo binding.
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
                        return wire_message(
                            16, 3, struct.pack("<IIII", serial, serial, code, int(down))
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
                            client.sendall(wire_message(12, 0))

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

                    # Select all, then test Ctrl+C through the actual Wayland
                    # data-source protocol and an SCM_RIGHTS transfer pipe.
                    workflow_shortcut(1900, 30, "Ctrl+A before clipboard copy")
                    clipboard_combo(1910, 46, "Ctrl+C", redraw=False)
                    expect_source_creation(19, 1911, "Ctrl+C")
                    receive_source_bytes(19, "Ctrl+C")
                    observations.append("Ctrl+C exported an immutable selected-text snapshot through wl_data_source.send")

                    # Ctrl+X must publish its own snapshot before deleting the
                    # selection, and that snapshot must survive the deletion.
                    client.sendall(ctrl_event(1930, 29, True) + ctrl_event(1931, 45, True))
                    expect_source_creation(20, 1931, "Ctrl+X")
                    workflow_redraw("Ctrl+X removes the selected document bytes")
                    client.sendall(
                        ctrl_event(1933, 45, False) + ctrl_event(1934, 29, False)
                        + wire_message(12, 0)
                    )
                    cut_state = read_document_state()
                    if cut_state["doc_contents"] != b"":
                        raise AssertionError(
                            "Ctrl+X did not delete the active selection: "
                            + repr(cut_state["doc_contents"])
                        )
                    receive_source_bytes(20, "Ctrl+X after document deletion")
                    observations.append("Ctrl+X deleted the selection only after publishing an independent snapshot")

                    # Replacing the selection retires both old source objects;
                    # the client must destroy them rather than retaining them.
                    client.sendall(wire_message(19, 2) + wire_message(20, 2))
                    expect_message(client, (19, 1, b""), "destroy retired Ctrl+C source")
                    expect_message(client, (20, 1, b""), "destroy retired Ctrl+X source")

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
                    client.sendall(wire_message(12, 0))
                    paste_state = read_document_state()
                    if paste_state["doc_contents"] != pasted:
                        raise AssertionError(
                            "Ctrl+V did not insert external clipboard bytes at the document caret: "
                            + repr(paste_state["doc_contents"])
                        )
                    observations.append("Ctrl+V received an external Wayland MIME offer asynchronously and inserted its text")
                    client.sendall(wire_message(10, 1))
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
                    punctuation_chars = "!\"#$%&'()*+,-./:;<=>?@[\\]^_" + chr(96) + "{|}~"
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

                if keyboard_layout_test:
                    # XKB keycode 24 is evdev 16. Group 1 maps it to 'a',
                    # Shift maps it to 'A', and Group 2 remaps it to 'q'.
                    key_step(1000, 16, "XKB group-one base symbol")
                    client.sendall(
                        wire_message(16, 4, struct.pack("<IIIII", 1001, 1, 0, 0, 0))
                    )
                    key_step(1002, 16, "XKB alphabetic Shift level")
                    client.sendall(
                        wire_message(16, 4, struct.pack("<IIIII", 1003, 0, 0, 0, 1))
                    )
                    key_step(1004, 16, "XKB second layout group")
                    # Right Alt is the common physical LevelThree selector.
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1005, 1005, 100, 1))
                    )
                    key_step(1006, 16, "XKB FOUR_LEVEL_ALPHABETIC LevelThree symbol")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1007, 1007, 100, 0))
                        + wire_message(12, 0)
                    )
                    # Verify every remaining ASCII letter using its evdev
                    # position and the parsed XKB keycode/symbol entries.
                    client.sendall(
                        wire_message(16, 4, struct.pack("<IIIII", 1010, 0, 0, 0, 0))
                    )
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
                    # The normal xkbcomp output uses shorthand arrays for
                    # number-row keys. Depress Shift and verify all twelve
                    # shifted digit-row/punctuation symbols.
                    client.sendall(
                        wire_message(16, 4, struct.pack("<IIIII", 1100, 1, 0, 0, 0))
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
                    client.sendall(
                        wire_message(16, 4, struct.pack("<IIIII", 1180, 0, 0, 0, 0))
                    )
                    workflow_shortcut(1200, 31, "Ctrl+S saves XKB-translated text")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "XKB keycode +8 lookup, Group1/Group2, Shift/LevelThree, all twelve shifted number-row symbols, shifted punctuation rows, and ONE_LEVEL Shift handling verified"
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
                        "settings_panel_x", "settings_panel_y", "settings_panel_width", "settings_panel_height",
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
                        surface_y = panel_y + (design_y - 32) * panel_height // 168
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
                        wire_message(16, 3, struct.pack("<IIII", 2628, 2628, 42, 1))
                        + wire_message(16, 4, struct.pack("<IIIII", 2629, 1, 0, 0, 0))
                    )
                    key_step(2630, 30, "type uppercase A in font picker field")
                    key_step(2632, 48, "type uppercase B in font picker field")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 2634, 2634, 42, 0))
                        + wire_message(16, 4, struct.pack("<IIIII", 2635, 0, 0, 0, 0))
                        + wire_message(12, 0)
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
                        workflow_click(400, 76, serial, f"increase document font size {index + 1} without closing Settings")
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
                        workflow_click(360, 76, serial, f"decrease document font size {index + 1} without closing Settings")
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
                    if picker_u32("settings_panel_width") <= 256 or picker_u32("settings_panel_height") <= 168:
                        raise AssertionError("Settings panel did not grow with the selected UI font")
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
                    workflow_click(200, 148, serial, "open the font-file picker")
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
                    workflow_click(200, 148, serial, "reopen font-file picker")
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
                        if len(fields) == 3 and fields[2] in {"picker_mode", "picker_focus", "picker_dir_fd", "picker_error", "picker_entry_count", "picker_selected", "picker_scroll", "picker_scroll_drag", "picker_scroll_thumb_top", "picker_scroll_thumb_height", "pointer_x", "pointer_y", "pointer_inside", "picker_path_length", "picker_path_cursor", "picker_path_buffer", "picker_current_path", "picker_name_length", "picker_name_cursor", "picker_name_match", "picker_suggestion_count", "picker_suggestion_selected", "picker_suggestion_indices", "picker_edit_select_all", "picker_name_buffer", "picker_last_click_index", "window_width", "window_height", "window_stride", "window_buffer_id", "window_is_maximized", "window_status_top", "window_status_bytes_x", "window_status_mode_x", "window_doc_pixel_width", "window_doc_visible_rows", "doc_capacity", "doc_gap_start", "doc_gap_end", "doc_storage_error", "doc_view_top_row", "doc_scroll_drag", "doc_scroll_drag_offset", "doc_scroll_thumb_top", "doc_scroll_thumb_height", "doc_total_visual_rows", "doc_wheel_remainder", "picker_panel_x", "picker_panel_y", "picker_panel_width", "picker_panel_height", "path_prompt_x", "path_prompt_y", "path_prompt_width", "path_prompt_height", "picker_last_click_time", "doc_length", "doc_cursor", "doc_buffer", "current_file_path", "current_path_buffer", "picker_target_buffer", "doc_save_error", "doc_line_index_base", "doc_line_index_bytes", "doc_line_index_capacity", "doc_line_count", "doc_line_index_valid", "doc_line_index_columns"}:
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
                        initial_editor_state.get("doc_scroll_thumb_height") != 0
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
                    observations.append("Save As overwrite confirmation and cancellation verified")

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

                    # Open a file above the former 64 KiB limit through the native
                    # picker, then save it again to verify the entire staged buffer.
                    large_open_start = serial + 12
                    workflow_shortcut(large_open_start, 24, "Ctrl+O before large-file Open")
                    large_open_serial = workflow_type_path("oversized.txt", large_open_start + 10)
                    key_step(large_open_serial, 28, "Open file larger than 64 KiB")
                    large_open_state = picker_state()
                    large_expected = b"x" * 65537
                    large_path = os.path.join(runtime_dir, "oversized.txt").encode()
                    if (
                        large_open_state.get("active_path") != large_path
                        or large_open_state.get("doc_length") != len(large_expected)
                        or large_open_state.get("doc_contents") != large_expected
                        or large_open_state.get("doc_capacity", 0) < len(large_expected)
                    ):
                        raise AssertionError(
                            f"large file Open did not commit the complete staged document: {large_open_state!r}"
                        )
                    workflow_shortcut(
                        large_open_serial + 4, 31, "Ctrl+S saves dynamically loaded file"
                    )
                    with open(os.path.join(runtime_dir, "oversized.txt"), "rb") as saved:
                        if saved.read() != large_expected:
                            raise AssertionError("Ctrl+S did not serialize the complete dynamic document")
                    observations.append(
                        "native picker Open and Ctrl+S save verified for a 65,537-byte document"
                    )
                    serial = large_open_serial + 42

                    # The 65,537-byte single-line fixture wraps into hundreds of
                    # visual rows. Verify editor scrolling is independent of the
                    # directory picker's separate scroll model.
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
                    if editor_scroll_state.get("doc_scroll_thumb_top", 92) <= 92:
                        raise AssertionError(
                            f"editor wheel did not move the thumb downward: {editor_scroll_state!r}"
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
                    # Mutter may emit multiple toplevel configures before the
                    # surface configure; the final width/height/state apply.
                    client.sendall(
                        wire_message(12, 0)
                        + wire_message(10, 0, struct.pack("<iiIII", 1024, 768, 8, 1, 4))
                        + wire_message(10, 0, struct.pack("<iiIII", 1920, 1080, 8, 1, 4))
                        + wire_message(9, 0, struct.pack("<I", 1235))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1235)), "ack maximized configure"
                    )
                    expect_message(client, (12, 0, b""), "destroy released pre-maximize buffer")
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", resize_buffer_base, 0, 1920, 1080, 7680, 1)),
                        "create maximized buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", resize_buffer_base, 0, 0)),
                        "attach maximized buffer",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 1920, 1080)),
                        "damage maximized surface",
                    )
                    expect_message(client, (8, 6, b""), "commit maximized surface")
                    max_state = picker_state()
                    if (
                        max_state.get("window_width") != 1920
                        or max_state.get("window_height") != 1080
                        or max_state.get("window_stride") != 7680
                        or max_state.get("window_buffer_id") != resize_buffer_base
                        or max_state.get("window_is_maximized") != 1
                        or max_state.get("window_status_top") != 1060
                        or max_state.get("window_status_bytes_x") != 1180
                        or max_state.get("window_status_mode_x") != 1864
                        or max_state.get("window_doc_pixel_width") != 1880
                        or max_state.get("window_doc_visible_rows") != 80
                        or max_state.get("picker_panel_x") != 588
                        or max_state.get("picker_panel_y") != 328
                        or max_state.get("picker_panel_width") != 744
                        or max_state.get("picker_panel_height") != 424
                        or max_state.get("path_prompt_x") != 608
                        or max_state.get("path_prompt_y") != 448
                        or max_state.get("path_prompt_width") != 704
                        or max_state.get("path_prompt_height") != 176
                    ):
                        raise AssertionError(f"maximized configure was not applied: {max_state!r}")
                    max_close_pixel = struct.unpack_from("<I", pixels, 4 * 7680 + 1880 * 4)[0]
                    if max_close_pixel != 0xFF754B52:
                        raise AssertionError(
                            f"window controls did not follow the maximized width: {hex(max_close_pixel)}"
                        )
                    if not rendered_color_present(1180, 1066, 48, 7, 7680, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not follow the maximized width")
                    if not rendered_color_present(1864, 1066, 40, 7, 7680, 0xFFD8DEE9):
                        raise AssertionError("the mode footer label did not follow the maximized width")
                    observations.append(
                        "Maximize acknowledges compositor configure and reallocates/repaints the surface at its new dimensions"
                    )

                    # Restore: deliver the configure while buffer {resize_buffer_base} is still
                    # compositor-owned. The client must ack but defer replacement.
                    workflow_window_click(1860, serial + 30, 10, "restore")
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiII", 800, 480, 4, 4))
                        + wire_message(9, 0, struct.pack("<I", 1236))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1236)), "ack restored configure"
                    )
                    client.sendall(wire_message(resize_buffer_base, 0))
                    expect_message(client, (resize_buffer_base, 0, b""), "destroy released maximized buffer")
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", resize_buffer_base + 1, 0, 800, 480, 3200, 1)),
                        "create restored buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", resize_buffer_base + 1, 0, 0)),
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
                        or restored_state.get("window_buffer_id") != resize_buffer_base + 1
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
                        wire_message(15, 2, struct.pack("<Iii", serial + 60, 10 * 256, 240 * 256))
                    )
                    if cursor_shape_supported and cursor_feedback_state["shape"] != 26:
                        expect_message(
                            client, (18, 1, struct.pack("<II", cursor_feedback_state["enter_serial"], 26)),
                            "left-edge resize cursor",
                        )
                        cursor_feedback_state["shape"] = 26
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 61, serial + 62, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (10, 6, struct.pack("<III", 13, serial + 61, 4)),
                        "left-edge interactive resize request",
                    )
                    client.sendall(
                        wire_message(15, 3, struct.pack("<IIII", serial + 63, serial + 64, 0x110, 0))
                        + wire_message(15, 1, struct.pack("<II", serial + 65, 8))
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
                    client.sendall(wire_message(resize_buffer_base + 1, 0))
                    expect_message(client, (resize_buffer_base + 1, 0, b""), "destroy old buffer after edge resize")
                    expect_message(
                        client, (11, 0, struct.pack("<6I", resize_buffer_base + 2, 0, 720, 480, 2880, 1)),
                        "create edge-resized buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", resize_buffer_base + 2, 0, 0)), "attach edge-resized buffer"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 720, 480)), "damage edge-resized surface"
                    )
                    expect_message(client, (8, 6, b""), "commit edge-resized surface")
                    client.sendall(
                        wire_message(
                            15, 0,
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
                        edge_state.get("window_width") != 720
                        or edge_state.get("window_height") != 480
                        or edge_state.get("window_stride") != 2880
                        or edge_state.get("window_buffer_id") != resize_buffer_base + 2
                        or edge_state.get("window_is_maximized") != 0
                        or edge_state.get("window_status_top") != 460
                        or edge_state.get("window_status_bytes_x") != 430
                        or edge_state.get("window_status_mode_x") != 664
                        or edge_state.get("window_doc_pixel_width") != 680
                        or edge_state.get("window_doc_visible_rows") != 30
                        or edge_state.get("picker_panel_x") != 16
                        or edge_state.get("picker_panel_y") != 28
                        or edge_state.get("picker_panel_width") != 688
                        or edge_state.get("picker_panel_height") != 424
                        or edge_state.get("path_prompt_x") != 16
                        or edge_state.get("path_prompt_y") != 148
                        or edge_state.get("path_prompt_width") != 688
                        or edge_state.get("path_prompt_height") != 176
                    ):
                        raise AssertionError(f"interactive resize configure was not applied: {edge_state!r}")
                    client.sendall(wire_message(resize_buffer_base + 2, 0))
                    if not rendered_color_present(430, 466, 48, 7, 2880, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not follow the 720px resized width")
                    if not rendered_color_present(664, 466, 40, 7, 2880, 0xFFD8DEE9):
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
                            wire_message(15, 2, struct.pack("<Iii", click_serial, x * 256, y * 256))
                            + wire_message(
                                15, 3, struct.pack("<IIII", click_serial + 1, click_serial + 2, 0x110, 1)
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
                            wire_message(
                                15, 3, struct.pack("<IIII", click_serial + 3, click_serial + 4, 0x110, 0)
                            )
                            + wire_message(buffer_id, 0)
                        )

                    # Re-enter at a neutral title-bar location so cursor feedback
                    # has a fresh, valid enter serial before opening the picker.
                    resized_enter = serial + 150
                    client.sendall(
                        wire_message(15, 1, struct.pack("<II", resized_enter - 1, 8))
                        + wire_message(
                            15, 0,
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
                        120, 12, serial + 160, "open File menu at 720px", resize_buffer_base + 2, 720, 480
                    )
                    resized_ui_click(
                        120, 48, serial + 170, "open picker at 720px", resize_buffer_base + 2, 720, 480
                    )
                    picker_720 = picker_state()
                    if (
                        picker_720.get("picker_mode") != 1
                        or picker_720.get("picker_panel_x") != 16
                        or picker_720.get("picker_panel_y") != 28
                        or picker_720.get("picker_panel_width") != 688
                        or picker_720.get("picker_panel_height") != 424
                    ):
                        raise AssertionError(f"picker did not fit the 720x480 window: {picker_720!r}")
                    cancel_x_720 = 16 + ((636 - 40) * 688 // 720)
                    cancel_y_720 = 28 + ((412 - 36) * 424 // 408)
                    cancel_pixel_x_720 = 16 + ((605 - 40) * 688 // 720)
                    cancel_pixel_y_720 = 28 + ((400 - 36) * 424 // 408)
                    if struct.unpack_from("<I", pixels, cancel_pixel_y_720 * 2880 + cancel_pixel_x_720 * 4)[0] != 0xFF414B5A:
                        raise AssertionError("resized picker Cancel button background was not drawn at its fitted location")
                    resized_ui_click(
                        cancel_x_720, cancel_y_720, serial + 180,
                        "cancel fitted picker at 720px", resize_buffer_base + 2, 720, 480,
                    )
                    if picker_state().get("picker_mode") != 0:
                        raise AssertionError("the fitted 720px picker Cancel hit target did not close the picker")
                    observations.append(
                        "centered picker scales to a resized 720px-wide surface and its Cancel hit target matches the drawn button"
                    )

                    # Exercise the smallest compositor geometry NekoEdit advertises.
                    # The picker and path prompt must both fit within its 16px margins.
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiIII", 480, 360, 8, 3, 4))
                        + wire_message(9, 0, struct.pack("<I", 1238))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1238)), "ack minimum-size configure"
                    )
                    expect_message(
                        client, (resize_buffer_base + 2, 0, b""), "destroy released 720px buffer"
                    )
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", resize_buffer_base + 3, 0, 480, 360, 1920, 1)),
                        "create minimum-size buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", resize_buffer_base + 3, 0, 0)),
                        "attach minimum-size buffer",
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 480, 360)),
                        "damage minimum-size surface",
                    )
                    expect_message(client, (8, 6, b""), "commit minimum-size surface")
                    small_state = picker_state()
                    if (
                        small_state.get("window_width") != 480
                        or small_state.get("window_height") != 360
                        or small_state.get("window_status_top") != 340
                        or small_state.get("window_status_bytes_x") != 280
                        or small_state.get("window_status_mode_x") != 424
                        or small_state.get("window_doc_pixel_width") != 440
                        or small_state.get("window_doc_visible_rows") != 20
                        or small_state.get("picker_panel_x") != 16
                        or small_state.get("picker_panel_y") != 16
                        or small_state.get("picker_panel_width") != 448
                        or small_state.get("picker_panel_height") != 328
                        or small_state.get("path_prompt_x") != 16
                        or small_state.get("path_prompt_y") != 88
                        or small_state.get("path_prompt_width") != 448
                        or small_state.get("path_prompt_height") != 176
                        or small_state.get("window_buffer_id") != resize_buffer_base + 3
                    ):
                        raise AssertionError(f"minimum-size layout geometry is inconsistent: {small_state!r}")
                    if not rendered_color_present(280, 346, 48, 7, 1920, 0xFFD8DEE9):
                        raise AssertionError("the byte-count footer label did not fit the minimum width")
                    if not rendered_color_present(424, 346, 40, 7, 1920, 0xFFD8DEE9):
                        raise AssertionError("the mode footer label did not fit the minimum width")
                    client.sendall(wire_message(resize_buffer_base + 3, 0))

                    small_enter = serial + 190
                    client.sendall(
                        wire_message(15, 1, struct.pack("<II", small_enter - 1, 8))
                        + wire_message(
                            15, 0,
                            struct.pack("<IIii", small_enter, 8, 120 * 256, 12 * 256),
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
                        120, 12, serial + 200, "open File menu at minimum size", resize_buffer_base + 3, 480, 360
                    )
                    resized_ui_click(
                        120, 48, serial + 210, "open picker at minimum size", resize_buffer_base + 3, 480, 360
                    )
                    picker_small = picker_state()
                    if picker_small.get("picker_mode") != 1:
                        raise AssertionError(f"picker did not open at minimum size: {picker_small!r}")
                    cancel_x_small = 16 + ((636 - 40) * 448 // 720)
                    cancel_y_small = 16 + ((412 - 36) * 328 // 408)
                    cancel_pixel_x_small = 16 + ((605 - 40) * 448 // 720)
                    cancel_pixel_y_small = 16 + ((400 - 36) * 328 // 408)
                    if struct.unpack_from("<I", pixels, cancel_pixel_y_small * 1920 + cancel_pixel_x_small * 4)[0] != 0xFF414B5A:
                        raise AssertionError("minimum-size picker Cancel background was not drawn at its fitted location")
                    resized_ui_click(
                        cancel_x_small, cancel_y_small, serial + 220,
                        "cancel fitted picker at minimum size", resize_buffer_base + 3, 480, 360,
                    )
                    if picker_state().get("picker_mode") != 0:
                        raise AssertionError("the minimum-size picker Cancel hit target did not close the picker")
                    observations.append(
                        "picker, path-prompt geometry, footer, and mouse hit targets remain fitted at the 480x360 minimum size"
                    )

                    # The app's own Close control exits cleanly; no terminal
                    # shutdown or synthetic xdg_toplevel.close is required.
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial + 230, 452 * 256, 16 * 256))
                    )
                    if cursor_shape_supported and cursor_feedback_state["shape"] != 1:
                        expect_message(
                            client,
                            (18, 1, struct.pack("<II", cursor_feedback_state["enter_serial"], 1)),
                            "restore default cursor before titlebar Close",
                        )
                        cursor_feedback_state["shape"] = 1
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 121, serial + 122, 0x110, 1)
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
                        wire_message(16, 3, struct.pack("<IIII", 1800, 1800, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1801, 1801, 30, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), "Ctrl+A attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "Ctrl+A damage"
                    )
                    expect_message(client, (8, 6, b""), "Ctrl+A commit")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1802, 1802, 30, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1803, 1803, 29, 0))
                        + wire_message(12, 0)
                    )
                    # Settings is a real upper-menu item. Verify the default-on
                    # save warning can be disabled and re-enabled in this session.
                    if child_u32("save_confirm_enabled") != 1:
                        raise AssertionError("save confirmation must default to enabled")
                    workflow_click(190, 20, 1750, "open Settings menu")
                    if child_u32("settings_menu_open") != 1:
                        raise AssertionError("Settings dropdown did not open")
                    workflow_click(248, 56, 1754, "disable confirm-before-save")
                    if (
                        child_u32("save_confirm_enabled") != 0
                        or child_u32("settings_menu_open") != 0
                    ):
                        raise AssertionError("Settings toggle did not disable save confirmation")
                    workflow_click(190, 20, 1760, "reopen Settings menu")
                    workflow_click(248, 56, 1764, "enable confirm-before-save")
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
                        wire_message(16, 3, struct.pack("<IIII", 1820, 1820, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1821, 1821, 31, 1))
                    )
                    workflow_redraw("Ctrl+S confirmation dialog")
                    if child_u32("save_confirm_open") != 1:
                        raise AssertionError("Ctrl+S did not open the save confirmation")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"I":
                            raise AssertionError("file was written before save confirmation")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1822, 1822, 31, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1823, 1823, 29, 0))
                        + wire_message(12, 0)
                    )
                    key_step(1830, 1, "cancel save confirmation with Escape")
                    if child_u32("save_confirm_open") != 0:
                        raise AssertionError("Escape did not cancel the save confirmation")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"I":
                            raise AssertionError("cancelled save modified the destination")

                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1840, 1840, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1841, 1841, 31, 1))
                    )
                    workflow_redraw("reopen Ctrl+S confirmation")
                    if child_u32("save_confirm_open") != 1:
                        raise AssertionError("second Ctrl+S did not reopen confirmation")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1842, 1842, 31, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1843, 1843, 29, 0))
                        + wire_message(12, 0)
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
                        wire_message(16, 3, struct.pack("<IIII", 1870, 1870, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1871, 1871, 31, 1))
                    )
                    workflow_redraw("open save dialog for pointer Cancel")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1872, 1872, 31, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1873, 1873, 29, 0))
                        + wire_message(12, 0)
                    )
                    workflow_click(484, 272, 1880, "pointer Cancel save dialog")
                    if child_u32("save_confirm_open") != 0:
                        raise AssertionError("pointer Cancel did not close the save dialog")
                    with open(initial_file, "rb") as saved_file:
                        if saved_file.read() != b"z":
                            raise AssertionError("pointer Cancel modified the destination")

                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1890, 1890, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1891, 1891, 31, 1))
                    )
                    workflow_redraw("open save dialog for pointer Save")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1892, 1892, 31, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1893, 1893, 29, 0))
                        + wire_message(12, 0)
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
                        wire_message(16, 3, struct.pack("<IIII", 1250, 1250, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1251, 1251, 31, 1))
                    )
                    workflow_redraw("Ctrl+S after dynamic document growth")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1252, 1252, 31, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1253, 1253, 29, 0))
                        + wire_message(12, 0)
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
                        wire_message(16, 3, struct.pack("<IIII", 1262, 1262, 42, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1263, 1263, 105, 1))
                    )
                    workflow_redraw("Shift+Left selects y across the gap")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1264, 1264, 105, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1265, 1265, 42, 0))
                        + wire_message(12, 0)
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
                        wire_message(16, 3, struct.pack("<IIII", 1308, 1308, 42, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1309, 1309, 105, 1))
                    )
                    workflow_redraw("Shift+Left selects complete four-byte character")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1310, 1310, 105, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1311, 1311, 42, 0))
                        + wire_message(12, 0)
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
                a_pixel = struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0]
                if a_pixel != 0xFFD8DEE9:
                    raise AssertionError(f"first key did not render an A glyph: {hex(a_pixel)}")
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
                    wire_message(16, 3, struct.pack("<IIII", 1011, 1011, 42, 1))
                    + wire_message(16, 4, struct.pack("<IIIII", 1012, 1, 0, 0, 0))
                    + wire_message(16, 3, struct.pack("<IIII", 1013, 1013, 2, 1))
                )
                expect_message(client, (8, 1, struct.pack("<III", 12, 0, 0)), "shifted key attach")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "shifted key damage")
                expect_message(client, (8, 6, b""), "shifted key commit")
                client.sendall(
                    wire_message(12, 0)
                    + wire_message(16, 3, struct.pack("<IIII", 1014, 1014, 42, 0))
                    + wire_message(16, 4, struct.pack("<IIIII", 1015, 0, 0, 0, 0))
                )

                # The remaining document must be "b\\n2!": Backspace removed
                # a, Enter and digit 2 formed the second line, and Shift+1
                # produced the exclamation mark.
                first_line = [
                    struct.unpack_from("<I", pixels, 92 * 800 * 4 + x * 4)[0]
                    for x in range(16, 24)
                ]
                if first_line[0] != 0xFFD8DEE9:
                    raise AssertionError(
                        "expected B glyph was not rendered at the first line; "
                        f"first pixels={[hex(value) for value in first_line]}"
                    )
                if struct.unpack_from("<I", pixels, 104 * 800 * 4 + 17 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("expected digit 2 was not rendered on the second line")
                if struct.unpack_from("<I", pixels, 104 * 800 * 4 + 26 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("Shift+1 did not render an exclamation mark")
                if struct.unpack_from("<I", pixels, 104 * 800 * 4 + 32 * 4)[0] != 0xFFFFFFFF:
                    raise AssertionError("document caret was not rendered after the shifted character")
                # The footer tracks the current logical caret position and byte count.
                if struct.unpack_from("<I", pixels, 466 * 800 * 4 + 41 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("status bar did not show logical line 2")
                if struct.unpack_from("<I", pixels, 466 * 800 * 4 + 100 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("status bar did not show logical column 3")
                observations.append(
                    "US-QWERTY insertion, cursor movement, Backspace, Enter, digit rendering, caret and live status verified"
                )

                def key_step_shift(serial: int, code: int, label: str) -> None:
                    client.sendall(
                        wire_message(16, 4, struct.pack("<IIIII", serial, 1, 0, 0, 0))
                        + wire_message(16, 3, struct.pack("<IIII", serial + 1, serial + 1, code, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    client.sendall(
                        wire_message(
                            16, 3, struct.pack("<IIII", serial + 2, serial + 2, code, 0)
                        )
                        + wire_message(12, 0)
                        + wire_message(16, 4, struct.pack("<IIIII", serial + 3, 0, 0, 0, 0))
                    )

                def pointer_click(x: int, y: int, serial: int, label: str) -> None:
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                        + wire_message(
                            15, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 3, serial + 4, 0x110, 0)
                        )
                        + wire_message(12, 0)
                    )

                def pointer_drag(
                    start_x: int, start_y: int, end_x: int, end_y: int,
                    serial: int, label: str
                ) -> None:
                    client.sendall(
                        wire_message(
                            15, 2, struct.pack("<Iii", serial, start_x * 256, start_y * 256)
                        )
                        + wire_message(
                            15, 3, struct.pack("<IIII", serial + 1, serial + 2, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} press attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} press damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} press commit")
                    client.sendall(wire_message(12, 0))

                    client.sendall(
                        wire_message(
                            15, 2, struct.pack("<Iii", serial + 3, end_x * 256, end_y * 256)
                        )
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} motion attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} motion damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} motion commit")
                    client.sendall(
                        wire_message(
                            15, 3, struct.pack("<IIII", serial + 4, serial + 5, 0x110, 0)
                        )
                        + wire_message(12, 0)
                    )

                # Mouse movement followed by a click snaps to character
                # insertion boundaries across lines and between characters.
                pointer_click(22, 98, 1100, "mouse caret first line")
                first_line_caret = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 24 * 4
                )[0]
                if first_line_caret != 0xFFFFFFFF:
                    raise AssertionError("mouse click did not place caret after first-line text")

                pointer_click(18, 110, 1110, "mouse caret second-line start")
                second_line_start = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 16 * 4
                )[0]
                if second_line_start != 0xFFFFFFFF:
                    raise AssertionError("mouse click did not place caret at second-line start")

                pointer_click(26, 110, 1120, "mouse caret between characters")
                between_chars = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 24 * 4
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
                    struct.unpack_from("<I", pixels, 92 * 800 * 4 + 39 * 4)[0],
                    struct.unpack_from("<I", pixels, 104 * 800 * 4 + 23 * 4)[0],
                    struct.unpack_from("<I", pixels, 104 * 800 * 4 + 31 * 4)[0],
                ]
                if vertical_pixels != [0xFF5E81AC] * 3:
                    raise AssertionError(
                        "Shift+Up did not select across the newline and previous line; "
                        f"pixels={[hex(x) for x in vertical_pixels]}"
                    )
                key_step_shift(1172, 108, "Shift+Down collapse vertical selection")
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 39 * 4)[0] != 0xFF252A33:
                    raise AssertionError("Shift+Down back to the anchor did not clear selection")

                key_step_shift(1176, 102, "Shift+Home select to line start")
                if struct.unpack_from("<I", pixels, 104 * 800 * 4 + 31 * 4)[0] != 0xFF5E81AC:
                    raise AssertionError("Shift+Home did not select text to the start of the line")
                key_step_shift(1180, 107, "Shift+End collapse to line end")
                if struct.unpack_from("<I", pixels, 104 * 800 * 4 + 31 * 4)[0] != 0xFF252A33:
                    raise AssertionError("Shift+End did not clear selection after returning to its anchor")
                if struct.unpack_from("<I", pixels, 104 * 800 * 4 + 32 * 4)[0] != 0xFFFFFFFF:
                    raise AssertionError("Shift+End did not leave the caret at the line end")
                observations.append(
                    "Shift+Arrow and Shift+Home/End selection, extension, collapse, and multi-line highlighting"
                )

                def expect_redraw(label: str) -> None:
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, initial_height)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")

                # Hold Left: the initial press acts immediately, then repeat
                # begins after ~300 ms and continues at roughly 30 Hz.
                repeat_started = time.monotonic()
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1200, 1200, 105, 1))
                )
                expect_redraw("initial held Left")
                client.sendall(wire_message(12, 0))
                caret = struct.unpack_from("<I", pixels, 104 * 800 * 4 + 24 * 4)[0]
                if caret != 0xFFFFFFFF:
                    raise AssertionError("initial Left press did not move the caret once")

                expect_redraw("first repeated Left")
                first_repeat_elapsed = time.monotonic() - repeat_started
                expected_delay = 0.18 if advertised_seat_version >= 4 else 0.30
                if first_repeat_elapsed < expected_delay - 0.04:
                    raise AssertionError(
                        "keyboard repeat started before the compositor/fallback delay; "
                        f"expected={expected_delay:.3f}s elapsed={first_repeat_elapsed:.3f}s"
                    )
                client.sendall(wire_message(12, 0))
                caret = struct.unpack_from("<I", pixels, 104 * 800 * 4 + 16 * 4)[0]
                if caret != 0xFFFFFFFF:
                    raise AssertionError("first repeated Left did not move the caret to line start")

                expect_redraw("second repeated Left")
                client.sendall(wire_message(12, 0))
                caret = struct.unpack_from("<I", pixels, 92 * 800 * 4 + 32 * 4)[0]
                if caret != 0xFFFFFFFF:
                    raise AssertionError("continued Left repeat did not cross to the previous line")
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1201, 1201, 105, 0))
                    + wire_message(12, 0)
                )

                # Backspace is repeatable too: after its immediate deletion,
                # the held key should delete the preceding character again.
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1210, 1210, 14, 1))
                )
                expect_redraw("initial held Backspace")
                client.sendall(wire_message(12, 0))
                first_line_b = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 17 * 4
                )[0]
                if first_line_b != 0xFFD8DEE9:
                    raise AssertionError("initial Backspace removed more than one character")

                expect_redraw("repeated Backspace")
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1211, 1211, 14, 0))
                    + wire_message(12, 0)
                )
                removed_b = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 17 * 4
                )[0]
                if removed_b != 0xFF252A33:
                    raise AssertionError("held Backspace did not repeat after its initial delay")
                # Delete-forward uses the same delayed repeat path.
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1220, 1220, 111, 1))
                )
                expect_redraw("initial held Delete")
                client.sendall(wire_message(12, 0))
                first_cell = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 20 * 4
                )[0]
                if first_cell != 0xFFD8DEE9:
                    raise AssertionError("initial Delete did not move the first character onto line one")

                expect_redraw("repeated Delete")
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1221, 1221, 111, 0))
                    + wire_message(12, 0)
                )
                next_glyph = struct.unpack_from(
                    "<I", pixels, 92 * 800 * 4 + 20 * 4
                )[0]
                if next_glyph != 0xFF252A33:
                    raise AssertionError("held Delete did not repeat after its initial delay")

                observations.append(
                    "keyboard auto-repeat used a 300 ms initial delay and repeated Left, Backspace, and Delete while held"
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
                wrapped_caret = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 56 * 4
                )[0]
                if wrapped_caret != 0xFFFFFFFF:
                    raise AssertionError("caret did not follow the text onto its soft-wrapped row")

                # A click on the wrapped row must map back to the same visual
                # insertion point, not to a logical hard-newline-only row.
                pointer_click(40, 110, 1510, "click within soft-wrapped row")
                wrapped_click_caret = struct.unpack_from(
                    "<I", pixels, 104 * 800 * 4 + 40 * 4
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
                    wire_message(16, 3, struct.pack("<IIII", 1700, 1700, 29, 1))
                    + wire_message(16, 4, struct.pack("<IIIII", 1701, 4, 0, 0, 0))
                    + wire_message(16, 3, struct.pack("<IIII", 1702, 1702, 30, 1))
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
                    wire_message(12, 0)
                    + wire_message(16, 3, struct.pack("<IIII", 1703, 1703, 30, 0))
                    + wire_message(16, 3, struct.pack("<IIII", 1704, 1704, 29, 0))
                    + wire_message(16, 4, struct.pack("<IIIII", 1705, 0, 0, 0, 0))
                )

                def caret_position() -> tuple[int, int]:
                    for y in range(92, 460 - 9, 12):
                        for x in range(16, 800 - 1, 8):
                            if all(
                                struct.unpack_from("<I", pixels, (y + dy) * 800 * 4 + x * 4)[0]
                                == 0xFFFFFFFF
                                for dy in range(9)
                            ):
                                return x, y
                    raise AssertionError("visible document caret could not be located")

                # A held printable key must insert the initial character and
                # then additional characters at the compositor's configured rate.
                before = caret_position()
                client.sendall(wire_message(16, 3, struct.pack("<IIII", 1710, 1710, 30, 1)))
                expect_redraw("initial held printable key")
                client.sendall(wire_message(12, 0))
                after_press = caret_position()
                # Ctrl+A left the complete document selected, so this first
                # character must replace it and restart at the document origin.
                if after_press != (24, 92):
                    raise AssertionError(
                        f"initial printable press did not replace the selection at document start: "
                        f"before={before}, after={after_press}"
                    )
                expect_redraw("first repeated printable key")
                client.sendall(wire_message(12, 0))
                after_repeat = caret_position()
                if after_repeat != (32, 92):
                    raise AssertionError(
                        f"held printable key did not repeat into the next cell: "
                        f"after_press={after_press}, after_repeat={after_repeat}"
                    )
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("repeated printable-key test did not render its first glyph")
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1711, 1711, 30, 0))
                    + wire_message(12, 0)
                )

                # Enter repeats as well; each timer tick advances one visual row.
                before_enter = caret_position()
                client.sendall(wire_message(16, 3, struct.pack("<IIII", 1720, 1720, 28, 1)))
                expect_redraw("initial held Enter")
                client.sendall(wire_message(12, 0))
                after_enter = caret_position()
                if after_enter != (16, before_enter[1] + 12):
                    raise AssertionError(
                        f"initial Enter did not move to the next row: before={before_enter}, after={after_enter}"
                    )
                expect_redraw("first repeated Enter")
                client.sendall(wire_message(12, 0))
                after_enter_repeat = caret_position()
                if after_enter_repeat != (16, after_enter[1] + 12):
                    raise AssertionError(
                        f"held Enter did not repeat: after_press={after_enter}, after_repeat={after_enter_repeat}"
                    )
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1721, 1721, 28, 0))
                    + wire_message(12, 0)
                )

                # Tab inserts four spaces per action, both on initial press and repeat.
                before_tab = caret_position()
                client.sendall(wire_message(16, 3, struct.pack("<IIII", 1730, 1730, 15, 1)))
                expect_redraw("initial held Tab")
                client.sendall(wire_message(12, 0))
                after_tab = caret_position()
                if after_tab != (before_tab[0] + 32, before_tab[1]):
                    raise AssertionError(
                        f"initial Tab did not insert four spaces: before={before_tab}, after={after_tab}"
                    )
                expect_redraw("first repeated Tab")
                client.sendall(wire_message(12, 0))
                after_tab_repeat = caret_position()
                if after_tab_repeat != (after_tab[0] + 32, after_tab[1]):
                    raise AssertionError(
                        f"held Tab did not repeat: after_press={after_tab}, after_repeat={after_tab_repeat}"
                    )
                client.sendall(
                    wire_message(16, 3, struct.pack("<IIII", 1731, 1731, 15, 0))
                    + wire_message(12, 0)
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
                client.close()

    thread = threading.Thread(target=fake_compositor, daemon=True)
    thread.start()
    environment = os.environ.copy()
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
            cwd=runtime_dir if file_workflow else None,
        )
        process_holder.append(process)
        if use_wayland_socket:
            # Popen has inherited the descriptor. Drop the parent's duplicate
            # so the compositor observes EOF when the child closes its socket.
            client_endpoint.close()
            client_endpoint = None
        # The expanded XKB and rendered-glyph integration cases inspect
        # child mappings and shared-memory pixels; allow extra scheduler
        # variance on slower CI hosts while keeping a finite upper bound.
        timeout_seconds = 50 if file_workflow else 20
        try:
            stdout, stderr_bytes = process.communicate(timeout=timeout_seconds)
        except subprocess.TimeoutExpired:
            process.kill()
            stdout, stderr_bytes = process.communicate()
            thread.join(timeout=9)
            details = "\\n".join(errors)
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

    if thread.is_alive():
        raise AssertionError("mock compositor did not finish the protocol exchange")
    stderr = result.stderr.decode(errors="replace")
    if errors:
        raise AssertionError(
            "mock compositor failed:\n" + "\n".join(errors)
            + f"\nNekoEdit exit status: {result.returncode}; stderr: {stderr!r}"
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
    if save_roundtrip:
        with open(initial_file, "rb") as saved_file:
            saved_bytes = saved_file.read()
        if saved_bytes != expected_saved_bytes:
            raise AssertionError(
                f"Ctrl+S saved incorrect document bytes: expected {expected_saved_bytes!r}, got {saved_bytes!r}"
            )
    transport = "WAYLAND_SOCKET" if use_wayland_socket else "WAYLAND_DISPLAY"
    print(f"Wayland mock integration test passed using {transport} (registry, xdg-shell, memfd, pixels, close).")
    print("Verified: " + ", ".join(observations))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} PATH_TO_NEKOEDIT")
    run(sys.argv[1])
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
            expected_saved_bytes=b"IaAq@wertyuiopasdfghjklzxcvbnm!@#$%^&*()_+~{}:\"<>?,",
            keyboard_layout_test=True,
        )
    finally:
        try:
            os.unlink(xkb_path)
        except FileNotFoundError:
            pass
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

    # The embedded 5x7 renderer must cover every printable ASCII punctuation
    # character, not replace the unimplemented glyphs with '?'.
    punctuation_fd, punctuation_path = tempfile.mkstemp(prefix="nekoedit-punctuation-")
    try:
        with os.fdopen(punctuation_fd, "wb") as punctuation_file:
            punctuation_file.write(b"A!\"#$%&'()*+,-./:;<=>?@[\\]^_")
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
