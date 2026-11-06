# NekoEdit

**A small, native, plain-text editor for Linux.**

NekoEdit is being built around one constraint: implement the necessary application machinery ourselves and avoid third-party runtime libraries. The first target is x86-64 Linux, independent of desktop environment, with native Wayland and X11 backends planned.

> **Development status: early prototype.** The current build opens a minimal Wayland toplevel and displays a software-rendered 800×480 test surface. It can be closed through the compositor's normal window controls. This is a graphics/windowing proof of concept, not a usable text editor yet. Text editing, keyboard input, system fonts, clipboard, the directory-browser picker, and X11 are still under development.

> **Project history:** See [CHANGELOG/](CHANGELOG/README.md) for the complete development history, current implementation status, and continuity notes for future development.

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

1. Reads WAYLAND_DISPLAY and XDG_RUNTIME_DIR from the process environment (and supports an absolute WAYLAND_DISPLAY path).
2. Connects to the Wayland Unix-domain socket using Linux system calls.
3. Discovers and binds wl_compositor, wl_shm, and xdg_wm_base.
4. Creates a wl_surface and an xdg_toplevel, then handles the initial configure/acknowledge sequence.
5. Allocates a memfd-backed pixel buffer, passes its descriptor to the compositor with SCM_RIGHTS, and draws a simple test surface in software.
6. Responds to xdg_wm_base ping events and exits when the compositor sends xdg_toplevel.close.

The current prototype does not yet process keyboard or pointer input, resize its buffer, draw text, or edit files. The X11 backend is not implemented yet.

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

The current test surface is static. Use the compositor's normal close button to exit.

The X11 backend is not ready. The explicit selector currently reports this rather than silently trying to use Wayland:

~~~sh
./build/nekoedit --backend=x11
~~~

The CLI also supports --help and --version.

### Tests

- **make test** runs command-line smoke tests.
- **make test-wayland** runs a small Python 3 mock-compositor test. It validates the Wayland wire messages, shared-memory FD transfer, and rendered pixels without requiring an installed compositor.
- **make check** rejects an ELF containing PT_INTERP or DT_NEEDED entries.
- **make inspect** prints ELF metadata.

Python 3 is used only by the optional protocol test harness; it is not linked to or required by the NekoEdit executable.

## GitHub Actions

The Build and test workflow runs on pushes to main and pull requests targeting main. It also supports manual execution through the repository's **Actions** tab using workflow_dispatch. A successful run uploads the built Linux x86-64 executable as an artifact.

## Planned first-release features

- New, open, save, and save as.
- A simple built-in directory-browser file picker.
- UTF-8 text editing with a gap buffer.
- Undo and redo.
- Cursor movement, keyboard and mouse selection, and line/column status.
- Cut, copy, and paste with ordinary desktop applications.
- Find and replace.
- Word wrapping and basic view preferences.
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

1. Freestanding ELF bootstrap and syscall conventions.
2. Wayland window and software-buffer proof of concept. (Current milestone.)
3. Wayland input, resize handling, and X11 protocol backend.
4. Font discovery, TrueType parsing, glyph rasterization, and text drawing.
5. UTF-8 document engine and editing commands.
6. Clipboard interoperability and the simple directory browser.
7. Complete editor workflow, compatibility tests, and profiling.

Correctness and interoperability take priority over arbitrary binary-size targets.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Wayland backend](docs/WAYLAND_BACKEND.md)
- [Clipboard behavior](docs/CLIPBOARD.md)
- [Directory-browser file picker](docs/FILE_PICKER.md)
- [Software rendering and fonts](docs/RENDERING.md)
