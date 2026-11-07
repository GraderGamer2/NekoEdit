#!/usr/bin/env python3
"""Protocol-level smoke test for the raw Wayland bootstrap (no compositor needed).

Python is used only by this test harness; it is not part of NekoEdit's runtime.
"""
from __future__ import annotations

import mmap
import os
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
            client.sendall(
                registry_global(1, "wl_compositor")
                + registry_global(2, "wl_shm")
                + registry_global(3, "xdg_wm_base")
                + registry_global(4, "wl_seat", version=advertised_seat_version)
                + wire_message(3, 0, struct.pack("<I", 1))
            )

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
                wire_message(10, 0, struct.pack("<iiI", 800, 480, 0))
                + wire_message(9, 0, struct.pack("<I", 1234))
            )
            expect_message(client, (9, 4, struct.pack("<I", 1234)), "ack_configure")
            if disconnect_after_configure_ack:
                # Close before the next client request so the send-failure
                # diagnostic exercises its bounded event-size output path.
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
                if struct.unpack_from("<I", pixels, 460 * 800 * 4)[0] != 0xFF78A9D4:
                    raise AssertionError("status bar accent separator was not rendered")
                if struct.unpack_from("<I", pixels, 461 * 800 * 4)[0] != 0xFF343D4B:
                    raise AssertionError("status bar background was not rendered")
                if struct.unpack_from("<I", pixels, 466 * 800 * 4 + 16 * 4)[0] != 0xFFD8DEE9:
                    raise AssertionError("logical line status label was not rendered")
                editor_origin_pixel = struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0]
                if initial_file is None:
                    if editor_origin_pixel != 0xFF252A33:
                        raise AssertionError(
                            "empty document area should not draw a placeholder; "
                            f"pixel={hex(editor_origin_pixel)}"
                        )
                elif editor_origin_pixel != 0xFFD8DEE9:
                    raise AssertionError("launch-time file content was not rendered at the document origin")

                expect_message(
                    client,
                    (11, 0, struct.pack("<6I", 12, 0, 800, 480, 3200, 1)),
                    "create wl_buffer",
                )
                expect_message(client, (8, 1, struct.pack("<III", 12, 0, 0)), "attach buffer")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "damage surface")
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
                client.sendall(
                    wire_message(13, 0, struct.pack("<I", 3))
                    + wire_message(14, 0, struct.pack("<I", 2))
                )
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
                observations.append("seat pointer and keyboard capability/object creation verified")

                # Release the initial buffer before sending a click. The client
                # must not rewrite the shared memory while the compositor owns it.
                client.sendall(
                    wire_message(12, 0)
                    + wire_message(
                        15, 0,
                        struct.pack(
                            "<IIii", 777, 8,
                            (50 if utf8_pointer_test else (34 if gap_buffer_test else (18 if (utf8_edit_test or utf8_delete_test or utf8_invalid_test) else 98))) * 256,
                            (98 if (utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test or gap_buffer_test) else 110) * 256,
                        ),
                    )
                    + wire_message(15, 3, struct.pack("<IIII", 778, 1000, 0x110, 1))
                )
                expect_message(client, (8, 1, struct.pack("<III", 12, 0, 0)), "redraw attach")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "redraw damage")
                expect_message(client, (8, 6, b""), "redraw commit")
                if not (
                    sparse_keymap_test or punctuation_render_test
                    or utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test
                    or gap_buffer_test
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
                        raise AssertionError(
                            "document click did not keep the caret visible after clamping to the document"
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

                def key_step(serial: int, code: int, label: str) -> None:
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", serial, serial, code, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} damage"
                    )
                    expect_message(client, (8, 6, b""), f"{label} commit")
                    client.sendall(
                        wire_message(
                            16, 3, struct.pack("<IIII", serial + 1, serial + 1, code, 0)
                        )
                        + wire_message(12, 0)
                    )

                def workflow_redraw(label: str) -> None:
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), f"{label} attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} damage"
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

                def workflow_axis(axis: int, value: int, serial: int, label: str) -> None:
                    client.sendall(
                        wire_message(15, 4, struct.pack("<IIi", serial, axis, value))
                    )
                    workflow_redraw(label)
                    client.sendall(wire_message(12, 0))

                def workflow_window_click(
                    x: int, serial: int, request_opcode: int, label: str,
                    y: int = 12, request_payload: bytes = b"",
                ) -> None:
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial, x * 256, y * 256))
                        + wire_message(
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

                evdev = {
                    "a": 30, "b": 48, "c": 46, "d": 32, "e": 18, "f": 33,
                    "g": 34, "h": 35, "i": 23, "j": 36, "k": 37, "l": 38,
                    "m": 50, "n": 49, "o": 24, "p": 25, "q": 16, "r": 19,
                    "s": 31, "t": 20, "u": 22, "v": 47, "w": 17, "x": 45,
                    "y": 21, "z": 44, "0": 11, "1": 2, "2": 3, "3": 4,
                    "4": 5, "5": 6, "6": 7, "7": 8, "8": 9, "9": 10,
                    ".": 52, "/": 53, "-": 12,
                }

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
                        if len(fields) == 3 and fields[2] in {"picker_mode", "picker_dir_fd", "picker_error", "picker_entry_count", "picker_selected", "picker_scroll", "picker_scroll_drag", "picker_scroll_thumb_top", "picker_scroll_thumb_height", "pointer_x", "pointer_y", "pointer_inside", "picker_path_length", "picker_path_cursor", "picker_path_buffer", "picker_current_path", "picker_name_length", "picker_name_cursor", "picker_name_match", "picker_suggestion_count", "picker_suggestion_selected", "picker_suggestion_indices", "picker_edit_select_all", "picker_name_buffer", "picker_last_click_index", "window_width", "window_height", "window_stride", "window_buffer_id", "window_is_maximized", "picker_last_click_time", "doc_length", "doc_buffer", "current_file_path", "current_path_buffer", "picker_target_buffer", "doc_save_error"}:
                            picker_symbols[fields[2]] = int(fields[0], 16)

                    def picker_state() -> dict[str, object]:
                        with open(f"/proc/{process_holder[0].pid}/mem", "rb", buffering=0) as memory:
                            fd = memory.fileno()
                            result: dict[str, object] = {}
                            for name, address in picker_symbols.items():
                                if name in {"picker_name_buffer", "doc_buffer", "picker_path_buffer", "picker_current_path", "current_path_buffer", "picker_target_buffer"}:
                                    size = 64 if name in {"picker_name_buffer", "doc_buffer"} else 256
                                    result[name] = os.pread(fd, size, address).split(b"\0", 1)[0]
                                elif name == "picker_suggestion_indices":
                                    result[name] = struct.unpack("<5I", os.pread(fd, 20, address))
                                elif name == "current_file_path":
                                    pointer = struct.unpack("<Q", os.pread(fd, 8, address))[0]
                                    result[name] = pointer
                                    result["active_path"] = os.pread(fd, 4096, pointer).split(b"\0", 1)[0] if pointer else b""
                                else:
                                    result[name] = struct.unpack("<i", os.pread(fd, 4, address))[0]
                            return result

                    def assert_picker(label: str) -> None:
                        panel_pixel = struct.unpack_from("<I", pixels, 70 * 800 * 4 + 40 * 4)[0]
                        path_pixel = struct.unpack_from("<I", pixels, 64 * 800 * 4 + 56 * 4)[0]
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

                    def double_click_picker_row(x: int, y: int, serial: int, label: str) -> int:
                        workflow_click(x, y, serial, f"{label}: first click")
                        workflow_click(x, y, serial + 10, f"{label}: second click")
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
                    serial = double_click_picker_row(120, 139, 2120, "enter nested directory")
                    small_directory_state = picker_state()
                    small_directory_pixel = struct.unpack_from(
                        "<I", pixels, 200 * 800 * 4 + 726 * 4
                    )[0]
                    if (
                        small_directory_state.get("picker_entry_count", 999) > 15
                        or small_directory_state.get("picker_scroll_thumb_height") != 0
                        or small_directory_pixel != 0xFF252A33
                    ):
                        raise AssertionError(
                            "a directory that fits its visible rows must not draw a scrollbar: "
                            f"state={small_directory_state!r}, pixel={hex(small_directory_pixel)}"
                        )
                    workflow_click(730, 200, serial, "click empty scrollbar gutter with no overflow")
                    no_scroll_drag_state = picker_state()
                    if no_scroll_drag_state.get("picker_scroll_drag") != 0:
                        raise AssertionError(
                            f"non-scrollable directory started a scrollbar drag: {no_scroll_drag_state!r}"
                        )
                    serial += 10
                    workflow_click(650, 110, serial, "show hidden files")
                    serial += 10
                    serial = double_click_picker_row(160, 139, serial, "open hidden file")
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
                    serial = double_click_picker_row(120, 139, 2220, "enter nested directory again")
                    workflow_click(78, 108, serial, "navigate Up to parent directory")
                    serial += 10
                    serial = double_click_picker_row(120, 139, serial, "re-enter nested directory")
                    serial = double_click_picker_row(160, 167, serial, "open inside.txt with hidden files hidden after two earlier entries")
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

                    workflow_shortcut(serial + 12, 24, "Ctrl+O before oversized file")
                    serial = workflow_type_path("oversized.txt", serial + 22)
                    key_step(serial, 28, "reject file larger than 64 KiB")
                    key_step(serial + 2, 1, "Escape oversized Open picker")
                    key_step(serial + 4, evdev["f"], "edit after oversized Open")
                    workflow_shortcut(serial + 6, 31, "save after oversized Open")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zabcdef":
                            raise AssertionError("oversized Open damaged the active document")

                    # Escape from Save As must not alter the active destination.
                    workflow_shortcut(serial + 12, 31, "Ctrl+Shift+S before cancellation", shift=True)
                    serial = workflow_type_path("cancelled.txt", serial + 22)
                    key_step(serial, 1, "Escape cancels Save As picker")
                    key_step(serial + 2, evdev["g"], "edit after cancelling Save As")
                    workflow_shortcut(serial + 4, 31, "save after cancelled Save As")
                    with open(menu_saveas, "rb") as saved:
                        if saved.read() != b"zabcdefg":
                            raise AssertionError("cancelled Save As changed the active destination")
                    if os.path.exists(os.path.join(runtime_dir, "cancelled.txt")):
                        raise AssertionError("Escape unexpectedly created the cancelled Save As path")
                    observations.append("missing/oversized Open rollback, failed Save As rollback, and Escape cancellation verified")

                    # A zero-byte text file must replace the current document
                    # with an actually empty buffer and commit its own exact path.
                    workflow_shortcut(serial + 10, 24, "Ctrl+O before zero-byte file")
                    open_picker_from_menu(serial + 20, "zero-byte file picker")
                    serial = double_click_picker_row(120, 139, serial + 40, "enter directory for zero-byte file")
                    # With dotfiles hidden, aaa.txt sorts before empty.txt;
                    # select row 1 to catch accidental row-zero/stale selection.
                    workflow_click(160, 153, serial, "select zero-byte empty.txt from second file row")
                    workflow_click(716, 410, serial + 10, "Open selected zero-byte empty.txt")
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
                    serial = double_click_picker_row(120, 139, serial + 60, "enter nested directory for double-click empty file")
                    serial = double_click_picker_row(160, 153, serial, "double-click empty.txt from second file row")
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
                    workflow_click(path_end_x, 76, serial + 10, "focus location before directory-scoped search check")
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
                    workflow_click(716, 410, serial + 10, "Open with no selected row after search navigation")
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
                    workflow_click(160, 153, serial + 20, "select empty.txt after stale-query rejection")
                    workflow_click(716, 410, serial + 30, "Open exact empty.txt after stale-query rejection")
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
                    workflow_axis(0, 42 * 256, serial + 30, "mouse wheel scroll down three rows")
                    scroll_state = picker_state()
                    if scroll_state.get("picker_scroll") != 3:
                        raise AssertionError(
                            f"vertical mouse wheel did not advance the picker by three rows: {scroll_state!r}"
                        )
                    thumb_top = scroll_state["picker_scroll_thumb_top"]
                    thumb_height = scroll_state["picker_scroll_thumb_height"]
                    thumb_center = thumb_top + thumb_height // 2
                    workflow_scrollbar_drag(
                        730, thumb_center, 730, 339, serial + 40,
                        "drag picker scrollbar thumb to bottom"
                    )
                    scroll_state = picker_state()
                    expected_max_scroll = scroll_state["picker_entry_count"] - 15
                    if scroll_state.get("picker_scroll") != expected_max_scroll:
                        raise AssertionError(
                            f"dragging the picker scrollbar did not reach the last rows: {scroll_state!r}"
                        )
                    workflow_axis(0, -14 * 256, serial + 50, "mouse wheel scroll up one row")
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
                    workflow_click(96, 76, serial + 80, "place path caret in the middle")
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
                    workflow_click(path_end_x, 76, serial + 100, "place path caret at the end")
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
                    workflow_click(192, 374, serial + 20, "place search-field cursor after two characters")
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
                    serial = double_click_picker_row(
                        120, 139, serial + 30, "enter directory for filename autocomplete"
                    )
                    serial = workflow_type_path("prefill-", serial + 10)
                    suggestion_state = picker_state()
                    if (
                        suggestion_state.get("picker_name_buffer") != b"prefill-"
                        or suggestion_state.get("picker_suggestion_count") != 2
                        or suggestion_state.get("picker_suggestion_selected") != 0
                        or suggestion_state.get("picker_selected") != suggestion_state.get("picker_suggestion_indices", ())[0]
                    ):
                        raise AssertionError(
                            f"filename autocomplete did not show both matching files: {suggestion_state!r}"
                        )
                    # The dropdown overlays the lower list area and is rendered
                    # with a distinct dark panel above the Search field.
                    popup_pixel = struct.unpack_from(
                        "<I", pixels, 272 * 800 * 4 + 168 * 4
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
                        (11, 0, struct.pack("<6I", 256, 0, 1920, 1080, 7680, 1)),
                        "create maximized buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 256, 0, 0)),
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
                        or max_state.get("window_buffer_id") != 256
                        or max_state.get("window_is_maximized") != 1
                    ):
                        raise AssertionError(f"maximized configure was not applied: {max_state!r}")
                    max_close_pixel = struct.unpack_from("<I", pixels, 4 * 7680 + 1880 * 4)[0]
                    if max_close_pixel != 0xFF754B52:
                        raise AssertionError(
                            f"window controls did not follow the maximized width: {hex(max_close_pixel)}"
                        )
                    observations.append(
                        "Maximize acknowledges compositor configure and reallocates/repaints the surface at its new dimensions"
                    )

                    # Restore: deliver the configure while buffer 256 is still
                    # compositor-owned. The client must ack but defer replacement.
                    workflow_window_click(1860, serial + 30, 10, "restore")
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiII", 800, 480, 4, 4))
                        + wire_message(9, 0, struct.pack("<I", 1236))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1236)), "ack restored configure"
                    )
                    client.sendall(wire_message(256, 0))
                    expect_message(client, (256, 0, b""), "destroy released maximized buffer")
                    expect_message(
                        client,
                        (11, 0, struct.pack("<6I", 257, 0, 800, 480, 3200, 1)),
                        "create restored buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 257, 0, 0)),
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
                        or restored_state.get("window_buffer_id") != 257
                        or restored_state.get("window_is_maximized") != 0
                    ):
                        raise AssertionError(f"restore configure was not applied: {restored_state!r}")
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
                        + wire_message(
                            15, 3, struct.pack("<IIII", serial + 61, serial + 62, 0x110, 1)
                        )
                    )
                    expect_message(
                        client, (10, 6, struct.pack("<III", 13, serial + 61, 4)),
                        "left-edge interactive resize request",
                    )
                    client.sendall(
                        wire_message(15, 3, struct.pack("<IIII", serial + 63, serial + 64, 0x110, 0))
                    )
                    # Deliver a new size while buffer 257 is still busy.
                    client.sendall(
                        wire_message(10, 0, struct.pack("<iiIII", 720, 480, 8, 3, 4))
                        + wire_message(9, 0, struct.pack("<I", 1237))
                    )
                    expect_message(
                        client, (9, 4, struct.pack("<I", 1237)), "ack interactive-resize configure"
                    )
                    client.sendall(wire_message(257, 0))
                    expect_message(client, (257, 0, b""), "destroy old buffer after edge resize")
                    expect_message(
                        client, (11, 0, struct.pack("<6I", 258, 0, 720, 480, 2880, 1)),
                        "create edge-resized buffer",
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 258, 0, 0)), "attach edge-resized buffer"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 720, 480)), "damage edge-resized surface"
                    )
                    expect_message(client, (8, 6, b""), "commit edge-resized surface")
                    edge_state = picker_state()
                    if (
                        edge_state.get("window_width") != 720
                        or edge_state.get("window_height") != 480
                        or edge_state.get("window_stride") != 2880
                        or edge_state.get("window_buffer_id") != 258
                        or edge_state.get("window_is_maximized") != 0
                    ):
                        raise AssertionError(f"interactive resize configure was not applied: {edge_state!r}")
                    client.sendall(wire_message(258, 0))

                    # Probe every remaining edge and corner with coordinates
                    # deliberately inside the new 12-pixel grab band.
                    for index, (x, y, edges, label) in enumerate((
                        (710, 240, 8, "right edge"),
                        (360, 10, 1, "top edge"),
                        (360, 470, 2, "bottom edge"),
                        (710, 10, 9, "top-right corner"),
                        (710, 470, 10, "bottom-right corner"),
                        (10, 10, 5, "top-left corner"),
                        (10, 470, 6, "bottom-left corner"),
                    )):
                        base_serial = serial + 80 + index * 4
                        workflow_window_click(
                            x, base_serial, 6, label, y=y,
                            request_payload=struct.pack("<III", 13, base_serial + 1, edges),
                        )

                    # The app's own Close control exits cleanly; no terminal
                    # shutdown or synthetic xdg_toplevel.close is required.
                    client.sendall(
                        wire_message(15, 2, struct.pack("<Iii", serial + 120, 692 * 256, 12 * 256))
                        + wire_message(
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

                if save_roundtrip and not (utf8_edit_test or utf8_delete_test or utf8_invalid_test or utf8_pointer_test or gap_buffer_test):
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
                    key_step(1810, 44, "replace loaded text with z")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1820, 1820, 29, 1))
                        + wire_message(16, 3, struct.pack("<IIII", 1821, 1821, 31, 1))
                    )
                    expect_message(
                        client, (8, 1, struct.pack("<III", 12, 0, 0)), "Ctrl+S attach"
                    )
                    expect_message(
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "Ctrl+S damage"
                    )
                    expect_message(client, (8, 6, b""), "Ctrl+S commit")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1822, 1822, 31, 0))
                        + wire_message(16, 3, struct.pack("<IIII", 1823, 1823, 29, 0))
                        + wire_message(12, 0)
                    )
                    observations.append("launch-time load, selection replacement, and Ctrl+S write verified")
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
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} damage"
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
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} damage"
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
                        raise AssertionError(
                            "drag selection did not highlight both selected characters; "
                            f"x={x}, pixel={hex(selected_pixel)}"
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
                        client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), f"{label} damage"
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

                # Insert enough characters to pass the 97-cell line width.
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
                    "<I", pixels, 104 * 800 * 4 + 40 * 4
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
        expected = (
            "Wayland send failed: object=5, opcode=0, errno=32",
            "Wayland previous request: object=9, opcode=4",
            "Wayland last event: object=9, opcode=0, payload bytes=4",
        )
        missing = [line for line in expected if line not in stderr]
        sentinel = b"PRIVATE_DIAGNOSTIC_SENTINEL"
        if result.returncode == 0 or missing:
            raise AssertionError(
                "closed-socket diagnostic did not preserve the expected request/event context: "
                f"status={result.returncode}, missing={missing!r}, stderr={stderr!r}"
            )
        if len(result.stderr) > 512 or sentinel in result.stderr or b"\\0" in result.stderr:
            raise AssertionError(
                "Wayland diagnostic output was unbounded, contained NUL bytes, or exposed document bytes: "
                f"stderr_length={len(result.stderr)}, nul_present={b'\\0' in result.stderr}, "
                f"sentinel_present={sentinel in result.stderr}"
            )
        print("Wayland send-failure diagnostic is bounded and does not expose document data.")
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
    # produce concise numeric diagnostics without dumping editor memory.
    diagnostic_fd, diagnostic_path = tempfile.mkstemp(prefix="nekoedit-diagnostic-")
    try:
        with os.fdopen(diagnostic_fd, "wb") as diagnostic_file:
            diagnostic_file.write(b"PRIVATE_DIAGNOSTIC_SENTINEL")
        run(
            sys.argv[1],
            initial_file=diagnostic_path,
            disconnect_after_configure_ack=True,
        )
    finally:
        try:
            os.unlink(diagnostic_path)
        except FileNotFoundError:
            pass
    # Test positional file loading and Ctrl+S using a temporary document.
    file_descriptor, file_path = tempfile.mkstemp(prefix="nekoedit-file-")
    try:
        with os.fdopen(file_descriptor, "wb") as initial_document:
            initial_document.write(b"I")
        run(sys.argv[1], initial_file=file_path, save_roundtrip=True)
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

    # Full File menu, Open, Save, and Save As interaction tests on both
    # supported connection transports. The subprocess CWD is the fixture dir.
    run(sys.argv[1], file_workflow=True)
    run(sys.argv[1], use_wayland_socket=True, file_workflow=True)
