# NekoEdit

**A small, native, plain-text editor for Linux.**

NekoEdit is being built around one constraint: implement the necessary application machinery ourselves and avoid third-party runtime libraries. The first target is x86-64 Linux, independent of desktop environment, with native Wayland and X11 backends planned.

> **Development status: native Wayland text-editor prototype with indexed editing, TrueType font switching, responsive controls, horizontal scrolling, Find/Replace, and persistent Settings.** The editor uses a geometrically growing gap buffer, a per-line byte/visual-row index, Unicode 18.0 grapheme-aware caret movement and selection, native Wayland clipboard transfers, bounded Undo/Redo, and software-rendered TrueType glyphs. Settings offers runtime TTF selection, document font size (8–32px), independent UI font size (8–16px), Wrap Lines, and save confirmation; all five settings persist between launches in `~/.nekoedit/preferences`. Settings and Find/Replace keep fixed, centered panel dimensions while their text follows the selected UI font. Find highlights every literal match in the document and distinguishes the current result. With wrapping disabled, a draggable bottom scrollbar supports track clicks, mouse dragging, horizontal-wheel scrolling, and Shift+vertical-wheel scrolling. Double-click selects a word; Ctrl+Left/Right navigates by word; Ctrl+Up/Down moves between logical lines; Shift variants extend selection; Ctrl+Home/End and Ctrl+Backspace/Delete provide document/word navigation. Ctrl+F opens Find and Ctrl+H opens Find/Replace, with Enter/F3/Shift+F3, Replace Current, and Replace All. Document typing accepts XKB Unicode keysyms in `Uxxxx` through `Uxxxxxx` form and encodes them as UTF-8; ASCII fallback remains available. Named non-ASCII keysyms, compose/dead keys, Wayland text-input/IME, full XKB semantics, and advanced shaping remain unfinished. Output/fractional scaling, release-tracked multi-buffer scheduling, and X11 remain future work. Open/Save/Save As use the in-window directory browser and same-directory atomic replacement. CI validates the mock Wayland compositor; manual GNOME/Mutter testing of the newest interactions and preference restoration remains outstanding.

> **Project history:** See [CHANGELOG/](CHANGELOG/README.md) for the complete development history, current implementation status, and continuity notes for future development sessions.

## Project principles

- **Plain text first.** No rich-text model, syntax engine, plugin host, or IDE features.
- **Native Linux interfaces.** Speak Wayland and X11 protocols directly rather than depending on GTK, Qt, Xlib, XCB, or libwayland.
- **No third-party runtime libraries.** The protocol, system-call, document, and UI code is written in x86-64 assembly; the outline rasterizer is a small freestanding C module with no libc dependency.
- **Software rendering.** Draw into CPU-managed pixel buffers; no OpenGL, Vulkan, EGL, or GPU requirement.
- **Use installed fonts.** Discover and parse supported system font files without Fontconfig, FreeType, or HarfBuzz.
- **Keep the interface small.** One document per window, a small menu, a status bar, and a straightforward directory browser.
- **Interoperate with the desktop.** Ordinary UTF-8 clipboard copy and paste must work with other applications.

## Current implementation

The first Wayland backend is a freestanding x86-64 assembly/C prototype. It:

1. Uses WAYLAND_SOCKET when a launcher supplies an inherited connected descriptor; otherwise reads WAYLAND_DISPLAY and XDG_RUNTIME_DIR (including absolute socket paths).
2. Connects to the Wayland Unix-domain socket using Linux system calls.
3. Discovers wl_compositor, wl_shm, xdg_wm_base, and an optional wl_seat.
4. Creates a wl_surface and an xdg_toplevel, then handles the initial configure/acknowledge sequence.
5. Allocates a memfd-backed pixel buffer, passes its descriptor to the compositor with SCM_RIGHTS, and draws a simple test surface in software.
6. Handles seat pointer and keyboard capabilities, pointer enter/leave/motion/button events, and keyboard focus, key, and modifier events.
7. Lets pointer clicks position the document caret at the nearest character insertion boundary. Holding the left button and dragging selects text across character and line boundaries. Shift+Left/Right and Shift+Up/Down/Home/End extend keyboard selections; unshifted Left/Right collapse an active selection. Typing or Backspace/Delete removes the selected range. Navigation and deletion respect Unicode 18.0 extended grapheme-cluster boundaries for valid UTF-8. Focused document typing uses the bounded XKB text-v1 subset, including Unicode keysyms in Uxxxx/Uxxxxx/Uxxxxxx form and UTF-8 insertion; unsupported or incomplete maps keep the built-in US-QWERTY evdev fallback active.
8. Implements bounded byte insertion/deletion, Enter, four-space Tab, Backspace, Delete, Left/Right/Up/Down, Home, End, and Ctrl+A Select All.
9. Draws mapped glyphs from supported TrueType outlines through bounded contour flattening, 4×4 grayscale supersampling, and a 128-entry glyph bitmap cache; keeps the embedded 5×7 bitmap as a fallback and repaints only after wl_buffer.release.
10. Responds to xdg_wm_base ping events and exits when the compositor sends xdg_toplevel.close.

The document uses an mmap-backed byte-oriented gap buffer that starts at 64 KiB and doubles geometrically on demand to a 1 GiB safety ceiling. The current document index stores per-line byte spans and visual-row counts with Fenwick prefix trees; newline changes split/merge records, while ordinary edits point-update the affected line. Open stages into its own growable mapping and commits only after a successful read and capacity reservation. Save uses a same-directory temporary file, fsync, and atomic rename; existing destination permissions/ACLs/xattrs are not preserved, and the parent directory is not fsynced after rename. Ctrl+O opens the native path prompt, Ctrl+S saves the active path (or opens Save As for Untitled), and Ctrl+Shift+S opens Save As. The supported XKB text-v1 subset translates common ASCII symbols and explicit Unicode Uxxxx/Uxxxxx/Uxxxxxx keysyms into Unicode scalars; document input encodes those scalars as UTF-8. The built-in US-QWERTY fallback remains available. Full modifier/type/action semantics, named non-ASCII keysym aliases, compose/dead keys, and IME are not implemented. Ctrl+C/X/V use the Wayland data-device manager and `text/plain;charset=utf-8`/`text/plain`; paste is asynchronous and limited to 64 MiB. Ctrl+Z/Y (also Ctrl+Shift+Z) uses bounded 16-entry-per-stack snapshot history with a 32 MiB aggregate memory budget and a 4 MiB per-snapshot limit. The renderer uses proportional TrueType metrics and grapheme-aware movement. Direct Unicode keysym input is supported, but complex shaping, bidirectional layout, kerning, ligatures, and combining-mark positioning are not implemented. Double-click selects a word; Ctrl+Left/Right moves between words; Ctrl+Up/Down moves between logical lines; Shift extends these selections. Ctrl+Home/End moves to document boundaries, and Ctrl+Backspace/Delete removes a word. Ctrl+F/H opens literal Find/Replace with Enter/F3/Shift+F3 navigation, Ctrl+Enter replacement, and Replace All. Search-field keyboard entry is limited to the supported ASCII XKB subset. Settings persist document font size (8–32px), UI font size (8–16px), Wrap Lines, Confirm before saving, and the last successfully loaded TTF path. Settings and Find/Replace use fixed-size centered panel geometry; their glyph sizes and pointer hit maps follow the selected UI font without enlarging the panels. Find paints all literal query matches in amber while the current selected result remains distinct. The no-wrap horizontal viewport includes a draggable bottom thumb, native horizontal-wheel and Shift+vertical-wheel scrolling, caret-following, viewport-aware selection painting, and offset-aware pointer hit-testing. Output/fractional scaling, release-tracked multi-buffer scheduling, persistent preferences, and X11 remain future work.

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

The current build uses GNU binutils (`as`, `ld`, and `readelf`), GNU Make, and a C compiler (`cc`, GCC or Clang) for the freestanding rasterizer. The C module is compiled without libc/builtins; the final executable remains a static freestanding ELF. NASM is not required.

## Build

On an x86-64 Linux development machine with GNU binutils, GNU Make, and a C compiler installed:

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

The window starts at 800×480 and shows clickable Minimize, Maximize/Restore, and Close controls, a **File** menu, active document tab, editor area, and status bar with logical line, column, byte count, and ASCII mode. The compositor may resize it; dragging its edges/corners starts an xdg-shell interactive resize, while dragging blank title-bar space starts an xdg-shell move. Maximize/Restore waits for the compositor's configure/acknowledge sequence before replacing and committing the resized software buffer. Select **File → Open** or press **Ctrl+O** to browse directories in the native in-window picker; its Search field displays up to five selectable filename suggestions. **File → Save As** or **Ctrl+Shift+S** chooses a destination in the same picker. **File → Save** or **Ctrl+S** saves the active path, while Ctrl+S on Untitled opens Save As. Press Enter to confirm or Escape to cancel. Relative paths are resolved from the working directory NekoEdit was launched in, and absolute paths are supported. Launch `nekoedit FILE` to load a file immediately. Click within the document area to place the caret or drag with the left mouse button to select text. Hold Shift while using the arrow keys or Home/End to extend a keyboard selection. Typing or Backspace/Delete removes the selected range. Navigation and deletion respect Unicode 18.0 extended grapheme-cluster boundaries for valid UTF-8. Focus the window and type basic US-QWERTY ASCII text. The arrow keys, Home/End, Backspace/Delete, Enter, and Tab are supported. Long lines wrap by default. Open Settings → Wrap Lines to disable soft wrapping; horizontal-wheel or Shift+vertical-wheel input then scrolls the long line, and the viewport follows the caret. Re-enable Wrap Lines to return to the normal wrapped layout. Use the compositor's normal close button to exit.

### TrueType font rendering

NekoEdit currently has a dependency-free TrueType `.ttf` outline renderer. It tries DejaVu Sans Mono, Liberation Mono, and DejaVu Sans at common Debian font paths. To choose a specific file, set `NEKOEDIT_FONT`:

~~~sh
NEKOEDIT_FONT=/absolute/path/to/font.ttf ./build/nekoedit [file]
~~~

The parser supports TrueType `glyf` simple and composite outlines, cmap formats 4/12, and quadratic contours. Glyphs are rasterized into bounded 64×64 grayscale bitmaps using 4×4 coverage sampling and a 128-entry cache, then blended by the Wayland software renderer. Document wrapping, the visual-row index, pointer hit-testing, selection, and painting use hmtx-derived pixel advances at the active document em size; vertical row pitch uses scaled OS/2 typographic metrics when USE_TYPO_METRICS is set, with hhea metrics as fallback. `NEKOEDIT_FONT` overrides deterministic attempts at DejaVu Sans Mono, Liberation Mono, and DejaVu Sans. The em size defaults to 12px and is adjustable from Settings (8–32px in two-pixel steps); the UI font is independently adjustable from 8–16px in one-pixel steps. The selected font path and both font sizes persist between launches. Hinting, CFF/CFF2, variable/color fonts, kerning, shaping, ligatures, combining-mark placement, and complex-script layout are not implemented. Only the first Unicode scalar of each grapheme is rasterized; unsupported glyphs retain the embedded 5×7 fallback.

### Persistent Settings

NekoEdit loads and saves the document font size, UI font size, Wrap Lines state, Confirm before saving, and last successfully loaded TrueType file. The configuration is stored at `$HOME/.nekoedit/preferences` (normally `~/.nekoedit/preferences`). `XDG_CONFIG_HOME` is intentionally ignored. The directory is created with mode 0700 and the preferences file uses mode 0600. Updates are written to a temporary file, fsynced, and atomically renamed into place.

The environment variable `NEKOEDIT_FONT` still takes priority over the saved font path. When it is absent or invalid, NekoEdit tries the saved path before the deterministic system-font candidates. Set `NEKOEDIT_DISABLE_PREFERENCES=1` to ignore persistent settings (useful for deterministic tests).

The X11 backend is not ready. The explicit selector currently reports this rather than silently trying to use Wayland:

~~~sh
./build/nekoedit --backend=x11
~~~

The CLI also supports --help and --version.

### Tests

- **make test** runs command-line smoke tests and an isolated persistent-preferences roundtrip/validation test.
- **make test-wayland** runs a Python 3 mock-compositor integration suite over both `WAYLAND_DISPLAY` and `WAYLAND_SOCKET`. In addition to the editor/input checks, it verifies the File menu rendering and click selection, Open and Save As prompts, path typing and Backspace, Enter confirmation, Escape cancellation, relative and absolute paths, Ctrl+S on Untitled, Ctrl+S on a named document, menu Save/Save As, successful file replacement, and preservation of the active document after missing-file Open failures, exact-capacity gap growth with suffix preservation, and successful Open/save of a 65,537-byte file. It also checks buffer-release-safe redraws, shared-memory FD transfer, and compositor protocol-error reporting without requiring an installed compositor. The horizontal-viewport scenario verifies the Wrap Lines toggle, one indexed visual row per logical line in no-wrap mode, caret-following scroll, 14px horizontal wheel movement, offset-aware pointer hit-testing, and restoration of wrapped rows.
- **make check** rejects an ELF containing PT_INTERP or DT_NEEDED entries.
- **make inspect** prints ELF metadata.

Python 3 is used only by the optional protocol test harness; it is not linked to or required by the NekoEdit executable.

## GitHub Actions

The Build and test workflow runs on pushes to main and pull requests targeting main. It also supports manual execution through the repository's **Actions** tab using workflow_dispatch. A successful run uploads the built Linux x86-64 executable as an artifact.

## Remaining roadmap

- Broader XKB modifier/type/action semantics and named non-ASCII keysym aliases beyond the explicit Unicode Uxxxx forms.
- Compose/dead-key handling and Wayland text-input/IME integration.
- More complete typography: hinting, kerning, ligatures, combining-mark positioning, bidirectional layout, CFF/CFF2, and variable/color-font support.
- Output/fractional scaling, release-tracked multi-buffer scheduling, and the X11 backend (including X11 clipboard interoperability).
- Broader system-font discovery and font-family/style selection.
Tabs, syntax highlighting, plugins, rich text, spell checking, auto-completion, and GPU rendering are deliberately out of scope for the initial release.

## Clipboard ownership

Copying must create an independent immutable snapshot of the selected bytes. The snapshot must not point into the document's gap buffer. It remains valid when the copied range is deleted, edited, or its document is closed. Clipboard transfers already in progress keep their own reference to that snapshot until the transfer completes.

The active Wayland implementation retains an independent immutable snapshot while NekoEdit owns the selection and keeps snapshots alive for in-flight sends. If another application replaces the clipboard, the source is retired after transfers finish. When NekoEdit exits, persistence depends on whether the desktop has a clipboard manager; NekoEdit will not run a separate clipboard daemon or claim guaranteed persistence after process exit. The current implementation caps clipboard payloads at 64 MiB; paste targets the editor document, not picker fields.

See [docs/CLIPBOARD.md](docs/CLIPBOARD.md).

## File picker

The implemented file picker is a small in-window directory browser rather than a platform dialog or a complex file manager. It shows the current path, folders and files, Up and Home controls, a Show hidden checkbox, editable filename search with selectable autocomplete suggestions, and Open/Save controls. It does not require a portal, D-Bus, GTK, or Qt.

See [docs/FILE_PICKER.md](docs/FILE_PICKER.md).

## Rendering and fonts

The active Wayland renderer uses CPU-side shared-memory pixel buffers and a 128-entry TrueType glyph cache. It parses bounded SFNT/cmap/hhea/hmtx/glyf data, rasterizes quadratic outlines with 4×4 grayscale coverage, and blends glyph masks into the surface. Proportional hmtx advances and hhea-derived vertical line pitch are integrated into document layout, selection, pointer mapping, and rendering. Font loading uses `NEKOEDIT_FONT` or deterministic common Debian paths rather than recursive discovery. This scoped renderer is not a replacement for FreeType or HarfBuzz; hinting, CFF/CFF2, variable/color fonts, kerning, complex shaping, bidi, and mark positioning remain unsupported.

See [docs/RENDERING.md](docs/RENDERING.md).

## Development roadmap

1. Freestanding ELF bootstrap and syscall conventions. (Implemented.)
2. Native Wayland window, xdg-shell setup, and software-buffer proof of concept. (Implemented prototype.)
3. Pointer/keyboard editing, in-window file operations, and initial ASCII document editing. (Implemented prototype.)
4. Bounded XKB text-v1 parsing, common ASCII layout-aware translation, and direct Unicode Uxxxx/Uxxxxx/Uxxxxxx keysym lookup are implemented. Sparse maps safely fall back; full modifier/type/action semantics, named non-ASCII aliases, compose/dead keys, and Wayland text-input integration remain.
5. Document storage, navigation, Unicode editing, history, and scrolling. Geometric gap-buffer growth, the indexed per-line byte/visual-row records and Fenwick trees, Unicode 18.0 grapheme navigation/deletion, vertical/horizontal scrolling, bounded Ctrl+Z/Y history, and UTF-8 insertion from XKB Unicode keysyms are implemented and mock-tested. Compose/dead keys, Wayland text-input/IME, named non-ASCII keysyms, and complex shaping remain unfinished.
6. TrueType parsing, glyph rasterization, proportional advance layout, font-metric line pitch, runtime font selection, and independent document/UI font-size controls are implemented. Persistent document/UI sizes, Wrap Lines, save confirmation, and the selected font path are implemented in `~/.nekoedit/preferences`; advanced shaping remains unfinished.
7. File open/save, the directory-browser picker, and Wayland clipboard interoperability (Ctrl+C/X/V) are implemented and mock-compositor tested. X11 clipboard support remains part of the future X11 backend.
8. Output-scale/fractional-scale handling, multi-buffer frame scheduling, X11 backend, compatibility testing, and profiling. Compositor-configured window resizing is implemented.

Correctness and interoperability take priority over arbitrary binary-size targets.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Wayland backend](docs/WAYLAND_BACKEND.md)
- [Clipboard behavior](docs/CLIPBOARD.md)
- [Directory-browser file picker](docs/FILE_PICKER.md)
- [Software rendering and fonts](docs/RENDERING.md)
