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
- Provides a compact title bar, an Untitled document tab, a document area, and a live status bar. Pointer clicks place the caret at the nearest insertion boundary; dragging selects byte ranges across lines and visual rows. Valid UTF-8 uses Unicode 18.0 extended grapheme boundaries for navigation, hit-testing, selection, Backspace, and Delete, while malformed bytes remain individually editable. Focused key events use the supported XKB text-v1 ASCII subset with a US-QWERTY fallback. The editor implements Ctrl+A, Ctrl+C, Ctrl+X, Ctrl+V, Ctrl+Z, Ctrl+Y, Ctrl+Shift+Z, Ctrl+O, Ctrl+S, and Ctrl+Shift+S, along with typing, Enter, Tab, Backspace/Delete and navigation.
- Uses an mmap-backed gap buffer that grows geometrically from 64 KiB up to 1 GiB and a per-line byte-span/visual-row index backed by Fenwick prefix trees. The software renderer uses supported TrueType fonts when available, with the embedded 5×7 bitmap as fallback; glyph advances and line pitch come from parsed font metrics. The XKB parser extracts common ASCII keysyms, up to four groups/four levels, and simplified alphabetic/four-level types; Shift/Caps, the active group, and physical Right-Alt LevelThree are handled.
- Waits for `wl_buffer.release` before rewriting or destroying the active buffer. Resizing acknowledges the xdg surface configure, destroys the released old `wl_buffer`, creates a replacement from the retained `wl_shm_pool`, then attaches and commits it with the new dimensions/stride.
- Sends `xdg_toplevel.move` from blank title-bar drags and `xdg_toplevel.resize` from a 12-pixel edge/corner hit region, using the serial from the initiating `wl_pointer.button` press.
- Maximize/Restore/Minimize requests return to the event loop without a stale-size surface commit. The next frame follows the compositor's toplevel/surface configure and `ack_configure` sequence; if the old buffer is still busy, replacement waits for `wl_buffer.release`.
- Answers xdg_wm_base ping requests.
- Sends Wayland socket requests with `MSG_NOSIGNAL`, so a closed compositor connection is returned as an ordinary write error instead of terminating the process with SIGPIPE. Failed sends report the client object ID, opcode, and Linux errno on stderr; this requires no journal or logfile. They also report the last complete client request written to the socket and the last Wayland event read, including its payload length. These are sequence clues, not proof that the compositor processed the preceding request.
- Exits on xdg_toplevel.close.

The wl_keyboard.keymap FD is received with recvmsg/SCM_RIGHTS, validated as a bounded NUL-terminated xkb_v1 keymap, and mapped read-only with MAP_PRIVATE. The parser supports compiled keycodes and aliases, common ASCII keysyms, up to four symbol groups/four levels, and common ONE_LEVEL/ALPHABETIC/THREE_LEVEL/FOUR_LEVEL families. Unsupported maps fall back to US-QWERTY; arbitrary custom type maps, virtual modifiers, actions, non-ASCII keysyms, keypad handling, compose/dead keys, and Unicode text input remain unsupported. The document uses Unicode 18.0 extended grapheme segmentation, a geometrically growing gap buffer, an indexed logical-line/Fenwick layout, proportional TrueType advances, font-metric line pitch, and vertical scrolling. The Wayland data-device backend implements immutable-snapshot Ctrl+C/X and asynchronous Ctrl+V. Ctrl+Z/Y and Ctrl+Shift+Z use bounded snapshot history (16 entries per stack, 32 MiB aggregate budget, 4 MiB maximum per snapshot); a successful new edit clears the redo branch. Settings exposes session-only document (8–24px) and UI (8–14px) font sizes, with the dropdown remaining open during repeated adjustments. Still unsupported: non-ASCII keyboard input, full XKB semantics, IME/compose/dead keys, complex shaping/kerning/mark positioning, font-family switching, persistent settings, horizontal scrolling, fractional/output scaling, multi-buffer scheduling, and X11. The client currently uses one active wl_buffer and waits for release before reuse/replacement.

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

The event loop uses `poll()` for the Wayland socket, key-repeat timer, four nonblocking clipboard-send descriptors, and one clipboard-receive descriptor. Keyboard shortcuts include Ctrl+O/S/Shift+S, Ctrl+C/X/V, Ctrl+Z/Y and Ctrl+Shift+Z. Clipboard transfers use bounded nonblocking chunks, without blocking keyboard dispatch or window-close processing. Open stages into a separately growing mapping and commits the document/path only after a successful read; saves use a same-directory temporary file, fsync, and atomic rename. Proportional TrueType advances and OS/2/hhea metrics are shared across wrapping, indexed visual rows, pointer placement and glyph painting. Long lines currently soft-wrap at available pixel width; automatic vertical caret-follow, wheel navigation and the draggable vertical scrollbar are implemented. Horizontal scrolling is not yet implemented.

The single-threaded event loop blocks between events, but its poll set includes the Wayland socket, key-repeat timer, four outgoing clipboard pipes and one incoming clipboard pipe. Clipboard state machines use nonblocking descriptors and bounded chunks; transfers do not perform blocking reads/writes in keyboard dispatch. Wayland messages and ancillary SCM_RIGHTS descriptors are received through recvmsg, and protocol payloads are length-checked before parsing.

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

1. Extend the XKB subset toward full modifier/type/action semantics, broader keysyms and non-ASCII text input.
2. Add compose/dead-key behavior and Wayland text-input/IME integration.
3. Add horizontal scrolling and fuller viewport controls for long lines.
4. Add runtime font-family/file selection, persistent typography preferences, and later kerning/GSUB/GPOS shaping plus grapheme mark positioning.
5. Add output/fractional-scale handling and a small release-tracked multi-buffer set; compositor-configured resizing, interactive edge/corner resizing, and title-bar move are implemented.
6. Add a native X11 backend and X11 clipboard support.
7. Improve picker-field editing with clipboard paste and partial Shift selection; add unsaved-document confirmation before Open replaces edited content.
8. Add Find/Replace (Ctrl+F).

Wayland clipboard ownership/transfer and Ctrl+C/X/V are implemented and tested. Undo/redo is implemented with bounded snapshot history and Ctrl+Z/Y/Ctrl+Shift+Z. File Open/Save/Save As is integrated with the directory picker. The event loop already uses poll and nonblocking clipboard descriptors. TrueType parsing/rasterization and proportional metric-aware layout are implemented; broader font selection and shaping remain future work.
