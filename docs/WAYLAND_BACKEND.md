# Wayland backend: interactive editing prototype

## Purpose and current scope

This document describes the current native Wayland development slice. It is deliberately not a complete Wayland client implementation. The freestanding x86-64 assembly program creates a software-rendered toplevel without GTK, Qt, libwayland, libc, or another third-party runtime library, and now includes ASCII text entry plus code-point-safe editing of valid UTF-8 documents.

The prototype currently:

- Uses WAYLAND_SOCKET when a launcher supplies an inherited, already-connected socket descriptor. Otherwise connects to WAYLAND_DISPLAY (defaulting to wayland-0 under XDG_RUNTIME_DIR); an absolute WAYLAND_DISPLAY path is also accepted.
- Discovers and binds wl_compositor, wl_shm, and xdg_wm_base; an optional wl_seat is bound after the initial window objects.
- Creates one top-level window with the title “NekoEdit - development window”. The software-rendered UI shows a compact application title bar, app-drawn Minimize, Maximize/Restore, and Close controls, an active document tab, an editor area, and a live status bar.
- Starts at 800×480 and advertises a 480×360 minimum and 3840×2160 maximum geometry through `xdg_toplevel.set_min_size`/`set_max_size`. Positive compositor configure dimensions are used exactly within that shared-memory limit rather than silently clamped; rectangle and glyph writes are clipped to the active surface.
- Passes the backing memfd to the compositor with SCM_RIGHTS.
- Handles the initial xdg configure/acknowledge handshake.
- Binds wl_seat when advertised, creates wl_pointer and wl_keyboard after the seat reports the corresponding capabilities, and handles pointer enter, leave, motion, and button events plus keyboard focus, key, and modifier events. Button serials are retained for compositor-mediated interactive window move/resize requests.
- Provides a compact title bar, an Untitled document tab, a document area, and a live status bar. Pointer clicks place the caret at the nearest character insertion boundary. Holding the left button and dragging selects the byte range between the anchor and current caret, including reverse-direction and multi-line drags; the renderer paints selected character cells, tabs, and newline cells. Typing or Backspace/Delete removes the selected range before applying the requested edit. Cursor movement, pointer hit-testing, selection, Backspace, and Delete respect valid UTF-8 code-point boundaries; malformed bytes are treated as individual editable units. Focused key events use the parsed XKB text-v1 subset for common ASCII symbols and execute basic editing/navigation commands, including Ctrl+A to select the complete document. An unparseable keymap falls back to the built-in US-QWERTY table.
- Uses a fixed 64 KiB byte array and an embedded 5×7 bitmap font covering all printable 7-bit ASCII characters (space through tilde). Each valid non-ASCII code point and each malformed byte currently renders as one `?` placeholder; Unicode glyph lookup is not implemented. The bounded XKB parser extracts key names, XKB keycodes, common ASCII keysyms, symbols for up to four groups/four levels, and simplified alphabetic/four-level type flags. Translation uses the active Wayland group, Shift/Caps, and physical Right-Alt LevelThree. An unparseable/unsupported keymap falls back to a built-in US-QWERTY table.
- Waits for `wl_buffer.release` before rewriting or destroying the active buffer. Resizing acknowledges the xdg surface configure, destroys the released old `wl_buffer`, creates a replacement from the retained `wl_shm_pool`, then attaches and commits it with the new dimensions/stride.
- Sends `xdg_toplevel.move` from blank title-bar drags and `xdg_toplevel.resize` from a 12-pixel edge/corner hit region, using the serial from the initiating `wl_pointer.button` press.
- Maximize/Restore/Minimize requests return to the event loop without a stale-size surface commit. The next frame follows the compositor's toplevel/surface configure and `ack_configure` sequence; if the old buffer is still busy, replacement waits for `wl_buffer.release`.
- Answers xdg_wm_base ping requests.
- Exits on xdg_toplevel.close.

The wl_keyboard.keymap FD is received with recvmsg/SCM_RIGHTS, validated as a bounded NUL-terminated xkb_v1 keymap, and mapped read-only with MAP_PRIVATE. The assembly parser handles compiled keycodes and aliases, common ASCII keysyms, up to four symbol groups and four levels, and common `ONE_LEVEL`, `ALPHABETIC`, `THREE_LEVEL`, and `FOUR_LEVEL` type families. `ONE_LEVEL` keys remain on their sole symbol even while modifiers are active. The current translator applies Shift/Caps to alphabetic keys, uses the active layout group from `wl_keyboard.modifiers`, and treats physical Right Alt as LevelThree. Keymaps outside this subset fall back to the built-in US-QWERTY table. This is not full XKB semantics: arbitrary custom type maps, virtual-modifier resolution, modifier actions, non-ASCII keysyms, keypad behavior, compose/dead keys, and Unicode text input remain unsupported. The document cursor and selection now use validated UTF-8 code-point boundaries, while malformed bytes remain independently editable. Grapheme clusters are not grouped, and the gap buffer is still a fixed 64 KiB document allocation. The editor also lacks IME integration, undo/redo, horizontal scrolling, installed-font parsing, clipboard, frame callbacks, output-scale handling, fractional scaling, and X11. The Wayland window starts at 800×480, advertises its 480×360–3840×2160 supported geometry, and applies positive compositor configure dimensions exactly within the backing-store limit; it draws its own Minimize, Maximize/Restore, and Close controls. The current renderer uses one active shared-memory buffer, with release-gated replacement on resize rather than a multi-buffer swap chain. The current keyboard path is physical key-event handling, not the separate Wayland text-input protocol used by input methods. Ctrl+A selects the whole document; Control state is tracked from physical left/right Ctrl transitions and the standard XKB Control modifier bit.

## Protocol flow

The implementation sends and receives the Wayland protocol directly over an AF_UNIX/SOCK_STREAM socket. The current binding version is 1 for each interface.

1. Resolve the connection: use the decimal file descriptor in WAYLAND_SOCKET when present; otherwise create and connect an AF_UNIX socket using WAYLAND_DISPLAY and XDG_RUNTIME_DIR.
2. Send wl_display.get_registry and wl_display.sync.
2. Process wl_registry.global events and remember the registry names for wl_compositor, wl_shm, and xdg_wm_base.
3. Bind those globals to client object IDs 4, 5, and 6.
4. Allocate subsequent client object IDs densely: the second sync callback is ID 7, wl_surface 8, xdg_surface 9, xdg_toplevel 10, and wl_shm_pool 11. The initial `wl_buffer` is ID 12; resize-created buffers receive monotonically increasing IDs beginning at 256. If `wl_seat` is advertised, it is bound as object 13, a sync callback uses object 14, and `wl_pointer` is object 15 when pointer capability is present. Skipped IDs are a protocol error on strict compositors.
5. Send a second wl_display.sync to ensure the bindings have been processed.
6. Create a wl_surface using wl_compositor.
7. Create its xdg_surface role and xdg_toplevel using xdg_wm_base; advertise the minimum and maximum supported window geometry with xdg_toplevel.set_min_size/set_max_size.
8. Set the toplevel title and issue an initial empty wl_surface.commit.
9. Wait for xdg_surface.configure and send xdg_surface.ack_configure with its serial.
10. Call memfd_create, ftruncate, and mmap to create a shared pixel buffer.
11. Send wl_shm.create_pool with the memfd attached as SCM_RIGHTS ancillary data.
12. Create the initial wl_buffer from the pool, attach it, damage the surface, and commit. Keep the wl_shm_pool alive: later configure events can allocate size-specific buffers from the same bounded mapping.

The initial surface commit is required to receive the first configure. The buffer is attached only after acknowledging that configure.

## Shared-memory buffer

The initial surface is 800×480 with a 3200-byte stride and WL_SHM_FORMAT_XRGB8888. The memfd mapping is reserved for the maximum 3840×2160 surface (four bytes per pixel); each created wl_buffer uses the active width, height, and stride. The buffer is drawn entirely by CPU stores:

- Full background: 0xFF252A33.
- Header band: 0xFF343D4B.
- Small accent mark: 0xFF78A9D4.

The memfd is sized before mapping. The request uses sendmsg with a SOL_SOCKET/SCM_RIGHTS control message to transfer the descriptor to the compositor. The renderer currently has one active wl_buffer and waits for its release before repainting. On resize, it destroys the released buffer and creates a replacement from the still-live wl_shm_pool; it never writes to storage while the compositor owns the frame. This is safe but can stall frequent redraws. A small release-tracked multi-buffer set is still future work.

## Event handling

The current event loop blocks in `poll` until either the Wayland socket or the monotonic repeat timer is readable, then receives a complete Wayland message header and payload with recvmsg, preserving SCM_RIGHTS descriptors attached to stream data. A positional startup path is loaded into the bounded 64 KiB document buffer. The File menu is rendered by the software UI; Open and Save As use a modal in-window ASCII path prompt, with Enter to confirm and Escape to cancel. Ctrl+O, Ctrl+S, and Ctrl+Shift+S invoke the corresponding actions; Ctrl+S routes Untitled to Save As. Paths are passed to `openat(AT_FDCWD,...)`, so relative paths resolve against the process working directory. Open reads into a staging buffer and only commits its contents/path/tab label after a complete read, size check, and successful close. Saves create a unique same-directory temporary path with `O_EXCL`, handle partial writes and `EINTR`, call `fsync` on the temporary file, close it, then use `renameat` to atomically replace the destination. Failed writes unlink the temporary file and leave the previous destination intact. The temporary is currently created with mode 0644, existing permission bits are not copied, and the parent directory is not fsynced after rename. The event loop answers xdg_wm_base.ping, tracks wl_buffer.release, and dispatches wl_pointer enter, leave, motion, and button events plus wl_keyboard enter, leave, key, and modifiers events. Long document lines soft-wrap at the available 97-cell width; tabs that would cross the edge move intact to the next visual row. The active caret automatically scrolls vertically into the 30-row document viewport as it moves down. The same visual-row mapping is used for caret rendering, vertical navigation, Home/End, selection highlighting, and mouse hit testing. Clicking inside the document area converts surface-local pointer coordinates into a line and visual column, then places the byte cursor at the nearest character insertion boundary (including tab spans and stopping only at valid UTF-8 code-point boundaries (malformed bytes remain individually addressable)). The footer derives the logical one-based line and column from the cursor byte offset, advances tabs to four-column stops, and displays the document byte count and current ASCII-only mode. A left-button press records a selection anchor; pointer motion while the button is held updates the caret and selection range, and button release ends the drag. Selected character cells and tabs receive a highlight, and a selected newline receives an end-of-line highlight. Typing or Backspace/Delete first removes the selected byte range; unshifted Left/Right collapse an active range to its corresponding edge, while Shift+Left/Right and Shift+Up/Down/Home/End extend the range from a stable anchor. Other unshifted navigation clears the highlight before moving. When the surface has keyboard focus, supported key presses are translated through the active parsed XKB text-v1 subset; if the keymap is unsupported or incomplete, the built-in US-QWERTY evdev table is used as a fallback. The supported commands are text insertion, Backspace, Delete, Enter, four-space Tab, Left/Right/Up/Down, Home, and End. The renderer repaints the document, selection, and caret after the buffer is released. Selection highlight rectangles currently use the fixed 8×12 cell grid, so their visual edges are approximate rather than glyph- or font-metric-aligned. The viewport currently provides automatic vertical caret-follow scrolling; horizontal scrolling and a fuller set of viewport controls are still future work. A monotonic timerfd implements key repetition for ordinary non-modifier/non-lock keys, including printable input, Enter, Tab, navigation, Backspace, and Delete. When the advertised `wl_seat` version is at least 4, NekoEdit binds that version and consumes `wl_keyboard.repeat_info` (rate in repeats per second and initial delay in milliseconds). A zero rate disables client-side repeat; later settings changes reconfigure an active repeat timer. Older seat versions retain a 300 ms / 30 Hz fallback. Key release or keyboard-focus loss cancels the active repeat. The event reader uses recvmsg for Wayland socket bytes so SCM_RIGHTS descriptors are not discarded. A wl_keyboard.keymap event's xkb_v1 FD is size-bounded, checked for its XKB text signature and terminating NUL, and mapped read-only with MAP_PRIVATE; the FD is closed after mapping. The XKB text-v1 payload is parsed into bounded keycode/name and ASCII symbol tables. Common compiled keycode entries and aliases, shorthand `[ ... ]` key arrays, explicit `symbols[GroupN] = [ ... ]` arrays, up to four groups/four levels, common named ASCII punctuation keysyms, and simplified alphabetic/four-level types are supported. A candidate map is activated only when it contains at least 16 recognized ASCII symbols and 12 alphabetic keys. Sparse or unsupported maps are rejected and leave the built-in US-QWERTY fallback active. Translation applies the active group, Shift/Caps for alphabetic keys, and physical Right Alt as LevelThree. This is not full XKB behavior: custom modifier maps, virtual modifier resolution, arbitrary type maps, actions, keypad behavior, non-ASCII keysyms, compose/dead keys, and input methods remain unsupported. The seat is bound at the lower of the advertised version and version 4 so the client can receive the repeat-info event without requesting unsupported protocol features. Pointer coordinates are fixed-point surface-local values; they are converted from 24.8 fixed point before hit testing. The process exits when xdg_toplevel.close arrives.

The current event loop uses poll to wait for Wayland socket events or the key-repeat timer. It remains a single-threaded, blocking-wait loop rather than a continuously spinning renderer. Clipboard transfers will require the poll set to include pending data-transfer descriptors. All event payloads must be length-checked before parsing; the prototype currently applies a fixed upper bound to event payload size.

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
- Parser-table inspection in the child process: XKB keycode 24 resolves to `<AD01>`, the expected alphabetic/LevelThree flags and Group1/Group2 symbols are populated, and integration input verifies XKB's +8 keycode offset, all 26 ASCII letters, group switching, Shift, Right-Alt LevelThree, all twelve shifted number-row symbols, and the exact saved output bytes.
- A punctuation-only XKB keymap with enough symbol entries but no alphabetic coverage is rejected; the test verifies the built-in US-QWERTY fallback still inserts and renders `a`.
- US-QWERTY text insertion, cursor movement, Backspace, Enter, Shift+1, pixel checks for the rendered glyphs and caret, a full printable-ASCII punctuation rendering regression test, and UTF-8 boundary tests for 2-, 3-, and 4-byte code points, selection, Backspace, Delete, and malformed input.
- Pointer-motion/button sequences that place the caret after first-line text, at the start of the second line, and between two characters on that line.
- Reverse-direction and multi-line pointer drag selection with highlight-pixel checks, including selected newline cells, and typing to replace selected text.
- Shift+Left/Right and Shift+Up/Down/Home/End selection extension, returning to the anchor, and unshifted arrow collapse behavior.
- Ctrl+A whole-document selection, including the visible portion after vertical scrolling.
- Long-line soft wrapping, pointer placement on wrapped rows, and vertical caret-follow scrolling past the window's bottom edge.
- Timed key repeat for printable keys, Enter, Tab, Left/Right/Up/Down, Home/End, Backspace, and Delete, including compositor-provided delay/rate and the legacy fallback.
- Buffer release before each edit redraw and before resize replacement, ensuring the shared-memory buffer is not modified or destroyed while the compositor owns it.
- Minimize, Maximize, Restore, and Close title-bar hit testing and request serialization.
- Maximize/Restore requests do not commit a stale-size frame before compositor configure; the new surface size/state is acknowledged before repaint.
- Blank title-bar `xdg_toplevel.move` and left/right/top/bottom/corner `xdg_toplevel.resize` request serialization with the originating pointer serial and the selected edge enum.
- Configure arrival while the old `wl_buffer` is busy, deferred replacement until release, exact positive configure dimensions within the advertised backing-store bound, min/max size-hint serialization, maximized-state capture, new buffer creation, and rendering at the updated dimensions/stride. Drawing is clipped to the active surface bounds.

Actions #253 passed the expanded mock scenario through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`. It verifies 1920×1080 maximize/restore, min/max size hints, exact configured geometry, release-gated buffer replacement, no-overflow scrollbar suppression, and the 12-pixel resize request zone on all edges/corners. This is still client-side protocol testing, not a Mutter integration test. The user reported that the #251 artifact still exited on Maximize and did not resize on GNOME, although title-bar movement worked; the #253 artifact must be retested in the actual GNOME Wayland session before that issue is considered fixed.

## Known limitations and next work

1. Extend the current XKB subset toward full XKB behavior: interpret custom type maps and modifier indices/virtual modifiers, actions, keypad symbols, and broader keysym values; add non-ASCII/Unicode text input and compose/dead-key handling.
2. Complete the UTF-8 document engine with a gap buffer, grapheme-aware navigation, Unicode glyph lookup and input, IME/compose support, undo, and redo. Initial code-point-safe navigation, selection, Backspace, and Delete on the fixed byte array are implemented and covered by integration tests.
3. Add Wayland text-input integration for IME preedit/commit and dead-key composition.
4. Add the system-font parser, glyph rasterizer, and text layout pipeline.
5. Add horizontal scrolling and fuller viewport controls, output-scale/fractional-scale handling, and a small release-tracked multi-buffer set. Compositor-configured resizing plus interactive edge/corner resize and title-bar move are implemented; manual GNOME/Mutter confirmation remains pending.
6. Replace the blocking loop with poll and nonblocking I/O.
7. Add wl_data_device clipboard support, with immutable copy snapshots independent of the document gap buffer.
8. Add Ctrl+C/X/V clipboard integration and Ctrl+Z/Y undo/redo; Ctrl+O, Ctrl+S, and Ctrl+Shift+S now route to the initial file-management workflow.
9. Connect the backend-neutral renderer and editor event model.
