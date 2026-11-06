# NekoEdit current status

**Snapshot date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Latest picker implementation-code tip:** [`89038d2ac801`](https://github.com/GraderGamer2/NekoEdit/commit/89038d2ac8017c7cedecd800529a399f68e705ca) — return list focus after explicit path navigation  
**Latest picker integration-test commit:** [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49) — correct scrollbar drag-frame release ordering  
**Latest main-history synchronization:** [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c)  
**Current PR:** [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) — open, targeting `main`  
**Previous PR:** [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged

## Start here when continuing development

Read [CHANGELOG/README.md](README.md), then this file, [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), and [PROJECT_HISTORY.md](PROJECT_HISTORY.md). Use [COMMIT_INDEX.md](COMMIT_INDEX.md) for the complete historic commit list. After that, inspect the current source and run/status of GitHub Actions. Never assume the branch, build, or latest code commit is unchanged.

## Repository coordination state (verified 2026-11-06)

- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged, with `early-alpha` as head and `main` as base. GitHub reported `mergeable=true` and `mergeable_state=clean` at the last branch check. PR #1 is closed and unmerged.
- `main` still contains the original Wayland prototype rather than the editor implementation. The work described here remains on `early-alpha`; no merge into `main` was performed.
- GitHub Actions [Build and test #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258) passed all eight workflow steps on head commit [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49).
- Run #235 passed toolchain inspection, freestanding x86-64 build/ELF checks, CLI smoke tests, the full Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes; ZIP SHA-256 `1afeefccb7c594100137e91538d30c0d8e661d026be964c956871c5a9eb64175`; artifact ID `13515385312`; expires 2026-11-13 15:00:57 UTC. [Run #235 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258/artifacts/13515385312).
- Intermediate attempts #224–#234 include failures/cancellations from BSS initialization, test fixture state, path-field focus, and mock-compositor shared-memory release ordering. The consolidated #235 run is the current passing validation.

## Latest verified program state

- Latest picker source-code change: [`89038d2ac801`](https://github.com/GraderGamer2/NekoEdit/commit/89038d2ac8017c7cedecd800529a399f68e705ca) — return keyboard focus to the directory list after a successful explicit path navigation.
- Editable path/name fields: [`01007757a7e2`](https://github.com/GraderGamer2/NekoEdit/commit/01007757a7e234be30b3f32d232da993589df4fc) renders horizontally following text fields and carets; [`b9ed6279c693`](https://github.com/GraderGamer2/NekoEdit/commit/b9ed6279c69353af2cd339e897358f7271d13c94) adds cursor-based keyboard editing; [`f377fc8b589d`](https://github.com/GraderGamer2/NekoEdit/commit/f377fc8b589dd85056999324f85f54552e887242) adds edit helpers and case-insensitive filename-prefix search.
- Empty-file correctness: [`79761ed700db`](https://github.com/GraderGamer2/NekoEdit/commit/79761ed700dbc9a5bfc4064a3e5cca8e60361b1b) adds Open/Save regression coverage for zero-byte files. Both single-click/Open and double-click routes are checked for exact active path and zero document length, followed by a save round-trip.
- Mouse-wheel and scrollbar implementation: [`4cf865d21fbc`](https://github.com/GraderGamer2/NekoEdit/commit/4cf865d21fbc38f7a9563f2c67001f3d01d16d9b) adds vertical `wl_pointer.axis` scrolling and a proportional draggable scrollbar. The hidden-files checkbox and per-session default were corrected in [`5d8212440bd0`](https://github.com/GraderGamer2/NekoEdit/commit/5d8212440bd043342fdb623a27b67f1910bbbc6c) and [`fe3335d43b1a`](https://github.com/GraderGamer2/NekoEdit/commit/fe3335d43b1ac66878d1fb5f9174824e82f08c4f).
- Latest integration verification: [Actions run #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258), all eight steps passed on `d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49`.
- The #235 file-workflow scenario covered zero-byte Open via both activation methods; exact active-path and empty-document assertions; wheel scrolling; scrollbar thumb dragging; cursor-positioned path insertion and Backspace; explicit path navigation; filename-prefix search; middle insertion, Backspace, Home/End/Left, forward Delete, Ctrl+A replacement; and Enter opening the matched empty file.
- The same #235 suite reran existing editor, Wayland protocol, XKB punctuation/ONE_LEVEL, gap-buffer, UTF-8, selection, auto-repeat, startup-load, and save regression scenarios through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- PR #2 remains open and unmerged. The branch ancestry synchronization commit [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c) still preserves the editor implementation on `early-alpha`; no feature code was merged into `main`.

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
| Native file picker | In-process Open/Save browser; vertical wheel scrolling and draggable scrollbar; real Show hidden checkbox; directory-first list; single/double-click activation; editable location and filename/search fields with caret, Home/End, Left/Right, Backspace/Delete, Ctrl+A; case-insensitive filename-prefix search; overwrite confirmation |
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
- Clipboard paste and Shift-based partial selection in picker fields are not implemented. Path and filename fields now support mouse-positioned cursors, insertion, Left/Right, Home/End, Backspace/Delete, Ctrl+A replacement, and horizontal cursor-follow rendering.
- Directory listings are capped at 128 entries (15 visible rows). Open-mode filename search is a case-insensitive prefix match over the currently loaded regular-file entries; there is no recursive/fuzzy search, bookmarks, filters, or incremental large-directory browsing.
- Symbolic-link navigation is not implemented; the picker navigates directories and opens regular files.
- Full XKB type/modifier/virtual-modifier/action semantics and broader non-ASCII keysyms.
- X11 backend.
- Further real-compositor testing. The mock Wayland compositor is valuable regression coverage but does not replace a GNOME Wayland smoke test.

File-operation limitations: picker path and filename typing is ASCII-only; non-ASCII filename bytes are preserved for filesystem operations but displayed through replacement glyphs. Clipboard paste into picker fields is not implemented. The temporary save file uses mode 0644 subject to umask; existing file permissions/ownership/ACLs/xattrs are not preserved; the parent directory is not fsynced after rename.

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
