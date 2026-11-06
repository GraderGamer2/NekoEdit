# NekoEdit current status

**Snapshot date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Latest implementation-code tip:** [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd) — terminate relative picker target paths  
**Latest picker regression-test fixture:** [`5f3199593694`](https://github.com/GraderGamer2/NekoEdit/commit/5f31995936943493116dc51045bf933fa9492627)  
**Latest main-history synchronization:** [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c)  
**Current PR:** [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) — open, targeting `main`  
**Previous PR:** [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged

## Start here when continuing development

Read [CHANGELOG/README.md](README.md), then this file, [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), and [PROJECT_HISTORY.md](PROJECT_HISTORY.md). Use [COMMIT_INDEX.md](COMMIT_INDEX.md) for the complete historic commit list. After that, inspect the current source and run/status of GitHub Actions. Never assume the branch, build, or latest code commit is unchanged.

## Repository coordination state (verified 2026-11-06)

- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) is open and unmerged, with `early-alpha` as head and `main` as base. GitHub has reported `mergeable=true` and a clean merge state after the passing picker implementation run. PR #1 is closed and unmerged.
- `main` still contains the original Wayland prototype rather than the editor implementation. The active editor work remains on `early-alpha`; no merge into `main` was performed.
- GitHub Actions [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800) passed all eight workflow steps on implementation commit [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd).
- Run #208 passed the freestanding x86-64 build/ELF checks, CLI smoke tests, complete Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 24,492 bytes; ZIP SHA-256 `f157014623b7beb16b954a67a7cdcdc70304371cdeefb36f4615e0df35a62782`; artifact ID `13511065251`; expires 2026-11-13 14:13:07 UTC. [Run #208 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800/artifacts/13511065251).
- Intermediate picker runs #199–#207 failed while exposing and correcting test-pixel mistakes, stale double-click history after directory navigation, diagnostic string trimming, and a missing NUL terminator in relative target paths. The #208 run is the current passing verification; earlier failures remain visible in Actions history.

## Latest verified program state

- Latest picker implementation-code commit: [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd) — explicitly terminate relative target paths after copying filenames, preventing stale suffix bytes from a previous longer target.
- Picker navigation regression fix: [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82) — reset prior row/time double-click state whenever the directory listing is rebuilt.
- Latest strengthened picker test commit: [`5f3199593694`](https://github.com/GraderGamer2/NekoEdit/commit/5f31995936943493116dc51045bf933fa9492627) — checks the exact active path and loaded document byte after nested navigation, along with an unobscured glyph pixel.
- Latest full verification: [Actions run #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800), all eight steps passed on `07bc16d71ac5940d206d31a792e46ec6f130c7fd`.
- The same #208 integration suite reran the established XKB ONE_LEVEL/shifted-punctuation, gap-buffer, UTF-8, selection, repeat, protocol, startup-load, and file-workflow scenarios. The XKB implementation fix remains [`267ef0557b8e`](https://github.com/GraderGamer2/NekoEdit/commit/267ef0557b8e00bd01eae004ed346dde16977e3f).
- PR #2 remains the active review for `early-alpha`, open and unmerged. PR #1 is historical, closed, and unmerged.
- The branch ancestry synchronization commit [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c) still has `main` as its first parent and preserves the earlier development history as its second parent; editor implementation has not been merged into `main`.

## Runtime and build interface

The application is a freestanding Linux x86-64 GNU assembly program, linked without a C runtime or third-party shared-library dependencies.

Build and test from the repository root:

```sh
make clean all
make test
make test-wayland
make inspect
```

The Makefile output is `build/nekoedit`. Run the Wayland build with:

```sh
./build/nekoedit --backend=wayland
```

The standalone binary can be run using the established form:

```sh
./nekoedit --backend=wayland
```

A file can be loaded positionally:

```sh
./build/nekoedit /path/to/document.txt
```

Do not change the existing `--backend=wayland` launch behavior as a shortcut for implementing missing editor features. The editor functionality belongs inside the application.

## Implemented functionality

| Area | Current state |
|---|---|
| x86-64 startup and syscalls | Freestanding GNU assembly; direct Linux syscalls |
| Runtime dependencies | No third-party shared-library/runtime dependency |
| Wayland connection | `WAYLAND_DISPLAY`, absolute socket path, and inherited `WAYLAND_SOCKET` |
| Wayland setup | Registry, compositor, shm, xdg-shell, configure, ping/pong, close, protocol-error reporting |
| Rendering | CPU software rendering into a memfd-backed shared-memory buffer |
| Editor window | 800×480 UI with header, File menu, active document tab, editor area, and live status bar |
| Document storage | Fixed-capacity 64 KiB byte-oriented gap buffer; cursor/selection offsets remain logical byte offsets; no dynamic growth yet |
| ASCII rendering | Embedded 5×7 glyphs for printable ASCII, including the full punctuation set |
| Keyboard layout | Bounded XKB text-v1 subset; common ASCII symbols, groups/levels, ONE_LEVEL/ALPHABETIC/THREE_LEVEL/FOUR_LEVEL type families, Shift/Caps, physical Right-Alt LevelThree, US fallback |
| Keyboard editing | ASCII input, Left/Right/Up/Down, Home/End, Backspace, Delete, Enter, four-space Tab |
| Selection | Mouse drag, reverse/multiline selection, Shift navigation, Ctrl+A, replacement on typing/deletion |
| Repeat | Compositor-configured repeat when available, legacy fallback otherwise |
| Viewport | Soft wrapping and vertical caret-follow scrolling |
| File loading | Positional startup path; staged picker Open with 64 KiB limit and rollback on failure |
| File saving | Save/Save As, same-directory temporary file, write loop, fsync, close, atomic rename; picker overwrite confirmation |
| Shortcuts | Ctrl+A, Ctrl+O, Ctrl+S, Ctrl+Shift+S |
| Native file picker | In-process Open/Save browser; path/name fields; Up/Home; hidden-file toggle; directory-first list; single-click selection and double-click activation; keyboard navigation; overwrite confirmation |
| UTF-8 document operations | Valid code-point-aware cursor movement, pointer hit-testing, selection, Backspace and Delete; malformed bytes remain individually editable |

## Important UTF-8 boundary

The latest implementation is an initial **code-point-safe editing** milestone, not full Unicode support:

- Valid 2-, 3-, and 4-byte UTF-8 code points are moved/deleted/selected as complete units.
- Malformed bytes remain individually addressable/editable.
- Non-ASCII code points and malformed bytes currently render as a single `?` placeholder cell.
- Physical keyboard/XKB text insertion remains ASCII-only.
- No Wayland text-input/IME, compose/dead-key system, or non-ASCII keysyms.
- No grapheme-cluster-aware navigation. Combining marks and multi-code-point emoji may still require multiple cursor positions.
- The gap buffer is still bounded by a fixed 64 KiB allocation; files larger than 64 KiB remain unsupported and the storage does not yet grow.

## Known unfinished work

- Dynamic gap-buffer growth beyond 64 KiB and a line-start index.
- Unicode glyph lookup/font rendering.
- Non-ASCII keyboard text input, IME, compose and dead-key handling.
- Grapheme-cluster-aware movement and deletion.
- Undo/redo.
- Clipboard copy/cut/paste using the Wayland data-device protocol and immutable snapshots.
- Horizontal scrolling and fuller viewport controls.
- Window resize/reconfigure and output scale handling.
- Unsaved-document confirmation before Open replaces an edited document.
- More complete path/filename editing: caret repositioning, in-field insertion, and clipboard paste are not implemented; current entry is ASCII-only with append/backspace/clear behavior.
- Directory listings are capped at 128 entries (15 visible rows); no filters, bookmarks, search, or incremental large-directory browsing.
- Symbolic-link navigation is not implemented; the picker navigates directories and opens regular files.
- Full XKB type/modifier/virtual-modifier/action semantics and broader non-ASCII keysyms.
- X11 backend.
- Further real-compositor testing. The mock Wayland compositor is valuable regression coverage but does not replace a GNOME Wayland smoke test.

File-operation limitations: picker path and filename entry is ASCII-only; non-ASCII filename bytes are preserved for filesystem operations but displayed through replacement glyphs. The temporary save file uses mode 0644 subject to umask; existing file permissions/ownership/ACLs/xattrs are not preserved; the parent directory is not fsynced after rename.

## Current source layout

- `src/entry.S` — freestanding entry point, command-line parsing, backend launch, help/version.
- `src/linux/syscall.S` — low-level syscall helpers.
- `src/backend/wayland.S` — Wayland protocol, window/UI, input, fixed-capacity gap-buffer document storage, rendering, file operations, UTF-8 code-point helpers.
- `src/backend/xkb.S` — bounded XKB text-v1 parser and ASCII symbol lookup.
- `tests/smoke.sh` — CLI smoke tests.
- `tests/wayland_mock.py` — mock compositor and end-to-end protocol/editor regression tests.
- `Makefile` — assemble, link, ELF checks, tests, inspection.
- `.github/workflows/build.yml` — CI and artifact upload.
- `docs/` — architecture, Wayland, rendering, file picker, and clipboard design documents.
- `CHANGELOG/` — durable continuity and development history.

## User-reported desktop validation

Keep these separate from the automated test results:

- The user confirmed that typing the previously problematic printable symbol sequence `!@#$%^&*()_+{}|:"<>?` works in the tested Actions build.
- After the UTF-8 code-point-safe milestone, the user reported that the UTF-8 formatting looked fine and earlier implementations remained usable.
- Latest user-reported test of a newer Actions build: ordinary letter keys worked again, but most shifted punctuation/symbol keys rendered as `?`; only a subset including `<>`, `:"`, and `()` rendered correctly. The exact run/artifact for this particular report was not identified. Treat this as an outstanding keyboard regression; mock-compositor CI does not establish that it is fixed.
- The patched ONE_LEVEL/punctuation implementation passed mock-compositor CI #186 and the subsequent full branch-sync run #187, but the user has not yet re-tested that patched artifact in the real GNOME Wayland session. Keep the desktop-symbol regression marked **awaiting manual confirmation**.

When conducting future work, add any new manual test feedback here or to the dated [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), with the build/commit tested and the exact behavior observed.

## Mandatory changelog maintenance

Every future NekoEdit development task must update `CHANGELOG/DEVELOPMENT_LOG.md`, `CHANGELOG/CURRENT_STATUS.md`, and `CHANGELOG/COMMIT_INDEX.md` as appropriate before that task is considered complete. Update [PROJECT_HISTORY.md](PROJECT_HISTORY.md) when a meaningful milestone is completed. Follow the procedure in [CHANGELOG/README.md](README.md).
