# NekoEdit project history

**Historical reconstruction date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Current development PR:** [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) — open against main  
**Previous PR:** [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged

This document reconstructs the development of NekoEdit from the first repository prototype through the current Wayland window-management and picker milestones. The exact history is retained in [COMMIT_INDEX.md](COMMIT_INDEX.md), including the original prototype, PR #1 implementation, changelog setup, and subsequent maintenance commits captured on 2026-11-06. This document explains what those changes built.

---

## 1. Original project goals and constraints

NekoEdit began as a small native plain-text editor for Linux, with a deliberately constrained implementation:

- Target: Linux x86-64 / System V AMD64 ABI.
- Language and assembler: GNU assembler, Intel syntax, freestanding assembly.
- Startup: custom `_start`, without C runtime startup code.
- System interface: direct Linux syscalls.
- Runtime: no third-party shared-library dependencies; no GTK, Qt, libc, libwayland, Xlib, XCB, Fontconfig, FreeType, HarfBuzz, or toolkit file chooser.
- Graphics: CPU software rendering into shared-memory buffers; no OpenGL, Vulkan, EGL, or GPU requirement.
- Display architecture: native Wayland first, X11 planned. The application is intended to be desktop-environment-independent.
- Document purpose: lightweight UTF-8 plain-text editing, not rich text or an IDE.

The original architecture describes distinct UI, editor-core, platform-neutral service, display-backend, and Linux syscall layers. The editor core should not depend on whether Wayland or X11 is active. The eventual document model is UTF-8 bytes with a gap buffer and byte offsets constrained to valid character boundaries.

These goals remain the design direction. Some planned layers and facilities are not yet implemented; see [CURRENT_STATUS.md](CURRENT_STATUS.md).

## 2. Phase A — freestanding Wayland window prototype

**Original `main` prototype history: 20 commits.**  
**Starting point:** the initial `feat: add freestanding Wayland window prototype and CI` commit (2026-11-06).

The first implementation proved that a standalone assembly executable could create a native Wayland toplevel and render a basic surface without a GUI toolkit or shared library.

Implemented in this phase:

- Command-line entry point with `--help`, `--version`, `--backend=wayland`, and an explicit not-yet-implemented X11 response.
- Small Linux syscall helpers for process exit, reads/writes, and related low-level operations.
- Environment lookup for `WAYLAND_DISPLAY` and `XDG_RUNTIME_DIR`; default `wayland-0` and absolute `WAYLAND_DISPLAY` paths.
- AF_UNIX/SOCK_STREAM connection to the Wayland display.
- Raw Wayland wire-message serialization and parsing.
- Registry discovery and binding of `wl_compositor`, `wl_shm`, and `xdg_wm_base`.
- Creation of `wl_surface`, `xdg_surface`, and `xdg_toplevel`.
- Initial empty surface commit, `xdg_surface.configure` acknowledgement, and handling of `xdg_wm_base.ping`.
- 800×480 XRGB8888 CPU-rendered buffer backed by `memfd`, mapped with `mmap`, transferred to the compositor through `sendmsg` and `SCM_RIGHTS`.
- Buffer attachment, surface damage/commit, and clean exit on `xdg_toplevel.close`.
- Dense client-side Wayland object-ID allocation. The development history includes fixes and tests for strict compositors that reject skipped IDs.
- Build checks that reject an ELF with a `PT_INTERP` program header or `DT_NEEDED` shared-library dependencies.
- GNU Make targets for build, smoke tests, Wayland mock tests, ELF inspection, and cleanup.
- GitHub Actions CI on Ubuntu 24.04, which assembles and links the freestanding binary, runs tests, inspects the ELF, and uploads a Linux x86-64 artifact.

At the end of this phase NekoEdit was only a window/rendering proof of concept. It had no editor input, document buffer, or file workflow.

## 3. Phase B — inherited Wayland sockets and protocol diagnostics

The first development PR extended the prototype's connection and failure handling:

- Supports a launcher-provided, already-connected `WAYLAND_SOCKET` descriptor as well as the normal `WAYLAND_DISPLAY` connection path.
- Handles Wayland protocol error events and reports compositor-provided diagnostics instead of silently failing.
- Adds bounded error-message handling and clearer setup-stage diagnostics.
- Retains the socket and protocol behavior across the later editor work.

Tests exercise both `WAYLAND_DISPLAY` and `WAYLAND_SOCKET` transports and simulate compositor protocol errors. This phase also established more useful diagnostics for failures during setup.

## 4. Phase C — Wayland seat, pointer, and keyboard input

The next milestone made the window interactive:

- Discovers `wl_seat` and handles advertised seat capabilities.
- Creates `wl_pointer` and `wl_keyboard` objects when those capabilities are available.
- Tracks keyboard focus and processes keyboard enter, leave, key, and modifier events.
- Processes pointer enter/leave/motion/button events.
- Tracks Shift, Ctrl, Caps Lock, and the physical Right-Alt/LevelThree state needed by the currently supported keyboard mapping.
- Keeps redraws safe with compositor buffer-release handling. The client must not rewrite shared memory while the compositor still owns the submitted buffer.
- Uses raw Wayland protocol messages and syscalls; no libwayland or other runtime library is introduced.

Pointer and keyboard focus/input were first tested independently before being connected to document editing. The commit index preserves the intermediate debugging, protocol serialization corrections, and test-harness synchronization fixes from this phase.

## 5. Phase D — initial text editing and editor UI

NekoEdit then became an actual, though still early, interactive editor.

### Document and rendering

- Added a bounded 64 KiB document byte array.
- Added an embedded 5×7 bitmap font covering printable ASCII.
- Added ASCII insertion and software rendering, with a visible caret.
- Added Left/Right/Up/Down, Home/End, Backspace, Delete, Enter, and four-space Tab.
- Added a compact application header, document area, active document tab, clickable File menu, and status/footer area.
- Added live logical line, column, and document byte-count status.
- The current window/document viewport is software-rendered at 800×480.
- Long lines soft-wrap; the active caret follows vertical movement through a 30-row document viewport.
- Pointer clicks position the caret in the document. Pointer coordinate conversion accounts for the document origin and visual row/column.
- Left-button drag selects text, including reverse-direction and multi-line ranges. Typing or Backspace/Delete replaces the selected range.
- Shift+Arrow and Shift+Home/End extend keyboard selections from a stable anchor; unshifted Left/Right collapse an active selection to the relevant edge.
- Ctrl+A selects the complete document.

### Keyboard repeat

- Added delayed repeat for ordinary non-modifier/non-lock keys, including printable input, navigation, Backspace, Delete, Enter, and Tab.
- Uses compositor `wl_keyboard.repeat_info` rate/delay when the seat version supports it.
- Retains a 300 ms / 30 Hz fallback for older seat versions.
- Cancels repeat on key release or keyboard focus loss; handles changed repeat settings.

### Test coverage

The Wayland mock compositor checks keyboard/pointer input, buffer release sequencing, caret and glyph pixels, selection highlighting/replacement, wrapping, vertical scrolling, and repeat timing. The editor tests are protocol-level integration tests; they do not replace running the program against a real GNOME/Wayland session.

## 6. Phase E — startup file loading and in-window file operations

File access was added without introducing a toolkit file chooser.

### Launch-time loading

- A single non-option argument is interpreted as the document path.
- Existing files are loaded into the bounded document buffer.
- A nonexistent path is retained as the target for a later save.
- The startup file path determines the active document name/tab label.

### In-window file workflow

- Added a clickable File menu with Open, Save, and Save As actions.
- Added an in-window path-entry prompt with character input, Backspace, Enter to confirm, and Escape to cancel.
- Added `Ctrl+O`, `Ctrl+S`, and `Ctrl+Shift+S`.
- Ctrl+S on an Untitled document opens Save As.
- Relative paths resolve from the process working directory; absolute paths are accepted.

### File safety

- Open reads into a separate staging buffer and only replaces the active document after a complete successful read and close.
- Partial reads and `EINTR` are handled.
- Files larger than the supported 64 KiB limit are rejected without replacing the active document.
- Save writes to a unique same-directory temporary file opened exclusively, handles partial writes and `EINTR`, fsyncs and closes the temporary file, then atomically renames it over the destination.
- Failed writes clean up the temporary file and do not truncate the existing target.

Current limitations remain: the path prompt is ASCII-only; there is no graphical directory browser, file filtering, or unsaved-changes confirmation. The temporary file uses mode 0644 subject to umask; existing mode/ownership/ACLs/xattrs are not preserved, and the parent directory is not fsynced after rename.

## 7. Phase F — XKB keymap transport and bounded layout parser

Keyboard layout support progressed from raw physical key handling to a dependency-free subset of XKB text-v1.

### Keymap descriptor transport

- Receives Wayland socket data with `recvmsg` so attached `SCM_RIGHTS` descriptors are not discarded.
- Receives `wl_keyboard.keymap` XKB_V1 file descriptors.
- Checks descriptor state, size bounds, expected keymap signature, and NUL termination.
- Maps the keymap read-only using `MAP_PRIVATE` and closes the received FD appropriately.
- Handles event EOF and descriptor cleanup.

### XKB text-v1 subset

The assembly parser handles a bounded common subset, including:

- Compiled keycodes and key names/aliases.
- Common named ASCII keysyms, including punctuation.
- Shorthand arrays such as `key <AE01> { [ ... ] }`.
- Explicit `symbols[GroupN]` arrays.
- Up to four groups and four levels.
- Common `ALPHABETIC`, `FOUR_LEVEL`, `THREE_LEVEL`, `EIGHT_LEVEL`, and related simplified type families.

Translation uses the XKB keycode +8 offset, active layout group, Shift/Caps behavior for alphabetic keys, and physical Right Alt as a LevelThree selector. Named punctuation keysyms are resolved into ASCII, including the twelve shifted US number-row symbols `!@#$%^&*()_+`.

### Safe fallback behavior

A keymap must contain sufficient recognized ASCII symbols and alphabetic keys before it is activated. Sparse or unsupported maps are rejected so they do not disable normal typing; NekoEdit retains its built-in US-QWERTY fallback. Tests cover incomplete/punctuation-only maps, parser table contents, all 26 ASCII letters, groups, Shift, Right-Alt LevelThree, and shifted number-row symbols.

This is not full XKB semantics. Custom type/modifier mappings, virtual modifier resolution, modifier actions, keypad behavior, compose/dead keys, non-ASCII keysyms, and IME integration are not implemented.

## 8. Phase G — printable ASCII punctuation rendering

A separate regression milestone completed the embedded bitmap glyph coverage for every printable ASCII punctuation character. The test checks that all 32 punctuation glyphs produce a nonblank bitmap and do not incorrectly fall back to the question-mark glyph.

The user tested a recent Actions build and reported that typing the symbol set `!@#$%^&*()_+{}|:"<>?` works. This is user-reported desktop behavior and is distinct from the automated bitmap test.

## 9. Phase H — initial UTF-8 code-point-safe editing

**Code milestone commit:** `70a333fc5392` — `feat: navigate and edit UTF-8 code points safely`.  
**Verified code/test commit:** `6cd9e08fada0` (Actions #160 passed).

This milestone begins safe editing around UTF-8 text already present in a file. The canonical document storage remains bytes; cursor positions are byte offsets, but operations now advance across valid Unicode code points instead of blindly incrementing one byte at a time.

Implemented:

- Added bounded `doc_utf8_next` and `doc_utf8_prev` helpers.
- Validates 2-, 3-, and 4-byte UTF-8 sequences, including restrictions that reject overlong encodings, surrogate code points, and values beyond U+10FFFF.
- Treats malformed bytes as individual one-byte editing units so invalid source bytes are not silently merged with adjacent characters.
- Left/Right and Shift+Left/Right move by complete valid code points.
- Backspace removes the previous complete code point.
- Delete removes the next complete code point.
- Selection and its visual rendering advance across code points rather than continuation bytes.
- Document rendering assigns one visual placeholder cell to a valid non-ASCII code point instead of one cell per encoded byte.
- Pointer hit-testing maps a visible text column back to the correct byte offset across variable-width UTF-8 sequences.
- Non-ASCII code points and malformed bytes still render as `?`; this is not Unicode glyph support.
- Text insertion from the physical keyboard/XKB path remains ASCII-only. There is no IME or Wayland text-input integration.
- The data structure remains a fixed 64 KiB byte array, not a gap buffer.
- Cursor positions are code-point-aware, not grapheme-cluster-aware. Combining sequences and multi-code-point emoji are not yet one navigation unit.

### Regression coverage added

The mock Wayland integration suite checks exact file bytes after operations on 2-, 3-, and 4-byte sequences. It covers:

- Right/Left movement across mixed-width code points.
- Shift selection of a complete four-byte code point.
- Backspace of 2-, 3-, and 4-byte code points.
- Delete-forward across ASCII and 2-, 3-, and 4-byte code points.
- Malformed UTF-8 bytes remaining independently editable.
- Pointer hit-testing after multiple multibyte code points, ensuring visual columns are translated to byte offsets correctly.

The test harness also received corrections to fixture positioning, dedicated UTF-8 test dispatch, malformed-byte deletion count, and failure diagnostics. These intermediate test/fix commits are all preserved in [COMMIT_INDEX.md](COMMIT_INDEX.md).

The user subsequently reported that the UTF-8 formatting/editing changes looked fine and that earlier functionality remained usable. This is recorded as user feedback, not as a substitute for the automated tests.

## 10. Phase I — fixed-capacity gap-buffer document storage

**Implementation commit:** [776a72c07579](https://github.com/GraderGamer2/NekoEdit/commit/776a72c07579ced1e54929946de65cea6271267e)  
**Verification:** [Build and test #169](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216369360), successful.

The editor replaces its contiguous document-editing array with a byte-oriented gap buffer inside the existing 65,536-byte allocation.

- doc_gap_start and doc_gap_end delimit the unused interval. Bytes before and after the interval form the logical document; document length, cursor, and selection offsets remain logical byte offsets.
- doc_move_gap moves the interval to a requested logical offset using backwards copying for leftward moves and forwards copying for rightward moves.
- doc_byte_at centralizes logical-to-physical offset translation. UTF-8 scalar validation, visual mapping, status calculation, selection rendering, and normal document rendering now use it instead of assuming the text is contiguous.
- Insertions consume available gap bytes. Backspace, Delete, and selection deletion enlarge the gap at the deletion point rather than shifting all remaining bytes.
- Startup load and successful staged Open place the gap after the loaded data. Save writes the prefix and suffix separately, omitting the gap while retaining the atomic temporary-file workflow.

A new mock-compositor regression case places the gap immediately after a two-byte UTF-8 character in AéBC, performs insertion on both sides, cursor movement, Backspace, Delete, and selection deletion, then verifies the exact saved byte sequence AéC. The complete CI workflow passed, including the full existing Wayland integration suite and artifact upload.

This is a real gap-buffer editing structure, but it is **not yet dynamically growing**. Its allocation is still 64 KiB, oversized files remain unsupported, and document/visual row mapping still uses linear scans rather than a line-start index. The existing code-point policy is unchanged: malformed bytes are individually editable, valid UTF-8 scalars remain whole, but grapheme clusters, non-ASCII rendering/input, and IME are not implemented.

## 11. Build, test, and artifact history

The Makefile provides these principal operations:

- `make` / `make clean all`: assemble and statically link the application, then verify the ELF has no interpreter or dynamic library dependencies.
- `make test`: run command-line smoke tests.
- `make test-wayland`: run the Python mock-compositor integration suite.
- `make inspect`: inspect ELF metadata.

GitHub Actions builds on Ubuntu 24.04 and uploads the Linux x86-64 executable as `nekoedit-linux-x86_64` with a seven-day artifact retention period. The Python test harness is test infrastructure, not a runtime dependency of NekoEdit.

On **2026-11-06**, Actions run [#160](https://github.com/GraderGamer2/NekoEdit/actions/runs/42213034086) passed for code commit `6cd9e08fada059ae3e24c9cdab7cf86762b24414`. The build, smoke tests, complete Wayland mock integration suite, executable inspection, and artifact upload succeeded. Artifact: `nekoedit-linux-x86_64`; reported archive SHA-256: `aa47ef8e0645e734f7dd7bd072cd31f51cc755907113603de6aebf8ab48917a7`; expiry: 2026-11-13.

## 12. Current milestone boundary

NekoEdit is an early interactive Wayland text-editor prototype with file operations, ASCII XKB translation, selection, scrolling, code-point-safe UTF-8 editing, and a fixed-capacity gap buffer. It is not yet dynamically growing, a complete editor, or a complete Unicode text stack.

Important items still on the roadmap include:

- Add dynamic gap-buffer growth beyond 64 KiB and a line-start index.
- Implement Unicode glyph lookup/rendering instead of question-mark placeholders.
- Implement non-ASCII text input, Wayland text-input/IME, compose and dead-key behavior.
- Add grapheme-cluster-aware navigation and deletion.
- Add undo/redo.
- Add clipboard integration using Wayland data-device protocols and immutable copy snapshots.
- Add horizontal scrolling and more complete viewport handling.
- Add resize/reconfigure and output scale handling.
- Add a directory-browser file picker and unsaved-changes protection.
- Expand XKB semantics beyond the currently supported common ASCII subset.
- Implement the X11 backend.
- Continue real-desktop smoke testing in addition to mock-compositor CI.

See [CURRENT_STATUS.md](CURRENT_STATUS.md) for the concise state to use before any further coding.


---

## 13. Repository administration — development branch renamed to `early-alpha`

On 2026-11-06, the development branch was renamed in GitHub from `feat/wayland-socket-error-handling` to `early-alpha`. The rename preserved the existing implementation tip, `6f9d17a3a09eaabf1393db214868fe57716ac7c0`; the former branch ref no longer appears in GitHub's branch search. No application implementation was changed by the rename.

GitHub Actions run [#174](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217617434) had already passed against that exact commit before the rename. Its eight workflow steps completed successfully. This is the last verified test result for the unchanged implementation tip, not a post-rename test run.

At the time of verification, PR [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) was closed and unmerged. Its API metadata still reported the former branch name in `head.ref`; this document records the observed metadata without assuming the reason for closure or treating the PR as merged. The rename and this documentation refresh did not merge editor code into `main`.

This administrative milestone changed no editor source, tests, build configuration, or runtime behavior. The project remains at the early interactive Wayland-editor milestone described above. Future implementation work remains paused pending explicit user authorization.


---

## 14. Review continuation — replacement PR #2

On 2026-11-06, [PR #2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) was opened from early-alpha into main. It provides a current review target for the renamed branch after PR #1 was closed without merging.

At creation, GitHub compared 185 commits ahead and 4 behind the target branch, with 12 changed files (6,804 additions and 235 deletions). PR-triggered Actions run [#179](https://github.com/GraderGamer2/NekoEdit/actions/runs/42220633279) passed all eight steps on head `108d7df1e024e74c653c5bb4cdbe52fb1d1289bf`. After CI, GitHub reported the PR mergeable with a clean merge state. The PR remains open and unmerged.

The PR description records the implementation, limitations, and the latest user-reported punctuation-key regression. The user's latest manual test reported that alphabetic input worked again but most shifted symbols produced `?`; this remains unresolved and is not negated by mock-compositor CI.

No source or test code was changed as part of opening the PR. Future implementation work remains paused pending explicit authorization.


---

## 15. Phase J — native directory-browser file picker

**Implementation milestone:** the native in-window Open/Save browser implementation, with final correctness fixes in [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82) and [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd).  
**Verification:** [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800), all eight workflow steps successful.

The native picker is an in-process modal directory browser drawn by the existing Wayland software renderer. It uses direct Linux filesystem syscalls and does not call GTK, Qt, a desktop portal, D-Bus, or an external file manager.

The interface contains an editable location field, Up and Home controls, Show hidden toggle, directory-first/file-second list, filename field, and Cancel/Open or Save actions. Directories are entered on double-click, regular files are opened on double-click or explicit activation, and Save As confirms replacement of an existing regular file. Failed or oversized Open and failed Save As preserve the previously active document/path.

The mock-compositor tests exercised Untitled Save, named Save, Open, nested-directory navigation, hidden-file visibility, Save As, overwrite confirmation/cancellation, missing/oversized Open rollback, failed Save As rollback, and Escape cancellation.

The strengthened exact-path test exposed two real defects: directory scans retained the prior row/time double-click history, and the relative path builder did not write a new terminating NUL after copying a shorter filename. Both were corrected. The test now checks the selected active pathname and loaded bytes, not only a rendered glyph.

The picker is intentionally small. At this milestone it was capped at 128 entries with 15 visible rows. Path/name entry was append/backspace-oriented, file filters and unsaved-document confirmation were absent, and real GNOME Wayland smoke testing remained separate from mock-compositor CI. These limitations and the full intermediate failure history are recorded in [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md).

---

## 16. Phase K — robust empty-file Open, scrollable picker, and editable location/search fields

**Implementation and validation:** [Build and test #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258), all eight workflow steps successful on [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49).

The file workflow now explicitly tests empty documents through both single-click-plus-Open and double-click activation. It asserts the exact active path and zero document length, then verifies that typing and Ctrl+S write to that same empty file. Keyboard selection now refreshes the filename field from the selected row, and Open confirmation uses the current search-match state rather than silently reusing an unrelated previous row.

The picker list responds to vertical `wl_pointer.axis` events, accumulates fixed-point scroll deltas, and uses a proportional draggable scrollbar. The Show hidden control is a bordered checkbox with a visible check mark; both the control and label toggle it, and every new picker session starts with dotfiles hidden.

The location and filename/search fields now support mouse-positioned caret placement, Left/Right, Home/End, insertion, Backspace, forward Delete, Ctrl+A replacement, and horizontal follow as the cursor moves. In Open mode, the filename field provides case-insensitive prefix matching over regular files in the current directory listing; the first match is selected and brought into view. A no-match query clears the old selection. The editable path field can commit a directory navigation with Enter and returns focus to the listing after success.

The integration suite covers zero-byte Open by both routes, exact path and document state, wheel movement, scrollbar thumb geometry/dragging, path middle insertion and Backspace, edited-path navigation, filename prefix matching, middle insertion/deletion, Home/End, Ctrl+A replacement, and opening the exact matched empty file. All of these run alongside the established editor, XKB, UTF-8, gap-buffer, repeat, selection, and protocol tests.

Actions run #235 passed all eight steps and uploaded `nekoedit-linux-x86_64` (27,216 bytes; SHA-256 `1afeefccb7c594100137e91538d30c0d8e661d026be964c956871c5a9eb64175`; artifact ID `13515385312`; expires 2026-11-13). Path/name input remains ASCII-only; clipboard paste and partial Shift selection are future work. Prefix search is limited to the current loaded directory listing, and the 128-entry limit remains. No third-party runtime library was added, and the launch form remains `./nekoedit --backend=wayland`.

Real GNOME Wayland desktop validation is still distinct from the passing mock-compositor suite. The user's previous report about shifted punctuation keys also remains awaiting manual confirmation against a recent artifact.

---

## 17. Phase L — filename autocomplete and native Wayland window management

**Autocomplete implementation:** [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519), validated by [Actions #245](https://github.com/GraderGamer2/NekoEdit/actions/runs/42245683431), all eight workflow steps successful.

The Open-mode filename Search field renders up to five matching filenames as a visible suggestion popup. Suggestions update while typing, Up/Down changes the highlighted result, Tab accepts it, and mouse selection is supported. Enter opens the highlighted entry. The integration fixture includes similarly named files and checks that choosing the second result opens that exact path and contents rather than defaulting to the first prefix match.

**Window-management implementation:** [`f516fc1a9b31`](https://github.com/GraderGamer2/NekoEdit/commit/f516fc1a9b316aa34a6c07533948822913469f02), subsequently corrected by [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969).

The Wayland window draws Minimize, Maximize/Restore, and Close controls in its title bar. It starts at 800×480, and renderer geometry, hit testing, status area, and editor viewport use the compositor-configured dimensions. The client retains a bounded memfd mapping and replaces its shared-memory buffer only after compositor release.

The GNOME window-management report prompted a focused correction. Maximize/Restore/Minimize no longer trigger an immediate stale-size attach/damage/commit after the state request; the client waits for the compositor's `xdg_toplevel.configure` / `xdg_surface.configure` sequence, acknowledges it, then redraws using the configured dimensions. Blank title-bar dragging now sends `xdg_toplevel.move`; a 6-pixel edge/corner hit region sends `xdg_toplevel.resize` using the serial from the initiating pointer press. Resize configures are applied through the existing buffer-release gate. Minimize remains a compositor request, so the resulting GNOME presentation is still subject to Mutter policy.

Actions [#251](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769) passed the full freestanding build, CLI, and Wayland mock suite through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`. The expanded scenario checks multiple toplevel configures, final state selection, configure-before-release deferral, title-bar move, and edge resize. Artifact `13521663942` (29,625 bytes) was uploaded. The user has not yet confirmed the fix in a real GNOME session; CI does not substitute for Mutter testing.

The one-active-buffer rendering model remains release-safe but can stall redraws while the compositor owns the buffer. Output-scale handling, fractional scaling, and a multi-buffer/frame-scheduling strategy remain future work. The supported launch command and freestanding/no-third-party-runtime design are unchanged.

## 18. Phase M — correct compositor geometry, edge resize targeting, and idle picker scrollbar

The user's real GNOME Wayland test exposed that the preceding mock-tested implementation had only fixed title-bar movement: Maximize still terminated the app and edge resizing did not take effect. The same report identified a scrollbar drawn outside its track when a directory had no overflow.

Implementation [`f990dc0aa9b1`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7) addresses those reports. The picker now omits the entire scrollbar when 15 or fewer entries fit, and the gutter cannot start a drag in that state. The Wayland client advertises its supported min/max window geometry, uses positive compositor-configured dimensions exactly within its preallocated shared-memory bound instead of silently clamping them, and clips rectangle/glyph writes to the active surface. Interactive resize hit targets are 12 pixels wide, with explicit tests for all four edges and four corners.

Actions [#253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598) passed the build, CLI checks, and expanded mock-compositor suite through both Wayland transports. The suite covers the 1920×1080 maximize/restore path, configure/acknowledge and buffer replacement, non-overflow scrollbar behavior, and resize request serialization. Artifact [`13524092766`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598/artifacts/13524092766) was uploaded.

This is not yet a confirmed GNOME fix. The user must retest the new artifact in Mutter; the #251 artifact was confirmed to crash on Maximize and fail to resize on the user's desktop. No unrelated feature work was started.
---

## 19. Phase N — dynamically growing document storage and large-file Open

**Implementation:** [8af89d509003](https://github.com/GraderGamer2/NekoEdit/commit/8af89d509003997272479ff2271542a304bdec07).  
**Verification:** [Build and test #312](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234), all eight workflow steps successful.

The fixed-capacity document array and separate fixed-capacity Open scratch area are replaced by independent mmap-backed buffers. Each starts at 64 KiB and doubles geometrically through mremap as data requires, with a 1 GiB safety ceiling. The document remains a byte-oriented gap buffer: when growth occurs, the suffix is relocated to the high end of the enlarged mapping, expanding the free interval into one contiguous gap while preserving logical byte offsets.

Initial command-line loading can now exceed 64 KiB. Picker Open reads into its own growable staging buffer, grows for larger files, reserves live document capacity before committing, and only changes the active document/path after a successful read and close. Failed Open continues to preserve the previous document.

The mock suite fills the initial 65,536-byte document exactly, inserts at byte zero, checks that capacity doubles to 131,072 bytes, verifies that all original suffix bytes survive, and saves the split gap as the exact expected byte stream. A second workflow opens and saves a 65,537-byte file through the native picker, confirming the active path, length, full contents, and on-disk result. Actions #312 also reruns the existing file-picker, UTF-8, gap-buffer, window-management, responsive-layout, protocol, and both Wayland-transport regressions.

Artifact [13556529585](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234/artifacts/13556529585) contains the freestanding Linux x86-64 executable (32,119 bytes; SHA-256 bb5666e76505c08b90e4ffac094af79bd2d4c4078014c0e81bf98c63cc3ba0f4). The user subsequently confirmed that a 70 KB file opens, accepts edits, and saves correctly on the live GNOME/Mutter desktop without crashing or behaving anomalously. This completes the real-desktop dynamic-storage/large-file verification.

The indexed line-navigation implementation is recorded in Phase P and grapheme-aware editing in Phase Q. The next rendering milestone is the installed-font parser and software glyph rasterizer; Unicode input/IME, shaping, undo/redo, horizontal scrolling, and clipboard integration remain unfinished.

---

## 20. Phase O — editor vertical scrollbar and mouse-wheel navigation

**Implementation:** [e3489badd178](https://github.com/GraderGamer2/NekoEdit/commit/e3489badd178d4db59c30e6660f9768f224f7e35), with initialization correction [028379b66a6b](https://github.com/GraderGamer2/NekoEdit/commit/028379b66a6bbfb0adb1d65d2c24696147258f96).
**Regression coverage:** [d4c0fcc5710b](https://github.com/GraderGamer2/NekoEdit/commit/d4c0fcc5710b0ab5ff49bc5831a3a334ecfaa01e).
**Verification:** [Build and test #316](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333006563), all eight workflow steps successful.

The document area now has a proportional vertical scrollbar when its visual content exceeds the viewport. Thumb height reflects visible visual rows relative to total rows, including soft-wrapped text, and the track is omitted when scrolling is unnecessary. The user can drag the thumb or click another point on the track to reposition it. Wayland vertical-axis events scroll the editor when the picker and path prompt are inactive; the directory picker keeps its independent scrolling. Manual scrolling redraws the viewport without forcing the caret back into view.

The editor reserves a 24-pixel gutter for the scrollbar, and line wrapping, selection clipping, and caret clipping use the reduced text width. Mock-compositor tests check empty-document hiding, the rendered thumb pixel on a 65,537-byte wrapped file, three-row wheel movement, drag-to-bottom, and one-row reverse scrolling. The full existing wrapping, resizing, selection, file, and protocol suite passes in Actions #316.

Artifact [13557973435](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333808492/artifacts/13557973435) contains the freestanding Linux x86-64 executable (32,919 bytes; SHA-256 `34ab58c1e8e3ebade7a85bdef2656900c7f2fa7595af15119b85cac8a24189ef`). The live GNOME/Mutter scrollbar check has not yet been performed. The user's separate 70 KB file edit/save test confirms the preceding dynamic-storage phase, but does not validate this new pointer and wheel interaction.

The next document-core milestone is a dynamic per-line index for byte lengths and visual-row counts, using prefix-sum trees so normal character edits do not shift all subsequent line offsets. Grapheme-aware cursor movement and Unicode input/rendering follow. The custom system-font parser and glyph rasterizer remain in the later rendering/font phase.


---

## 21. Phase P — indexed document line navigation

**Implementation:** [87a33b203501](https://github.com/GraderGamer2/NekoEdit/commit/87a33b20350180f324b70ce1bff091deabef0bab), feat: add indexed document line navigation.  
**Transactional Open correction:** [78db904b063f](https://github.com/GraderGamer2/NekoEdit/commit/78db904b063fc44cda4d2eabfd84aa5954da626c), invalidate the old index when a new document is committed.  
**Verification:** [Build and test #326](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320), all eight workflow steps successful.

The document core now maintains one compact record per logical line. Each 16-byte record stores the line's byte span (including LF), its soft-wrapped visual-row count, and the corresponding nodes of two Fenwick prefix trees. One tree indexes byte lengths; the other indexes visual-row counts. Both byte-offset-to-line and visual-row-to-line lookups use O(log N) prefix searches, then scan only within the selected logical line to locate the exact character boundary.

Ordinary byte insertion and deletion update the current line's metadata and point-update the Fenwick paths. Inserting LF splits a record; deleting LF merges two records. Since records remain in a compact contiguous array, structural newline edits shift the following records and rebuild the prefix trees. A window-width change recalculates the visual-row count for each logical line and rebuilds the row tree.

The index is integrated into caret/visual mapping, pointer hit-testing, scrollbar geometry, logical line status, and the renderer's first visible byte. As a result, painting a scrolled viewport no longer has to walk all preceding document bytes. The mmap-backed index starts at 256 records and grows geometrically to a bounded maximum of 0x01000000 lines. If it cannot be allocated or the document exceeds that line bound, the editor marks the index unavailable and retains the previous scan-based mapping as a fallback. Successful transactional Open invalidates the previous file's records before the next lookup rebuilds the index for the new document.

The regression suite inspects the actual per-line records and independently verifies both Fenwick node arrays on a document containing hard newlines, a soft-wrapped line, and a tab. It exercises ordinary insert/delete, newline split/merge, and exact save preservation. The complete Actions #326 run also confirms the existing 65,537-byte Open/save and editor-scrollbar path, including visibility, proportional thumb geometry, wheel movement, and thumb dragging. The live GNOME/Mutter index path still requires manual confirmation.

Artifact [13559973130](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320/artifacts/13559973130) contains the freestanding Linux x86-64 executable (34,965 bytes; SHA-256 e2e0e7b77095ece17f2b0573cb37fcb6e0823c56d95a0f4d3003e826ae40134a).


---

## 22. Phase Q — Unicode 18.0 extended grapheme-cluster editing

**Implementation:** [1eb5894443aa](https://github.com/GraderGamer2/NekoEdit/commit/1eb5894443aafcccd73e2463e91e7d85787dfaf1), navigate and delete extended grapheme clusters.  
**CRLF pointer correction:** [fd8020b4fe67](https://github.com/GraderGamer2/NekoEdit/commit/fd8020b4fe67fe056e61d69e819210b41268dd7e), keep hit-testing outside CRLF graphemes.  
**Verification:** [Build and test #331](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462), all eight workflow steps successful.

The document model now distinguishes UTF-8 scalar decoding from user-visible cursor positions. Valid scalar sequences are segmented into Unicode 18.0 extended grapheme clusters using embedded Grapheme_Cluster_Break, Indic_Conjunct_Break, and Extended_Pictographic property tables. The implementation follows the extended grapheme boundary rules in UAX #29, including CRLF, combining and spacing marks, Hangul syllable composition, Prepend, Indic conjuncts, emoji modifier and ZWJ sequences, and regional-indicator pairing. The tables are embedded in the assembly read-only section; no third-party runtime library or external property file is needed.

Left/Right and Shift+Left/Right now move between grapheme boundaries. Backspace and Delete remove the entire previous/next cluster, including clusters formed from several scalars. The same segmentation is used by visual-row measurement, byte/visual mapping, pointer hit-testing, selection painting, document rendering, and status-bar column counting. This keeps the line index and the rendered text layout consistent with the editing model. A grapheme occupies one cell in the current bitmap renderer; non-ASCII clusters still render as a question-mark placeholder until the custom font phase.

CRLF is one extended grapheme cluster. Deleting it removes both bytes, and the line-index merge uses the complete deleted byte span. Pointer hit-testing at the end of a CRLF-terminated line lands before the pair rather than between CR and LF.

The mock-compositor regression uses mixed UTF-8 cases for combining marks, emoji modifiers, family ZWJ, regional-indicator pairing, Hangul, Indic conjuncts, Prepend, SpacingMark, and CRLF. It checks each expected forward/backward boundary, pointer placement, whole-cluster Backspace/Delete, and line-index state after CRLF removal. The complete Actions #331 run also passes the existing line-index, large-file Open/scrollbar, picker, selection, keyboard, resize, and Wayland protocol regressions. Manual GNOME/Mutter validation of grapheme editing remains pending.

Artifact [13561405061](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462/artifacts/13561405061) contains the freestanding Linux x86-64 executable (43,886 bytes; SHA-256 25b80bd07ea11f7bc82816bdfae9c125878e67058f2e5ac563ae03bbfe86740c).



---

## 23. Phase R — proportional TrueType layout and font-metric line boxes

**Horizontal metric integration:** [`0cc839c72181`](https://github.com/GraderGamer2/NekoEdit/commit/0cc839c72181c8ac0ec6792db01996e1ebafa8fd) exposes TrueType horizontal advances; [`3b566344ee8a`](https://github.com/GraderGamer2/NekoEdit/commit/3b566344ee8aaf83fa3f89f4d0ffa5ec9463771d) applies them to document layout and hit-testing; [`fd2e4793aa3d`](https://github.com/GraderGamer2/NekoEdit/commit/fd2e4793aa3d0b16920f90429c289f57eeb27a8f) aligns selection painting; [`3efdcbc537a4`](https://github.com/GraderGamer2/NekoEdit/commit/3efdcbc537a4b9a63224d8b68c34d24a16fe9a8e) applies advances to picker and path-prompt text.  
**Cleanup:** [`3bc0b93a9994`](https://github.com/GraderGamer2/NekoEdit/commit/3bc0b93a999402400111b75a8644307d6ece3141) removes temporary pointer/visual hit-test diagnostics.  
**Vertical metric integration:** [`f6d735b21549`](https://github.com/GraderGamer2/NekoEdit/commit/f6d735b215493d7a67759de2f0aa269fc66d5e21), derives document line pitch from hhea ascent, descent, and line gap; [`beac1f4a9622`](https://github.com/GraderGamer2/NekoEdit/commit/beac1f4a96229817bc3444fd035330d12914cd53), zero-initializes its runtime state for the freestanding BSS section.  
**Verification:** [Build and test #400](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260), all eight substantive checks successful.

The first variable-width document layout now uses each grapheme's first decoded Unicode scalar to obtain a TrueType glyph advance from `hmtx`. At the fixed 12-pixel em, the advance is scaled to pixels, rounded to the nearest integer, and bounded to 1–32 pixels. This one measurement is shared by soft wrapping, indexed visual-row counts, byte/visual mapping, pointer hit-testing, selection painting, and document rendering. Picker and path-prompt text also consume these advances. The no-font/invalid-metric fallback retains the legacy eight-pixel advance.

Vertical document geometry uses OS/2 sTypoAscender, sTypoDescender, and sTypoLineGap when a version 4+ OS/2 table declares USE_TYPO_METRICS; otherwise it falls back to hhea ascent, descent, and line gap. The selected line box is scaled to the fixed 12-pixel em, rounded upward, and clamped to 12–32 pixels. A single runtime line-pitch value is used by viewport row counts, pointer row selection, document/selection painting, and caret placement. With no loaded font, the original 12-pixel row pitch is retained.

The synthetic-font regression deliberately assigns 900-unit ascent, −300-unit descent, and 100-unit line gap in a 1000-unit em. It verifies the resulting 16-pixel line pitch, 23 visible rows in an 800×480 surface, proportional 8px/5px advances, a correct pointer-to-caret result, the indexed wrapping record, and actual glyph pixels on both visual rows. The initial attempt failed at assembly because a nonzero value was emitted in `.bss`; the state was changed to zero initialization and Actions #400 then passed the complete workflow.

Font selection and font-size controls remain unimplemented. The em size is fixed at 12 pixels, and layout currently handles only the first Unicode scalar of a grapheme; full shaping, kerning, ligatures, combining-mark positioning, bidirectional/complex-script layout, hinting, variable/color fonts, and IME remain future work. Manual GNOME/Mutter validation of the metric-aware font rendering is still pending.

---

## 24. Phase S — TrueType typographic metrics and responsive picker text alignment

**Metric parsing and layout:** [32e54ad242d5](https://github.com/GraderGamer2/NekoEdit/commit/32e54ad242d5a95f100946629e43d6d214a8fe83) adds OS/2 typographic line metrics and cmap/hmtx-based space advances; [668da6cafbe7](https://github.com/GraderGamer2/NekoEdit/commit/668da6cafbe7d6aadf4e40c21c3b10c508a712c9) corrects SFNT hmtx validation and path-prompt centering after CI exposed register-lifetime errors.
**Dialog metric/transform alignment:** [961e19fec1a9](https://github.com/GraderGamer2/NekoEdit/commit/961e19fec1a903e061cc7804a164fb4426145825) measures picker and overlay glyph advances at the active raster size and converts them through the same horizontal transform used by glyph origins. Caret position, visible-text clipping, and pointer hit-testing therefore share the rendered glyph widths, including when the dialog is height-constrained.
**Regression and verification:** [8106dd3e109d](https://github.com/GraderGamer2/NekoEdit/commit/8106dd3e109d4b0afea3847b30503f78cca8088c) and [5324e05b45c8](https://github.com/GraderGamer2/NekoEdit/commit/5324e05b45c8f1bba8906fe6a1453f05958ab2f5) adapt the compact mock-compositor fixture and assert transformed row geometry. GitHub Actions [Build and test #414](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432) passed the complete workflow and uploaded artifact [13570135812](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432/artifacts/13570135812).

The font parser now uses OS/2 typographic ascent, descent, and line gap when a version 4+ OS/2 table sets USE_TYPO_METRICS, while retaining hhea as a fallback. U+0020 SPACE resolves through cmap and hmtx like other glyphs, so proportional fonts no longer inherit a hard-coded space width. The Open/Save picker and path prompt keep glyph raster size and advance calculations in one coordinate system: advances are measured at the actual UI font size, then mapped back through the dialog's horizontal scale before later glyph origins are transformed. Picker prefix measurement, clipping, caret position, and mouse hit-testing all use this same metric.

The compact 800x360 synthetic-font test deliberately constrains the picker by height. It verifies the 8px rendered size, exact caret and focus-line pixels, a pointer coordinate that distinguishes the 8px metrics from the previous fixed 10px advance, and filename glyph pixels inside the selected-row highlight. It also retains selected-row top/bottom pixel checks.

The intermediate CI failures were preserved and corrected rather than bypassed: #409 and #410 exposed incorrect SFNT table-length validation after OS/2 parsing; #412 and #413 exposed stale 480px and unscaled-row assumptions in the new compact-window test. The final #414 run passed the full build, CLI, mock Wayland, ELF inspection, and artifact-upload workflow.

The result is verified in the mock compositor only. A live GNOME/Mutter run is still needed to confirm the user's original appearance issue is fully resolved. Font-size selection UI, runtime font switching, hinting, kerning, script shaping, and combining-mark positioning remain unfinished.