# NekoEdit

**A small, native, plain-text editor for Linux.**

NekoEdit is being built around one constraint: implement the necessary application machinery ourselves and avoid third-party runtime libraries. The first target is x86-64 Linux, independent of desktop environment, with native Wayland and X11 backends planned.

> **Development status: early interactive text-editor prototype.** The Wayland build opens an 800×480 software-rendered window with a clickable palette and a keyboard-editable document area. It supports basic ASCII entry using a built-in US-QWERTY evdev mapping, Shift/Caps state, Ctrl+A select-all, Enter, Tab, Backspace, Delete, arrow navigation, Home, End, mouse caret placement, left-button drag selection, and Shift+Arrow/Home/End keyboard selection. Long lines soft-wrap at the right edge, and the document scrolls vertically to keep the active caret visible. Typing or pressing Backspace/Delete removes the selected byte range before editing. A fixed 64 KiB byte buffer and built-in 5×7 bitmap font are used for this stage. It is not yet a complete editor: compositor XKB keymap parsing, non-US layouts, UTF-8 text input/rendering, IME/dead-key composition, undo, scrolling, file operations, clipboard, resizing, the directory-browser picker, and X11 remain unfinished.

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
7. Lets pointer clicks select a palette swatch or position the document caret at the nearest character insertion boundary. Holding the left button and dragging selects text across character and line boundaries. Shift+Left/Right and Shift+Up/Down/Home/End extend keyboard selections; unshifted Left/Right collapse an active selection. Typing or Backspace/Delete removes the selected range. Focused keyboard input edits the document through a built-in US-QWERTY evdev table; Shift and Caps state are synchronized from physical key transitions and Wayland modifier events.
8. Implements bounded byte insertion/deletion, Enter, four-space Tab, Backspace, Delete, Left/Right/Up/Down, Home, End, and Ctrl+A Select All.
9. Draws ASCII text and a caret with an embedded 5×7 bitmap font, repainting only after wl_buffer.release.
10. Responds to xdg_wm_base ping events and exits when the compositor sends xdg_toplevel.close.

The current document storage is a fixed 64 KiB byte array, not yet a gap buffer. The `wl_keyboard.keymap` FD is not parsed, so keyboard layouts other than the built-in US-QWERTY mapping are unsupported. All ordinary non-modifier/non-lock keys repeat while held. The client uses the compositor's `wl_keyboard.repeat_info` rate and delay when the bound `wl_seat` version supports it, with a 300 ms / 30 Hz fallback for older compositors. Unicode input/rendering, IME and dead-key composition, undo/redo, file operations, clipboard, resizing, and the X11 backend remain unfinished. Vertical cursor-follow scrolling is implemented; horizontal scrolling and more complete viewport controls remain future work.

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

The current window shows three color swatches above a simple text area. Click a swatch to change its border, click within the document area to place the caret, or drag with the left mouse button to select text. Hold Shift while using the arrow keys or Home/End to extend a keyboard selection. Typing or Backspace/Delete removes the selected range. Focus the window and type basic US-QWERTY ASCII text. The arrow keys, Home/End, Backspace/Delete, Enter, and Tab are supported. Long lines wrap automatically, and the view follows the caret as it moves down through the document. Use the compositor's normal close button to exit.

The X11 backend is not ready. The explicit selector currently reports this rather than silently trying to use Wayland:

~~~sh
./build/nekoedit --backend=x11
~~~

The CLI also supports --help and --version.

### Tests

- **make test** runs command-line smoke tests.
- **make test-wayland** runs a small Python 3 mock-compositor test. It validates both connection methods, seat/pointer/keyboard setup, palette clicks, US-QWERTY text insertion, navigation, Backspace, Enter, Shift/modifier state, mouse caret placement, reverse-direction and multi-line drag selection, Shift+Arrow/Home/End keyboard selection and collapse behavior, Ctrl+A whole-document selection, text wrapping beyond the window width, mouse hit testing on wrapped rows, vertical cursor-follow scrolling beyond the window height, typing to replace selected text, buffer-release-safe redraws, shared-memory FD transfer, and compositor protocol-error reporting without requiring an installed compositor.
- **make check** rejects an ELF containing PT_INTERP or DT_NEEDED entries.
- **make inspect** prints ELF metadata.

Python 3 is used only by the optional protocol test harness; it is not linked to or required by the NekoEdit executable.

## GitHub Actions

The Build and test workflow runs on pushes to main and pull requests targeting main. It also supports manual execution through the repository's **Actions** tab using workflow_dispatch. A successful run uploads the built Linux x86-64 executable as an artifact.

## Planned first-release features

- New, open, save, and save as.
- A simple built-in directory-browser file picker.
- XKB keymap parsing and layout-aware symbol translation.
- UTF-8 text editing with a gap buffer and Unicode-aware cursor movement.
- IME/dead-key composition through the appropriate Wayland text-input protocol.
- Undo and redo.
- Horizontal scrolling, viewport controls, and line/column status.
- Cut, copy, and paste with ordinary desktop applications.
- Keyboard shortcuts: Ctrl+A (select all; implemented), Ctrl+C (copy), Ctrl+X (cut), Ctrl+V (paste), Ctrl+Z/Ctrl+Y (undo/redo), Ctrl+S (save), Ctrl+Shift+S (save as), Ctrl+O (open), and Ctrl+F (find).
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

The file picker will be a small directory browser rather than a platform dialog or a complex file manager. It will show the current path, folders and files, an Up button, a Home button, and the minimal Open/Save controls. It will not require a portal, D-Bus, GTK, or Qt.

See [docs/FILE_PICKER.md](docs/FILE_PICKER.md).

## Rendering and fonts

The renderer will use CPU-side pixel buffers. The font subsystem will scan ordinary system font directories and initially parse TrueType-outline SFNT fonts (glyf/loca), rasterizing glyphs into a small cache. This is a deliberately scoped custom renderer, not a complete replacement for FreeType or HarfBuzz. Complex script shaping, bidirectional layout, variable fonts, CFF/CFF2 outlines, color fonts, and full hinting are not initial-release requirements.

See [docs/RENDERING.md](docs/RENDERING.md).

## Development roadmap

1. Freestanding ELF bootstrap and syscall conventions. (Implemented.)
2. Native Wayland window, xdg-shell setup, and software-buffer proof of concept. (Implemented prototype.)
3. Pointer/keyboard events and the initial US-QWERTY ASCII editing prototype. (Current milestone.)
4. XKB keymap FD parsing, layout-aware keysym translation, and Wayland input-method integration.
5. UTF-8 gap-buffer document engine, Unicode-aware navigation, selection-aware editing, undo/redo, and scrolling.
6. Installed-font discovery, TrueType parsing, glyph rasterization, and text layout.
7. File open/save, the directory-browser picker, and clipboard interoperability.
8. Resize/output-scale handling, X11 backend, compatibility testing, and profiling.

Correctness and interoperability take priority over arbitrary binary-size targets.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Wayland backend](docs/WAYLAND_BACKEND.md)
- [Clipboard behavior](docs/CLIPBOARD.md)
- [Directory-browser file picker](docs/FILE_PICKER.md)
- [Software rendering and fonts](docs/RENDERING.md)
