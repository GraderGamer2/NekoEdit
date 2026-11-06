# NekoEdit current status

**Snapshot date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Latest window-management fix:** [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969) — wait for compositor configure after state requests; implement serial-correct title-bar move and edge/corner resize  
**Latest implementation-code tip:** [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969) — configure-driven window-state transitions and interactive Wayland move/resize  
**Latest picker implementation-code tip:** [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519) — selectable filename autocomplete suggestions  
**Latest picker integration-test commit:** [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519) — five-row filename suggestions, keyboard navigation, acceptance, and exact-file opening  
**Latest main-history synchronization:** [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c)  
**Current PR:** [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) — open, targeting `main`  
**Previous PR:** [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged

## Start here when continuing development

Read [CHANGELOG/README.md](README.md), then this file, [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), and [PROJECT_HISTORY.md](PROJECT_HISTORY.md). Use [COMMIT_INDEX.md](COMMIT_INDEX.md) for the complete historic commit list. After that, inspect the current source and run/status of GitHub Actions. Never assume the branch, build, or latest code commit is unchanged.

## Repository coordination state (verified 2026-11-06)

- GitHub Actions [Build and test #245](https://github.com/GraderGamer2/NekoEdit/actions/runs/42245683431) passed all eight workflow steps on autocomplete commit [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519). It covers the selectable filename suggestion popup and opening the exact highlighted second match.
- GitHub Actions [Build and test #246](https://github.com/GraderGamer2/NekoEdit/actions/runs/42247690288) built and linked window-controls commit [`f516fc1a9b31`](https://github.com/GraderGamer2/NekoEdit/commit/f516fc1a9b316aa34a6c07533948822913469f02) and passed CLI smoke tests, but failed in the Wayland mock workflow because the test did not release maximized buffer 256 before Restore. Commit [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419) added the missing compositor `wl_buffer.release`.
- GitHub Actions [Build and test #247](https://github.com/GraderGamer2/NekoEdit/actions/runs/42251823911) built/linked successfully and passed CLI smoke tests. The complete `WAYLAND_DISPLAY` file workflow passed, including Minimize, Maximize, Restore, and title-bar Close. The inherited-`WAYLAND_SOCKET` workflow exposed a mock-harness EOF wait because the parent retained a duplicate of the client endpoint after passing it to the child.
- GitHub Actions [Build and test #248](https://github.com/GraderGamer2/NekoEdit/actions/runs/42252513357) passed all workflow steps on commit [`69b63767d1bc`](https://github.com/GraderGamer2/NekoEdit/commit/69b63767d1bc3223ac9d300b3be056cc9c36c56f), including both Wayland connection transports and the window-control workflow.
- GitHub Actions [Build and test #251](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769) passed **all workflow steps** on [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969): freestanding assembly/link and ELF checks, CLI smoke tests, the complete Wayland mock integration suite through `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`, executable inspection, and artifact upload. The expanded window scenario checks configure-driven Maximize/Restore, no premature stale-size commit, title-bar `xdg_toplevel.move`, left-edge `xdg_toplevel.resize` with the initiating pointer serial, and deferred buffer replacement when configure arrives before `wl_buffer.release`.
- Artifact: `nekoedit-linux-x86_64`, 29,625 bytes, ZIP SHA-256 `3c3a5563fe033772d46bd9209cbfd9fd31a1ae950a69c5851e6813afba6de2c1`, artifact ID `13521663942`, expires 2026-11-13 16:46:27 UTC. [Actions #251 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769/artifacts/13521663942).
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged, with `early-alpha` as head and `main` as base. GitHub reported `mergeable=true` and `mergeable_state=clean` at the last branch check. PR #1 is closed and unmerged.
- `main` still contains the original Wayland prototype rather than the editor implementation. The work described here remains on `early-alpha`; no merge into `main` was performed.
- GitHub Actions [Build and test #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677) passed all eight workflow steps on test commit [`5e7d2d2158eb`](https://github.com/GraderGamer2/NekoEdit/commit/5e7d2d2158ebe560ab7153556e4e25672039bd3d).
- Run #241 passed toolchain inspection, freestanding x86-64 build/ELF checks, CLI smoke tests, the full Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes; ZIP SHA-256 `79a0a6f56a7981ad443f0adaa75c521aa3521f48310d72d272778bb425f195ed`; artifact ID `13513782459`; expires 2026-11-13 15:10:30 UTC. [Run #241 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677/artifacts/13513782459).
- The zero-byte regression now places `empty.txt` at the second regular-file row, with non-empty files before and after it. Both click/Open and double-click are checked for exact active path and zero document length; the single-click route also saves a newly typed byte back to that exact file.
- Run #241 also reran scrolling, scrollbar drag, checkbox, editable location/search, filename-prefix search, XKB, UTF-8, gap-buffer, selection, key-repeat, protocol, and existing save/open tests. Both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` scenarios passed.
- Earlier attempts #224–#240 include failures/cancellations while calibrating BSS state, test fixtures, path-field focus, and Wayland shared-memory release ordering. Runs #235 and #240 passed the consolidated earlier implementation; #241 passed the strengthened nonzero-row empty-file regression.
- GitHub Actions [Build and test #243](https://github.com/GraderGamer2/NekoEdit/actions/runs/42241453789) passed all eight workflow steps on [`51a9b4d49166`](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66), including the new directory-scoped search regression.
- Run #243 verified that a no-match query from the parent directory is cleared after navigating into a directory containing a same-named file; Open with no selected row leaves the picker/document unchanged, while explicitly selecting row 1 opens the exact empty file.
- Artifact: nekoedit-linux-x86_64, 27,249 bytes; SHA-256 d5549748f2e58f95da6cc176d630c087af15efd4b7b298ce6106dce5c484c664; artifact ID 13515965431; expires 2026-11-13 15:16:20 UTC. [Run #243 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42241453789/artifacts/13515965431).

## Latest verified program state

- Latest application/window-management implementation: [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969) — Maximize/Restore/Minimize wait for compositor configure; blank title-bar dragging sends `xdg_toplevel.move`; 6-pixel edges/corners send `xdg_toplevel.resize` with the originating pointer serial; resize configures remain release-gated.
- Earlier Wayland test-harness corrections: [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419) releases the maximized frame before Restore; [`69b63767d1bc`](https://github.com/GraderGamer2/NekoEdit/commit/69b63767d1bc3223ac9d300b3be056cc9c36c56f) closes the parent's duplicate inherited socket FD after spawn.
- Latest picker implementation commit: [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519) — visible filename autocomplete suggestions with keyboard and mouse selection.
- Previous picker source-code change: [`51a9b4d49166`](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66) — clear Open-mode search state on listing rebuilds and require a selected row when the directory list has focus.
- Editable path/name fields: [`01007757a7e2`](https://github.com/GraderGamer2/NekoEdit/commit/01007757a7e234be30b3f32d232da993589df4fc) renders horizontally following text fields and carets; [`b9ed6279c693`](https://github.com/GraderGamer2/NekoEdit/commit/b9ed6279c69353af2cd339e897358f7271d13c94) adds cursor-based keyboard editing; [`f377fc8b589d`](https://github.com/GraderGamer2/NekoEdit/commit/f377fc8b589dd85056999324f85f54552e887242) adds edit helpers and case-insensitive filename-prefix search.
- Empty-file correctness: [`79761ed700db`](https://github.com/GraderGamer2/NekoEdit/commit/79761ed700dbc9a5bfc4064a3e5cca8e60361b1b) added zero-byte Open/Save coverage; [`5e7d2d2158eb`](https://github.com/GraderGamer2/NekoEdit/commit/5e7d2d2158ebe560ab7153556e4e25672039bd3d) strengthens it by placing `empty.txt` at row 1 between ordinary files and checking both activation routes plus a save round-trip.
- Mouse-wheel and scrollbar implementation: [`4cf865d21fbc`](https://github.com/GraderGamer2/NekoEdit/commit/4cf865d21fbc38f7a9563f2c67001f3d01d16d9b) adds vertical `wl_pointer.axis` scrolling and a proportional draggable scrollbar. The hidden-files checkbox and per-session default were corrected in [`5d8212440bd0`](https://github.com/GraderGamer2/NekoEdit/commit/5d8212440bd043342fdb623a27b67f1910bbbc6c) and [`fe3335d43b1a`](https://github.com/GraderGamer2/NekoEdit/commit/fe3335d43b1ac66878d1fb5f9174824e82f08c4f).
- Latest passing integration verification: [Actions run #251](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769), all workflow steps passed on window-management fix `77c8f9884e843d529ea89a317e3a915a245b2969`. Both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` passed the expanded window-control/move/resize scenario; the Linux x86-64 artifact was uploaded. Artifact ID `13521663942`, 29,625 bytes.
- Manual GNOME/Mutter confirmation is **pending**. The automated mock-compositor suite validates request serialization, configure ordering, buffer-release deferral, and both connection transports, but it cannot establish that this specific build no longer crashes inside the user's GNOME session.
- The #241 file-workflow scenario covered zero-byte Open from the second regular-file row (with non-empty files before and after it) via both activation methods; exact active-path and empty-document assertions; and saving back to that exact empty-file path. It also covered wheel scrolling, scrollbar thumb dragging, cursor-positioned path insertion and Backspace, explicit path navigation, filename-prefix search, middle insertion, Backspace, Home/End/Left, forward Delete, and Ctrl+A replacement.
- The same #241 suite reran existing editor, Wayland protocol, XKB punctuation/ONE_LEVEL, gap-buffer, UTF-8, selection, auto-repeat, startup-load, and save regression scenarios through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- The #243 test additionally verifies query clearing after navigation into a directory where the unmatched old query would otherwise be an exact filename; no-selection Open must not activate it.
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
| Editor window | Starts at 800×480; compositor-configured size range 480×360–3840×2160; Maximize/Restore/Minimize wait for configure before repaint; blank title-bar drag requests move; 6-pixel edges/corners request interactive resize; old buffers are replaced only after release |
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
| Native file picker | In-process Open/Save browser; vertical wheel scrolling and draggable scrollbar; real Show hidden checkbox; directory-first list; single/double-click activation; editable location and filename/search fields with caret, Home/End, Left/Right, Backspace/Delete, Ctrl+A; case-insensitive filename-prefix search; up to five selectable autocomplete suggestions (Up/Down, Tab, mouse, Enter); overwrite confirmation |
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
- Output scale handling, fractional scaling, and multi-buffer/frame scheduling. Window resize/reconfigure and dynamic wl_buffer replacement are now implemented; the current renderer keeps one active buffer and waits for release before reusing or replacing it.
- Unsaved-document confirmation before Open replaces an edited document.
- Clipboard paste and Shift-based partial selection in picker fields are not implemented. Path and filename fields now support mouse-positioned cursors, insertion, Left/Right, Home/End, Backspace/Delete, Ctrl+A replacement, and horizontal cursor-follow rendering.
- Directory listings are capped at 128 entries (15 visible rows). Open-mode filename search is a case-insensitive prefix match over the currently loaded regular-file entries; there is no recursive/fuzzy search, bookmarks, filters, or incremental large-directory browsing.
- Symbolic-link navigation is not implemented; the picker navigates directories and opens regular files.
- Full XKB type/modifier/virtual-modifier/action semantics and broader non-ASCII keysyms.
- X11 backend.
- Manual GNOME/Mutter testing of commit `77c8f9884e84` remains pending. The mock tests now cover move/resize requests and configure/buffer-release sequencing, but cannot substitute for running the artifact in the actual GNOME session. Minimize behavior remains compositor policy; the client sends `xdg_toplevel.set_minimized` and does not simulate minimizing itself.

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
- The user reported that opening a zero-byte .txt file sometimes activated another file. The code review identified a reproducible stale-search-across-directory-navigation failure mode and Actions #243 now covers/fixes it. The user has not yet manually re-tested the new artifact in GNOME Wayland; do not mark the desktop report as user-confirmed resolved.

When conducting future work, add any new manual test feedback here or to the dated [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md), with the build/commit tested and the exact behavior observed.

## Mandatory changelog maintenance

Every future NekoEdit development task must update `CHANGELOG/DEVELOPMENT_LOG.md`, `CHANGELOG/CURRENT_STATUS.md`, and `CHANGELOG/COMMIT_INDEX.md` as appropriate before that task is considered complete. Update [PROJECT_HISTORY.md](PROJECT_HISTORY.md) when a meaningful milestone is completed. Follow the procedure in [CHANGELOG/README.md](README.md).
