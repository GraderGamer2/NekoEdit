# Architecture

## Goals

NekoEdit is a freestanding Linux x86-64 application implemented in GNU Assembly and freestanding C. Assembly handles process entry, the syscall layer, and the low-level Wayland/XKB protocol paths; bounded rendering and platform-neutral services use C where it improves implementation clarity. Both are linked into one executable without a C runtime or third-party shared-library dependencies. The application talks to the Linux kernel through direct system calls and to the desktop through the native display protocol available in the session.

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

## Assembly, C and ABI

- Source syntax: GNU assembler, .intel_syntax noprefix.
- Architecture: x86-64.
- Internal function convention: System V AMD64 ABI unless a module documents a private convention.
- Process entry: _start; no C runtime startup code.
- System calls: syscall instruction, with Linux x86-64 syscall register conventions.
- Link: GNU ld, static executable, no interpreter, no DT_NEEDED entries.

C modules are compiled with freestanding/no-builtin options and use the same direct Linux syscall boundary rather than libc APIs. The current production C modules cover TrueType rasterization, clipboard transfers, Compose locale-pack handling, history journals, and preferences. They are not dynamically loaded and do not introduce a C runtime. Host-side test programs may link test-only libraries (for example libxkbcommon); those test links are separate from the editor ELF.

Every assembly module should document input registers, output registers, clobbers, ownership of pointers, and whether a routine can block. Shared structures should be defined in one include/source-of-truth file when the number of modules grows.

## Event loop

The active Wayland backend uses a nonblocking `poll()` event loop. It services the display socket, the keyboard-repeat timerfd, a separate pointer-selection auto-scroll timerfd, and the bounded clipboard send/receive descriptors. The auto-scroll timer is armed only during an active document selection drag and is disarmed on button release; keyboard repeat and selection scrolling therefore progress independently while the compositor socket is otherwise idle.

Clipboard and document I/O use nonblocking descriptors and bounded chunks rather than waiting for a transfer or a large file read to complete. A normal redraw requests one `wl_surface.frame` callback; intervening edits are coalesced until both `wl_callback.done` and `wl_buffer.release` have arrived. This keeps the single shared-memory buffer out of use while the compositor owns it and avoids submitting multiple frames within one callback interval.

## Memory

Use mmap/munmap for large buffers and explicitly managed arenas. The document uses a gap buffer. Clipboard contents use separate immutable allocations, retained through in-flight Wayland sends. The current clipboard implementation uses eight reusable source records, four concurrent send records, and a 64 MiB payload/receive ceiling. When Clipboard Service is enabled, closing the editor forks a small helper from the same executable; it inherits the original Wayland connection and immutable snapshot, serves the current selection after the parent exits, and terminates when ownership is replaced or the compositor disconnects. Undo/Redo uses one per-document disk-backed delta journal in `~/.nekoedit/*.history`; grouped edits store changed bytes and before/after caret/selection state, while a saved-document checksum guards restart recovery. The History tab exposes counts, Export, and Delete. These mechanisms are bounded by available disk space, record-size limits, clipboard payload size, and concurrent transfer slots rather than retaining full document snapshots in RAM. Glyph bitmaps and parsed font metadata use bounded caches with explicit eviction. Every length calculation must be overflow-checked before allocation or pointer arithmetic.

No allocator library is required. A small internal allocator may be introduced only when individual mmap calls become a measurable or maintainability problem; avoid building a general-purpose heap unnecessarily.

## Document model

- Canonical storage: UTF-8 bytes.
- Storage: a byte-oriented gap buffer in an anonymous mmap-backed allocation. The live document and transactional Open-staging buffer each start at 64 KiB and grow geometrically through mremap, up to a 1 GiB safety ceiling. For the live buffer, the suffix is relocated to the end of the enlarged mapping so the added allocation becomes one contiguous insertion gap. Document length, cursor, and selection remain logical byte offsets. Startup loading grows the live mapping; picker Open grows its separate staging mapping and reserves live capacity before committing the replacement document.
- Cursor and selection: logical byte offsets at extended grapheme-cluster boundaries. UTF-8 is still decoded one scalar at a time, but navigation, pointer hit-testing, selection, Backspace, and Delete use Unicode 18.0 UAX #29 segmentation; malformed bytes remain independent one-byte units.
- Invalid UTF-8: retain the original byte sequence unless an edit explicitly removes bytes within it. The current prototype treats each malformed byte as an independent one-byte replacement unit; supported non-ASCII scalars render through the active TrueType face when a glyph exists, and unsupported/malformed units use the fallback glyph.
- Character model: extended grapheme clusters are segmented using embedded Unicode 18.0 Grapheme_Cluster_Break, Indic_Conjunct_Break, and Extended_Pictographic property tables. The implementation covers CRLF, combining and spacing marks, Hangul composition, Prepend, Indic conjuncts, emoji ZWJ sequences, emoji modifiers, and regional-indicator pairing. Grapheme-aware navigation, hit-testing, selection, wrapping, and deletion are implemented. Text shaping and non-ASCII glyph rasterization are separate unfinished features.
- Line index: implemented as a dynamically mmap-backed array of 16-byte logical-line records. Each record stores its byte span (including a terminating LF), visual-row count, and one node from each of two Fenwick prefix trees. With Wrap Lines enabled, the visual-row count reflects soft wrapping at the current document width; when disabled, each logical line contributes exactly one visual row. Byte-offset-to-line and visual-row-to-line lookup use O(log N) prefix searches, followed by a scan within the selected logical line for the exact character boundary. Ordinary byte insertions/deletions update the affected line and the corresponding Fenwick paths. LF insertion/deletion splits or merges records and rebuilds the trees after shifting later records; a window-width change remeasures every line because soft wrapping depends on available columns. The mapping grows geometrically from 256 records up to 0x01000000 lines. If allocation fails or that bound is reached, the index is marked unavailable and the previous scan-based mapping remains as a correctness fallback. Replacing a document invalidates the prior index before the next lookup rebuilds it.
- Line endings: detect and preserve LF or CRLF for existing files; define a consistent default for new files.

A byte-oriented gap buffer is intentionally simpler than a rope or piece table for the target workload. Rendering and cursor movement decode UTF-8 safely and never use encoded bytes as visible character positions. Dynamic storage growth, the per-line Fenwick index, grapheme-aware editing, vertical scrolling/scrollbar, and horizontal viewport scrolling for unwrapped lines are implemented. Mouse selection includes character-range drags and double-click whole-word drags in either direction. When a drag crosses a viewport edge, vertical scrolling follows the pointer in both wrap modes; horizontal scrolling follows it in no-wrap mode, driven by a timer while the pointer remains stationary. The no-wrap viewport also supports a dedicated bottom thumb, track clicks, dragging, horizontal-wheel, and Shift+vertical-wheel input. Rendering begins at the indexed byte offset for the first visible visual row; caret mapping, scrollbar geometry, and logical line status also use the index. The index has an explicit maximum line count and falls back to scan-based mapping if it cannot be maintained. The document's separate 1 GiB byte-capacity ceiling is an implementation bound, not a claim of unlimited files. Direct XKB Unicode keysyms and a curated set of 273 common named non-ASCII aliases spanning Latin-1, Greek, Cyrillic, and selected regional variants are inserted as UTF-8. Six named dead-key actions arm pending combining marks; 52 common Latin-1 base/mark pairs are precomposed, while unsupported pairs preserve base+combining-mark order. The XKB `Multi_key` action also supports a bounded table of 20 two-symbol Compose pairs, with literal fallback and Backspace/Escape cancellation; longer locale-specific Compose sequences remain future work. Broader XKB modifier/action/type semantics, Wayland text-input/IME, and advanced shaping also remain future work.

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
- Request wl_registry and bind wl_compositor at no more than v6 (for preferred surface scale/transform events where available), wl_shm at v1, and xdg_wm_base at v1.
- Discover up to eight wl_output globals, bind at no more than v3 after the fixed bootstrap IDs and optional input-service objects are allocated, track v2+ integer scale transactionally through wl_output.done, and track wl_surface.enter/leave membership. Handle global removal with version-gated release requests. Preserve surface-local window dimensions for layout/input and compute distinct physical backing-buffer width/height and byte stride at an applied integer scale of 1× or 2×. The 2× path is capped to logical surfaces no larger than 1920×1080 so the existing 3840×2160 shared-memory pool remains sufficient.
- Create wl_surface, xdg_surface, and xdg_toplevel objects.
- Set the window title and perform the initial empty surface commit.
- Receive xdg_surface.configure and acknowledge its serial before attaching a buffer.
- Create a memfd, size it with ftruncate, map it with mmap, and pass its descriptor to wl_shm.create_pool using sendmsg + SCM_RIGHTS.
- Keep the wl_shm_pool alive after creating the initial 800×480 XRGB8888 wl_buffer; the pool backs subsequent buffers after compositor-requested resizes.
- Handle xdg_toplevel.configure width/height/maximized state and xdg_surface.configure acknowledgement. Recompute active geometry/stride, wait for the previous wl_buffer.release, destroy the old buffer, and allocate a replacement from the retained pool. The memfd mapping is bounded for 3840×2160 XRGB8888.
- Draw Minimize, Maximize/Restore, and Close controls in the application title bar and serialize the corresponding xdg_toplevel requests or clean client shutdown.
- Answer xdg_wm_base.ping and exit on xdg_toplevel.close.

The Wayland prototype has one active release-tracked buffer rather than a static-size buffer set. Configure-driven resizing and single-buffer `wl_surface.frame` pacing are implemented. Output discovery, integer-scale fallback, output hotplug, surface enter/leave membership, and compositor-preferred surface buffer scale/transform are tracked for up to eight outputs and the current surface. Integer 1×/2× scale is applied to physical backing-buffer dimensions and software rasterization while surface-local layout, pointer/input, and damage coordinates remain logical. Scale-only buffer replacement is release-gated; the current 3840×2160 shared-memory pool limits 2× to logical dimensions up to 1920×1080. Preferred transforms remain metadata-only; fractional scaling and release-tracked multi-buffer scheduling are not implemented. The event loop waits in poll for socket, keyboard-repeat timer, pointer-selection auto-scroll timer, or clipboard activity. Seat discovery, keyboard/pointer input, software text rendering, and file operations are also implemented in the active branch. It binds wl_compositor at up to v6, while wl_shm and xdg_wm_base remain at v1.

See [WAYLAND_BACKEND.md](WAYLAND_BACKEND.md).

### Wayland: next steps

Seat hotplug lifecycle is mock-tested for seat versions 1–4, including protocol release compatibility, input-state reset, pointer-bound cursor-shape recreation, immediate redraw, and keyboard removal during an active text-input-v3 preedit.


Seat capability hotplug now releases/abandons removed pointer and keyboard proxies according to the bound seat version, clears stale input state, stops pointer-drag auto-scroll, and recreates pointer-bound cursor-shape state on re-addition. The mock covers seat versions 1–4.


Further work: apply preferred buffer transforms (including axis swaps for 90°/270° and reflections); add fractional scale support where available; replace the single active buffer with a small release-tracked buffer set; and continue protocol interoperability testing. The app-drawn window controls and configure-driven resizing are implemented. Clipboard data-device support will be added as a separate service with immutable snapshot ownership.

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
