# Architecture

## Goals

NekoEdit is a Linux x86-64 application written in assembly. Its runtime should have no third-party shared-library dependencies. It talks to the Linux kernel through direct system calls and to the desktop through the native display protocol available in the session.

The first release targets Linux x86-64 only. The application is desktop-environment-independent, not operating-system-independent: Wayland and X11 are the intended display systems. Wayland is the only implemented backend at the current prototype stage.

## Layers

~~~text
+-----------------------------------------------------+
| Application UI                                      |
| menus, editor view, status bar, open/save dialogs    |
+------------------------------+----------------------+
                               |
+------------------------------v----------------------+
| Editor core                                           |
| UTF-8 buffer, cursor, selection, undo, search         |
+------------------------------+----------------------+
                               |
+------------------------------v----------------------+
| Platform-neutral services                             |
| clipboard snapshot, file operations, layout, commands |
+----------------------+------------------------------+
                       |
          +------------+------------+
          |                         |
+---------v-----------+   +---------v-----------+
| Wayland backend     |   | X11 backend         |
| raw wire protocol   |   | raw X11 protocol    |
| input + clipboard   |   | input + clipboard   |
+---------+-----------+   +---------+-----------+
          |                         |
          +------------+------------+
                       |
+----------------------v------------------------------+
| Linux x86-64 syscall layer                            |
| sockets, mmap, files, directories, poll, clocks       |
+-----------------------------------------------------+
~~~

The editor core must not know which display backend is active. Backends translate native protocol messages into a small common event model (key, text, pointer, resize, clipboard offer, clipboard completion, and close request).

## Assembly and ABI

- Source syntax: GNU assembler, .intel_syntax noprefix.
- Architecture: x86-64.
- Internal function convention: System V AMD64 ABI unless a module documents a private convention.
- Process entry: _start; no C runtime startup code.
- System calls: syscall instruction, with Linux x86-64 syscall register conventions.
- Link: GNU ld, static executable, no interpreter, no DT_NEEDED entries.

Every assembly module should document input registers, output registers, clobbers, ownership of pointers, and whether a routine can block. Shared structures should be defined in one include/source-of-truth file when the number of modules grows.

## Event loop

The first Wayland window proof of concept uses a blocking socket read loop because it has no interactive widgets or outstanding asynchronous clipboard transfers yet. The editor implementation must move to a nonblocking event loop using poll or ppoll.

The future event loop must service:

- Display-server socket readability and writability.
- Pending clipboard pipe/file-descriptor transfers.
- Timers only when required for blinking or deferred UI work.

Do not block while waiting for a clipboard transfer or while loading a large file. Use nonblocking descriptors and process bounded chunks per event-loop iteration. Redraw requests should be coalesced so repeated input events do not trigger redundant full-window rendering.

## Memory

Use mmap/munmap for large buffers and explicitly managed arenas. The document uses a gap buffer. Clipboard contents use separate immutable allocations. Glyph bitmaps and parsed font metadata use bounded caches with explicit eviction. Every length calculation must be overflow-checked before allocation or pointer arithmetic.

No allocator library is required. A small internal allocator may be introduced only when individual mmap calls become a measurable or maintainability problem; avoid building a general-purpose heap unnecessarily.

## Document model

- Canonical storage: UTF-8 bytes.
- Storage: a byte-oriented gap buffer in an anonymous mmap-backed allocation. The live document and transactional Open-staging buffer each start at 64 KiB and grow geometrically through mremap, up to a 1 GiB safety ceiling. For the live buffer, the suffix is relocated to the end of the enlarged mapping so the added allocation becomes one contiguous insertion gap. Document length, cursor, and selection remain logical byte offsets. Startup loading grows the live mapping; picker Open grows its separate staging mapping and reserves live capacity before committing the replacement document.
- Cursor and selection: logical byte offsets at extended grapheme-cluster boundaries. UTF-8 is still decoded one scalar at a time, but navigation, pointer hit-testing, selection, Backspace, and Delete use Unicode 18.0 UAX #29 segmentation; malformed bytes remain independent one-byte units.
- Invalid UTF-8: retain the original byte sequence unless an edit explicitly removes bytes within it. The current prototype treats each malformed byte as an independent one-byte replacement unit; supported non-ASCII scalars render through the active TrueType face when a glyph exists, and unsupported/malformed units use the fallback glyph.
- Character model: extended grapheme clusters are segmented using embedded Unicode 18.0 Grapheme_Cluster_Break, Indic_Conjunct_Break, and Extended_Pictographic property tables. The implementation covers CRLF, combining and spacing marks, Hangul composition, Prepend, Indic conjuncts, emoji ZWJ sequences, emoji modifiers, and regional-indicator pairing. Grapheme-aware navigation, hit-testing, selection, wrapping, and deletion are implemented. Text shaping and non-ASCII glyph rasterization are separate unfinished features.
- Line index: implemented as a dynamically mmap-backed array of 16-byte logical-line records. Each record stores its byte span (including a terminating LF), visual-row count, and one node from each of two Fenwick prefix trees. With Wrap Lines enabled, the visual-row count reflects soft wrapping at the current document width; when disabled, each logical line contributes exactly one visual row. Byte-offset-to-line and visual-row-to-line lookup use O(log N) prefix searches, followed by a scan within the selected logical line for the exact character boundary. Ordinary byte insertions/deletions update the affected line and the corresponding Fenwick paths. LF insertion/deletion splits or merges records and rebuilds the trees after shifting later records; a window-width change remeasures every line because soft wrapping depends on available columns. The mapping grows geometrically from 256 records up to 0x01000000 lines. If allocation fails or that bound is reached, the index is marked unavailable and the previous scan-based mapping remains as a correctness fallback. Replacing a document invalidates the prior index before the next lookup rebuilds it.
- Line endings: detect and preserve LF or CRLF for existing files; define a consistent default for new files.

A byte-oriented gap buffer is intentionally simpler than a rope or piece table for the target workload. Rendering and cursor movement decode UTF-8 safely and never use encoded bytes as visible character positions. Dynamic storage growth, the per-line Fenwick index, grapheme-aware editing, vertical scrolling/scrollbar, and horizontal viewport scrolling for unwrapped lines are implemented. The no-wrap viewport uses a pixel offset and supports a dedicated bottom thumb, track clicks, dragging, horizontal-wheel, and Shift+vertical-wheel input. Rendering begins at the indexed byte offset for the first visible visual row; caret mapping, scrollbar geometry, and logical line status also use the index. The index has an explicit maximum line count and falls back to scan-based mapping if it cannot be maintained. The document's separate 1 GiB byte-capacity ceiling is an implementation bound, not a claim of unlimited files. Direct XKB Unicode keysyms are inserted as UTF-8, but compose/dead-key input, IME, and advanced shaping remain future work.

## User preferences

User-facing preferences belong in the Settings menu and must be separate from document bytes. The initial preferences are:

- Confirm before saving: enabled by default. Save and new Save As operations ask before writing; overwriting an existing file retains an explicit overwrite decision.
- Font: choose a validated supported font from the user's installed font directories without Fontconfig or a shared font library.
- Font size: change glyph pixel size and recompute layout metrics, wrapped visual rows, pointer hit-testing, caret placement, and scrollbar ranges.
- Wrap Lines: toggle soft wrapping; when disabled, keep one visual row per logical line and expose horizontal viewport movement.

Preferences are stored in `$HOME/.nekoedit/preferences` (normally `~/.nekoedit/preferences`); `XDG_CONFIG_HOME` is intentionally ignored. The freestanding store validates each field and atomically persists document/UI font sizes, the last validated TTF path, Wrap Lines, and Confirm before saving. The directory is mode 0700 and the file is mode 0600. `NEKOEDIT_FONT` remains an explicit environment override. The TrueType outline renderer and metric-aware document layout are integrated: hmtx advances drive wrapping, indexed visual rows, pointer mapping and selection; hhea/OS/2 metrics determine vertical line pitch. Advanced shaping and broader system-font discovery remain future work.

## Platform backends

### Wayland: implemented prototype

The current prototype implements a deliberately small part of the stable core protocol and xdg-shell:

- Read WAYLAND_DISPLAY (default wayland-0) and XDG_RUNTIME_DIR; absolute WAYLAND_DISPLAY paths are supported.
- Connect to the Wayland Unix-domain stream socket with socket/connect syscalls.
- Request wl_registry and bind wl_compositor, wl_shm, and xdg_wm_base at protocol version 1.
- Create wl_surface, xdg_surface, and xdg_toplevel objects.
- Set the window title and perform the initial empty surface commit.
- Receive xdg_surface.configure and acknowledge its serial before attaching a buffer.
- Create a memfd, size it with ftruncate, map it with mmap, and pass its descriptor to wl_shm.create_pool using sendmsg + SCM_RIGHTS.
- Keep the wl_shm_pool alive after creating the initial 800×480 XRGB8888 wl_buffer; the pool backs subsequent buffers after compositor-requested resizes.
- Handle xdg_toplevel.configure width/height/maximized state and xdg_surface.configure acknowledgement. Recompute active geometry/stride, wait for the previous wl_buffer.release, destroy the old buffer, and allocate a replacement from the retained pool. The memfd mapping is bounded for 3840×2160 XRGB8888.
- Draw Minimize, Maximize/Restore, and Close controls in the application title bar and serialize the corresponding xdg_toplevel requests or clean client shutdown.
- Answer xdg_wm_base.ping and exit on xdg_toplevel.close.

The Wayland prototype now has a single active release-tracked buffer rather than a static-size buffer set; configure-driven resizing is implemented but output-scale changes and multi-buffer/frame scheduling are not. The event loop waits in poll for socket or repeat-timer activity. Seat discovery, keyboard/pointer input, software text rendering, and file operations are also implemented in the active branch. It intentionally binds the core globals at protocol version 1 to keep the initial request/event surface small.

See [WAYLAND_BACKEND.md](WAYLAND_BACKEND.md).

### Wayland: next steps

Further work: complete output-scale/fractional-scale handling, replace the single active buffer with a small release-tracked buffer set, add frame scheduling, and continue protocol interoperability testing. The app-drawn window controls and configure-driven resizing are implemented. Clipboard data-device support will be added as a separate service with immutable snapshot ownership.

### X11

Implement the minimum X11 connection handshake, setup parsing, request/reply/event framing, window creation, properties, input selection, and image upload. Support X11 authentication using the normal authority data when required.

The initial X11 graphics path can use core PutImage; query the server's visual masks, depth, and image byte order instead of assuming one pixel layout. Window-manager protocols such as WM_DELETE_WINDOW and relevant EWMH properties should be implemented where needed for normal desktop behavior.

### Backend selection

--backend=auto|wayland|x11 is the planned interface. auto will prefer a valid native Wayland session and otherwise try X11. The current binary accepts --backend=wayland; --backend=x11 reports that the backend is not implemented. XWayland may be used as the X11 server when present, but it is not required for native Wayland operation.

## File access and directory listing

Use direct syscalls such as openat, read, write, close, newfstatat, and getdents64. Do not use opendir, readdir, realpath, or toolkit file chooser APIs. Treat filesystem names as byte sequences from the kernel and validate UTF-8 before rendering them; preserve the original name bytes for path operations.

The file picker is specified separately in [FILE_PICKER.md](FILE_PICKER.md).

## Error handling

- Check all syscall results, partial I/O, EINTR, and allocation failures.
- Treat display-server disconnects and protocol errors as fatal to the active window session, but report them cleanly.
- Permission errors, missing files, invalid paths, and unsupported font formats should produce small in-application errors, not crashes.
- Do not assume d_type is populated in directory entries; query metadata when needed.

## Build and verification

make check verifies that the output has no PT_INTERP and no DT_NEEDED dynamic dependencies. This proves the current ELF has no dynamic loader or shared-library dependency; it does not prove the final program is portable across all Linux distributions, compositors, or CPU feature sets.

The optional Python mock compositor test is test infrastructure only. It does not become a runtime dependency of NekoEdit.
