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
    advertised_seat_version: int = 7,
    initial_file: str | None = None,
    save_roundtrip: bool = False,
    file_workflow: bool = False,
    keyboard_layout_test: bool = False,
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
        with open(os.path.join(runtime_dir, "relative-open.txt"), "wb") as document:
            document.write(b"I")
        with open(os.path.join(runtime_dir, "oversized.txt"), "wb") as document:
            document.write(b"x" * 65537)

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
            title = recv_wayland_message(client)
            if title[0:2] != (10, 2) or title[3]:
                raise AssertionError(f"unexpected set_title request: {title!r}")
            title_len = struct.unpack_from("<I", title[2])[0]
            if title[2][4 : 4 + title_len] != b"NekoEdit - development window\0":
                raise AssertionError("window title was not serialized as a Wayland string")
            expect_message(client, (8, 6, b""), "initial surface commit")

            client.sendall(wire_message(9, 0, struct.pack("<I", 1234)))
            expect_message(client, (9, 4, struct.pack("<I", 1234)), "ack_configure")

            pool = recv_wayland_message(client)
            if pool[0:2] != (5, 0) or len(pool[3]) != 1:
                raise AssertionError(f"wl_shm.create_pool did not transfer exactly one fd: {pool!r}")
            pool_id, buffer_size = struct.unpack("<II", pool[2])
            expected_size = 800 * 480 * 4
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
                expect_message(client, (11, 1, b""), "destroy shm pool")
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
                    + wire_message(15, 0, struct.pack("<IIii", 777, 8, 98 * 256, 110 * 256))
                    + wire_message(15, 3, struct.pack("<IIII", 778, 1000, 0x110, 1))
                )
                expect_message(client, (8, 1, struct.pack("<III", 12, 0, 0)), "redraw attach")
                expect_message(client, (8, 2, struct.pack("<4I", 0, 0, 800, 480)), "redraw damage")
                expect_message(client, (8, 6, b""), "redraw commit")
                clicked_caret_x = 24 if initial_file is not None else 16
                if struct.unpack_from("<I", pixels, 92 * 800 * 4 + clicked_caret_x * 4)[0] != 0xFFFFFFFF:
                    raise AssertionError("document click did not keep the caret visible after clamping to the document")
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
    <AD01> = 24;
    <AC02> = 39;
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
        type = "ALPHABETIC",
        symbols[Group1] = [ a, A ],
        symbols[Group2] = [ q, Q ]
    };
    key <AE01> {
        type = "FOUR_LEVEL",
        symbols[Group1] = [ ampersand, 1, numbersign, exclam ]
    };
    key <AC02> {
        type = "ALPHABETIC",
        symbols[Group1] = [ s, S ]
    };
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
                    key_step(1006, 2, "XKB FOUR_LEVEL LevelThree symbol")
                    client.sendall(
                        wire_message(16, 3, struct.pack("<IIII", 1007, 1007, 100, 0))
                        + wire_message(12, 0)
                    )
                    workflow_shortcut(1010, 31, "Ctrl+S saves XKB-translated text")
                    client.sendall(wire_message(10, 1))
                    observations.append(
                        "XKB keycode +8 lookup, Group1/Group2 selection, alphabetic Shift level, and Right-Alt LevelThree symbol translation verified"
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
                    # The File control must be visible even when the process
                    # starts with --backend=wayland and no document path.
                    file_pixels = [
                        struct.unpack_from("<I", pixels, y * 800 * 4 + x * 4)[0]
                        for y in range(12, 20) for x in range(112, 144)
                    ]
                    if 0xFFD8DEE9 not in file_pixels:
                        raise AssertionError("the File menu control was not rendered in the header")
                    observations.append("visible File menu header control")

                    # Ctrl+S on Untitled opens Save As. Correct a mistyped final
                    # character with Backspace, then confirm a relative path.
                    key_step(2000, evdev["h"], "type first Untitled character")
                    key_step(2002, evdev["i"], "type second Untitled character")
                    workflow_shortcut(2010, 31, "Ctrl+S opens Save As for Untitled")
                    if struct.unpack_from("<I", pixels, 184 * 800 * 4 + 48 * 4)[0] != 0xFF1F242D:
                        raise AssertionError("Untitled Ctrl+S did not render the Save As path prompt")
                    if struct.unpack_from("<I", pixels, 204 * 800 * 4 + 72 * 4)[0] != 0xFF252A33:
                        raise AssertionError("Save As path-entry field was not rendered")
                    serial = workflow_type_path("created.txz", 2020)
                    key_step(serial, 14, "path prompt Backspace")
                    key_step(serial + 2, evdev["t"], "correct Save As path")
                    key_step(serial + 4, 28, "confirm Untitled Save As")
                    with open(os.path.join(runtime_dir, "created.txt"), "rb") as saved:
                        if saved.read() != b"hi":
                            raise AssertionError("Ctrl+S on Untitled did not create the selected file")
                    observations.append("Ctrl+S on Untitled opened Save As; relative path and Backspace worked")

                    # The now-named document saves in place with Ctrl+S.
                    key_step(serial + 6, evdev["c"], "edit named document")
                    workflow_shortcut(serial + 8, 31, "Ctrl+S saves named document")
                    with open(os.path.join(runtime_dir, "created.txt"), "rb") as saved:
                        if saved.read() != b"hic":
                            raise AssertionError("Ctrl+S did not update the active named file")

                    # Open is available from the pointer-operated File menu.
                    workflow_click(120, 12, 2100, "open File menu")
                    if struct.unpack_from("<I", pixels, 35 * 800 * 4 + 108 * 4)[0] != 0xFF1F242D:
                        raise AssertionError("File dropdown background was not rendered")
                    workflow_click(120, 44, 2110, "select File > Open")
                    if struct.unpack_from("<I", pixels, 184 * 800 * 4 + 48 * 4)[0] != 0xFF1F242D:
                        raise AssertionError("File > Open did not render its path prompt")
                    serial = workflow_type_path("relative-open.txz", 2120)
                    key_step(serial, 14, "Open path Backspace")
                    key_step(serial + 2, evdev["t"], "correct Open path")
                    key_step(serial + 4, 28, "confirm Open")
                    if struct.unpack_from("<I", pixels, 92 * 800 * 4 + 17 * 4)[0] != 0xFFD8DEE9:
                        raise AssertionError("Open did not render the selected file's first character")
                    observations.append("File > Open loaded a real relative-path document without restarting")

                    # Replace the opened one-character document and save it.
                    workflow_shortcut(serial + 6, 30, "Ctrl+A before named-file edit")
                    key_step(serial + 14, evdev["z"], "replace opened document")
                    workflow_shortcut(serial + 16, 31, "Ctrl+S after Open")
                    with open(os.path.join(runtime_dir, "relative-open.txt"), "rb") as saved:
                        if saved.read() != b"z":
                            raise AssertionError("Ctrl+S after Open did not target the opened file")

                    # Exercise Save from the clickable menu as well.
                    key_step(serial + 22, evdev["a"], "append before menu Save")
                    workflow_click(120, 12, 2200, "reopen File menu")
                    workflow_click(120, 68, 2210, "select File > Save")
                    with open(os.path.join(runtime_dir, "relative-open.txt"), "rb") as saved:
                        if saved.read() != b"za":
                            raise AssertionError("File > Save did not write the active document")

                    # Menu Save As changes the active path only after success.
                    workflow_click(120, 12, 2220, "open File menu for Save As")
                    workflow_click(120, 92, 2230, "select File > Save As")
                    serial = workflow_type_path("menu-saveas.txt", serial + 30)
                    key_step(serial, 28, "confirm menu Save As")
                    key_step(serial + 2, evdev["b"], "edit after menu Save As")
                    workflow_shortcut(serial + 4, 31, "Ctrl+S after menu Save As")
                    with open(os.path.join(runtime_dir, "menu-saveas.txt"), "rb") as saved:
                        if saved.read() != b"zab":
                            raise AssertionError("menu Save As did not change the active destination")

                    # Ctrl+Shift+S accepts an absolute path.
                    absolute_path = absolute_file_path
                    workflow_shortcut(serial + 10, 31, "Ctrl+Shift+S opens Save As", shift=True)
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
                    # A failed Save As must leave the previously active path
                    # intact, so a subsequent Ctrl+S still writes that path.
                    workflow_shortcut(serial + 10, 31, "Ctrl+Shift+S before failed Save As", shift=True)
                    serial = workflow_type_path("/no-such-nekoedit-directory/save.txt", serial + 20)
                    key_step(serial, 28, "confirm failed Save As")
                    key_step(serial + 2, 1, "Escape failed Save As prompt")
                    key_step(serial + 4, evdev["d"], "edit after failed Save As")
                    workflow_shortcut(serial + 6, 31, "save to prior path after failed Save As")
                    with open(absolute_path, "rb") as saved:
                        if saved.read() != b"zabcd":
                            raise AssertionError("failed Save As changed the active document path")
                    if os.path.exists("/no-such-nekoedit-directory/save.txt"):
                        raise AssertionError("failed Save As unexpectedly created its destination")
                    observations.append("File > Save, File > Save As, Ctrl+Shift+S, absolute paths, and failed Save As rollback verified")

                    # A failed Open and an over-limit Open must leave the active
                    # bytes/path untouched; Escape dismisses either prompt.
                    workflow_shortcut(serial + 10, 24, "Ctrl+O opens path prompt")
                    serial = workflow_type_path("missing-file.txt", serial + 20)
                    key_step(serial, 28, "confirm missing-file Open")
                    key_step(serial + 2, 1, "Escape failed Open prompt")
                    key_step(serial + 4, evdev["e"], "edit after failed Open")
                    workflow_shortcut(serial + 6, 31, "save after failed Open")
                    with open(absolute_path, "rb") as saved:
                        if saved.read() != b"zabcde":
                            raise AssertionError("failed Open changed the active document or its save path")

                    workflow_shortcut(serial + 12, 24, "Ctrl+O before oversized file")
                    serial = workflow_type_path("oversized.txt", serial + 22)
                    key_step(serial, 28, "reject file larger than 64 KiB")
                    key_step(serial + 2, 1, "Escape oversized Open prompt")
                    key_step(serial + 4, evdev["f"], "edit after oversized Open")
                    workflow_shortcut(serial + 6, 31, "save after oversized Open")
                    with open(absolute_path, "rb") as saved:
                        if saved.read() != b"zabcdef":
                            raise AssertionError("oversized Open damaged the active document")

                    # Cancel Save As after entering a path; the active destination
                    # must remain the absolute path from the prior successful save.
                    workflow_shortcut(serial + 12, 31, "Ctrl+Shift+S before cancellation", shift=True)
                    serial = workflow_type_path("cancelled.txt", serial + 22)
                    key_step(serial, 1, "Escape cancels Save As")
                    key_step(serial + 2, evdev["g"], "edit after cancelling Save As")
                    workflow_shortcut(serial + 4, 31, "save after cancelled Save As")
                    with open(absolute_path, "rb") as saved:
                        if saved.read() != b"zabcdefg":
                            raise AssertionError("cancelled Save As changed the active destination")
                    if os.path.exists(os.path.join(runtime_dir, "cancelled.txt")):
                        raise AssertionError("Escape unexpectedly created the cancelled Save As path")
                    observations.append("failed/oversized Open preservation and Escape cancellation verified")

                    client.sendall(wire_message(10, 1))
                    return

                if save_roundtrip:
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
        timeout_seconds = 50 if file_workflow else 10
        try:
            stdout, stderr_bytes = process.communicate(timeout=timeout_seconds)
        except subprocess.TimeoutExpired:
            process.kill()
            stdout, stderr_bytes = process.communicate()
            raise AssertionError(
                f"NekoEdit exceeded the {timeout_seconds}s Wayland test timeout; "
                f"stderr={stderr_bytes.decode(errors='replace')!r}"
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
    if errors:
        raise AssertionError("mock compositor failed:\n" + "\n".join(errors))
    stderr = result.stderr.decode(errors="replace")
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
            expected_saved_bytes=b"IaAq#",
            keyboard_layout_test=True,
        )
    finally:
        try:
            os.unlink(xkb_path)
        except FileNotFoundError:
            pass
    # Full File menu, Open, Save, and Save As interaction tests on both
    # supported connection transports. The subprocess CWD is the fixture dir.
    run(sys.argv[1], file_workflow=True)
    run(sys.argv[1], use_wayland_socket=True, file_workflow=True)
