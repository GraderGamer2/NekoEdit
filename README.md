# NekoEdit

**A small, native, plain-text editor for Linux.**

NekoEdit is being built around one constraint: implement the necessary application machinery ourselves and avoid third-party runtime libraries. The first target is x86-64 Linux, independent of desktop environment, with native Wayland and X11 backends planned.

> **Development status: native Wayland text-editor prototype with indexed editing, TrueType font switching, responsive controls, horizontal scrolling, Find/Replace, and persistent Settings.** The editor uses a geometrically growing gap buffer, a per-line byte/visual-row index, Unicode 18.0 grapheme-aware caret movement and selection, native Wayland clipboard transfers with an optional process-exit owner, disk-backed per-document Undo/Redo journals, and software-rendered TrueType glyphs. Settings offers runtime TTF selection, document font size (8–32px), independent UI font size (8–16px), Wrap Lines, save confirmation, and the Clipboard Service toggle; preferences persist in `~/.nekoedit/preferences`. A History tab lists document journals, opens the selected document, and provides Undo/Redo, export, and selected-history deletion; its path filter is present but still needs a functional fix. Settings and Find/Replace keep fixed, centered panel dimensions while their text follows the selected UI font. Find highlights every literal match in the document and distinguishes the current result. With wrapping disabled, a draggable bottom scrollbar supports track clicks, mouse dragging, horizontal-wheel scrolling, and Shift+vertical-wheel scrolling. Double-click selects a word and keeps whole-word selection active while dragging across words in either direction. Selection drags that reach the document or window edge continue through Wayland's implicit pointer grab and auto-scroll vertically in both wrap modes and horizontally when Wrap Lines is disabled; Ctrl+Left/Right navigates by word; Ctrl+Up/Down moves between logical lines; Shift variants extend selection; Ctrl+Home/End and Ctrl+Backspace/Delete provide document/word navigation. Ctrl+F opens Find and Ctrl+H opens Find/Replace, with Enter/F3/Shift+F3, Replace Current, and Replace All. Document typing accepts explicit XKB Unicode keysyms in `Uxxxx` through `Uxxxxxx` form and the static Unicode-annotated X.Org named-keysym set, including Latin-1, Greek, Cyrillic, Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, and the xorgproto 2026.1 German, punctuation, and phone-keypad aliases, encoding the selected scalar as UTF-8; ASCII fallback remains available. Optional Wayland text-input-v3 preedit/commit/delete handling is implemented and mock-tested behind the explicit `NEKOEDIT_ENABLE_TEXT_INPUT=1` opt-in; by default, physical XKB typing remains active even when a compositor advertises the text-input manager, because live GNOME/Mutter IME handoff is not yet verified. The XKB text-v1 reader parses declared per-key/per-group key types, exact 32-bit modifier-to-level maps, up to eight levels, explicit virtual-modifier encodings, direct and recognized indirect keysym-based real modifier_map bindings, direct key-level virtualModifiers, and a bounded xkb_compat interpretation subset (recognized modifier keysyms, AnyOfOrNone/AnyOf/NoneOf/AllOf/Exactly predicates, keysym and predicate specificity, first-declaration ties, virtualModifier, and useModMapMods=level1|any), including ISO group/level symbols such as ISO_Group_Shift and ISO_Next_Group. Per-key repeat follows XKB's separate defaults: `interpret.repeat` defaults to False for compatibility interpretations, while the default interpretation enables repeat only when Group 1 / Level 1 contains a symbol. Direct key `repeat` properties override compatibility results, which are resolved only from Group 1 / Level 1. XKB type `preserve[]` masks are parsed per exact map entry; consumed modifiers are computed from the selected type and its preserved mask, and Control and Shift are filtered per key before shortcut dispatch while symbol lookup retains the full compositor state. General XKB key actions, compatibility indicators, complete locale Compose tables, advanced preedit attributes, and text shaping remain unfinished; a static X.Org libX11 `en_US.UTF-8`-derived `Multi_key` Compose baseline with 2,140 two-symbol pairs and 564 three-symbol sequences (while preserving the editor's original 40 mappings), and a six-dead-key Latin-1 compose subset are implemented. This is not yet locale selection or `.XCompose` file support. Output/fractional scaling, release-tracked multi-buffer scheduling, and X11 remain future work. Open/Save/Save As use the in-window directory browser and same-directory atomic replacement. CI validates the mock Wayland compositor, including text-input-v3 event sequencing; real GNOME/Mutter input-method behavior still requires desktop testing. The user has manually confirmed that whole-word text selection and drag auto-scroll behave as expected, and has separately confirmed that `Ctrl+Shift+Left` selects words correctly in the current build; physical keyboard Compose behavior and preference restoration still need separate desktop verification.

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
7. Lets pointer clicks position the document caret at the nearest character insertion boundary. Holding the left button and dragging selects text across character and line boundaries. Double-click begins a whole-word selection; keeping the second press held and dragging extends or reverses the selection by complete words. Shift+Left/Right and Shift+Up/Down/Home/End extend keyboard selections; unshifted Left/Right collapse an active selection. Typing or Backspace/Delete removes the selected range. Navigation and deletion respect Unicode 18.0 extended grapheme-cluster boundaries for valid UTF-8. Focused document typing uses the bounded XKB text-v1 subset, including Unicode keysyms in Uxxxx/Uxxxxx/Uxxxxxx form and UTF-8 insertion; unsupported or incomplete maps keep the built-in US-QWERTY evdev fallback active.
8. Implements bounded byte insertion/deletion, Enter, four-space Tab, Backspace, Delete, Left/Right/Up/Down, Home, End, and Ctrl+A Select All.
9. Draws mapped glyphs from supported TrueType outlines through bounded contour flattening, 4×4 grayscale supersampling, and a 128-entry glyph bitmap cache; keeps the embedded 5×7 bitmap as a fallback and repaints only after wl_buffer.release.
10. Responds to xdg_wm_base ping events and exits when the compositor sends xdg_toplevel.close.

The document uses an mmap-backed byte-oriented gap buffer that starts at 64 KiB and doubles geometrically on demand to a 1 GiB safety ceiling. The current document index stores per-line byte spans and visual-row counts with Fenwick prefix trees; newline changes split/merge records, while ordinary edits point-update the affected line. Open stages into its own growable mapping and commits only after a successful read and capacity reservation. Save uses a same-directory temporary file, fsync, and atomic rename; existing destination permissions/ACLs/xattrs are not preserved, and the parent directory is not fsynced after rename. Ctrl+O opens the native path prompt, Ctrl+S saves the active path (or opens Save As for Untitled), and Ctrl+Shift+S opens Save As. The supported XKB text-v1 subset translates common ASCII symbols, explicit Unicode Uxxxx/Uxxxxx/Uxxxxxx keysyms, the Unicode-annotated X.Org named keysym aliases and xorgproto 2026.1 phone/German/punctuation additions, and six dead-key actions (grave, acute, circumflex, tilde, diaeresis, cedilla). The dead-key path composes 52 common Latin-1 pairs; unsupported pairs insert the base followed by its combining mark. The built-in US-QWERTY fallback remains available. The XKB `Multi_key` action supports 2,140 two-symbol pairs plus 564 three-symbol sequences from X.Org libX11's `en_US.UTF-8` Compose source. The original 40 editor pairs take precedence on overlap. For three-symbol input, the second scalar is buffered only when it is a recognized prefix; unknown pairs remain literal, and Backspace/Escape cancel unfinished state. Four-symbol sequences, locale-based table selection, locale include rules, and user `.XCompose` files remain unfinished. The reader supports up to 64 declared key types, 32 map entries per type, four symbol groups, eight levels per group, and up to 24 named virtual modifiers. It keeps each declaration index separate from that modifier's effective 32-bit encoding, and parses explicit `virtual_modifiers NAME = ...` assignments using real modifier combinations (for example `Mod4+Mod5`), numeric masks, or `none`. The custom fixture verifies `LevelThree = Mod5`, `NumLock = Mod2`, a combined real-modifier mask, a high-bit mask at bit 31, and repeated declarations in a later section. The lookup filters the compositor's full modifier state through each type's declared `modifiers` mask and uses exact `map[combination] = LevelN` lookup; numeric masks and numeric or `LevelN` level values are accepted. Unsupported or malformed type definitions fail closed to the built-in US-QWERTY fallback. The reader resolves direct keycode and recognized indirect keysym `modifier_map` entries; direct key-level `virtualModifiers` and bounded `xkb_compat` interpretation results contribute to effective 32-bit virtual-modifier masks. Compatibility interpretations support recognized modifier keysyms, all five real-modifier predicates, implicit `Exactly(mask)`, specificity/tie ordering, `virtualModifier`, `useModMapMods=level1|any`, and per-key repeat policy. General stateful XKB key actions and compatibility indicators remain compositor-owned or unfinished. Per-entry `preserve[]` and consumed-modifier filtering are implemented for Control and Shift shortcut handling; Alt and other modifiers are not yet part of the shortcut filter. Extended Compose tables and full locale behavior also remain unsupported. LevelThree and NumLock retain conventional Mod5/Mod2 fallback masks when a keymap omits explicit encodings. Optional Wayland text-input-v3 is implemented; advanced preedit attributes and live compositor validation remain follow-ups. Ctrl+C/X/V use the Wayland data-device manager and `text/plain;charset=utf-8`/`text/plain`; paste is asynchronous and limited to 64 MiB. Ctrl+Z/Y (also Ctrl+Shift+Z) uses per-document disk-backed delta journals under ~/.nekoedit. New version-2 records use compact variable-length offsets and lengths; existing version-1 journals remain readable and writable. The History tab searches stored document paths, has an Open Selected action and a Browse picker, and deletes the highlighted journal rather than an unrelated active document. The renderer uses proportional TrueType metrics and grapheme-aware movement. Direct Unicode keysym input is supported, but complex shaping, bidirectional layout, kerning, ligatures, and combining-mark positioning are not implemented. Double-click selects a word; Ctrl+Left/Right moves between words; Ctrl+Up/Down moves between logical lines; Shift extends these selections. Ctrl+Home/End moves to document boundaries, and Ctrl+Backspace/Delete removes a word. Ctrl+F/H opens literal Find/Replace with Enter/F3/Shift+F3 navigation, Ctrl+Enter replacement, and Replace All. Search-field keyboard entry is limited to the supported ASCII XKB subset. Settings persist document font size (8–32px), UI font size (8–16px), Wrap Lines, Confirm before saving, and the last successfully loaded TTF path. Settings and Find/Replace use fixed-size centered panel geometry; their glyph sizes and pointer hit maps follow the selected UI font without enlarging the panels. Find paints all literal query matches in amber while the current selected result remains distinct. The no-wrap horizontal viewport includes a draggable bottom thumb, native horizontal-wheel and Shift+vertical-wheel scrolling, caret-following, viewport-aware selection painting, and offset-aware pointer hit-testing. Output/fractional scaling, release-tracked multi-buffer scheduling, and X11 remain future work.

See [docs/WAYLAND_BACKEND.md](docs/WAYLAND_BACKEND.md) for protocol details and [docs/COMPOSE.md](docs/COMPOSE.md) for the Compose table's source and supported subset.

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

The output is **build/nekoedit**. For a per-user installation with a command-line entry and desktop launcher:

~~~sh
make install-user
~~~

The launcher appears in the desktop application menu as **NekoEdit**, and the executable is installed at `~/.local/bin/nekoedit`. Open a terminal and run `nekoedit [FILE]` (or use `~/.local/bin/nekoedit [FILE]` when that directory is not in PATH). The installed `.desktop` entry advertises `text/plain` files under **Open With**. To also make NekoEdit the default plain-text handler, use `make install-user MAKE_DEFAULT=1`; this changes the user's `text/plain` association. To remove the per-user installation, run `make uninstall-user`. A system-wide installation is available through `sudo make install` (or a package build using DESTDIR).

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

NekoEdit loads and saves the document font size, UI font size, Wrap Lines state, Confirm before saving, Clipboard Service state, and last successfully loaded TrueType file. The configuration is stored at `$HOME/.nekoedit/preferences` (normally `~/.nekoedit/preferences`). `XDG_CONFIG_HOME` is intentionally ignored. The directory is created with mode 0700 and the preferences file uses mode 0600. Updates are written to a temporary file, fsynced, and atomically renamed into place.

The environment variable `NEKOEDIT_FONT` still takes priority over the saved font path. When it is absent or invalid, NekoEdit tries the saved path before the deterministic system-font candidates. Set `NEKOEDIT_DISABLE_PREFERENCES=1` to ignore persistent settings (useful for deterministic tests).

The X11 backend is not ready. The explicit selector currently reports this rather than silently trying to use Wayland:

~~~sh
./build/nekoedit --backend=x11
~~~

The CLI also supports --help and --version.

### Tests

- **make test** runs command-line smoke tests, an isolated persistent-preferences roundtrip/validation test, and a host-side disk-backed history test (grouped edits, branching, restart recovery, export, delete, and permissions).
- **make test-wayland** runs a Python 3 mock-compositor integration suite over both `WAYLAND_DISPLAY` and `WAYLAND_SOCKET`. It covers File/Open/Save workflows, picker navigation/autocomplete, rollback on failed Open/Save, a 65,537-byte document, scrollbars, resizing, wrapping, Unicode/grapheme editing, XKB scalar and Compose/dead-key input, word selection/edge auto-scroll, and protocol error handling. Clipboard cases verify independent Ctrl+C/Ctrl+X snapshots, asynchronous external Ctrl+V, Ctrl+Z/Ctrl+Y for that delayed paste, and the bundled `nekoedit-clip` helper destroying the editor toplevel/surface while serving the selection after parent exit, then disconnecting on selection replacement. History UI coverage verifies the filter, Browse picker, Open Selected button, responsive Undo/Redo/Export/Delete History controls, and selected-history removal. All tests use an isolated temporary HOME and a mock compositor; they do not require an installed desktop compositor.
- **make check** rejects an ELF containing PT_INTERP or DT_NEEDED entries.
- **make inspect** prints ELF metadata.

Python 3 is used only by the optional protocol test harness; it is not linked to or required by the NekoEdit executable.

## GitHub Actions

The Build and test workflow runs on pushes to main and pull requests targeting main. It also supports manual execution through the repository's **Actions** tab using workflow_dispatch. A successful run uploads the built Linux x86-64 executable as an artifact.

## Remaining roadmap

- Expand XKB interoperability against real desktop keymaps, broaden consumed-modifier shortcut coverage beyond Control and Shift where NekoEdit adds corresponding shortcuts, and assess remaining `xkb_compat` semantics; stateful modifier/key actions remain compositor-owned on Wayland.
- Keep **en_US.UTF-8 as the built-in default**. A bounded runtime loader now accepts explicitly selected, versioned data-only locale packs from `$HOME/.nekoedit/locales/` via `NEKOEDIT_LOCALE`; missing or malformed packs fall back to built-in en_US. The NLP1 format supports two- to four-scalar inputs and one- to eight-scalar outputs, with size, CRC-32, locale, ordering, prefix, and Unicode-scalar validation. No native library, executable plugin, network access, or automatic download is involved.
- Add more non-en_US locale datasets, broader locale-specific dead-key tables, and optional system/user Compose-file import. Settings now opens a generic picker for any installed `.nlp` pack, provides an explicit Base en_US choice, and supports local Add and confirmed Remove. Automatic character-locale discovery checks `LC_ALL`, `LC_CTYPE`, and `LANG` when no saved choice or NekoEdit-specific override exists.
- Expand Wayland text-input-v3 preedit attributes/cursor handling and validate the protocol against GNOME/Mutter with a live input method.
- More complete typography: hinting, kerning, ligatures, combining-mark positioning, bidirectional layout, CFF/CFF2, and variable/color-font support.
- Output/fractional scaling, release-tracked multi-buffer scheduling, and the X11 backend (including X11 clipboard interoperability).
- Broader system-font discovery and font-family/style selection.
Tabs, syntax highlighting, plugins, rich text, spell checking, auto-completion, and GPU rendering are deliberately out of scope for the initial release.

## Compose locale packs

The core executable embeds default en_US Compose tables. The first non-en_US dataset is `pt_BR.UTF-8`, a complete flattened table derived from pinned X.Org libX11 and xorgproto sources. `tools/import_xcompose.py` regenerates its JSON input; `make locale-packs` builds a separate `.nlp` file, and the Release workflow attaches that asset and its source notice when a GitHub Release is published. In Settings, **Locale** opens a picker for every installed `.nlp` pack, **Base** explicitly selects embedded en_US, **Add** imports a local pack, and **Remove** deletes the selected pack after confirmation. Choices are persisted in `~/.nekoedit/preferences`. Without a saved choice, NekoEdit checks `NEKOEDIT_LOCALE`, then `LC_ALL`, `LC_CTYPE`, and `LANG` in that order. Common pt_BR spellings resolve to the canonical `pt_BR.UTF-8` pack tag. A missing or invalid selected pack leaves en_US active and displays `MISSING`. Packs remain data-only; no network access or runtime shared libraries are required. See [docs/COMPOSE_PACK_FORMAT.md](docs/COMPOSE_PACK_FORMAT.md).

## Document context menu

Right-clicking inside the document viewport opens a small in-surface menu with exactly three commands: **Copy**, **Paste**, and **Cut**. Opening it preserves the current selection. The commands reuse the existing native Wayland clipboard/data-device implementation; Escape and an outside click dismiss the popup.

## Clipboard ownership

Copying must create an independent immutable snapshot of the selected bytes. The snapshot must not point into the document's gap buffer. It remains valid when the copied range is deleted, edited, or its document is closed. Clipboard transfers already in progress keep their own reference to that snapshot until the transfer completes.

The active Wayland implementation retains an independent immutable snapshot while NekoEdit owns the selection and keeps snapshots alive for in-flight sends. It has eight reusable source records, four concurrent outgoing-send slots, and a 64 MiB payload/receive limit; these are resource/concurrency limits rather than a lifetime count of sequential copy/paste commands. When Clipboard Service is enabled, a forked `nekoedit-clip` helper inherits the current Wayland connection and serves the selection after the editor window closes. The helper detaches from the launching terminal, releases the editor's history state, destroys the inherited xdg toplevel/surface/buffer, and retains only the clipboard service loop and its in-flight sends. It exits when another application replaces the selection or the compositor disconnects. This persists only the latest clipboard contents until logout/session teardown; it is not a clipboard-history database. Paste targets the editor document, not picker fields.

See [docs/CLIPBOARD.md](docs/CLIPBOARD.md).

Undo/Redo uses a per-document disk-backed delta journal under `~/.nekoedit/*.history`, with restart recovery guarded by the checksum of the last saved document. The History tab exposes Undo/Redo counts, Export, and Delete for the active document. See [docs/UNDO.md](docs/UNDO.md) for the journal format, recovery rules, and storage limits.

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
4. XKB and keyboard-layout interoperability. Implemented: bounded XKB text-v1 parsing; per-key/per-group types, four groups and eight levels; exact 32-bit modifier maps; up to 24 virtual modifiers; direct and recognized indirect `modifier_map` bindings; bounded `xkb_compat` predicates including the implicit `Exactly(mask)` form, specificity/tie handling, `useModMapMods=level1|any`, and compatibility repeat defaults; per-entry `preserve[]` and per-key consumed Control/Shift shortcut handling. Character translation includes direct `Uxxxx`–`Uxxxxxx` notation and the Unicode-annotated X.Org named keysym set, plus xorgproto 2026.1's SSHARP, single-angle quotation marks, phone-numeric aliases, and `dead_apostrophe`; CI covers Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, and UTF-8 insertion. Six dead-key actions with 52 Latin-1 compositions, the built-in en_US two-/three-symbol `Multi_key` baseline, and a runtime NLP1 loader for optional two- to four-input locale tables with multi-scalar results are implemented. The first external dataset is pt_BR.UTF-8; Settings supports generic selection, local installation, and confirmed removal of installed packs. Optional Wayland text-input-v3 preedit/commit/delete integration is implemented and mock-tested. Remaining: more locale datasets, locale-specific dead-key rules, full system/user Compose import, general stateful XKB actions and indicators (compositor-owned on Wayland), advanced preedit attributes, broader shortcut policy if more modifiers are bound, and live GNOME/Mutter layout/IME verification. Unsupported or malformed keymaps continue to fail closed to the built-in US-QWERTY fallback.
5. Document storage, navigation, Unicode editing, history, and scrolling. Geometric gap-buffer growth, indexed per-line byte/visual-row records and Fenwick trees, Unicode 18.0 grapheme navigation/deletion, vertical/horizontal scrolling, grouped delta-based Ctrl+Z/Y history under `~/.nekoedit/*.history`, and UTF-8 insertion from explicit and curated named XKB Unicode keysyms are implemented. The History tab exposes journal counts, Export, and Delete; restart recovery is guarded by the last-saved document checksum. The six-accent dead-key path and the 2,140-pair/two-symbol plus 564-sequence/three-symbol `Multi_key` Compose paths are also covered by the mock suite. Whole-word mouse drag selection and edge auto-scroll are implemented. The en_US Compose baseline is embedded as the built-in default; optional non-en_US locale packs are separate data-only downloads handled by the bounded runtime loader and generic Settings pack manager. NLP1 supports four-input sequences and multi-scalar outputs. System/user Compose-file import and locale-specific dead-key semantics remain unfinished; advanced Wayland preedit attributes and complex shaping are also incomplete.
6. TrueType parsing, glyph rasterization, proportional advance layout, font-metric line pitch, runtime font selection, and independent document/UI font-size controls are implemented. Persistent document/UI sizes, Wrap Lines, save confirmation, and the selected font path are implemented in `~/.nekoedit/preferences`; advanced shaping remains unfinished.
7. File open/save, the directory-browser picker, Wayland clipboard interoperability (Ctrl+C/X/V), and an optional process-exit clipboard owner (`nekoedit-clip`) are implemented. The helper hands off the same Wayland client connection, needs no extra executable or runtime library, and is toggleable in Settings. X11 clipboard support remains part of the future X11 backend.
8. Output-scale/fractional-scale handling, multi-buffer frame scheduling, X11 backend, compatibility testing, and profiling. Compositor-configured window resizing is implemented.

Correctness and interoperability take priority over arbitrary binary-size targets.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Wayland backend](docs/WAYLAND_BACKEND.md)
- [Clipboard behavior](docs/CLIPBOARD.md)
- [Directory-browser file picker](docs/FILE_PICKER.md)
- [Software rendering and fonts](docs/RENDERING.md)
