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
- Storage: a byte-oriented gap buffer in a fixed 64 KiB allocation. The current editor moves the gap to the logical cursor for insertion and deletion, while `doc_length`, cursor, and selection offsets remain logical byte offsets. The allocation does not yet grow; files larger than 64 KiB remain unsupported.
- Cursor and selection: byte offsets kept on valid UTF-8 code-point boundaries. The current navigation, hit-testing, selection, Backspace, and Delete paths use bounded UTF-8 scalar decoding.
- Invalid UTF-8: retain the original byte sequence unless an edit explicitly removes bytes within it. The current prototype treats each malformed byte as an independent one-byte replacement unit; valid non-ASCII code points and malformed bytes currently render as `?`.
- Character model: code-point boundaries are implemented, but grapheme clusters (for example, base letters plus combining marks or multi-code-point emoji sequences) are not yet treated as one cursor position.
- Line index: offsets of line starts, updated incrementally where practical.
- Line endings: detect and preserve LF or CRLF for existing files; define a consistent default for new files.

A byte-oriented gap buffer is intentionally simpler than a rope or piece table for the target workload. Rendering and cursor movement must decode UTF-8 safely and must not treat each byte as a visible character. The current implementation has a movable gap but is still bounded by its fixed 64 KiB allocation; dynamic growth and a line-start index remain future work. Unicode glyph lookup, non-ASCII keyboard/IME input, and grapheme-aware navigation are also not implemented.

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
- Create one XRGB8888 wl_buffer, destroy the pool object, attach the buffer, damage the surface, and commit.
- Answer xdg_wm_base.ping and exit on xdg_toplevel.close.

This prototype has one static buffer and a blocking event loop. It does not yet implement seat discovery, keyboard or pointer input, frame callbacks, resize/reconfigure handling, buffer recreation, clipboard, or text rendering. It intentionally binds protocol version 1 to keep the initial request/event surface small.

See [WAYLAND_BACKEND.md](WAYLAND_BACKEND.md).

### Wayland: next steps

Add seat discovery and keyboard/pointer objects, keymap interpretation without libxkbcommon, input event normalization, resize and scale handling, release-safe multiple buffers, and a nonblocking poll-based event loop. The clipboard data-device protocol will be added as a separate service with immutable snapshot ownership.

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
