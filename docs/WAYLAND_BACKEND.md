# Wayland backend: first window prototype

## Purpose and current scope

This document describes the first native Wayland slice. It is deliberately not a complete Wayland client implementation. Its only purpose at this milestone is to prove that a freestanding x86-64 assembly program can create and display a software-rendered toplevel without GTK, Qt, libwayland, libc, or another third-party runtime library.

The prototype currently:

- Connects to the socket named by WAYLAND_DISPLAY, defaulting to wayland-0 under XDG_RUNTIME_DIR. An absolute WAYLAND_DISPLAY path is also accepted.
- Discovers and binds wl_compositor, wl_shm, and xdg_wm_base.
- Creates one top-level window with the title “NekoEdit - development window”.
- Allocates an 800×480 XRGB8888 software buffer.
- Passes the backing memfd to the compositor with SCM_RIGHTS.
- Handles the initial xdg configure/acknowledge handshake.
- Answers xdg_wm_base ping requests.
- Exits on xdg_toplevel.close.

It does not yet implement keyboard/pointer input, window resizing, text, fonts, clipboard, frame scheduling, output scale changes, or X11.

## Protocol flow

The implementation sends and receives the Wayland protocol directly over an AF_UNIX/SOCK_STREAM socket. The current binding version is 1 for each interface.

1. Send wl_display.get_registry and wl_display.sync.
2. Process wl_registry.global events and remember the registry names for wl_compositor, wl_shm, and xdg_wm_base.
3. Bind those globals to client object IDs.
4. Send a second wl_display.sync to ensure the bindings have been processed.
5. Create a wl_surface using wl_compositor.
6. Create its xdg_surface role and xdg_toplevel using xdg_wm_base.
7. Set the toplevel title and issue an initial empty wl_surface.commit.
8. Wait for xdg_surface.configure and send xdg_surface.ack_configure with its serial.
9. Call memfd_create, ftruncate, and mmap to create a shared pixel buffer.
10. Send wl_shm.create_pool with the memfd attached as SCM_RIGHTS ancillary data.
11. Create a wl_buffer from the pool, destroy the pool object, attach the buffer, damage the surface, and commit.

The initial surface commit is required to receive the first configure. The buffer is attached only after acknowledging that configure.

## Shared-memory buffer

The prototype uses a single 800×480 buffer with a 3200-byte stride and WL_SHM_FORMAT_XRGB8888. The buffer is drawn entirely by CPU stores:

- Full background: 0xFF252A33.
- Header band: 0xFF343D4B.
- Small accent mark: 0xFF78A9D4.

The memfd is sized before mapping. The request uses sendmsg with a SOL_SOCKET/SCM_RIGHTS control message to transfer the descriptor to the compositor. A static buffer is sufficient for this proof of concept because it is not modified after the initial commit. A real editor renderer must use buffer-release tracking and at least a safe double-buffering strategy before drawing into a buffer again.

## Event handling

The current read loop reads a complete Wayland message header and payload. It answers xdg_wm_base.ping by sending xdg_wm_base.pong with the supplied serial. It exits when the xdg_toplevel.close event arrives.

The current loop is intentionally blocking. Before keyboard input or clipboard transfers are introduced, replace it with a nonblocking poll-based loop that monitors the Wayland socket and pending data-transfer descriptors. All event payloads must be length-checked before parsing; the prototype currently applies a fixed upper bound to event payload size.

## Error behavior

The prototype reports concise errors for a missing XDG_RUNTIME_DIR, an unavailable socket, missing required globals, and protocol/shared-memory setup failure. A display-server disconnection currently terminates the window session. Better error decoding using wl_display.error and protocol-specific diagnostics is a follow-up task.

## Testing

make test-wayland runs tests/wayland_mock.py. The mock compositor exercises the binary protocol exchange and verifies:

- get_registry and sync requests.
- Global discovery and wl_registry.bind serialization.
- Creation of wl_surface, xdg_surface, and xdg_toplevel.
- Window title string encoding.
- xdg_surface.configure acknowledgement.
- memfd size and SCM_RIGHTS descriptor transfer.
- Buffer dimensions, stride, format, and selected pixel colors.
- Surface attach, damage, commit, and compositor close event.

This verifies the client-side wire serialization and basic shared-memory mechanics. It does **not** prove compatibility with every real compositor. Run the binary inside the target GNOME Wayland session as a separate integration test.

## Known limitations and next work

1. Support WAYLAND_SOCKET when a launcher passes an already-connected socket descriptor.
2. Decode wl_display.error and provide useful protocol diagnostics.
3. Handle seat capabilities, keyboard and pointer objects, and focus.
4. Implement keymap translation without libxkbcommon; do not assume physical keycodes equal text characters.
5. Recreate buffers after configure/resize and output scale changes.
6. Replace the blocking loop with poll and nonblocking I/O.
7. Add frame callbacks and buffer-release tracking.
8. Add wl_data_device clipboard support, with immutable copy snapshots independent of the document gap buffer.
9. Connect the backend-neutral renderer and editor event model.
