# Architecture

## Goals

NekoEdit is a Linux x86-64 application written in assembly. Its runtime should have no third-party shared-library dependencies. It talks to the Linux kernel through direct system calls and to the desktop through the native display protocol available in the session.

The first release targets Linux x86-64 only. The application is desktop-environment-independent, not operating-system-independent: Wayland and X11 are the supported display systems.

## Layers

```text
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
| wire protocol       |   | X11 wire protocol   |
| input + clipboard   |   | input + clipboard   |
+---------+-----------+   +---------+-----------+
          |                         |
          +------------+------------+
                       |
+----------------------v------------------------------+
| Linux x86-64 syscall layer                            |
| sockets, mmap, files, directories, poll, clocks       |
+-----------------------------------------------------+
```

The editor core must not know which display backend is active. Backends translate native protocol messages into a small common event model (key, text, pointer, resize, clipboard offer, clipboard completion, and close request).

## Assembly and ABI

- Source syntax: GNU assembler, `.intel_syntax noprefix`.
- Architecture: x86-64.
- Internal function convention: System V AMD64 ABI unless a module documents a private convention.
- Process entry: `_start`; no C runtime startup code.
- System calls: `syscall` instruction, with Linux x86-64 syscall register conventions.
- Link: GNU `ld`, static executable, no interpreter, no `DT_NEEDED` entries.

Every assembly module should document input registers, output registers, clobbers, ownership of pointers, and whether a routine can block. Shared structures should be defined in one include/source-of-truth file when the number of modules grows.

## Event loop

Start with a single-threaded event loop using `poll` (or `ppoll` if signal-mask semantics become necessary). It must service:

- Display-server socket readability and writability.
- Pending clipboard pipe/file-descriptor transfers.
- Timers only when required for blinking or deferred UI work.

Do not block while waiting for a clipboard transfer or while loading a large file. Use nonblocking descriptors and process bounded chunks per event-loop iteration. Redraw requests should be coalesced so repeated input events do not trigger redundant full-window rendering.

## Memory

Use `mmap`/`munmap` for large buffers and explicitly managed arenas. The document uses a gap buffer. Clipboard contents use separate immutable allocations. Glyph bitmaps and parsed font metadata use bounded caches with explicit eviction. Every length calculation must be overflow-checked before allocation or pointer arithmetic.

No allocator library is required. A small internal allocator may be introduced only when individual `mmap` calls become a measurable or maintainability problem; avoid building a general-purpose heap unnecessarily.

## Document model

- Canonical storage: UTF-8 bytes.
- Editing: gap buffer.
- Cursor and selection: byte offsets that are always adjusted to valid UTF-8 boundaries.
- Line index: offsets of line starts, updated incrementally where practical.
- Line endings: detect and preserve LF or CRLF for existing files; define a consistent default for new files.
- Invalid UTF-8: preserve original bytes where possible and render replacement glyphs rather than silently rewriting file contents. Editing around invalid sequences needs a deliberate policy before implementation.

A byte-oriented gap buffer is intentionally simpler than a rope or piece table for the target workload. Rendering and cursor movement must decode UTF-8 safely and must not treat each byte as a visible character.

## Platform backends

### Wayland

Implement the minimum required core protocol and stable `xdg-shell` interfaces directly over the Wayland Unix-domain socket. The initial window path requires registry discovery, compositor, shared memory, surface, `xdg_wm_base`, `xdg_surface`, `xdg_toplevel`, seat, keyboard, and pointer interfaces. Clipboard requires the data-device interfaces when advertised.

Use `wl_shm` buffers backed by a `memfd` or another supported file descriptor. Respect buffer release events; never overwrite a buffer the compositor may still be reading. Start with two buffers and a small state machine.

Keyboard keymap files are XKB keymaps. Without libxkbcommon, NekoEdit needs a deliberately scoped keymap parser/translator. That is a substantial separate module; do not hardcode physical key positions as text characters.

### X11

Implement the minimum X11 connection handshake, setup parsing, request/reply/event framing, window creation, properties, input selection, and image upload. Support X11 authentication using the normal authority data when required.

The initial X11 graphics path can use core `PutImage`; query the server's visual masks, depth, and image byte order instead of assuming one pixel layout. Window-manager protocols such as `WM_DELETE_WINDOW` and relevant EWMH properties should be implemented where needed for normal desktop behavior.

### Backend selection

`--backend=auto|wayland|x11` is the planned interface. `auto` prefers a valid native Wayland session and otherwise tries X11. An explicit backend should fail with a useful diagnostic rather than silently switching. XWayland may be used as the X11 server when present, but it is not required for native Wayland operation.

## File access and directory listing

Use direct syscalls such as `openat`, `read`, `write`, `close`, `newfstatat`, and `getdents64`. Do not use `opendir`, `readdir`, `realpath`, or toolkit file chooser APIs. Treat filesystem names as byte sequences from the kernel and validate UTF-8 before rendering them; preserve the original name bytes for path operations.

The file picker is specified separately in [FILE_PICKER.md](FILE_PICKER.md).

## Error handling

- Check all syscall results, partial I/O, `EINTR`, and allocation failures.
- Treat display-server disconnects and protocol errors as fatal to the active window session, but report them cleanly.
- Permission errors, missing files, invalid paths, and unsupported font formats should produce small in-application errors, not crashes.
- Do not assume `d_type` is populated in directory entries; query metadata when needed.

## Build and verification

`make check` verifies that the output has no `PT_INTERP` and no `DT_NEEDED` dynamic dependencies. This proves the current ELF has no dynamic loader or shared-library dependency; it does not prove the final program is portable across all Linux distributions, compositors, or CPU feature sets.
