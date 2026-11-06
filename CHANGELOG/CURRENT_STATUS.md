# NekoEdit current status

**Snapshot date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Implementation tip preserved by the rename:** [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0)  
**Base branch:** `main`  
**Development PR:** [#1 — feat: add Wayland editing and initial editor UI](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged (verified 2026-11-06)

## Start here when continuing development

Read [CHANGELOG/README.md](README.md), then this file, [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), and [PROJECT_HISTORY.md](PROJECT_HISTORY.md). Use [COMMIT_INDEX.md](COMMIT_INDEX.md) for the complete historic commit list. After that, inspect the current source and run/status of GitHub Actions. Never assume the branch, build, or latest code commit is unchanged.

## Repository coordination state (verified 2026-11-06)

- GitHub now lists `early-alpha`; a branch search for the former name `feat/wayland-socket-error-handling` returns no branch. The rename preserved the implementation tip at `6f9d17a3a09eaabf1393db214868fe57716ac7c0`.
- GitHub Actions [Build and test #174](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217617434) passed against that exact commit before the branch rename. All eight workflow steps succeeded, including the freestanding build/ELF checks, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload. The workflow correctly records the branch name that existed when it ran.
- PR #1 is currently **closed and unmerged**. The GitHub Pull Requests API still reports its `head.ref` as the former branch name, even though that branch ref no longer exists. This record does not infer why the PR was closed. No PR state or metadata was changed during this documentation update.
- At verification, `main` pointed to `f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d`. The main branch remains the original Wayland prototype; these changelog updates do not merge the editor implementation.
- This is repository administration and documentation only. No editor source, tests, build files, or runtime behavior were changed.

## Latest verified program state

- Latest fully verified **program-code commit:** `776a72c07579ced1e54929946de65cea6271267e` — fixed-capacity 64 KiB gap-buffer document storage.
- Main-to-feature ancestry synchronization point: [merge commit `379a34981fc6`](https://github.com/GraderGamer2/NekoEdit/commit/379a34981fc697be322063458b44ff4dd9a1e72d), with `main` as first parent and prior development history as second parent. Later changes in this session were documentation-only.
- Current `main` head: [`f31dc4177c78`](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d); changelog files are mirrored on both branches.
- PR #1 is closed and unmerged as of the 2026-11-06 API check; its returned head ref still uses the former branch name.
- GitHub Actions [Build and test #171](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217176741) passed on the synchronized feature branch head. All eight steps succeeded, including the complete Wayland integration suite and artifact upload.
- The #171 artifact is `nekoedit-linux-x86_64` (18,978 bytes), SHA-256 `2fa05d8a3b0f2b4422a4d4f81c1ebd3f701ea6d74c97221f467bf1b3ea9dbebf`, expiring 2026-11-13.
- GitHub Actions [Build and test #169](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216369360) passed for this commit on 2026-11-06.
- All eight workflow steps passed: toolchain inspection, freestanding x86-64 build/ELF verification, CLI smoke tests, complete Wayland mock-compositor integration, executable inspection, and artifact upload.
- Uploaded artifact: `nekoedit-linux-x86_64` (18,978 bytes).
- Artifact SHA-256: `dae27df70c60ae73c4bd45e494b10c7c47c7d0962c86c8876f48ab00965b515a`.
- Artifact expiration: 2026-11-13 (seven-day retention).
- The new integration scenario exercised gap movement around a mixed-width UTF-8 prefix, insertion on both sides of the gap, Backspace, Delete, selection deletion, and serialization of the two physical document segments.
- The changelog was separately installed on `main` by docs-only commit [`9377c5c9c4bf`](https://github.com/GraderGamer2/NekoEdit/commit/9377c5c9c4bfee8a6a6ea4b8f27be451e85bf6e8), then updated to include the gap-buffer milestone by [`f31dc4177c78`](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d). Main’s changelog sync run #170 passed. Neither commit merges the editor implementation; `main` remains the original prototype.
- PR #1 is closed and unmerged; GitHub still reports the former head ref in PR metadata. Recheck live refs and PR state before any future development.

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
- Graphical directory-browser/file picker, file filters, and unsaved-changes confirmation.
- Full XKB type/modifier/virtual-modifier/action semantics and broader non-ASCII keysyms.
- X11 backend.
- Further real-compositor testing. The mock Wayland compositor is valuable regression coverage but does not replace a GNOME Wayland smoke test.

File-operation limitations: the in-window path prompt is ASCII-only; the temporary save file uses mode 0644 subject to umask; existing file permissions/ownership/ACLs/xattrs are not preserved; the parent directory is not fsynced after rename.

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

When conducting future work, add any new manual test feedback here or to the dated [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), with the build/commit tested and the exact behavior observed.

## Mandatory changelog maintenance

Every future NekoEdit development task must update `CHANGELOG/DEVELOPMENT_LOG.md`, `CHANGELOG/CURRENT_STATUS.md`, and `CHANGELOG/COMMIT_INDEX.md` as appropriate before that task is considered complete. Update [PROJECT_HISTORY.md](PROJECT_HISTORY.md) when a meaningful milestone is completed. Follow the procedure in [CHANGELOG/README.md](README.md).
