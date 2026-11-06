# NekoEdit development log

This is an append-only narrative log. New entries go at the top, with the newest work first. The complete historical narrative is in [PROJECT_HISTORY.md](PROJECT_HISTORY.md); the full SHA/subject ledger is in [COMMIT_INDEX.md](COMMIT_INDEX.md).

---

## 2026-11-06 — Strengthen zero-byte Open coverage for a non-first list row

**Purpose:** Investigate the user-reported case where opening an empty text file appeared to select another file. The active branch already contained zero-byte Open/Save tests and the completed scrolling, checkbox, and editable search-field implementation. The existing empty-file fixture, however, placed `empty.txt` at the first regular-file row. This follow-up tests the same operation with ordinary files before and after the empty target.

### Regression fixture change

- Added non-empty `aaa.txt` and `zzz.txt` fixtures around `empty.txt`, while retaining `inside.txt` and the hidden-file fixture.
- With hidden files disabled, the sorted regular-file order now places `empty.txt` at row 1, after `aaa.txt`; the Open-button test selects that second file row rather than row 0.
- The double-click route uses the same nonzero row. Both activation paths still verify the exact active path and `doc_length == 0`; the single-click/Open route then inserts one byte, saves with Ctrl+S, and checks that only that byte appears in `empty.txt`.
- Updated the separate `inside.txt` navigation/save regression to select its new row position after adding the surrounding fixtures.
- This is deliberately a test-hardening change, not a claim that a new assembly loader defect was found. Inspection of `load_document_from_path` confirmed that a successful zero-byte read sets `doc_length` and the gap-buffer start to zero. The pointer-selection path is now exercised against a nonzero row with neighboring regular files.

### Verification

- GitHub Actions [Build and test #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677) passed **all eight workflow steps** on test commit [`5e7d2d2158eb`](https://github.com/GraderGamer2/NekoEdit/commit/5e7d2d2158ebe560ab7153556e4e25672039bd3d): freestanding build/ELF checks, CLI smoke tests, complete Wayland mock-compositor integration, executable inspection, and artifact upload.
- The file-workflow test passed for both single-click/Open and double-click of `empty.txt` from row 1, with the exact active path and zero document length. The same integration sequence passed nested-file Open/Save, mouse-wheel scrolling, scrollbar dragging, editable location/search fields, and prefix matching.
- The same workflow also exercised the established Wayland, XKB punctuation/ONE_LEVEL, gap-buffer, UTF-8, selection, key-repeat, and protocol tests through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes, artifact ID `13513782459`, SHA-256 `79a0a6f56a7981ad443f0adaa75c521aa3521f48310d72d272778bb425f195ed`, expires 2026-11-13 15:10:30 UTC. [Download from Actions run #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677/artifacts/13513782459).

### Scope and remaining validation

- No application source or runtime behavior changed in this follow-up; no runtime dependencies were added. The wheel/scrollbar, checkbox, and editable path/search implementation is already present in the active `early-alpha` source and is rerun by #241.
- The mock compositor now covers the reported selection shape more closely, but it cannot reproduce every GNOME mouse/compositor interaction. The user's original desktop symptom remains **awaiting manual confirmation** against the #241 artifact.
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; no change was made to `main`.

---

## 2026-11-06 — Correct empty-file Open, add picker scrolling, and finish editable path/search fields

**Purpose:** Respond to picker testing feedback by verifying zero-byte Open behavior, adding mouse-wheel and scrollbar navigation, converting the hidden-files indicator into a normal checkbox, and making the location and filename/search fields genuinely editable. The implementation remains in the freestanding GNU assembly Wayland backend, with no third-party runtime dependency.

### Empty-file Open and stale-selection correctness

- Added a zero-byte `nested-dir/empty.txt` fixture and exercised both activation paths: single-click followed by the Open button, and double-click directly on the file.
- Each route checks the exact active document pathname and verifies `doc_length == 0`. The single-click route then types one byte, presses Ctrl+S, and verifies that the exact empty file now contains only that byte.
- Strengthened the selection/search state so keyboard movement refreshes the filename field from the newly highlighted regular file. Open confirmation uses the current explicit prefix-match state; when a typed prefix has no match, an older row selection is not silently reused.
- A successful edited-path navigation returns focus to the directory list. That keeps subsequent typing in the filename/search field rather than unexpectedly extending the location field.

### Mouse scrolling and checkbox interaction

- Routed the core Wayland `wl_pointer.axis` vertical-axis event into the picker. Smooth 24.8 fixed-point deltas are accumulated and converted into list-row movement without discarding fractional remainder.
- Added a proportional scrollbar thumb, track click/drag behavior, and a drag-state visual. The directory list remains capped at 128 entries with 15 rows visible at a time.
- Added a regression fixture with more than two viewport pages. It checks wheel-down by three rows, drag-to-bottom, and wheel-up by one row.
- The first checkbox revision left only the small box clickable; the label is now clickable too. Each new dialog starts with hidden files disabled, and the checkbox has a bordered square with a visible check mark when enabled.
- The scrollbar test harness was corrected to honor Wayland buffer lifetime: it releases the shared-memory frame after the drag redraw before requesting the separate pointer-release redraw. Earlier timeout/SIGPIPE failures were test-side buffer-release ordering, not a failure of wheel movement or thumb dragging.

### Editable location and filename/search fields

- The location and filename fields now have explicit byte cursors. Clicking positions the cursor at the nearest visible character; the text viewport follows the cursor horizontally when the field is longer than the available width.
- Both fields support insertion at the cursor, Left/Right, Home/End, Backspace, forward Delete, and Ctrl+A replacement. The UI draws the caret and a field-selection highlight.
- In Open mode, the filename field is labeled **SEARCH** and performs case-insensitive prefix matching against regular files in the current in-memory directory listing. A match selects and scrolls the first matching file into view. No match clears the previous selection; the text remains available as a literal path/name input rather than reusing an unrelated old row.
- In Save mode, the field remains **FILE NAME** and retains relative/absolute Save As and overwrite confirmation behavior.
- The path field can be edited in the middle and committed with Enter to navigate to that directory. The path is still passed directly to filesystem syscalls; no shell command or external file manager is involved.

### Regression tests and verification

- The expanded Wayland workflow verifies both zero-byte activation routes and the exact active path/document length, then checks typing and Ctrl+S against that same file.
- The same test sequence verifies wheel scrolling, proportional thumb geometry, thumb dragging, location-field mouse-positioned insertion and Backspace, explicit path navigation, filename prefix selection, mid-string insertion and Backspace, Home/End/Left, forward Delete, Ctrl+A replacement, and Enter opening the exact matching empty file.
- GitHub Actions [Build and test #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258) passed **all eight workflow steps** on head commit [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49): toolchain inspection, freestanding x86-64 build and ELF checks, CLI smoke tests, the full Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Run #235 exercised both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` test transports. The file-workflow observation confirms zero-byte Open through single-click/Open and double-click, wheel scrolling, scrollbar dragging, editable path navigation, cursor-based filename edits, Ctrl+A replacement, and filename prefix search.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes, artifact ID `13515385312`, SHA-256 `1afeefccb7c594100137e91538d30c0d8e661d026be964c956871c5a9eb64175`, expires 2026-11-13 15:00:57 UTC. [Download from Actions run #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258/artifacts/13515385312).
- Intermediate runs #224–#234 include failed or cancelled attempts while the tests were being calibrated. They exposed the BSS zero-initialization requirement, stale hidden-file test state, field-navigation focus handling, and Wayland shared-memory buffer-release ordering. The passing #235 result is the validation for the consolidated state; the intermediate history remains in GitHub Actions.

### Remaining limits and manual validation

- Path and filename editing remains ASCII-only. Non-ASCII filesystem names remain usable as raw filename bytes in the listing and filesystem calls, but non-ASCII typed input and Unicode glyph display are not supported.
- Clipboard paste is not implemented; it requires the Wayland data-device protocol and belongs in a separate clipboard milestone. There is no Shift-based partial text selection in these picker fields; Ctrl+A selects the whole field.
- Filename search is a case-insensitive prefix search over the current directory's loaded regular-file entries. It is not recursive, fuzzy, or an on-disk search index. Listings remain capped at 128 entries (15 visible rows).
- The picker does not follow symbolic links, does not ask before discarding an edited document on Open, and does not yet provide file filters, bookmarks, or incremental large-directory enumeration.
- CI uses a mock Wayland compositor. No real GNOME Wayland desktop smoke test has been performed for this updated picker. The prior shifted-symbol keyboard report also remains awaiting manual confirmation against a current artifact.

### Scope and commits

- The supported launch form remains `./nekoedit --backend=wayland`; the Makefile build output remains `./build/nekoedit`.
- The code and tests added no third-party runtime or shared-library dependency. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; no change was made to `main`.
- The picker/scroll/edit/test commits from 2026-11-06 14:39–15:00 UTC are individually recorded in [`COMMIT_INDEX.md`](COMMIT_INDEX.md).

---

## 2026-11-06 — Complete and stabilize the native directory-browser file picker

**Purpose:** Resume NekoEdit development from the repository's existing picker implementation, inspect the active source and regression tests, and bring the native Open/Save directory browser to a fully passing automated integration state without changing the established launch command or adding runtime dependencies.

### Implementation brought to a verified state

- The active `early-alpha` source already contained the native in-window picker work: a modal Open/Save browser rendered by the Wayland software renderer, with a path field, Up and Home navigation, a hidden-files toggle, directory-first/file-second listing, filename field, and Cancel/Open actions.
- The picker uses direct Linux filesystem syscalls and keeps the file workflow inside the freestanding assembly application. No GTK, Qt, portal, D-Bus, external file manager, C runtime, or third-party shared-library dependency was added.
- Open mode supports listing selection, double-click directory entry, double-click regular-file opening, and keyboard activation/navigation. Save mode uses the same browser, supports relative and absolute destinations, and asks before replacing an existing target.
- The existing mock-compositor workflow covers Untitled Save, named Save, Open, nested-directory navigation, hidden-file visibility, Save As, overwrite confirmation/cancellation, missing/oversized Open rollback, failed Save As rollback, and Escape cancellation.

### Defects found and corrected

- Early picker tests sampled an unlit column in the first row of the H/N glyphs. The final assertions sample an unobscured lit glyph column and, more importantly, also inspect the actual active path and loaded document byte. This avoids treating a pixel coincidence as proof that the correct file opened.
- Re-entering a directory could carry the previous directory's double-click row index and timestamp into the new listing. A first click on row zero could then be treated as a second click from the prior directory. `picker_scan_directory` now resets both click-history fields every time it rebuilds a listing. This is implemented in [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82).
- The strengthened test exposed stale bytes in `picker_target_buffer`: the relative filename-copy loop stopped at the source NUL but failed to write a new NUL into the destination. Opening a shorter name after a longer one could therefore generate a target such as `inside.txtte`. The loop now explicitly terminates the new target path. This is implemented in [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd).
- Test-only process-memory diagnostics were added to report the current document path, target path, picker selection, and loaded bytes when an integration assertion fails. The fixture also correctly trims those values at actual NUL bytes. These diagnostics made the mis-navigation and stale-path failures distinguishable from rendering assertions.

### Regression history and verification

- Intermediate Actions runs **#199–#207** failed during test development. The failures exposed invalid glyph-pixel samples, stale double-click state across directory scans, and the missing target-path terminator; a diagnostic-fixture NUL-escaping mistake was also corrected. Those failed runs are retained in GitHub history rather than being represented as successful validation.
- GitHub Actions [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800) passed **all eight workflow steps** on implementation commit [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd): toolchain inspection, freestanding x86-64 build and ELF checks, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload.
- The file-workflow scenario specifically verified opening the hidden file, navigating Up and re-entering the nested directory, opening the exact `inside.txt` path, replacing its document contents, and saving the exact nested file with Ctrl+S. It also verified Save As overwrite confirmation/cancellation and rollback on failed or oversized operations.
- Artifact: `nekoedit-linux-x86_64`, 24,492 bytes, artifact ID `13511065251`, SHA-256 `f157014623b7beb16b954a67a7cdcdc70304371cdeefb36f4615e0df35a62782`, expires 2026-11-13 14:13:07 UTC. [Download from Actions run #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800/artifacts/13511065251).

### Remaining limits and manual validation

- The picker currently stores at most 128 entries per directory listing and displays 15 rows at a time. It is a document Open/Save utility, not a general-purpose file manager.
- Path and filename input is currently ASCII-only and supports simple append/backspace/clear behavior; caret repositioning, in-field insertion, and clipboard paste are not implemented. Non-ASCII filename bytes remain available to filesystem operations but render through the safe replacement glyph path.
- Unsaved-document confirmation, richer path/name editing, symlink navigation, file filters, and clipboard integration remain unfinished.
- CI uses a mock Wayland compositor. No real GNOME Wayland desktop smoke test has been performed for this picker build. The previously reported shifted-symbol keyboard regression also remains awaiting confirmation against a current artifact in the user's desktop session.

### Scope and commits

- The supported launch form remains `./nekoedit --backend=wayland`; the Makefile build output remains `./build/nekoedit`.
- The picker and regression work added no runtime dependency and did not merge PR #2. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, targeting `main`.
- The individual picker implementation, regression-test, diagnostic, and correction commits are indexed in [`COMMIT_INDEX.md`](COMMIT_INDEX.md), including the final click-state fix and target-path termination fix.

---

## 2026-11-06 — Correct XKB ONE_LEVEL handling and expand shifted-punctuation tests

**Purpose:** Address the reported case where ordinary keys worked but many shifted punctuation keys displayed `?`. Inspection found that the bounded XKB type classifier collapsed ONE_LEVEL into the generic non-alphabetic path, so a one-symbol key could select an empty Level 2 slot while Shift was held.

### Implementation

- Added an explicit ONE_LEVEL type flag in `src/backend/xkb.S`. The lookup now forces Level 1 for ONE_LEVEL keys regardless of Shift, Caps Lock, or LevelThree state, instead of attempting to read a nonexistent second level.
- Kept the existing ALPHABETIC and three-/four-level handling unchanged. This is a targeted correction within the project's bounded XKB text-v1 subset, not full libxkbcommon-equivalent XKB support.
- Updated `README.md`, `docs/WAYLAND_BACKEND.md`, and `CHANGELOG/CURRENT_STATUS.md` to describe the currently supported common ONE_LEVEL/ALPHABETIC/THREE_LEVEL/FOUR_LEVEL families.

### Regression coverage and CI

- Extended `tests/wayland_mock.py` with actual Wayland key events for shifted grave/tilde, bracket/brace, semicolon/colon, apostrophe/quote, comma/less-than, period/greater-than, and slash/question keys, plus a ONE_LEVEL keypad key while Shift is active.
- The first CI attempt, [Build and test #185](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223115089), failed in the new test at the bracket key. The build/ELF verification and CLI smoke tests had passed; the Wayland integration test exposed incorrect fixture metadata: the added entries used raw evdev numbers, while the XKB fixture must declare the XKB keycode (evdev + 8).
- Corrected the fixture in [commit `b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b), also removing an accidental duplicate AB09 entry. The physical key events still use evdev keycodes as required by Wayland.
- The corrected [Build and test #186](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121) passed all eight workflow steps on `b260457007589469abdb492358b7581558c0cc5b`: freestanding build/link, ELF dependency checks, CLI smoke tests, complete Wayland mock integration, executable inspection, and artifact upload.
- The XKB scenario verified the evdev-to-XKB +8 lookup, group switching, Shift/LevelThree, all twelve shifted number-row symbols, the added shifted punctuation rows, ONE_LEVEL Shift behavior, and the exact saved document bytes. The complete suite also passed the UTF-8, gap-buffer, file-workflow, protocol-error, and sparse-keymap fallback scenarios.
- Artifact from #186: `nekoedit-linux-x86_64`, 19,009 bytes, SHA-256 `a27b9571cf9752c947ff7700f012320316db4e720bba195773ec8647644a8d7b`, artifact ID `13504771747`, expires 2026-11-13. [Run #186 artifacts](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121/artifacts/13504771747).
- The post-sync [Build and test #187](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584) also passed all eight steps on merge commit `3a1b2bb9bed50e15bbd37da634505fead4f7724c`. Artifact ID `13504384311`, 19,009 bytes, SHA-256 `f0b63d507d2057dc46c8524ffc3e4f15d01dc9b1f09005ffcb3bc700acde98e5`, expires 2026-11-13. [Run #187 artifacts](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584/artifacts/13504384311).

### Manual verification still needed

- The latest user-reported desktop issue (most shifted punctuation showing `?`) has not yet been manually re-tested against this patched artifact in the user's GNOME Wayland session. The mock compositor validates a controlled synthetic keymap, not every installed layout or GNOME modifier map.
- After downloading the #186 artifact, run it with the unchanged command `./nekoedit --backend=wayland` and test the full shifted punctuation sequence on the actual active layout. Report which physical keys still fail, if any. Do not call the user's desktop regression fully resolved until this check succeeds.

### Scope

- No third-party runtime libraries or external dependencies were added. The launch interface and document model are unchanged.
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, unmerged, and mergeable with a clean state at the time of this update.
- The changelog update was committed as [`8fa6e2282703`](https://github.com/GraderGamer2/NekoEdit/commit/8fa6e2282703d164dcab2ecb096b9416523957ac). Because `main` contained separate changelog-only commits, the PR briefly became dirty. Created synchronization merge [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c), with `main` as first parent and the previous `early-alpha` head as second parent; it preserved the entire development tree and brought the PR back to 0 commits behind / clean mergeability.
- Commits: [`267ef0557b8e`](https://github.com/GraderGamer2/NekoEdit/commit/267ef0557b8e00bd01eae004ed346dde16977e3f) (parser + regression test + docs); [`b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b) (fixture keycode correction).

---

## 2026-11-06 — Open replacement pull request #2 for early-alpha

**Purpose:** Attach the renamed development branch to an active review so GitHub's recent-push prompt has a pull-request destination. The user explicitly authorized opening a pull request if required to clear the repository notification.

### Pull request

- Opened [PR #2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2), from `early-alpha` into `main`. It replaces closed, unmerged PR #1 as the active review for this development branch.
- At creation, GitHub compared the branch as 185 commits ahead and 4 behind main; the PR contained 12 changed files, 6,804 additions, and 235 deletions.
- PR #2 is open and not draft. No merge was attempted.
- After creation and its CI run, GitHub reported `mergeable=true` and `mergeable_state=clean`.

### Validation

- PR-triggered GitHub Actions [Build and test #179](https://github.com/GraderGamer2/NekoEdit/actions/runs/42220633279) completed successfully on head commit `108d7df1e024e74c653c5bb4cdbe52fb1d1289bf`. All eight workflow steps passed, including the freestanding x86-64 build/ELF verification, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload.
- No application source or tests changed after implementation-code tip [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0); the tested head contains later changelog-only maintenance commits.
- The mock compositor does not replace a real GNOME Wayland smoke test.

### Outstanding user-reported keyboard regression

- In the latest user test of a newer Actions build, normal alphabetic keys worked again, but most shifted punctuation/symbol keys displayed `?`. The user reported only a subset (including `<>`, `:"`, and `()`) rendered correctly.
- The exact Actions run/artifact for that manual report was not identified. Do not claim the regression is fixed because automated mock-compositor tests pass.

### Scope

- This is PR creation and repository documentation only; no editor implementation, tests, or build files were changed for this task.
- PR #2 remains open and unmerged. Further feature development remains paused pending explicit user authorization.
- The PR-status documentation was committed on `early-alpha` as [`fa4725159a20`](https://github.com/GraderGamer2/NekoEdit/commit/fa4725159a202130c5fdd8d2123d1e10be35cadc) and mirrored to `main` as [`92fa00fca547`](https://github.com/GraderGamer2/NekoEdit/commit/92fa00fca547f4b5d947a645bce345f59046e9f6). Both commits touch only the four CHANGELOG files.
- The index/log follow-up commits are [`156e0ab2e53f`](https://github.com/GraderGamer2/NekoEdit/commit/156e0ab2e53fcdbcb4c8403154f577e1e41351c5) on `early-alpha` and [`4795856b1713`](https://github.com/GraderGamer2/NekoEdit/commit/4795856b1713c39103f56f3ba944f0723e3b4218) on `main`.

---

## 2026-11-06 — Rename the development branch to `early-alpha`

**Purpose:** Replace the overly specific branch name with a concise early-development label while preserving the existing implementation history and keeping the project handoff documentation accurate.

### Branch and PR verification

- The user renamed `feat/wayland-socket-error-handling` to `early-alpha` in GitHub.
- Verified that GitHub's branch endpoint returns `early-alpha` at commit [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0). Searching for the former branch name returns no branch.
- The branch rename preserved the implementation tip; it did not modify source history or create a new implementation commit.
- PR [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) is currently closed and unmerged. The GitHub API still returns the former name in the PR's `head.ref`, despite the old branch ref no longer being present. The reason for closure is not inferred here; no PR action was taken.
- GitHub Actions [Build and test #174](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217617434) passed on the exact implementation tip before the rename. All eight workflow steps succeeded. This is validation of the unchanged code commit, not a new run triggered by the branch rename.
- At verification, `main` remained at [`f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d`](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d); it still contains the original prototype rather than the editor implementation.

### Scope

- Refreshed the status, development log, project history, and commit index so the renamed branch and current PR state are clear in future handoffs.
- The four-file documentation update was committed on `early-alpha` as [`4d3786b206db`](https://github.com/GraderGamer2/NekoEdit/commit/4d3786b206dbdb6dc86ca4a2d140e57fe78ed459) (12:41:33 UTC), then mirrored to `main` as [`6f50ea994362`](https://github.com/GraderGamer2/NekoEdit/commit/6f50ea994362178dc7a34320263d00b3d7244158) (12:41:35 UTC).
- Follow-up commit-index maintenance was committed as [`e50e87f2fe62`](https://github.com/GraderGamer2/NekoEdit/commit/e50e87f2fe62f0212b7fb0f77e6ebf5d1b4a55e5) on `early-alpha` and [`2c2dfbe16a9f`](https://github.com/GraderGamer2/NekoEdit/commit/2c2dfbe16a9feed38ea279281e6321b283219c54) on `main`.
- The current-status wording was then clarified in [`b452c39c82a0`](https://github.com/GraderGamer2/NekoEdit/commit/b452c39c82a069236443b8ce14266a3fd2fae8aa) on `early-alpha` and [`99084a344cf3`](https://github.com/GraderGamer2/NekoEdit/commit/99084a344cf39f9ba2c5beec7a7db1528c7cf507) on `main`. All six commits in this documentation sequence touch only files under `CHANGELOG/`.
- Mirrored the documentation-only update to `main`; no application source, tests, Makefile, workflow, or binary changed.
- No feature development was performed. Further NekoEdit development remains paused until the user explicitly authorizes it.

---

## 2026-11-06 — Put the changelog on main and synchronize the development branch

**Purpose:** Make the project continuity record available from main as requested, while keeping PR #1 based on main without merging the editor implementation prematurely.

### Main-branch changelog

- Created the initial main-only documentation commit [9377c5c9c4bf](https://github.com/GraderGamer2/NekoEdit/commit/9377c5c9c4bfee8a6a6ea4b8f27be451e85bf6e8). It adds all five CHANGELOG files and a root README link, and does not copy application code from PR #1.
- The main push workflow [Build and test #168](https://github.com/GraderGamer2/NekoEdit/actions/runs/42215548988) passed.
- After the gap-buffer milestone was documented on the feature branch, copied the updated CURRENT_STATUS, DEVELOPMENT_LOG, PROJECT_HISTORY, and COMMIT_INDEX blobs to main in [f31dc4177c78](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d). The project README and CHANGELOG onboarding file remained in place.
- Main push workflow [Build and test #170](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216873766) passed. Main remains the original Wayland prototype; only the changelog and its README link were added/updated.

### Feature-branch synchronization

- The independent main documentation commits initially made PR #1 report a dirty merge state even though the feature branch already contained identical changelog file contents.
- Created the explicit two-parent merge commit [379a34981fc6](https://github.com/GraderGamer2/NekoEdit/commit/379a34981fc697be322063458b44ff4dd9a1e72d): first parent is main at f31dc4177c78; second parent is the development branch's gap-buffer changelog commit d35d54bb8726. Its tree preserves the complete feature branch implementation and has the same changelog contents as main.
- This is a branch synchronization commit, not a PR merge. PR #1 remains open and unmerged; GitHub subsequently reported mergeable=true and mergeable_state=clean.
- Feature-branch [Build and test #171](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217176741) passed on the merge commit. All eight workflow steps passed, including the full Wayland mock-compositor suite and executable artifact upload.
- Artifact: nekoedit-linux-x86_64; 18,978 bytes; SHA-256 2fa05d8a3b0f2b4422a4d4f81c1ebd3f701ea6d74c97221f467bf1b3ea9dbebf; expires 2026-11-13.

No program-code changes were made in this synchronization entry. The standalone launch command and 64 KiB gap-buffer implementation from commit 776a72c remain unchanged.

---

## 2026-11-06 — Implement a fixed-capacity gap-buffer document engine

**Purpose:** Replace the contiguous editing byte array with the planned gap-buffer structure while preserving the current Wayland interface, 64 KiB file limit, UTF-8 code-point handling, and freestanding runtime constraints.

### Implementation

- Added the logical gap interval [doc_gap_start, doc_gap_end) inside the existing 64 KiB allocation. doc_length, doc_cursor, and selection positions remain logical byte offsets.
- Added doc_byte_at to translate logical offsets to physical storage. UTF-8 validation/navigation, visual-row and pointer mapping, status calculation, selection painting, and document rendering now read through this accessor.
- Added overlap-safe gap movement in both directions. Moving left copies the prefix tail backwards; moving right copies the suffix head forwards. The direction flag is cleared before returning.
- Insertion moves the gap to the logical cursor and consumes bytes from the gap. Backspace/Delete and selection deletion move the gap to the deletion boundary and enlarge it instead of compacting the entire remaining suffix.
- Startup file loading and successful in-window Open initialize the gap immediately after the loaded bytes. Staged Open still leaves the current document untouched on failure.
- Atomic Save now writes the prefix and suffix as separate segments, excluding the unused gap, while retaining the existing write loop, EINTR handling, fsync, close, and rename behavior.
- Updated the project README and architecture description to distinguish a working gap buffer from the still-fixed 64 KiB capacity.

### Regression coverage

- Added a dedicated gap_buffer_test integration scenario using AéBC. It places the gap after the two-byte UTF-8 character, inserts on both sides, moves the cursor across the split, exercises Backspace and Delete, removes a selection, and verifies the exact saved bytes (AéC).
- The full GitHub Actions [Build and test #169](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216369360) completed successfully on code commit [776a72c07579](https://github.com/GraderGamer2/NekoEdit/commit/776a72c07579ced1e54929946de65cea6271267e).
- All eight CI steps passed, including assembly/link and ELF checks, CLI smoke tests, full Wayland mock-compositor integration, executable inspection, and artifact upload.
- Artifact: nekoedit-linux-x86_64; size 18,978 bytes; SHA-256 dae27df70c60ae73c4bd45e494b10c7c47c7d0962c86c8876f48ab00965b515a; expiration 2026-11-13.
- No new real-GNOME-desktop manual test was performed for this milestone. The user's earlier desktop feedback about symbols and UTF-8 formatting remains separate from these automated results.

### Scope and remaining limits

- The gap buffer remains fixed at 65,536 bytes; there is no dynamic growth or allocation expansion yet, and oversized files continue to be rejected.
- There is no line-start index; rendering, cursor-to-row mapping, and row-to-cursor mapping still scan the document.
- UTF-8 support remains code-point-boundary-aware, not grapheme-aware. Non-ASCII glyphs still render as ?, keyboard text input is still ASCII-only, and IME/compose support is not implemented.
- Clipboard, undo/redo, horizontal scrolling, resize/scale handling, a directory-browser picker, and X11 remain unfinished.

The existing launch interface is unchanged: ./nekoedit --backend=wayland or ./build/nekoedit --backend=wayland. Development remains on feat/wayland-socket-error-handling / PR #1; the separate changelog-only commit on main did not merge the editor code.

---

## 2026-11-06 — Create permanent changelog and recover full project history

**Purpose:** Establish a durable development record before any further feature work, so a new ChatGPT conversation can reconstruct project context from the repository instead of depending on a long previous chat.

### Repository reconstruction

- Inspected the active repository, the original `main` prototype history, development PR #1, source tree, build files, architecture/backend documentation, and test harness.
- Reconstructed the complete history available on 2026-11-06: 20 commits on the original `main` prototype history and 168 commits in PR #1.
- Added `CHANGELOG/COMMIT_INDEX.md` with all 188 commit subjects, dates, abbreviated/full linked commit identities, including tests, intermediate debugging, documentation changes, fixes, and reverts.
- Added `CHANGELOG/PROJECT_HISTORY.md` with a functional milestone narrative: original freestanding Wayland window; inherited socket/error reporting; pointer/keyboard input; ASCII editing and UI; selection, key repeat, wrapping and scrolling; file loading and atomic saving; XKB keymap transport/parser; complete printable ASCII punctuation; and UTF-8 code-point-safe editing.
- Added `CHANGELOG/README.md` with instructions for future development chats and a mandatory changelog-maintenance procedure.
- Added this file as the append-only narrative log.
- Added `CHANGELOG/CURRENT_STATUS.md` as the concise source-of-truth snapshot.
- Added a link to this directory from the root project README.

### Code milestone included in the reconstructed history

The latest implementation work before this retrospective changelog task added code-point-safe editing around existing UTF-8 document bytes:

- `doc_utf8_next` and `doc_utf8_prev` validate bounded UTF-8 scalar sequences.
- Left/Right, Shift+Left/Right, pointer hit-testing, selection rendering, Backspace, and Delete operate on whole valid code points instead of splitting valid 2-, 3-, and 4-byte sequences.
- Malformed bytes remain independently editable.
- The fixed 64 KiB byte array remains; this did not implement the planned gap buffer.
- Non-ASCII rendering remains a `?` placeholder, keyboard text entry remains ASCII-only, and grapheme/IME support is not implemented.

Related code/test/docs commits (all individual entries are in [COMMIT_INDEX.md](COMMIT_INDEX.md)):

- `70a333fc5392` — UTF-8 code-point-safe editing implementation.
- `056b381ab571`, `711613327410` — UTF-8 navigation/deletion and selection regression tests.
- `29ea6773e2`, `f9bc6f5df0`, `ec5d5ef33a`, `fd14288098` — correct test dispatch, better failure diagnostics, fixture positioning, and malformed-byte fixture coverage.
- `6e401497373c`, `749d1cc085d2`, `998577b6e09a` — update README, architecture, and Wayland backend documentation.
- `b71fa066fd3a`, `5c8b0aea3ed9`, `6cd9e08fada0` — pointer hit-testing coverage and test-fixture corrections.

### Verification

- GitHub Actions [run #160](https://github.com/GraderGamer2/NekoEdit/actions/runs/42213034086) passed for code commit `6cd9e08fada059ae3e24c9cdab7cf86762b24414`.
- Passed stages: freestanding x86-64 build and ELF checks; command-line smoke tests; complete Wayland mock-compositor integration; executable inspection; Linux x86-64 artifact upload.
- The integration suite includes the original Wayland, keyboard, pointer, file workflow, XKB, punctuation, repeat, valid UTF-8, malformed UTF-8, selection, deletion, and mixed-width UTF-8 pointer hit-testing cases.
- Artifact: `nekoedit-linux-x86_64`; archive SHA-256 `aa47ef8e0645e734f7dd7bd072cd31f51cc755907113603de6aebf8ab48917a7`; artifact expiry reported as 2026-11-13.
- User feedback: the printable symbol input set `!@#$%^&*()_+{}|:"<>?` works in the tested Actions build. The user also reported that the UTF-8 formatting/editing change looked fine and that earlier implementations remained usable. These are user-reported results, separate from CI verification.

### Outcome and scope

This task changes documentation only; it does not intentionally modify editor code or the launch interface. The existing Wayland launch form remains supported: `./nekoedit --backend=wayland` (or `./build/nekoedit --backend=wayland` when running the Makefile output).

No feature development is being started in this entry. The next development task should begin only after reading the changelog directory and inspecting the current source/branch/CI state.
