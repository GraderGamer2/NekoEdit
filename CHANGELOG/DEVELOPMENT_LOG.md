# NekoEdit development log

This is an append-only narrative log. New entries go at the top, with the newest work first. The complete historical narrative is in [PROJECT_HISTORY.md](PROJECT_HISTORY.md); the full SHA/subject ledger is in [COMMIT_INDEX.md](COMMIT_INDEX.md).

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
