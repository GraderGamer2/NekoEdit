# NekoEdit

**A small, native, plain-text editor for Linux.**

NekoEdit is being designed around one constraint: do the necessary work ourselves, and avoid third-party runtime libraries. The first target is x86-64 Linux, independent of desktop environment, with native Wayland and X11 backends.

> **Development status:** early scaffold. The repository currently contains a freestanding assembly bootstrap and design documents. It is **not a graphical text editor yet**; Wayland, X11, text editing, rendering, font parsing, clipboard, and file-picker implementations are still planned.

## Project principles

- **Plain text first.** No rich-text model, syntax engine, plugin host, or IDE features.
- **Native Linux interfaces.** Speak Wayland and X11 protocols directly rather than depending on GTK, Qt, Xlib, XCB, or libwayland.
- **No third-party runtime libraries.** The application is written in x86-64 assembly and makes Linux system calls directly.
- **Software rendering.** Draw into CPU-managed pixel buffers; no OpenGL, Vulkan, EGL, or GPU requirement.
- **Use installed fonts.** Discover and parse supported system font files without Fontconfig, FreeType, or HarfBuzz.
- **Keep the interface small.** One document per window, a small menu, a status bar, and a straightforward directory browser.
- **Interoperate with the desktop.** Ordinary UTF-8 clipboard copy and paste must work with other applications.

## Target and compatibility

| Area | Initial target |
| --- | --- |
| CPU / ABI | x86-64, System V ABI |
| Operating system | Linux |
| Display | Wayland and X11 |
| Desktop environments | DE-independent; no GNOME/KDE-specific integration |
| Implementation | GNU assembler (`as`), Intel syntax |
| Linker | GNU `ld` |
| Runtime libraries | None |
| Rendering | CPU software renderer |
| Document format | UTF-8 plain text |

This is a Linux application, not a cross-platform application in the first release. The Wayland and X11 backends are intended to work across compatible compositors and window managers, not to depend on a particular desktop environment.

## Runtime dependency policy

NekoEdit will not dynamically link to third-party libraries. In particular, the runtime must not require GTK, Qt, libc, libwayland, Xlib, XCB, Fontconfig, FreeType, HarfBuzz, D-Bus, a toolkit file chooser, or a GPU API.

The unavoidable environment is the Linux kernel, a running Wayland compositor or X11 server, and (for system-font rendering) readable font files installed on the machine. Build tools are not runtime dependencies.

The initial build uses GNU binutils: `as`, `ld`, and `readelf`. `make` is used as a build convenience. There is no C or C++ application code and no NASM requirement.

## Build

On an x86-64 Linux development machine with GNU binutils and GNU Make installed:

```sh
make
make test
```

The output is `build/nekoedit`.

The current bootstrap accepts:

```sh
./build/nekoedit --help
./build/nekoedit --version
```

Running it without arguments currently reports that the graphical backends are not implemented. That is intentional: the bootstrap must not pretend to be a functioning GUI before the native backends exist.

`make check` inspects the ELF program and dynamic sections. It fails if the executable has a `PT_INTERP` segment or a `DT_NEEDED` entry. `make inspect` prints the ELF header and program headers.

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

The renderer will use CPU-side pixel buffers. The font subsystem will scan ordinary system font directories and initially parse TrueType-outline SFNT fonts (`glyf`/`loca`), rasterizing glyphs into a small cache. This is a deliberately scoped custom renderer, not a complete replacement for FreeType or HarfBuzz. Complex script shaping, bidirectional layout, variable fonts, CFF/CFF2 outlines, color fonts, and full hinting are not initial-release requirements.

See [docs/RENDERING.md](docs/RENDERING.md).

## Development roadmap

1. Freestanding ELF bootstrap and syscall conventions.
2. Wayland and X11 protocol connections and basic windows.
3. Software pixel surfaces and event loop.
4. Font discovery, TrueType parsing, glyph rasterization, and text drawing.
5. UTF-8 document engine and editing commands.
6. Clipboard interoperability and the simple directory browser.
7. Complete editor workflow, compatibility tests, and profiling.

The order may change as protocol and rendering prototypes expose implementation risks. Correctness and interoperability take priority over arbitrary binary-size targets.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Clipboard behavior](docs/CLIPBOARD.md)
- [Directory-browser file picker](docs/FILE_PICKER.md)
- [Software rendering and fonts](docs/RENDERING.md)
