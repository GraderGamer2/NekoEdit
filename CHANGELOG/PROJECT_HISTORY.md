# NekoEdit project history

**Historical reconstruction date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `feat/wayland-socket-error-handling`  
**Active development PR:** [#1 — feat: add Wayland editing and initial editor UI](https://github.com/GraderGamer2/NekoEdit/pull/1)

This document reconstructs the development of NekoEdit from the first repository prototype through the fixed-capacity gap-buffer milestone. The exact history is retained in [COMMIT_INDEX.md](COMMIT_INDEX.md), including the original prototype, PR #1 implementation, changelog setup, and subsequent maintenance commits captured on 2026-11-06. This document explains what those changes built.

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
