# NekoEdit project history

**Historical reconstruction date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Current development PR:** [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) — open against main  
**Previous PR:** [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged

This document reconstructs the development of NekoEdit from the first repository prototype through the current Wayland window-management and picker milestones. The exact history is retained in [COMMIT_INDEX.md](COMMIT_INDEX.md), including the original prototype, PR #1 implementation, changelog setup, and subsequent maintenance commits captured on 2026-11-06. This document explains what those changes built.


## 2026-11-08 — Extend named XKB Unicode coverage

The bounded XKB named-symbol table now resolves 273 case-sensitive non-ASCII aliases. Alongside the pre-existing Latin-1, EuroSign, and punctuation entries, the parser now recognizes the Greek upper/lower alphabets and accented forms; core Cyrillic upper/lower alphabets; and common Ukrainian, Belarusian, Serbian, and Macedonian letters.

The new entries reuse the existing scalar table and UTF-8 insertion path. Mock-compositor coverage reads U+03B1 from `Greek_alpha` and U+044F from `Cyrillic_ya`, then verifies the inserted document bytes as part of the full Unicode/dead-key fixture. This expands named alias coverage; it does not make the parser fully xkbcommon-compatible. General custom key types, virtual modifiers and actions, other unlisted scripts/aliases, general Compose tables, and Wayland text-input/IME remain future work.


## 2026-11-08 — Add bounded XKB Multi_key Compose input

NekoEdit now recognizes the XKB `Multi_key` symbol as an editor-side Compose action. After it is pressed, the next two printable symbols are buffered and matched against a curated 20-pair table. Covered pairs include `oe/OE` → œ/Œ, `ae/AE` → æ/Æ, `ss` → ß, common accent-letter pairs, plus/minus, right arrow, guillemets, one-half, and cedilla-c. Successful matches insert a single Unicode scalar. Unsupported pairs are inserted unchanged as two literal characters.

Compose state is transient: Backspace and Escape cancel an unfinished sequence without deleting document text, and losing keyboard focus clears the pending sequence. Mock-compositor tests verify successful composition, literal fallback, and both cancellation keys. This is not general Compose support: multi-stage/longer sequences, locale-provided Compose tables, full XKB type/modifier/action semantics, and Wayland text-input/IME are still future work.

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

---

## 25. Phase T — Persistent-open font Settings and native Wayland clipboard shortcuts

**Implementation:** [`6a1db52996c8`](https://github.com/GraderGamer2/NekoEdit/commit/6a1db52996c8c134f11736d0f173eaf70ca1af11) keeps the Settings dropdown open during repeated font-size changes and adds an independent UI font-size control. [`b5c52ecca8a1`](https://github.com/GraderGamer2/NekoEdit/commit/b5c52ecca8a1973ffb97f5541b119103887cad46) adds the native Wayland clipboard backend; [`78a67be968b3`](https://github.com/GraderGamer2/NekoEdit/commit/78a67be968b39bf9b123952fcef311584be73170) corrects event dispatch so data-device events reach the clipboard state machine.

The Settings dropdown exposes two independent controls: document em size from 8–24px in two-pixel steps and UI text size from 8–14px in one-pixel steps. Neither plus/minus action closes the menu, including at its limits. The UI size affects ordinary interface text without changing document layout metrics; picker height-fitted text remains separately scaled. Preferences currently remain session-only.

The Wayland clipboard manager creates a data device for the application seat. Ctrl+C publishes an immutable copy of the selected bytes; Ctrl+X first establishes clipboard ownership from that snapshot and only then deletes the range; Ctrl+V requests UTF-8 plain text (or plain-text fallback) and receives the response asynchronously through a nonblocking pipe. Outgoing snapshots are independent of the document gap buffer and remain alive through in-flight sends. A 64 MiB transfer cap bounds clipboard payloads. The poll loop services send and receive descriptors without blocking key handling.

**Regression coverage:** the Settings test performs repeated increments/decrements without reopening the dropdown and checks the two settings independently. The clipboard test runs a separate compositor-side receiver for Copy/Cut, verifies the original bytes remain transferable after Cut deletes the document selection, and sends an external MIME offer through Ctrl+V to verify asynchronous insertion. Actions [#432](https://github.com/GraderGamer2/NekoEdit/actions/runs/42367881187) passed the settings milestone; Actions [#437](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369161877) passed the clipboard end-to-end test. The initial clipboard test exposed fixture/dispatcher defects, which were fixed before #437 rather than bypassed.

## 26. Phase U — Bounded undo/redo history and core editor shortcuts

**Implementation:** [`4fa444ef96d8`](https://github.com/GraderGamer2/NekoEdit/commit/4fa444ef96d8a3f9ef70ede628db6d1b34ec28af) adds `src/editor/history.c`, an independent bounded snapshot-history module. The Wayland keyboard path maps Ctrl+Z to Undo, Ctrl+Y and Ctrl+Shift+Z to Redo. Document edits are grouped by input action, rather than recording a new history state for each inserted byte. Snapshots store document bytes, caret offset, selection anchor and selection-active state. Loading a different document resets history; a new edit after Undo invalidates the Redo branch.

The history store is intentionally bounded: 16 entries per Undo/Redo stack, a 32 MiB aggregate snapshot budget, and a 4 MiB per-snapshot ceiling. Each snapshot is an independent mmap allocation; restoring a state reserves sufficient gap-buffer capacity, replaces its contents, invalidates the per-line index, and refreshes caret visibility. Documents larger than the snapshot ceiling remain editable but cannot be fully represented by this history implementation.

**Regression coverage and verification:** the Wayland integration test replaces a selected document, checks Undo and Redo byte-for-byte, verifies restoration of the prior caret and active selection, collapses that selection with Right Arrow, then types a new character and checks that a stale Redo action cannot alter the new branch. An intermediate #439 failure was a test-expectation error: it expected typing after Undo to append despite Undo correctly restoring the selected range; the test was corrected to collapse that range before branching. Actions [#440](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369791425) passed all build, CLI, Wayland mock, ELF inspection and artifact-upload stages. Artifact [`13572958390`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369791425/artifacts/13572958390) is 61,359 bytes with SHA-256 `e8d1c2027d934efa7dc7661819c28de22af7538a23c5c07eec00ae939d45a2e7`. Live GNOME/Mutter validation of this artifact remains outstanding.


---

## 15. Phase V — soft-wrap control and horizontal document viewport

**Implementation:** [80c2fdc6916f](https://github.com/GraderGamer2/NekoEdit/commit/80c2fdc6916f8403350d10826043f90936642f0a) adds horizontal scrolling for unwrapped document lines; follow-up fixes and integration-test corrections are recorded in [COMMIT_INDEX.md](COMMIT_INDEX.md).

The Settings menu now includes a session-only **Wrap Lines** switch, enabled by default. In wrapped mode, long logical lines continue to use pixel-advance-based soft wrapping and the line index records the resulting visual rows. In no-wrap mode, each logical line maps to one visual row and the editor maintains a horizontal pixel origin for the document viewport.

Wayland horizontal-axis wheel events and Shift+vertical-wheel events scroll the viewport horizontally. The caret is kept visible as it moves along a long line. Pointer hit-testing includes the horizontal offset and continues to use the same font advances and grapheme-boundary mapping as the renderer. No-wrap selection backgrounds are painted through a viewport-clipped path. Turning wrapping back on resets the horizontal origin and rebuilds the wrapped row index. The existing vertical scrollbar represents wrapped visual rows in wrapped mode and logical lines in no-wrap mode; a dedicated draggable horizontal scrollbar remains future work.

The dedicated 200-byte-line mock-compositor scenario verifies the Settings toggle, one-row no-wrap index, caret-following horizontal offset, 14px horizontal wheel movement, pointer hit-testing with a nonzero horizontal origin, and restoration of wrapped layout. GitHub Actions [#447](https://github.com/GraderGamer2/NekoEdit/actions/runs/42372524911) passed the complete freestanding build, CLI, Wayland mock, ELF inspection, and artifact-upload workflow. Artifact [13574342289](https://github.com/GraderGamer2/NekoEdit/actions/runs/42372524911/artifacts/13574342289) is 62,237 bytes. Manual GNOME/Mutter verification of this exact build remains outstanding.


---

## 27. Phase W — Responsive controls, horizontal scrollbar, selection, and search

**Responsive interface:** [`4b116c25e730`](https://github.com/GraderGamer2/NekoEdit/commit/4b116c25e7304743ff54cd3c731da887cbd0eb01) scales Settings controls with the selected UI typography. Follow-up layout fixes use a centered, aspect-ratio-preserving panel transform so the panel, glyph raster size, and pointer hit map stay in the same coordinate system. Find/Replace follows the same sizing policy.

**Horizontal document scrollbar:** [`ed9f432dca08`](https://github.com/GraderGamer2/NekoEdit/commit/ed9f432dca0883be6c2e1d76b3ecbca589703466) adds the bottom horizontal rail for no-wrap documents. The thumb maps the widest logical line to the document viewport; track clicks reposition it and mouse dragging retains the thumb grab offset. Horizontal-wheel and Shift+vertical-wheel inputs use the same pixel-scroll path. The viewport height is reduced while the rail is visible so it never obscures document content.

**Selection and keyboard navigation:** [`9ba8ec298672`](https://github.com/GraderGamer2/NekoEdit/NekoEdit/commit/9ba8ec298672201d31551eb5bacd90116eeaf098) adds word selection on double-click and Ctrl+Left/Right word navigation. [`844da8f8a8fb`](https://github.com/GraderGamer2/NekoEdit/commit/844da8f8a8fbaeb447f03e99480fb13ad541f4b7) adds Ctrl+Up/Down movement between logical lines; Shift variants extend selections. Ctrl+Home/End and Ctrl+Backspace/Delete provide document-boundary and word-deletion operations.

**Find/Replace:** [`a8bd382bbd75`](https://github.com/GraderGamer2/NekoEdit/commit/a8bd382bbd75b4fb99786ae8c83cf91a83cfd3f2) adds a centered Find/Replace modal. Ctrl+F/ Ctrl+H open Find and Replace, Enter/F3/Shift+F3 navigate literal matches, Ctrl+Enter replaces a selected match, and Replace All iterates through the document. Query text entry follows the currently supported ASCII XKB subset.

**Verification:** the full Wayland mock-compositor suite checks horizontal track dragging and both wheel paths, panel centering and UI-font scale, Ctrl+word and logical-line movement, Shift-extended selection, double-click word selection, and Find/Replace byte results. Actions [Build and test #493](https://github.com/GraderGamer2/NekoEdit/actions/runs/42391111760) passed all workflow stages and uploaded artifact [13581805940](https://github.com/GraderGamer2/NekoEdit/NekoEdit/actions/runs/42391111760/artifacts/13581805940), 67,298 bytes. The user has manually confirmed runtime font selection; the newly added interactions still need a GNOME/Mutter desktop smoke test.


---

## 28. Phase X — persistent typography, font, and editor preferences

The responsive editor controls and search interactions were followed by a small persistent-settings layer. The implementation lives in `src/editor/preferences.c` and follows the project's freestanding design: it uses raw Linux syscalls rather than libc or a third-party configuration dependency.

The preference file is stored at `$XDG_CONFIG_HOME/nekoedit/preferences`, or `~/.config/nekoedit/preferences` when `XDG_CONFIG_HOME` is unset. It records document font size, UI font size, Wrap Lines, Confirm before saving, and the last successfully loaded TrueType path. Startup restores these values before the first layout calculation and before font initialization. An explicit `NEKOEDIT_FONT` environment setting continues to take priority over the saved font; the saved path is tried before the deterministic system-font candidates.

Values are parsed with bounded input and range checks. Font paths must be absolute and cannot contain carriage returns or newlines. The application directory is created with mode 0700 and the file is mode 0600. Updates go to a same-directory temporary file, handle partial writes and EINTR, fsync the file, atomically rename it, and fsync the containing directory. `NEKOEDIT_DISABLE_PREFERENCES=1` leaves runtime defaults/settings alone and bypasses persistence.

The preference-specific unit test verifies initial defaults, persistence and reload of every supported setting, the TTF path, restrictive file mode, invalid/range-out-of-bounds values, path-format rejection, and the disable switch. The Wayland mock-compositor test sets the disable switch so machine-specific user settings cannot change the expected pixel/input fixtures.

GitHub Actions [Build and test #505](https://github.com/GraderGamer2/NekoEdit/actions/runs/42391762592) passed the full build, ELF, CLI, preferences, Wayland, executable-inspection, and artifact-upload workflow on commit [`8dc43ea3a1a3`](https://github.com/GraderGamer2/NekoEdit/commit/8dc43ea3a1a34350d45aa016e8c815e58e713ef7). The artifact is 70,250 bytes with SHA-256 `796dc4ceb118b364eccd37ff58db88c5bf33e50dbd5263b76ffaf314ce4c2279`. This remains mock-compositor/automated verification; manual GNOME/Mutter testing of the scrollbar, responsive overlays, Find/Replace, and preference restoration is still required.


---

## 29. Phase Y — home-level settings, document-wide search highlighting, and Unicode keyboard input

### Home-level settings storage

The preferences implementation was moved from the XDG-style configuration directories to a single hidden application folder directly under the user's home directory: `$HOME/.nekoedit/preferences`. The application no longer reads XDG_CONFIG_HOME. The directory retains mode 0700 and the preference file mode 0600; same-directory temporary writes, fsync, atomic rename, and directory fsync are retained. The preferences test sets both HOME and XDG_CONFIG_HOME and proves that only the HOME-level `.nekoedit` directory is created.

### Typography panel refinement

Settings and Find/Replace no longer scale their outer panel dimensions with the UI font-size preference. They retain 256×168 and 448×192 design dimensions respectively, centered and fitted to the available window. The actual glyph size follows the selected UI font and the pointer transform remains in the same coordinate space. The regression test sets the UI font to 16px and checks the two panel dimensions stay at their fixed values while both overlay font-size values report 16px.

### Document-wide Find highlighting

The renderer now runs a literal query scan over the document while Find/Replace is open. Every occurrence is highlighted in amber, including repeated and overlapping results. The active result is painted afterward using the selection renderer, so the current match remains distinct. The Find integration test inspects the framebuffer to prove that the second non-active occurrence is also painted.

### Unicode keysyms and UTF-8 document insertion

The XKB text-v1 parser now maintains a parallel Unicode-scalar table in addition to its existing ASCII byte lookup table. It recognizes explicit Unicode keysym tokens in Uxxxx, Uxxxxx, and Uxxxxxx form, rejects values outside Unicode's scalar range, surrogate values and control characters, and stores each value by keycode, group and level. Document keyboard input uses the Unicode lookup path when a parsed keymap is available and encodes the selected scalar into one to four UTF-8 bytes through the normal document insertion path. The built-in US-QWERTY fallback remains unchanged.

The regression map maps one physical key to U+00E9 (é) and its Shift level to U+1F600 (😀). The mock test verifies the document contains the exact byte sequence C3 A9 F0 9F 98 80. Existing ASCII layout tests still exercise keycode offset, group switching, Shift, LevelThree, and the shifted punctuation rows. This is explicit Unicode-keysym support only; named keysym aliases, full XKB modifier/type/action handling, compose/dead keys and Wayland text-input/IME remain future work.

### Verification and boundaries

Actions [Build and test #518](https://github.com/GraderGamer2/NekoEdit/actions/runs/42393599670) passed the three requested refinement tests. After the Unicode-input work, Actions [Build and test #523](https://github.com/GraderGamer2/NekoEdit/actions/runs/42393972784) passed the complete build, CLI, preferences, Wayland mock, ELF inspection, and artifact-upload workflow on [`72695a3d9f3d`](https://github.com/GraderGamer2/NekoEdit/commit/72695a3d9f3dd7a714c5f80bf014b9e1d7fd28e6). Artifact [13582597118](https://github.com/GraderGamer2/NekoEdit/actions/runs/42393972784/artifacts/13582597118) is 70,702 bytes. This is automated mock-compositor verification; GNOME/Mutter desktop testing of the latest settings restoration, responsive panels, search highlights, and Unicode typing remains outstanding.


---

## 30. Phase Z — whole-word pointer dragging, edge auto-scroll, and named Unicode keysyms

### Whole-word mouse dragging

Double-click now creates a complete word selection while preserving the active pointer grab. Dragging the held button extends the selection by whole words; moving to the left of the original word retains its right boundary and extends toward earlier words, while moving right retains the original left boundary. Single-click dragging continues to operate at character/grapheme boundaries.

### Selection edge auto-scroll

Selection motion is handled even when the pointer is outside the document viewport or the application surface. NekoEdit clamps the hit-test position to the nearest document edge while retaining the actual pointer location to determine the scroll direction. A separate timerfd drives scrolling while the mouse button is held and the pointer is outside the viewport. Vertical scrolling works in both soft-wrap modes; horizontal scrolling follows the pointer when Wrap Lines is disabled. Timer-driven scrolling continues if the pointer stops moving at the edge and stops on button release.

### Named XKB Unicode keysyms

The parser now resolves a curated set of 105 common named non-ASCII keysyms, covering Latin-1 symbol/letter names and selected currency, punctuation, quotation-mark, and typographic symbols such as EuroSign, endash, emdash, bullet, ellipsis, and trademark. These aliases populate the same per-key/group/level scalar table as explicit Uxxxx/Uxxxxx/Uxxxxxx tokens and use the existing UTF-8 document insertion path. This is a deliberate subset rather than full XKB support; complete virtual-modifier and action semantics, arbitrary custom type maps, compose/dead keys, and text-input/IME remain future work.

### Regression coverage and verification

The mock compositor verifies forward and reverse whole-word dragging after double-click; character-selection continuation after pointer-leave; vertical auto-scroll both immediately and while the pointer is stationary; horizontal auto-scroll with Wrap Lines disabled; and timer cleanup on release. XKB tests inspect the parsed scalar table and confirm explicit U+00E9/U+1F600 plus EuroSign/eacute/emdash insertion. GitHub Actions [Build and test #544](https://github.com/GraderGamer2/NekoEdit/actions/runs/42396964885) passed the complete freestanding build, CLI, preferences, Wayland integration, ELF inspection, and artifact-upload workflow on [e9bbc7a6ff04](https://github.com/GraderGamer2/NekoEdit/commit/e9bbc7a6ff048b53e4961d2bd9014cac45a7569a). Artifact [13583613881](https://github.com/GraderGamer2/NekoEdit/actions/runs/42396964885/artifacts/13583613881) is 72,303 bytes with SHA-256 `4d01116a148ed94405a5f6623927a7d7bf41c6b207f02e8ab105a9d6ec318a13`. A GNOME/Mutter desktop test of the new mouse interaction remains outstanding.


---

## 31. Phase AA — bounded XKB dead-key composition

Six common XKB dead-key names are now recognized: grave, acute, circumflex, tilde, diaeresis, and cedilla. Their keysyms use reserved action tokens rather than pretending to be ordinary Unicode scalars. The Wayland keyboard path stores a pending combining mark and applies it to the next printable scalar. A 52-pair mapping produces common Latin-1 precomposed letters. When no precomposed result exists, the editor inserts the base scalar followed by the combining mark, preserving the input. Backspace and Escape cancel a pending mark without modifying the document, and keyboard focus loss clears it.

The mock compositor verifies that AC04 maps to the reserved dead_acute action, dead acute followed by e inserts UTF-8 for é, dead acute followed by g preserves g plus U+0301, and Backspace/Escape cancellation leaves document bytes and length unchanged. This is a deliberately bounded first compose implementation: general Compose sequences/tables, locale-specific mappings, full XKB actions/types, and Wayland text-input/IME remain unimplemented.

GitHub Actions [Build and test #551](https://github.com/GraderGamer2/NekoEdit/actions/runs/42397866256) passed the full build/ELF, CLI, preferences, Wayland mock-compositor, executable-inspection, and artifact-upload workflow on [cb469d616f8b](https://github.com/GraderGamer2/NekoEdit/commit/cb469d616f8b40cd27e4d37fe2e1320169a826ad). Artifact [13584292417](https://github.com/GraderGamer2/NekoEdit/actions/runs/42397866256/artifacts/13584292417) is 72,887 bytes with uploaded ZIP SHA-256 947dd732391b1f7f792ca60c0b60b28114f81cff0e8a4b066989d3a64705a6f8. Automated verification is complete; live GNOME/Mutter testing remains outstanding.
