# NekoEdit

**A small, native, plain-text editor for Linux.**

NekoEdit is being built around one constraint: implement the necessary application machinery ourselves and avoid third-party runtime libraries. The first target is x86-64 Linux, independent of desktop environment, with native Wayland and X11 backends planned.

> **Development status: early interactive text-editor prototype.** The Wayland build opens an 800×480 software-rendered editor window with an active document tab, a live line/column/byte-count status bar, and a keyboard-editable document area. It supports ASCII entry using a bounded parser for common XKB text-v1 keymaps (keycodes, ASCII keysyms, one-/two-/three-/four-level type families, up to four groups and four levels), with a built-in US-QWERTY fallback when a map cannot be parsed. Shift/Caps, the active layout group, and a physical Right-Alt LevelThree selector are handled, alongside Ctrl+A select-all, Ctrl+S save, Enter, Tab, Backspace, Delete, arrow navigation, Home, End, mouse caret placement, left-button drag selection, and Shift+Arrow/Home/End keyboard selection. Pass a file path as the first argument to load it; a nonexistent path starts a new document that Ctrl+S creates. Long lines soft-wrap at the right edge, and the document scrolls vertically to keep the active caret visible; overflowing documents also show a proportional draggable scrollbar and accept mouse-wheel scrolling. Typing or pressing Backspace/Delete removes the selected range before editing. For valid UTF-8, cursor movement, pointer hit-testing, selection, Backspace, and Delete use complete Unicode code-point boundaries; malformed bytes remain individually editable. A byte-oriented gap buffer and built-in 5×7 bitmap font are used for this stage. The document and Open-staging mappings start at 64 KiB and grow geometrically as needed, up to a 1 GiB safety ceiling. Non-ASCII code points currently render as one `?` placeholder each; text entry is still ASCII-only. The in-window File menu provides Open, Save, and Save As through a path-entry prompt; Open is staged in a separate growable mapping, and saves use same-directory atomic replacement. The XKB keymap FD is received and mapped read-only, then parsed by a deliberately limited XKB text-v1 subset for keycodes, common ASCII keysyms, groups, and up to four levels. Common ONE_LEVEL, alphabetic, and three-/four-level type names, Shift/Caps, the active group, and physical Right-Alt LevelThree are handled; arbitrary XKB modifier/type maps, virtual modifiers, actions, non-ASCII keysyms, compose/dead keys, and Unicode input are not. The UTF-8 work is an initial code-point-safe editing slice, not the finished document engine: the gap buffer now grows geometrically from 64 KiB up to a 1 GiB safety ceiling, while grapheme clusters are not yet kept together, non-ASCII glyph rendering and keyboard text input are not implemented, and IME integration, undo, horizontal scrolling, clipboard, output-scale handling, and X11 remain unfinished. The window starts at 800×480 and supports compositor-configured resizing plus app-drawn Minimize, Maximize/Restore, and Close controls. Blank title-bar dragging requests compositor-managed window movement; dragging within its 12-pixel edge/corner bands requests interactive resizing. Maximize/Restore waits for the compositor's configure/acknowledge sequence before committing the newly sized frame. The native directory-browser picker supports editable path/search fields, prefix matches, up to five selectable filename suggestions, and Open/Save workflows.

> **Project history:** See [CHANGELOG/](CHANGELOG/README.md) for the complete development history, current implementation status, and continuity notes for future development sessions.

## Project principles

- **Plain text first.** No rich-text model, syntax engine, plugin host, or IDE features.
- **Native Linux interfaces.** Speak Wayland and X11 protocols directly rather than depending on GTK, Qt, Xlib, XCB, or libwayland.
- **No third-party runtime libraries.** The application is written in x86-64 assembly and makes Linux system calls directly.
- **Software rendering.** Draw into CPU-managed pixel buffers; no OpenGL, Vulkan, EGL, or GPU requirement.
- **Use installed fonts.** Discover and parse supported system font files without Fontconfig, FreeType, or HarfBuzz.
- **Keep the interface small.** One document per window, a small menu, a status bar, and a straightforward directory browser.
- **Interoperate with the desktop.** Ordinary UTF-8 clipboard copy and paste must work with other applications.

## Current implementation

The first Wayland backend is a freestanding assembly prototype. It:

1. Uses WAYLAND_SOCKET when a launcher supplies an inherited connected descriptor; otherwise reads WAYLAND_DISPLAY and XDG_RUNTIME_DIR (including absolute socket paths).
2. Connects to the Wayland Unix-domain socket using Linux system calls.
3. Discovers wl_compositor, wl_shm, xdg_wm_base, and an optional wl_seat.
4. Creates a wl_surface and an xdg_toplevel, then handles the initial configure/acknowledge sequence.
5. Allocates a memfd-backed pixel buffer, passes its descriptor to the compositor with SCM_RIGHTS, and draws a simple test surface in software.
6. Handles seat pointer and keyboard capabilities, pointer enter/leave/motion/button events, and keyboard focus, key, and modifier events.
7. Lets pointer clicks position the document caret at the nearest character insertion boundary. Holding the left button and dragging selects text across character and line boundaries. Shift+Left/Right and Shift+Up/Down/Home/End extend keyboard selections; unshifted Left/Right collapse an active selection. Typing or Backspace/Delete removes the selected range. Navigation and deletion respect valid UTF-8 code-point boundaries. Focused keyboard input uses the bounded XKB text-v1 subset described below; unsupported or incomplete maps keep the built-in US-QWERTY evdev fallback active.
8. Implements bounded byte insertion/deletion, Enter, four-space Tab, Backspace, Delete, Left/Right/Up/Down, Home, End, and Ctrl+A Select All.
9. Draws ASCII text and a caret with an embedded 5×7 bitmap font; valid non-ASCII code points are currently shown as `?`, repainting only after wl_buffer.release.
10. Responds to xdg_wm_base ping events and exits when the compositor sends xdg_toplevel.close.

The document uses a byte-oriented gap buffer in an anonymous mmap-backed allocation that starts at 64 KiB and doubles geometrically on demand, up to a 1 GiB safety ceiling. The gap moves to the logical cursor before insertion or deletion, so edits do not shift the entire suffix. When the gap is exhausted, mremap grows the mapping and relocates the suffix to the end of the new allocation without changing logical byte offsets. A path supplied on the command line is read at startup; the in-window File menu also provides Open, Save, and Save As through a native path-entry prompt. Ctrl+O opens a path prompt, Ctrl+S saves the active path (or opens Save As for Untitled), and Ctrl+Shift+S opens Save As. Relative paths are resolved against the process working directory; absolute paths are accepted. Open stages data in a separate growable mapping, initially 64 KiB, and commits the staged contents only after the full file has been read and enough live-document capacity has been reserved. Files can grow up to the 1 GiB safety ceiling; a failed Open leaves the active document and path unchanged. Saves write and fsync a same-directory temporary file before atomically renaming it over the destination, avoiding an early truncation of the prior file. The temporary file currently uses mode 0644 rather than preserving an existing destination's permission bits, and the parent directory is not fsynced after rename. The `wl_keyboard.keymap` XKB text-v1 payload is parsed by a bounded assembly parser for compiled keycodes and aliases, common ASCII keysyms, shorthand key symbol arrays, explicit `symbols[GroupN]` arrays, up to four groups and four levels, and common alphabetic/four-level type names. The parser requires at least 16 recognized ASCII symbols and 12 alphabetic keys before activating a map; punctuation-only or incomplete maps are rejected, leaving the built-in US-QWERTY table active. Input uses the active group, Shift/Caps, and physical Right-Alt LevelThree. This is a useful subset, not full XKB semantics: arbitrary modifier maps, virtual modifiers, custom type maps, actions, non-ASCII symbols, compose/dead keys, and IME are not implemented. All ordinary non-modifier/non-lock keys repeat while held. The client uses the compositor's `wl_keyboard.repeat_info` rate and delay when the bound `wl_seat` version supports it, with a 300 ms / 30 Hz fallback for older compositors. Unicode input/rendering, IME and dead-key composition, undo/redo, clipboard, output-scale handling, multi-buffer frame scheduling, and the X11 backend remain unfinished. The current window size is compositor-configurable within the implementation's bounded 480×360 to 3840×2160 range. Vertical cursor-follow scrolling, mouse-wheel scrolling, and a proportional draggable editor scrollbar are implemented; horizontal document scrolling remains future work.

See [docs/WAYLAND_BACKEND.md](docs/WAYLAND_BACKEND.md) for protocol details.

## Target and compatibility

| Area | Initial target |
| --- | --- |
| CPU / ABI | x86-64, System V ABI |
| Operating system | Linux |
| Display | Wayland first; X11 planned |
| Desktop environments | DE-independent; no GNOME/KDE-specific integration |
| Implementation | GNU assembler (as), Intel syntax |
| Linker | GNU ld |
| Runtime libraries | None |
| Rendering | CPU software renderer |
| Document format | UTF-8 plain text |

This is a Linux application, not a cross-platform application in the first release. The Wayland and X11 backends are intended to work across compatible compositors and window managers, not to depend on a particular desktop environment.

## Runtime dependency policy

NekoEdit will not dynamically link to third-party libraries. In particular, the runtime must not require GTK, Qt, libc, libwayland, Xlib, XCB, Fontconfig, FreeType, HarfBuzz, D-Bus, a toolkit file chooser, or a GPU API.

The unavoidable environment is the Linux kernel and a running Wayland compositor or X11 server. System font files will be used for text rendering. Build tools are not runtime dependencies.

The current build uses GNU binutils: as, ld, and readelf. GNU Make is used as a build convenience. There is no C or C++ application code and no NASM requirement.

## Build

On an x86-64 Linux development machine with GNU binutils and GNU Make installed:

~~~sh
make
make test
make test-wayland
~~~

The output is **build/nekoedit**.

Run inside a Wayland desktop session:

~~~sh
./build/nekoedit
# or explicitly:
./build/nekoedit --backend=wayland
~~~

The window starts at 800×480 and shows clickable Minimize, Maximize/Restore, and Close controls, a **File** menu, active document tab, editor area, and status bar with logical line, column, byte count, and ASCII mode. The compositor may resize it; dragging its edges/corners starts an xdg-shell interactive resize, while dragging blank title-bar space starts an xdg-shell move. Maximize/Restore waits for the compositor's configure/acknowledge sequence before replacing and committing the resized software buffer. Select **File → Open** or press **Ctrl+O** to browse directories in the native in-window picker; its Search field displays up to five selectable filename suggestions. **File → Save As** or **Ctrl+Shift+S** chooses a destination in the same picker. **File → Save** or **Ctrl+S** saves the active path, while Ctrl+S on Untitled opens Save As. Press Enter to confirm or Escape to cancel. Relative paths are resolved from the working directory NekoEdit was launched in, and absolute paths are supported. Launch `nekoedit FILE` to load a file immediately. Click within the document area to place the caret or drag with the left mouse button to select text. Hold Shift while using the arrow keys or Home/End to extend a keyboard selection. Typing or Backspace/Delete removes the selected range. Navigation and deletion respect valid UTF-8 code-point boundaries. Focus the window and type basic US-QWERTY ASCII text. The arrow keys, Home/End, Backspace/Delete, Enter, and Tab are supported. Long lines wrap automatically, and the view follows the caret as it moves down through the document. Use the compositor's normal close button to exit.

The X11 backend is not ready. The explicit selector currently reports this rather than silently trying to use Wayland:

~~~sh
./build/nekoedit --backend=x11
~~~

The CLI also supports --help and --version.

### Tests

- **make test** runs command-line smoke tests.
- **make test-wayland** runs a Python 3 mock-compositor integration suite over both `WAYLAND_DISPLAY` and `WAYLAND_SOCKET`. In addition to the editor/input checks, it verifies the File menu rendering and click selection, Open and Save As prompts, path typing and Backspace, Enter confirmation, Escape cancellation, relative and absolute paths, Ctrl+S on Untitled, Ctrl+S on a named document, menu Save/Save As, successful file replacement, and preservation of the active document after missing-file Open failures, exact-capacity gap growth with suffix preservation, and successful Open/save of a 65,537-byte file. It also checks buffer-release-safe redraws, shared-memory FD transfer, and compositor protocol-error reporting without requiring an installed compositor.
- **make check** rejects an ELF containing PT_INTERP or DT_NEEDED entries.
- **make inspect** prints ELF metadata.

Python 3 is used only by the optional protocol test harness; it is not linked to or required by the NekoEdit executable.

## GitHub Actions

The Build and test workflow runs on pushes to main and pull requests targeting main. It also supports manual execution through the repository's **Actions** tab using workflow_dispatch. A successful run uploads the built Linux x86-64 executable as an artifact.

## Planned first-release features

- New, open, save, and save as.
- A simple built-in directory-browser file picker.
- Full XKB modifier/type/action semantics beyond the supported common ASCII subset, plus broader non-ASCII keysym and layout handling.
- Add a line-start index, grapheme-aware navigation, Unicode glyph rendering, and Unicode text input. (Geometrically growing gap-buffer storage and large-file Open are implemented.)
- IME/dead-key composition through the appropriate Wayland text-input protocol.
- Undo and redo.
- Horizontal document scrolling.
- Cut, copy, and paste with ordinary desktop applications.
- Keyboard shortcuts: Ctrl+A (select all; implemented), Ctrl+S (save to launch-time path; implemented), Ctrl+C (copy), Ctrl+X (cut), Ctrl+V (paste), Ctrl+Z/Ctrl+Y (undo/redo), Ctrl+Shift+S (save as), Ctrl+O (open), and Ctrl+F (find).
- Find and replace.
- Glyph/font-metric-aware wrapping and advanced view preferences.
- A system-font software renderer.
- Wayland and X11 backends.

Tabs, syntax highlighting, plugins, rich text, spell checking, auto-completion, and GPU rendering are deliberately out of scope for the initial release.

## Clipboard ownership

Copying must create an independent immutable snapshot of the selected bytes. The snapshot must not point into the document's gap buffer. It remains valid when the copied range is deleted, edited, or its document is closed. Clipboard transfers already in progress keep their own reference to that snapshot until the transfer completes.

The snapshot remains available while NekoEdit owns the system clipboard. If another application replaces the clipboard, NekoEdit may release the old snapshot after outstanding transfers finish. When NekoEdit exits, persistence depends on whether the desktop has a clipboard manager; NekoEdit will not run a separate clipboard daemon or claim guaranteed persistence after process exit.

See [docs/CLIPBOARD.md](docs/CLIPBOARD.md).

## File picker

The implemented file picker is a small in-window directory browser rather than a platform dialog or a complex file manager. It shows the current path, folders and files, Up and Home controls, a Show hidden checkbox, editable filename search with selectable autocomplete suggestions, and Open/Save controls. It does not require a portal, D-Bus, GTK, or Qt.

See [docs/FILE_PICKER.md](docs/FILE_PICKER.md).

## Rendering and fonts

The renderer will use CPU-side pixel buffers. The font subsystem will scan ordinary system font directories and initially parse TrueType-outline SFNT fonts (glyf/loca), rasterizing glyphs into a small cache. This is a deliberately scoped custom renderer, not a complete replacement for FreeType or HarfBuzz. Complex script shaping, bidirectional layout, variable fonts, CFF/CFF2 outlines, color fonts, and full hinting are not initial-release requirements.

See [docs/RENDERING.md](docs/RENDERING.md).

## Development roadmap

1. Freestanding ELF bootstrap and syscall conventions. (Implemented.)
2. Native Wayland window, xdg-shell setup, and software-buffer proof of concept. (Implemented prototype.)
3. Pointer/keyboard editing, in-window file operations, and initial ASCII document editing. (Implemented prototype.)
4. Bounded XKB text-v1 parsing and common ASCII layout-aware translation. (Implemented subset; sparse maps safely fall back.) Next: broader XKB modifier/type semantics and Wayland text-input integration.
5. Dynamic gap-buffer growth, line indexing, grapheme-aware navigation, Unicode glyph/input support, undo/redo, and scrolling. (Geometric mmap-backed growth from 64 KiB to a 1 GiB safety ceiling is implemented and tested, including insert-at-full-capacity, suffix relocation, and staged Open/save of a 65,537-byte file. Vertical cursor-follow scrolling, a proportional editor scrollbar, pointer dragging, and mouse-wheel scrolling are implemented and CI-tested. The user also confirmed that editing and saving a 70 KB file works on GNOME. The line-start index, grapheme handling, Unicode input/rendering, undo/redo, and horizontal scrolling remain unfinished.)
6. Installed-font discovery, TrueType parsing, glyph rasterization, and text layout.
7. File open/save, the directory-browser picker, and clipboard interoperability.
8. Output-scale/fractional-scale handling, multi-buffer frame scheduling, X11 backend, compatibility testing, and profiling. Compositor-configured window resizing is implemented.

Correctness and interoperability take priority over arbitrary binary-size targets.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Wayland backend](docs/WAYLAND_BACKEND.md)
- [Clipboard behavior](docs/CLIPBOARD.md)
- [Directory-browser file picker](docs/FILE_PICKER.md)
- [Software rendering and fonts](docs/RENDERING.md)
