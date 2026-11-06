# NekoEdit current status

**Snapshot date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Active PR:** [#1 — feat: add Wayland editing and initial editor UI](https://github.com/GraderGamer2/NekoEdit/pull/1)  
**Development branch:** `feat/wayland-socket-error-handling)  
**Base branch:** `main` (PR #1 remains open; no merge is recorded here)

## Start here when continuing development

Read [CHANGELOG/README.md](README.md), then this file, [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), and [PROJECT_HISTORY.md](PROJECT_HISTORY.md). Use [COMMIT_INDEX.md](COMMIT_INDEX.md) for the complete historic commit list. After that, inspect the current source and run/status of GitHub Actions. Never assume the branch, build, or latest code commit is unchanged.

## Latest verified program state

- Latest fully verified **program-code commit:** `6cd9e08fada059ae3e24c9cdab7cf86762b24414`.
- GitHub Actions [Build and test #160](https://github.com/GraderGamer2/NekoEdit/actions/runs/42213034086) passed for that code commit.
- All pipeline stages passed: freestanding x86-64 assembly/link and ELF verification, command-line smoke tests, full Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Uploaded artifact: `nekoedit-linux-x86_64`.
- Artifact archive SHA-256 reported by GitHub: `aa47ef8e0645e734f7dd7bd072cd31f51cc755907113603de6aebf8ab48917a7`.
- Artifact expiration was reported as 2026-11-13 (seven-day retention).
- Commits after `6cd9e08f` in this retrospective task add changelog documentation only; they do not intentionally modify source, tests, build rules, or the executable.
- The active PR includes the new `CHANGELOG/` records. Check the current PR head and newest Actions run before making a new claim about the latest branch verification.

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
| Document storage | Fixed 64 KiB byte array; not yet a gap buffer |
| ASCII rendering | Embedded 5×7 glyphs for printable ASCII, including the full punctuation set |
| Keyboard layout | Bounded XKB text-v1 subset; common ASCII symbols, groups/levels, Shift/Caps, physical Right-Alt LevelThree, US fallback |
| Keyboard editing | ASCII input, Left/Right/Up/Down, Home/End, Backspace, Delete, Enter, four-space Tab |
| Selection | Mouse drag, reverse/multiline selection, Shift navigation, Ctrl+A, replacement on typing/deletion |
| Repeat | Compositor-configured repeat when available, legacy fallback otherwise |
| Viewport | Soft wrapping and vertical caret-follow scrolling |
| File loading | Positional startup path; staged Open with 64 KiB limit and rollback on failure |
| File saving | Save/Save As, same-directory temporary file, write loop, fsync, close, atomic rename |
| Shortcuts | Ctrl+A, Ctrl+O, Ctrl+S, Ctrl+Shift+S |
| UTF-8 document operations | Valid code-point-aware cursor movement, pointer hit-testing, selection, Backspace and Delete; malformed bytes remain individually editable |

## Important UTF-8 boundary

The latest implementation is an initial **code-point-safe editing** milestone, not full Unicode support:

- Valid 2-, 3-, and 4-byte UTF-8 code points are moved/deleted/selected as complete units.
- Malformed bytes remain individually addressable/editable.
- Non-ASCII code points and malformed bytes currently render as a single `?` placeholder cell.
- Physical keyboard/XKB text insertion remains ASCII-only.
- No Wayland text-input/IME, compose/dead-key system, or non-ASCII keysyms.
- No grapheme-cluster-aware navigation. Combining marks and multi-code-point emoji may still require multiple cursor positions.
- The 64 KiB fixed byte array remains; it is not yet the intended gap buffer.

## Known unfinished work

- Actual UTF-8 gap-buffer document engine and line indexing.
- Unicode glyph lookup/font rendering.
- Non-ASCII keyboard text input, IME, compose and dead-key handling.
- Grapheme-cluster-aware movement and deletion.
- Undo/redo.
- Clipboard copy/cut/paste using the Wayland data-device protocol and immutable snapshots.
- Horizontal scrolling and fuller viewport controls.
- Window resize/reconfigure and output scale handling.
- Graphical directory-browser/file picker, file filters, and unsaved-changes confirmation.
- Full XKB type/modifier/virtual-modifier/action semantics and broader non-ASCII keysyms.
- X11 backend.
- Further real-compositor testing. The mock Wayland compositor is valuable regression coverage but does not replace a GNOME Wayland smoke test.

File-operation limitations: the in-window path prompt is ASCII-only; the temporary save file uses mode 0644 subject to umask; existing file permissions/ownership/ACLs/xattrs are not preserved; the parent directory is not fsynced after rename.

## Current source layout

- `src/entry.S` — freestanding entry point, command-line parsing, backend launch, help/version.
- `src/linux/syscall.S` — low-level syscall helpers.
- `src/backend/wayland.S` — Wayland protocol, window/UI, input, editor buffer, rendering, file operations, UTF-8 code-point helpers.
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

When conducting future work, add any new manual test feedback here or to the dated [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), with the build/commit tested and the exact behavior observed.

## Mandatory changelog maintenance

Every future NekoEdit development task must update `CHANGELOG/DEVELOPMENT_LOG.md`, `CHANGELOG/CURRENT_STATUS.md`, and `CHANGELOG/COMMIT_INDEX.md` as appropriate before that task is considered complete. Update [PROJECT_HISTORY.md](PROJECT_HISTORY.md) when a meaningful milestone is completed. Follow the procedure in [CHANGELOG/README.md](README.md).
