# Wayland backend: interactive editing prototype

## Purpose and current scope

This document describes the current native Wayland development slice. It is deliberately not a complete Wayland client implementation. The freestanding x86-64 assembly program creates a software-rendered toplevel without GTK, Qt, libwayland, libc, or another third-party runtime library, and now includes a deliberately limited ASCII editing path.

The prototype currently:

- Uses WAYLAND_SOCKET when a launcher supplies an inherited, already-connected socket descriptor. Otherwise connects to WAYLAND_DISPLAY (defaulting to wayland-0 under XDG_RUNTIME_DIR); an absolute WAYLAND_DISPLAY path is also accepted.
- Discovers and binds wl_compositor, wl_shm, and xdg_wm_base; an optional wl_seat is bound after the initial window objects.
- Creates one top-level window with the title “NekoEdit - development window”.
- Allocates an 800×480 XRGB8888 software buffer.
- Passes the backing memfd to the compositor with SCM_RIGHTS.
- Handles the initial xdg configure/acknowledge handshake.
- Binds wl_seat when advertised, creates wl_pointer and wl_keyboard after the seat reports the corresponding capabilities, and handles pointer enter, leave, motion, and button events plus keyboard focus, key, and modifier events.
- Provides three clickable palette swatches and a document area. Pointer clicks select a swatch or place the caret at the nearest character insertion boundary. Holding the left button and dragging selects the byte range between the anchor and current caret, including reverse-direction and multi-line drags; the renderer paints selected character cells, tabs, and newline cells. Typing or Backspace/Delete removes the selected range before applying the requested edit. Focused key events otherwise insert US-QWERTY ASCII characters and execute basic editing/navigation commands.
- Uses a fixed 64 KiB byte array, a built-in US-QWERTY evdev lookup table, and an embedded 5×7 bitmap font. Shift and Caps state are synchronized from Wayland modifier events, with physical Shift/Caps key transitions as fallback.
- Waits for wl_buffer.release before rewriting and recommitting the single shared buffer.
- Answers xdg_wm_base ping requests.
- Exits on xdg_toplevel.close.

It does not yet parse the wl_keyboard.keymap FD, so the built-in US-QWERTY mapping is not adapted to the user's configured layout. It also lacks Unicode input/rendering, IME/dead-key composition, a gap buffer, keyboard-extended selection, undo/redo, text scrolling, window resizing, installed-font parsing, clipboard, frame scheduling, output scale changes, and X11. The current keyboard path is physical key-event handling, not the separate Wayland text-input protocol used by input methods.

## Protocol flow

The implementation sends and receives the Wayland protocol directly over an AF_UNIX/SOCK_STREAM socket. The current binding version is 1 for each interface.

1. Resolve the connection: use the decimal file descriptor in WAYLAND_SOCKET when present; otherwise create and connect an AF_UNIX socket using WAYLAND_DISPLAY and XDG_RUNTIME_DIR.
2. Send wl_display.get_registry and wl_display.sync.
2. Process wl_registry.global events and remember the registry names for wl_compositor, wl_shm, and xdg_wm_base.
3. Bind those globals to client object IDs 4, 5, and 6.
4. Allocate subsequent client object IDs densely: the second sync callback is ID 7, wl_surface 8, xdg_surface 9, xdg_toplevel 10, wl_shm_pool 11, and wl_buffer 12. If wl_seat is advertised, it is bound as object 13, a sync callback uses object 14, and wl_pointer is object 15 when pointer capability is present. Skipped IDs are a protocol error on strict compositors.
5. Send a second wl_display.sync to ensure the bindings have been processed.
6. Create a wl_surface using wl_compositor.
7. Create its xdg_surface role and xdg_toplevel using xdg_wm_base.
8. Set the toplevel title and issue an initial empty wl_surface.commit.
9. Wait for xdg_surface.configure and send xdg_surface.ack_configure with its serial.
10. Call memfd_create, ftruncate, and mmap to create a shared pixel buffer.
11. Send wl_shm.create_pool with the memfd attached as SCM_RIGHTS ancillary data.
12. Create a wl_buffer from the pool, destroy the pool object, attach the buffer, damage the surface, and commit.

The initial surface commit is required to receive the first configure. The buffer is attached only after acknowledging that configure.

## Shared-memory buffer

The prototype uses a single 800×480 buffer with a 3200-byte stride and WL_SHM_FORMAT_XRGB8888. The buffer is drawn entirely by CPU stores:

- Full background: 0xFF252A33.
- Header band: 0xFF343D4B.
- Small accent mark: 0xFF78A9D4.

The memfd is sized before mapping. The request uses sendmsg with a SOL_SOCKET/SCM_RIGHTS control message to transfer the descriptor to the compositor. The current prototype reuses one buffer and waits for wl_buffer.release before modifying its pixels; a production editor renderer should move to a small release-tracked buffer set to avoid stalls under frequent redraws.

## Event handling

The current blocking read loop reads a complete Wayland message header and payload. It answers xdg_wm_base.ping, tracks wl_buffer.release, and dispatches wl_pointer enter, leave, motion, and button events plus wl_keyboard enter, leave, key, and modifiers events. Left-clicking a palette swatch changes its selected border. Clicking inside the document area converts surface-local pointer coordinates into a line and visual column, then places the byte cursor at the nearest character insertion boundary (including tab spans and avoiding UTF-8 continuation-byte boundaries). A left-button press records a selection anchor; pointer motion while the button is held updates the caret and selection range, and button release ends the drag. Selected character cells and tabs receive a highlight, and a selected newline receives an end-of-line highlight. Typing or Backspace/Delete first removes the selected byte range; Left/Right collapse an active range to its start/end, while other navigation clears the highlight before moving. When the surface has keyboard focus, supported key presses are translated through a built-in US-QWERTY evdev table and applied to the document. The supported commands are text insertion, Backspace, Delete, Enter, four-space Tab, Left/Right/Up/Down, Home, and End. The renderer repaints the document, selection, and caret after the buffer is released. The XKB keymap FD and repeat-info are not parsed, so the application does not follow the compositor's selected keyboard layout. Pointer coordinates are fixed-point surface-local values; they are converted from 24.8 fixed point before hit testing. The process exits when xdg_toplevel.close arrives.

The current loop is intentionally blocking. Before keyboard input or clipboard transfers are introduced, replace it with a nonblocking poll-based loop that monitors the Wayland socket and pending data-transfer descriptors. All event payloads must be length-checked before parsing; the prototype currently applies a fixed upper bound to event payload size.

## Error behavior

The prototype reports concise errors for a missing XDG_RUNTIME_DIR, an unavailable socket, missing required globals, and protocol/shared-memory setup failure. A wl_display.error event is fatal; its length-prefixed message is printed only after validating the event bounds and NUL terminator. A display-server disconnection terminates the window session.

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
- Optional seat binding and pointer/keyboard capability handling with dense client object IDs.
- Pointer object creation, pointer focus, and left-click hit testing.
- Keyboard object creation, focus handling, physical key events, and Wayland modifier-mask synchronization. The fixture sends a synthetic keymap event, but the implementation does not parse its payload or consume it as an XKB mapping.
- US-QWERTY text insertion, cursor movement, Backspace, Enter, Shift+1, and pixel checks for the rendered glyphs and caret.
- Pointer-motion/button sequences that place the caret after first-line text, at the start of the second line, and between two characters on that line.
- Reverse-direction pointer drag selection with highlight-pixel checks and typing to replace the selected text.
- Buffer release before each edit redraw, ensuring the single shared-memory buffer is not modified while the compositor owns it.

This verifies the client-side wire serialization and basic shared-memory mechanics. It does **not** prove compatibility with every real compositor. Run the binary inside the target GNOME Wayland session as a separate integration test.

## Known limitations and next work

1. Receive and parse the compositor's XKB keymap FD; map keycodes to keysyms according to the active layout and support the relevant modifier levels without libxkbcommon.
2. Implement Unicode input and UTF-8-aware document operations with a gap buffer, keyboard-extended selection, undo, and redo.
3. Add Wayland text-input integration for IME preedit/commit and dead-key composition.
4. Add the system-font parser, glyph rasterizer, and text layout pipeline.
5. Add document scrolling and recreate buffers after configure/resize and output scale changes; use a small release-tracked buffer set.
6. Replace the blocking loop with poll and nonblocking I/O.
7. Add wl_data_device clipboard support, with immutable copy snapshots independent of the document gap buffer.
8. Connect the backend-neutral renderer and editor event model.
