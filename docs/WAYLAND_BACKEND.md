# Wayland backend: interactive editing prototype

## Purpose and current scope

This document describes the current native Wayland development slice. It is deliberately not a complete Wayland client implementation. The freestanding x86-64 assembly program creates a software-rendered toplevel without GTK, Qt, libwayland, libc, or another third-party runtime library, and now includes a deliberately limited ASCII editing path.

The prototype currently:

- Uses WAYLAND_SOCKET when a launcher supplies an inherited, already-connected socket descriptor. Otherwise connects to WAYLAND_DISPLAY (defaulting to wayland-0 under XDG_RUNTIME_DIR); an absolute WAYLAND_DISPLAY path is also accepted.
- Discovers and binds wl_compositor, wl_shm, and xdg_wm_base; an optional wl_seat is bound after the initial window objects.
- Creates one top-level window with the title “NekoEdit - development window”. The software-rendered UI shows a compact application title bar, an active Untitled document tab, an editor area, and a live status bar with logical line, column, byte count, and ASCII mode.
- Allocates an 800×480 XRGB8888 software buffer.
- Passes the backing memfd to the compositor with SCM_RIGHTS.
- Handles the initial xdg configure/acknowledge handshake.
- Binds wl_seat when advertised, creates wl_pointer and wl_keyboard after the seat reports the corresponding capabilities, and handles pointer enter, leave, motion, and button events plus keyboard focus, key, and modifier events.
- Provides a compact title bar, an Untitled document tab, a document area, and a live status bar. Pointer clicks place the caret at the nearest character insertion boundary. Holding the left button and dragging selects the byte range between the anchor and current caret, including reverse-direction and multi-line drags; the renderer paints selected character cells, tabs, and newline cells. Typing or Backspace/Delete removes the selected range before applying the requested edit. Focused key events use the parsed XKB text-v1 subset for common ASCII symbols and execute basic editing/navigation commands, including Ctrl+A to select the complete document. An unparseable keymap falls back to the built-in US-QWERTY table.
- Uses a fixed 64 KiB byte array and an embedded 5×7 bitmap font. The bounded XKB parser extracts key names, XKB keycodes, common ASCII keysyms, symbols for up to four groups/four levels, and simplified alphabetic/four-level type flags. Translation uses the active Wayland group, Shift/Caps, and physical Right-Alt LevelThree. An unparseable/unsupported keymap falls back to a built-in US-QWERTY table.
- Waits for wl_buffer.release before rewriting and recommitting the single shared buffer.
- Answers xdg_wm_base ping requests.
- Exits on xdg_toplevel.close.

The wl_keyboard.keymap FD is received with recvmsg/SCM_RIGHTS, validated as a bounded NUL-terminated xkb_v1 keymap, and mapped read-only with MAP_PRIVATE. The assembly parser handles compiled keycodes and aliases, common ASCII keysyms, up to four symbol groups and four levels, and simplified `ALPHABETIC`/`FOUR_LEVEL` type families. The current translator applies Shift/Caps to alphabetic keys, uses the active layout group from `wl_keyboard.modifiers`, and treats physical Right Alt as LevelThree. Keymaps outside this subset fall back to the built-in US-QWERTY table. This is not full XKB semantics: arbitrary custom type maps, virtual-modifier resolution, modifier actions, non-ASCII keysyms, keypad behavior, compose/dead keys, and Unicode text input remain unsupported. The editor also lacks IME integration, a gap buffer, keyboard-extended selection, undo/redo, text scrolling, window resizing, installed-font parsing, clipboard, frame scheduling, output scale changes, and X11. The current keyboard path is physical key-event handling, not the separate Wayland text-input protocol used by input methods. Ctrl+A selects the whole document; Control state is tracked from physical left/right Ctrl transitions and the standard XKB Control modifier bit.

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

The current event loop blocks in `poll` until either the Wayland socket or the monotonic repeat timer is readable, then receives a complete Wayland message header and payload with recvmsg, preserving SCM_RIGHTS descriptors attached to stream data. A positional startup path is loaded into the bounded 64 KiB document buffer. The File menu is rendered by the software UI; Open and Save As use a modal in-window ASCII path prompt, with Enter to confirm and Escape to cancel. Ctrl+O, Ctrl+S, and Ctrl+Shift+S invoke the corresponding actions; Ctrl+S routes Untitled to Save As. Paths are passed to `openat(AT_FDCWD,...)`, so relative paths resolve against the process working directory. Open reads into a staging buffer and only commits its contents/path/tab label after a complete read, size check, and successful close. Saves create a unique same-directory temporary path with `O_EXCL`, handle partial writes and `EINTR`, call `fsync` on the temporary file, close it, then use `renameat` to atomically replace the destination. Failed writes unlink the temporary file and leave the previous destination intact. The temporary is currently created with mode 0644, existing permission bits are not copied, and the parent directory is not fsynced after rename. The event loop answers xdg_wm_base.ping, tracks wl_buffer.release, and dispatches wl_pointer enter, leave, motion, and button events plus wl_keyboard enter, leave, key, and modifiers events. Long document lines soft-wrap at the available 97-cell width; tabs that would cross the edge move intact to the next visual row. The active caret automatically scrolls vertically into the 30-row document viewport as it moves down. The same visual-row mapping is used for caret rendering, vertical navigation, Home/End, selection highlighting, and mouse hit testing. Clicking inside the document area converts surface-local pointer coordinates into a line and visual column, then places the byte cursor at the nearest character insertion boundary (including tab spans and avoiding UTF-8 continuation-byte boundaries). The footer derives the logical one-based line and column from the cursor byte offset, advances tabs to four-column stops, and displays the document byte count and current ASCII-only mode. A left-button press records a selection anchor; pointer motion while the button is held updates the caret and selection range, and button release ends the drag. Selected character cells and tabs receive a highlight, and a selected newline receives an end-of-line highlight. Typing or Backspace/Delete first removes the selected byte range; unshifted Left/Right collapse an active range to its corresponding edge, while Shift+Left/Right and Shift+Up/Down/Home/End extend the range from a stable anchor. Other unshifted navigation clears the highlight before moving. When the surface has keyboard focus, supported key presses are translated through a built-in US-QWERTY evdev table and applied to the document. The supported commands are text insertion, Backspace, Delete, Enter, four-space Tab, Left/Right/Up/Down, Home, and End. The renderer repaints the document, selection, and caret after the buffer is released. Selection highlight rectangles currently use the fixed 8×12 cell grid, so their visual edges are approximate rather than glyph- or font-metric-aligned. The viewport currently provides automatic vertical caret-follow scrolling; horizontal scrolling and a fuller set of viewport controls are still future work. A monotonic timerfd implements key repetition for ordinary non-modifier/non-lock keys, including printable input, Enter, Tab, navigation, Backspace, and Delete. When the advertised `wl_seat` version is at least 4, NekoEdit binds that version and consumes `wl_keyboard.repeat_info` (rate in repeats per second and initial delay in milliseconds). A zero rate disables client-side repeat; later settings changes reconfigure an active repeat timer. Older seat versions retain a 300 ms / 30 Hz fallback. Key release or keyboard-focus loss cancels the active repeat. The event reader uses recvmsg for Wayland socket bytes so SCM_RIGHTS descriptors are not discarded. A wl_keyboard.keymap event's xkb_v1 FD is size-bounded, checked for its XKB text signature and terminating NUL, and mapped read-only with MAP_PRIVATE; the FD is closed after mapping. The mapping is retained for the upcoming parser, but keysyms, layout groups, and modifier levels are not interpreted, so text translation still uses the built-in US-QWERTY fallback. The seat is bound at the lower of the advertised version and version 4 so the client can receive the repeat-info event without requesting unsupported protocol features. Pointer coordinates are fixed-point surface-local values; they are converted from 24.8 fixed point before hit testing. The process exits when xdg_toplevel.close arrives.

The current loop is intentionally blocking. Before keyboard input or clipboard transfers are introduced, replace it with a nonblocking poll-based loop that monitors the Wayland socket and pending data-transfer descriptors. All event payloads must be length-checked before parsing; the prototype currently applies a fixed upper bound to event payload size.

## Error behavior

The prototype reports concise errors for a missing XDG_RUNTIME_DIR, an unavailable socket, missing required globals, and protocol/shared-memory setup failure. File-operation failures are shown as OPEN ERR or SAVE ERR in the application header while the path prompt remains available for correction or cancellation. A failed Open, including a file larger than 64 KiB, does not replace the active document or its path. A failed atomic save does not truncate the old destination. A wl_display.error event is fatal; its length-prefixed message is printed only after validating the event bounds and NUL terminator. A display-server disconnection terminates the window session.

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
- File menu drawing and pointer hit-testing for Open, Save, and Save As.
- Modal path entry, character input, Backspace, Enter, Escape, and keyboard focus isolation from document editing.
- In-window Open/Save As workflows with relative/absolute paths, named-file saving, Untitled-to-Save-As routing, and destination/tab updates only after successful operations.
- Open staging, missing-file and >64 KiB rejection without destroying the active document, plus atomic same-directory temporary-file save and rename.
- Pointer object creation, pointer focus, and left-click hit testing.
- Keyboard object creation, focus handling, physical key events, and Wayland modifier-mask synchronization.
- A synthetic wl_keyboard.keymap event carrying an XKB_V1 memfd over SCM_RIGHTS; the test checks that the client retains it as a read-only MAP_PRIVATE mapping after the sender closes its descriptor.
- Parser-table inspection in the child process: XKB keycode 24 is resolved to `<AD01>`, the expected alphabetic/LevelThree type flags and Group1/Group2 ASCII symbol levels are populated, and integration input verifies XKB's +8 keycode offset, group switching, Shift, Right-Alt LevelThree, and saved output bytes.
- US-QWERTY text insertion, cursor movement, Backspace, Enter, Shift+1, and pixel checks for the rendered glyphs and caret.
- Pointer-motion/button sequences that place the caret after first-line text, at the start of the second line, and between two characters on that line.
- Reverse-direction and multi-line pointer drag selection with highlight-pixel checks, including selected newline cells, and typing to replace selected text.
- Shift+Left/Right and Shift+Up/Down/Home/End selection extension, returning to the anchor, and unshifted arrow collapse behavior.
- Ctrl+A whole-document selection, including the visible portion after vertical scrolling.
- Long-line soft wrapping, pointer placement on wrapped rows, and vertical caret-follow scrolling past the window's bottom edge.
- Timed key repeat for printable keys, Enter, Tab, Left/Right/Up/Down, Home/End, Backspace, and Delete, including compositor-provided delay/rate and the legacy fallback.
- Buffer release before each edit redraw, ensuring the single shared-memory buffer is not modified while the compositor owns it.

This verifies the client-side wire serialization and basic shared-memory mechanics. It does **not** prove compatibility with every real compositor. Run the binary inside the target GNOME Wayland session as a separate integration test.

## Known limitations and next work

1. Extend the current XKB subset toward full XKB behavior: interpret custom type maps and modifier indices/virtual modifiers, actions, keypad symbols, and broader keysym values; add non-ASCII/Unicode text input and compose/dead-key handling.
2. Implement Unicode input and UTF-8-aware document operations with a gap buffer, selection-aware editing, undo, and redo.
3. Add Wayland text-input integration for IME preedit/commit and dead-key composition.
4. Add the system-font parser, glyph rasterizer, and text layout pipeline.
5. Add horizontal scrolling and viewport controls, then recreate buffers after configure/resize and output scale changes; use a small release-tracked buffer set.
6. Replace the blocking loop with poll and nonblocking I/O.
7. Add wl_data_device clipboard support, with immutable copy snapshots independent of the document gap buffer.
8. Add Ctrl+C/X/V clipboard integration and Ctrl+Z/Y undo/redo; Ctrl+O, Ctrl+S, and Ctrl+Shift+S now route to the initial file-management workflow.
9. Connect the backend-neutral renderer and editor event model.
