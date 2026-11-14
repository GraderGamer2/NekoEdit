## 2026-11-15 — gap-aware line-index rebuild (Actions #984 PASS)

The rebuild already used `REPNE SCASB` when the gap was at EOF, but an internal gap sent both newline counting and line-boundary discovery through byte-at-a-time `doc_byte_at` loops. The edited-document path now scans the physical prefix and suffix as independent contiguous spans.

The count pass initializes the prefix pointer at `doc_buffer` and searches exactly `doc_gap_start` bytes, then starts the suffix at `doc_buffer + doc_gap_end` and searches exactly `doc_length - doc_gap_start` bytes. This preserves logical byte order and counts LF characters on both sides of the gap.

The record-fill pass carries the current logical line start and logical offset between spans. Each found LF closes a record using its logical end offset; if no LF occurs before the gap, the same record continues into the suffix. The final unterminated or empty line is retained as before. `doc_line_index_measure_rows`, stable-ID assignment, record layout, and Fenwick-tree construction are unchanged.

The new mock cases deliberately invalidate the current index after an ordinary insertion and after Enter, then trigger rebuilding at two exact gap placements: inside a logical line, and immediately after the inserted LF. The test checks that the rebuilt byte spans, row counts, unique line IDs and Fenwick nodes match the expected logical document. Actions [#984](https://github.com/GraderGamer2/NekoEdit/actions/runs/43638409180) passed the complete 17-step workflow, including the full Wayland mock, 11 MiB Open/Save and nested GNOME Shell/Mutter/IBus integration.

The ELF reports text 237,686 bytes, data 64 bytes and BSS 3,764,856 bytes. The executable artifact is 151,150 bytes (78 bytes larger than #983); the Compose artifact is 120,536 bytes. No speed improvement is claimed: no before/after end-to-end timing was collected. The remaining visual-row measurement path still uses its existing grapheme and glyph-width calculations.

Implementation commit: [f8ff3f8](https://github.com/GraderGamer2/NekoEdit/commit/f8ff3f8df0575a5349a3f5d7acec020890661983).

---

## 2026-11-15 — whole-tree low-level optimization pass (Actions #983 PASS)

Performed a source/build audit across the assembly backends, C support modules and Makefile, then applied conservative improvements to measured or visibly repeated work.

The rectangle fill routine now computes a starting row pointer and per-row padding once, then advances a pointer after each `REP STOSD`. This removes the per-row multiply and address additions from the full-frame and dirty-band loops. Fenwick construction now seeds each node from its line's own byte/visual-row values during the initialization pass; the following pass no longer reloads and adds those same values before parent propagation.

Added `src/editor/gap_buffer.h` to share bulk gap-buffer copy operations. A logical `[begin,end)` range is physically contiguous on at most two sides of the gap, so `gap_buffer_copy_range` uses at most two `REP MOVSB` copies. Clipboard selection snapshots, history deleted-byte capture, and history transaction encoding use this instead of per-byte calls/loops. `hash_doc` now hashes the prefix/suffix spans directly. `reset_file_to_current` writes the initial document snapshot in at most two bulk writes; previously it issued a write syscall for every byte in the base document.

The build now compiles C code with `-ffunction-sections -fdata-sections -fno-ident`, links with `--gc-sections`, and reports section size through `make inspect`. All 308 uniquely typed assembly functions across the Wayland, XKB, SFNT, entry and syscall files were isolated into separate executable sections. The normal development profile remains `-O2`, unstripped, with no third-party runtime dependency.

Added exhaustive representative gap-range coverage: every start/end selection for each gap position in a 19-byte logical document, using gap sizes 1, 7, 16 and 31. Existing host history tests and clipboard/Wayland integration cover the production call sites.

Validation: Actions [#983](https://github.com/GraderGamer2/NekoEdit/actions/runs/43636763115) passed all 17 steps. This includes build/ELF, CLI and C tests, renderer equivalence, full Wayland mock with 11 MiB Open/Save and clipboard scenarios, native `us(intl)`, X.Org importer, Compose pack, nested GNOME Shell/Mutter, and artifact uploads. An earlier intermediate run (#982) stopped at compilation of the new range test because three fixture assignments still referenced the old clipboard globals; commit [cb2ebe5](https://github.com/GraderGamer2/NekoEdit/commit/cb2ebe5fd798e5989dcee608ea1518ebfa92cd53) removed those stale assignments, and #983 passed.

Final `size` output: text 237,542 bytes; data 64 bytes; BSS 3,764,856 bytes. Uploaded executable artifact: 151,072 bytes; prior comparable #979 artifact: 151,261 bytes. This is a 189-byte artifact-size decrease. Compose pack artifact: 120,536 bytes. The artifacts expire 2026-11-16 03:21 WIB.

No new end-to-end speed benchmark was performed. The optimization claims are limited to removed work in the affected loops/syscalls; the small artifact-size delta is reported separately. No live GNOME session retest is claimed.

The review also covered the TrueType rasterizer, SFNT parser, XKB parser/key tables, Compose/locale loader, clipboard/history/preferences support, Linux entry/syscall layer and build configuration. No broad parser/rasterizer rewrite was made: those paths need focused profiling and equivalence/performance measurements first. Follow-up should measure target-machine large-document edit/input-to-present behavior and profile line-index invalidation/rebuild and full-frame edit repaint.

Implementation commits:
- [4ea34cfd](https://github.com/GraderGamer2/NekoEdit/commit/4ea34cfd6ee502ad7bb1a6dfdb1b103d5cc6c1d9) — row fills, Fenwick initialization and first clipboard bulk copy.
- [0e32b6a4](https://github.com/GraderGamer2/NekoEdit/commit/0e32b6a4e51911ebdc543d4cc365889ff566f6f2) — shared gap-buffer helpers and history bulk paths.
- [aa4d6e48](https://github.com/GraderGamer2/NekoEdit/commit/aa4d6e4808dcf83e028de72bfcc6605498a531b2) — assembly per-function sections for linker GC.
- [cb2ebe5f](https://github.com/GraderGamer2/NekoEdit/commit/cb2ebe5fd798e5989dcee608ea1518ebfa92cd53) — clipboard range test fixture correction.

---

## 2026-11-15 — clipped rectangle row traversal (Actions #979 PASS)

**Branch:** `early-alpha` at [2d7248f](https://github.com/GraderGamer2/NekoEdit/commit/2d7248f3328fa7eac027bf1c7ca702446357537c); normal development remains `-O2`, unstripped. **Workflow:** [Actions #979](https://github.com/GraderGamer2/NekoEdit/actions/runs/43633743211) passed all steps.

During caret-only partial rendering, `draw_rect` previously iterated over every row of each rectangle and checked whether that row intersected either dirty clip band. This meant the full-window background rectangle still scanned the entire window height despite only repainting the caret and status bands.

The rectangle rasterizer now intersects its Y range with the two ordered clip intervals before entering the paint loops. It visits only the intersecting rows, avoids duplicate work if the two intervals touch/overlap, and retains a separate unclipped full-frame loop without per-row clip checks. Pixel format, rectangle clipping, the two Wayland damage rectangles, and full-render behavior are unchanged.

The dirty-render Wayland regression now records row iterations specifically for the full-window background rectangle on each committed caret frame. It requires every partial frame to visit fewer rows than the full surface height, and requires full-frame fallback to keep the clipped-row counter unchanged. The existing 4,096-row document test still verifies bounded document traversal near EOF. Actions #979 passed this assertion and the full Wayland mock, build/ELF, CLI, renderer equivalence, XKB, X.Org importer, Compose, nested GNOME Shell/Mutter, and artifact-upload checks.

This verifies reduced row-loop work for eligible caret-only partial frames; it is not an end-to-end frame-time or FPS measurement.

Artifacts: [Linux x86-64 executable, 151,261 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43633743211/artifacts/14128774572); [Compose locale packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43633743211/artifacts/14129257247). Expiry: 2026-11-16 02:48 WIB.

## 2026-11-15 — compact TrueType glyph-cache metadata (Actions #978 PASS)

**Branch:** `early-alpha` at [8fa73ea](https://github.com/GraderGamer2/NekoEdit/commit/8fa73eada67d274e0b495fcfbe791a2c42b29f53); normal development remains `-O2`, unstripped. **Workflow:** [Actions #978](https://github.com/GraderGamer2/NekoEdit/actions/runs/43632872689) passed all steps.

The glyph cache now stores its hot lookup/LRU metadata separately from its 128 per-slot 16 KiB pixel masks. The old array-of-structures layout made metadata lookups and the bounded LRU victim scan step across large pixel-bearing records. The new structure-of-arrays layout keeps metadata compact and contiguous. Cache keys, hash chains, stamp-based LRU behavior, slot identity, mask storage, and rasterization/drawing results are preserved.

The renderer benchmark directly compares the compact AoS reference and compact SoA implementation. For the synthetic 128-glyph working set, warm draw improved from **182.0 ns to 176.6 ns per glyph draw (3.0% lower)**. Cache-fill and warm-framebuffer checksums matched across every benchmark variant. This is a microbenchmark result, not an end-to-end typing-latency or FPS claim.

Actions #978 passed the freestanding build/ELF checks, CLI tests, all renderer equivalence/benchmark variants, full Wayland protocol mock (including 10 MiB clipboard and 11 MiB Open/Save coverage), executable inspection, native `us(intl)` parsing, X.Org importer verification, Compose-pack build, nested GNOME Shell/Mutter integration, and both artifact uploads.

Artifacts: [Linux x86-64 executable, 151,091 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43632872689/artifacts/14128074614); [Compose locale packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43632872689/artifacts/14128294260). Expiry: 2026-11-16 02:38 WIB.

## 2026-11-15 — provider-safe large clipboard paste and 30 Hz key repeat (Actions #977 PASS)

**Branch:** `early-alpha`; normal development remains `-O2`, unstripped. Implementation: [675bb06](https://github.com/GraderGamer2/NekoEdit/commit/675bb060abdbbaf69f562f4d95990e21a536c83c); repeat-test comment clarification: [8095dd5](https://github.com/GraderGamer2/NekoEdit/commit/8095dd5ffa50119910154b7650840688037799b2). **Workflow:** [Actions #977](https://github.com/GraderGamer2/NekoEdit/actions/runs/43630643206) passed all 17 steps.

**Clipboard/paste:** The receive limit was already 64 MiB and the document buffer supports substantially larger documents; there was no intentional 4 MiB paste cap. The clipboard receive pipe had been created with `O_NONBLOCK` on both ends, which also exposed a nonblocking writer FD to the external clipboard provider. The receiver now creates a close-on-exec pipe, then marks only its own read end nonblocking. The provider gets a normal blocking write FD. NekoEdit also recognizes `UTF8_STRING` in addition to `text/plain;charset=utf-8` and `text/plain`, improving compatibility with GTK/X11-bridged clipboard owners.

The Wayland mock asserts that the provider receives a blocking FD, offers only `UTF8_STRING`, and sends an exact 10 MiB payload through it. NekoEdit preserves every byte and line-index record; bulk Undo/Redo passed. The measured mock transfer plus Undo/Redo completed in 159.4 ms. This verifies NekoEdit's receive path and the GTK/X11 MIME fallback; a direct test with the user's installed l3afpad build still remains useful.

**Keyboard repeat:** The app previously gated repeat on `xkb_key_repeats()`. That allowed keymap repeat policy to suppress editing keys such as Backspace/Enter even though NekoEdit had a client-side timer. The application now starts its timer for every ordinary key, independent of per-key XKB repeat flags, at a fixed **30 ticks per second**. It retains the compositor's initial repeat delay (180 ms in the modern-protocol regression; 300 ms fallback when repeat-info is unavailable). Modifier, lock, and Compose keys remain excluded; Ctrl shortcuts remain single-shot.

The Wayland regression verifies repeat for Left, Backspace, Delete, Enter, Tab and printable keys, including custom XKB fixtures with `repeat=False`. The test also changes `wl_keyboard.repeat_info` while a key is held and confirms that the delay updates while the repeat rate stays at 30 Hz.

**Validation:** Actions #977 passed freestanding build/ELF validation, CLI smoke, renderer equivalence, the full Wayland protocol mock (including 10 MiB clipboard paste and 11 MiB Open/Save), executable inspection, native `us(intl)` parsing, pinned X.Org importer verification, Compose generation, nested GNOME Shell/Mutter integration, and both artifact uploads.

Artifacts: [Linux x86-64 executable, 151,038 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43630643206/artifacts/14127667227); [Compose locale packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43630643206/artifacts/14128111687). Expiry: 2026-11-16 02:13 WIB.

---

## 2026-11-15 — opaque glyph pixel fast path (Actions #973 PASS)

**Branch:** `early-alpha`; implementation [e873215](https://github.com/GraderGamer2/NekoEdit/commit/e873215ad4e1519b72c686cfa07398a6bfe85776). **Workflow:** [Actions #973](https://github.com/GraderGamer2/NekoEdit/actions/runs/43627839385) passed all 17 steps.

The TrueType glyph blitter's normal identity-transform path writes alpha-255 pixels directly as the fixed opaque foreground color `0xffd8dee9`, skipping the destination read and three-channel blend. Antialiased edge pixels and rotated/reflected paths retain the original blend. A four-way benchmark required matching framebuffer checksums; warm draw improved from 239.5 ns to 169.2 ns per glyph draw (29.4% lower) against the same hash-cache/identity renderer with the previous blend. The cumulative comparison against the original linear-cache/generic-transform reference was 58.7% lower. These are synthetic microbenchmark results, not an end-to-end editor latency or FPS claim.

---

## 2026-11-15 — signed pointer coordinates for selection edge auto-scroll (Actions #972 PASS)

**Branch:** `early-alpha`; implementation [d0f0360](https://github.com/GraderGamer2/NekoEdit/commit/d0f036054360a2d5f8d5a8e49a828b7b75ed66f3); timeout test adjustment [d3e7938](https://github.com/GraderGamer2/NekoEdit/commit/d3e7938ca6a889133e1304cda36deecc3fa62688).

Wayland pointer coordinates are signed 24.8 surface-local values. During an implicit button grab, motion can continue outside the surface and produce negative X/Y values. Unsigned division previously wrapped them into large positive virtual coordinates, which could reverse selection edge auto-scroll. Pointer enter/motion and geometry rebasing now preserve signed values. Actions #972 passed all 17 steps, including the Wayland mock, 11 MiB Open/Save, and nested Mutter integration. The user confirmed selection works at both screen edges.

---

## 2026-11-15 — signed pointer coordinates for selection edge auto-scroll (Actions #972 PASS)

**Branch:** early-alpha; normal development remains -O2, unstripped. Implementation: [d0f0360](https://github.com/GraderGamer2/NekoEdit/commit/d0f036054360a2d5f8d5a8e49a828b7b75ed66f3). Test-timeout adjustment: [d3e7938](https://github.com/GraderGamer2/NekoEdit/commit/d3e7938ca6a889133e1304cda36deecc3fa62688).

Wayland pointer coordinates are signed 24.8 surface-local values. During an implicit button grab, pointer motion can continue outside the surface and produce negative X/Y coordinates. The previous unsigned division converted negative positions into large positive virtual coordinates, which could reverse selection auto-scroll when dragging above or left of the window. Pointer enter, pointer motion, and geometry-change rebasing now use signed division for both axes; the scroll thresholds and doc_scroll_by direction logic are unchanged.

The Wayland mock covers downward and upward auto-scroll, including negative Y above the surface and a stationary timer check that forbids direction reversal, as well as no-wrap horizontal drag. Actions [#972](https://github.com/GraderGamer2/NekoEdit/actions/runs/43626802935) passed all 17 workflow steps, including the complete Wayland protocol mock (with 11 MiB Open/Save), ELF inspection, us(intl) keymap validation, X.Org importer checks, Compose-pack generation, nested GNOME Shell/Mutter integration, and both artifact uploads. The user also confirmed that selection now scrolls correctly at the top and bottom edges of the screen.

---

## 2026-11-15 — signed pointer coordinates for selection edge auto-scroll (Actions #972 PASS)

**Branch:** early-alpha; normal development remains -O2, unstripped. Implementation: [d0f0360](https://github.com/GraderGamer2/NekoEdit/commit/d0f036054360a2d5f8d5a8e49a828b7b75ed66f3). Test-timeout adjustment: [d3e7938](https://github.com/GraderGamer2/NekoEdit/commit/d3e7938ca6a889133e1304cda36deecc3fa62688).

Wayland pointer coordinates are signed 24.8 surface-local values. During an implicit button grab, pointer motion can continue outside the surface and produce negative X/Y coordinates. The previous unsigned division converted negative positions into large positive virtual coordinates, which could reverse selection auto-scroll when dragging above or left of the window. Pointer enter, pointer motion, and geometry-change rebasing now use signed division for both axes; the scroll thresholds and doc_scroll_by direction logic are unchanged.

The Wayland mock covers downward and upward auto-scroll, including negative Y above the surface and a stationary timer check that forbids direction reversal, as well as no-wrap horizontal drag. Actions [#972](https://github.com/GraderGamer2/NekoEdit/actions/runs/43626802935) passed all 17 workflow steps, including the complete Wayland protocol mock (with 11 MiB Open/Save), ELF inspection, us(intl) keymap validation, X.Org importer checks, Compose-pack generation, nested GNOME Shell/Mutter integration, and both artifact uploads. The user has also confirmed that selection now scrolls correctly at the top and bottom edges of the screen.

---
---

## 2026-11-15 — dirty caret-band document traversal bounded (Actions #970 PASS)

**Branch:** `early-alpha` at [9420d2c](https://github.com/GraderGamer2/NekoEdit/commit/9420d2ce6fe4670bcf155c0306ee4fb77a122b05). **Rendering implementation:** [09cf984](https://github.com/GraderGamer2/NekoEdit/commit/09cf98497c60eefef3beeaee767d072efe19defd). **Workflow:** [Actions run #970](https://github.com/GraderGamer2/NekoEdit/actions/runs/43619977492) passed the complete workflow.

The caret-only partial-render path now bounds document traversal to the same visual-row interval as its dirty pixel bands. `render_prepare_slot` records the first dirty row (one row before the earlier caret) and the exclusive end after the later caret plus one row of overhang. `render_document` maps directly to that first row through `doc_visual_to_offset` (including the horizontal pixel origin when Wrap Lines is OFF) and stops at the interval's end. The full-render path is unchanged.

The optimization remains guarded by the existing per-SHM-slot committed snapshots. It applies only to plain, unselected arrow-key movement with both caret rows visible and no more than one row apart. Edits, selections, scrolling, IME/Compose, overlays, pointer drags, resizes, scale changes, transformed buffers and stale snapshots retain the full-frame fallback.

The Wayland mock now checks a 4,096-row document and requires caret-only movement near EOF to scan no more than 512 document bytes while using two-band damage. A separate 11-byte fixture verifies that text insertion still uses full-frame damage and appends the exact expected byte. Actions #968 and #969 exposed test-harness assumptions; the long-document traversal and short-document edit-fallback cases are now isolated. Actions #970 passed the complete suite, including dual-buffer coverage, 11 MiB Open/Save, XKB, X.Org importer, Compose generation, nested GNOME Shell/Mutter integration, and both artifact uploads.

Artifacts: Linux x86-64 executable, 150,886 bytes ([#14123966705](https://github.com/GraderGamer2/NekoEdit/actions/runs/43619977492/artifacts/14123966705)); Compose locale packs, 120,536 bytes ([#14123123164](https://github.com/GraderGamer2/NekoEdit/actions/runs/43619977492/artifacts/14123123164)).

This is a bounded-work verification for eligible caret-only redraws, not an end-to-end FPS or latency claim. Manual visual testing on the target GNOME/Mutter session and controlled input-to-present measurements remain outstanding.

---

## 2026-11-14 — dirty caret-band rendering validated (Actions #967 PASS)

**Branch:** `early-alpha` at [a786d7b](https://github.com/GraderGamer2/NekoEdit/commit/a786d7b522126121bef8d0d60df940bd3fb8c1bf). **Workflow:** [Actions run #967](https://github.com/GraderGamer2/NekoEdit/actions/runs/43592103656) completed successfully.

The new dirty caret-band path passed the complete CI workflow: ELF build/inspection, command-line smoke tests, linear-reference versus hash-indexed glyph-cache equivalence, the Wayland protocol mock (including the focused partial-damage test, dual-SHM-buffer cases, and 11 MiB Open/Save), XKB keymap checks, X.Org source/import verification, Compose-pack build, and nested GNOME Shell/Mutter Wayland integration. Compose and Linux x86-64 artifacts were uploaded successfully.

The renderer remains deliberately conservative: plain unselected arrow-key caret motion can repaint the old/new caret-row neighbourhood and status footer, with per-slot SHM snapshots. Edits, selection, scroll, overlays, IME/Compose, resize/scale changes, transformed buffers and stale slot state keep the full-frame fallback. This reduces pixel writes and compositor damage area, but visible-row layout traversal is still performed; no end-to-end latency improvement is claimed. User-machine GNOME/Mutter smoke testing and controlled performance measurements remain outstanding.

---

## 2026-11-14 — dirty-render fixture click boundary correction

Actions #966 passed the build, command-line smoke tests and rasterizer comparison, then reached the focused Wayland scenario. Its initial click landed at EOF for the 12-character fixture (caret column 12, x=112), one column beyond the existing generic non-empty-file pixel assertion's sampled columns 9–11. The fixture is now eleven characters, so the same click clamps to a caret position within the assertion's tested range. The focused scenario still moves to EOF explicitly before its repeated arrow-key and insertion checks. This is a test-fixture adjustment only; renderer source remains unchanged. Actions validation is pending.

---

## 2026-11-14 — dirty-render click fixture length correction

Actions #965 passed the build, command-line tests, rasterizer comparison, and the regular Wayland mock cases, including the two-buffer pool. The focused dirty-render scenario then stopped in the shared initial-click assertion before reaching its own navigation checks. The fixture had six bytes, while that generic non-empty-file assertion samples caret positions at columns 9–11; the observed caret at column 6 was correct for the file. Extend the fixture to twelve ASCII bytes so the initial click lands in the range the generic assertion checks. The subsequent test still explicitly moves the caret to EOF before exercising repeated Left/Right navigation and insertion. Renderer source is unchanged.

---

## 2026-11-14 — dual-SHM-slot caret test correction

Actions run #964 compiled the ELF, passed CLI smoke tests, and passed the rasterizer equivalence/benchmark checks. The held-Enter Wayland scenario then exposed that its caret pixel scanner read from SHM pool offset zero even when the compositor had most recently attached the alternate buffer slot. The test now applies the active attached buffer's tracked offset to caret scans, failure diagnostics, and adjacent glyph-pixel assertions. This corrects the test's observation of the existing two-slot pool; the rendering source is unchanged. Actions validation is pending.

---

## 2026-11-14 — dirty-render mock expectation correction

Actions run #963 built the ELF successfully, passed the command-line smoke tests and renderer equivalence/microbenchmark checks, then exposed a stale test assumption in the Wayland mock: the held-Left repeat scenario required a single full-frame damage request even though the newly enabled caret-only path correctly emitted two damage bands. The focused test also needed to permit the first redraw to use the safe full-frame fallback while an initially unrendered SHM slot receives its first snapshot.

The mock now accepts two well-formed damage bands only for held plain Left navigation, while Backspace and text edits continue to require full-frame damage. The focused test permits one initial full repaint and requires the subsequent alternating caret moves to use the partial path. No renderer source changes are made in this correction. Actions validation is pending.

---

## 2026-11-14 — first dirty caret-band repaint pass

The Wayland software renderer now has a conservative partial-paint path for plain, unselected Left/Right/Up/Down caret movement. It clips rectangle fills, the embedded bitmap-glyph writer, and the TrueType glyph blitter to a band around the old/new caret rows plus a separate status-footer band. The corresponding two `wl_surface.damage` requests cover those same surface-coordinate regions. Other redraw classes retain full damage and full-surface pixel writes.

The optimization uses per-slot render snapshots for scene generation, document revision, viewport offsets, caret visual row, line pitch, document font size, wrap mode, UI density, backing raster scale, and buffer transform. A slot is eligible only if its snapshot matches the current editor state, the caret rows are visible and at most one row apart, and there is no selection, pointer drag, IME/Compose state, menu, modal overlay, resize, or non-normal transform. Snapshots are committed only after a successful Wayland commit; resize invalidates both. Pending caret candidates are cancelled by unrelated input/events before a deferred redraw, preventing an unrelated scene update from inheriting a partial repaint.

The Wayland mock adds a focused scenario that requires two clipped damage rectangles for repeated plain Left/Right navigation and a full-frame damage fallback after text insertion. Actions validation is pending. No performance percentage is claimed; the implementation currently reduces pixel writes and Wayland damage, not visible-row traversal. Manual GNOME/Mutter smoke testing and controlled end-to-end timing remain outstanding.

---

## 2026-11-14 — wrapped visual-row-to-byte checkpoints (CI PASS #961)

The indexed reverse mapper `doc_visual_to_offset_indexed` previously found the logical line with the Fenwick tree, then scanned that line from its first byte to find a requested visual row and pixel column. A very long wrapped logical line could therefore still incur a long scan during viewport painting, selection mapping, find highlighting, and pointer hit-testing after vertical scrolling.

Reused the existing 4,096-slot byte-to-visual checkpoint working set (24 bytes per entry; 96 KiB total) for the reverse direction:
- The mapper derives the maximum 4 KiB bucket from the logical line's byte span and uses the stable line ID and shared layout epoch to locate checkpoints.
- Since checkpoint row numbers are monotonic with increasing byte buckets, lookup binary-searches the lexicographic coordinate **(local visual row, pixel X)**. It resumes from the greatest checkpoint not after the requested coordinate.
- Comparing pixel X as well as row is important: a checkpoint can occur partway across a visual row. A later checkpoint on that same row must not be used when the caller requests an earlier X, or the mapper would skip text at the beginning of that row.
- If a bucket is missing or its direct-mapped slot contains a collision, lookup scans the fixed 4,096-entry working set and selects the closest earlier row/column checkpoint. This fallback is bounded and does not allocate another cache.
- Wrap Lines OFF continues to use the existing horizontal-pixel checkpoint path.

The 4 MiB single-line Wayland fixture now checks the reverse mapper after Ctrl+End scrolls the wrapped document to its final rows. Test instrumentation requires the scan to resume within the last 64 KiB of the fixture and to consume no more than 4 KiB. The same scenario still verifies byte-to-visual caret mapping within 4 KiB in wrapped and unwrapped modes, plus the separate no-wrap glyph traversal bound during horizontal scrolling.

The first run of this change, Actions #960, reached the existing Wayland mock's ordinary soft-wrap typing scenario but failed its frame/buffer settle gate. The final version passes the complete suite in [Actions #961](https://github.com/GraderGamer2/NekoEdit/actions/runs/43586060233), all 17 steps, including nested GNOME Shell/Mutter integration. Build/ELF, CLI smoke tests, glyph-cache comparison, executable inspection, `us(intl)` parser, X.Org importer, Compose pack generation, and both artifact uploads also passed.

Artifacts: Linux x86-64 [149,288 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43586060233/artifacts/14109863343); Compose packs [120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43586060233/artifacts/14110002983). Both expire 2026-11-15 10:39 UTC (17:39 WIB).

No controlled before/after timing benchmark was collected. The validated claim is bounded local byte traversal in the 4 MiB fixture, not a measured frame-rate multiplier. Full-frame software-surface repaint remains unchanged.

Next performance target: measure the full `render_surface` repaint path and introduce dirty-region rendering only with explicit invalidation for document pixels, caret/selection, status, menus, dialogs, and resized buffers.

---

## 2026-11-14 — sparse byte-to-visual checkpoints for long logical lines (CI PASS #959)

Caret-to-visual mapping previously rescanned a long logical line from its first byte after a large caret jump. This remained expensive even after document glyph painting had been bounded to the viewport and no-wrap horizontal mapping had acquired its own pixel checkpoints.

Added a separate sparse byte-position working set:
- 4,096 direct-mapped entries, 24 bytes each (96 KiB total).
- Each entry stores the shared layout/cache epoch, stable logical-line ID, 4 KiB byte bucket, line-relative byte offset, local visual-row number, and pixel X.
- The existing line-index metric pass populates checkpoints in both wrapped and unwrapped modes. A checkpoint is recorded at the line start and at the first grapheme boundary encountered after each 4 KiB bucket boundary.
- Caret mapping hashes the target line ID and bucket, checks the target bucket and up to 15 preceding buckets, and resumes from a valid checkpoint no later than the requested byte.
- Relative offsets mean insertions in earlier lines do not invalidate untouched lines merely because their absolute document positions shifted. Existing fresh IDs for edited/split/merged lines and the layout epoch for rebuild/reflow prevent stale positions from being reused.

The Wayland regression uses a 4 MiB one-line document. It moves to true document EOF with Ctrl+End in Wrap Lines ON, measures the actual local byte scan, then disables wrapping and repeats the check. Both modes must scan no more than 4 KiB. The existing horizontal-scroll regression also continues to require no-wrap glyph traversal to stay within 4 KiB. The initial #957 attempt used plain End, which correctly stops at the current visual row in wrapped mode; the regression was corrected to Ctrl+End. The final harness sends the modifier/key events directly because the later-defined shortcut helper is not yet in scope at that earlier test point.

Actions [#959](https://github.com/GraderGamer2/NekoEdit/actions/runs/43584742359) passed all 17 workflow steps, including the full Wayland protocol mock and nested GNOME Shell/Mutter integration. The freestanding build, CLI tests, glyph-cache comparison, executable inspection, `us(intl)` parser, X.Org importer, Compose pack build, and both artifact uploads also passed.

Artifacts: Linux x86-64 [148,935 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43584742359/artifacts/14110291102); Compose packs [120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43584742359/artifacts/14110286091). Artifacts expire 2026-11-15 10:24 UTC (17:24 WIB).

No before/after timing benchmark was collected. The validated claim is that the measured caret-to-visual scan is bounded to 4 KiB on the 4 MiB single-line fixture in both wrap modes. This does not establish an end-to-end latency or FPS improvement.

Next: add sparse visual-row-to-byte checkpoints for the reverse lookup used when a long wrapped line is scrolled vertically. Full-frame software-surface repainting is unchanged and should be measured separately.

---

## 2026-11-14 — sparse horizontal checkpoints and bounded no-wrap painting (CI PASS #956)

Wrap Lines OFF previously still made the editor walk a long logical line from its first byte to locate the horizontal viewport, and the glyph loop could continue consuming the hidden suffix after reaching the right edge.

Added a stable per-line identity array parallel to the existing line-index records and a fixed 1,024-slot horizontal checkpoint cache. A line's checkpoints are keyed by its stable ID rather than its absolute document byte start, so unrelated lines retain their cache identity when earlier text shifts offsets. Ordinary edits and newline split/merge operations assign fresh IDs to affected lines; rebuild/reflow advances the cache epoch. The cache is populated while unwrapped line metrics are measured.

The indexed visual-to-byte mapper now uses a nearby horizontal checkpoint. The main glyph painter starts at the mapped horizontal viewport and, when it reaches the right edge, jumps to the next logical line at the same horizontal offset rather than traversing the unseen suffix.

Regression coverage:
- A 4 MiB one-line document is opened with wrapping, switched to Wrap Lines OFF, moved to End, and scrolled horizontally in both directions. Each checked glyph-paint pass remains within a 4 KiB byte span.
- Existing line-index mutation coverage now asserts stable IDs are nonzero and unique after ordinary insertion/deletion, Enter split, and Backspace merge.
- The 11 MiB / 89,414-line Open/Save scenario and its 1,935-byte visible glyph/selection paint assertions continue to pass.

The first build attempt (#955) correctly rejected nonzero initializers in `.bss`; the IDs/epoch were changed to zero-initialized storage with runtime initialization. Actions [#956](https://github.com/GraderGamer2/NekoEdit/actions/runs/43580042865) then passed all 17 workflow steps, including the full Wayland mock and nested GNOME Shell/Mutter integration.

Artifacts: Linux x86-64 [148,575 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43580042865/artifacts/14107887437); Compose packs [120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43580042865/artifacts/14108071561).

No before/after redraw benchmark was collected. Caret-to-pixel conversion on very long lines and sparse mapping within a single very long wrapped logical line remain next optimization targets; the full-frame software surface is still repainted.

---

## 2026-11-14 — viewport-bounded document painting (CI PASS #954)

The document glyph renderer already maps `doc_view_top_row` through the Fenwick index and stops when it reaches the bottom of the visible document region. Added test-only byte-range counters to make that property observable after a large scroll.

Changed the expensive auxiliary paint passes:
- Wrapped selection rendering maps the visible top row and the row immediately below the viewport to byte offsets, then scans only the visible selection span.
- Find highlighting uses a new non-wrapping bounded byte-search helper and searches only the viewport's visible span, with enough look-behind to paint a match that begins just above the viewport. In no-wrap mode, candidate ranges are limited to each visible row's horizontal interval.

The 11 MiB / 89,414-line Wayland scenario selects the full document and drags the scrollbar to the middle. It measured a 1,935-byte glyph-paint span and a 1,935-byte selection-paint span. It then enters Find and fast-scrolls 4,096 rows, asserting that the Find search range stays within 16,384 bytes. Actions [#954](https://github.com/GraderGamer2/NekoEdit/actions/runs/43578215465) passed all 17 workflow steps, including Wayland, native XKB, importer checks, Compose generation, and GNOME Shell/Mutter integration.

Open-to-first-redraw samples were 119.2, 118.2, and 117.3 ms. There is no matched before/after baseline, so these are recorded only as context.

The remaining horizontal edge case is a very long logical line with Wrap Lines disabled. Mapping a horizontal pixel coordinate to a byte still scans from that logical line's start, and the glyph pass can visit a hidden suffix. A sparse per-line horizontal advance/checkpoint index is the next safe optimization; its invalidation/update rules must cover editing and font metric changes.

Implementation: [213ad8c](https://github.com/GraderGamer2/NekoEdit/commit/213ad8cc5364b46ba132779269c49445e7c7105c); regression instrumentation: [ab34e2f](https://github.com/GraderGamer2/NekoEdit/commit/ab34e2fe9f4326f0e84ccd72b5d333915c191263).

---

## 2026-11-14 — printable-ASCII reverse grapheme fast path (CI PASS #952)

Added a guarded fast path to `doc_grapheme_prev`. Once the previous scalar start is known, the function can return it directly when both it and the immediately preceding byte are printable ASCII. This pair is guaranteed to be separated by a grapheme boundary, so the Unicode property/boundary scan is unnecessary. Controls (including CR/LF) and all non-ASCII cases keep the existing general path.

The existing Wayland grapheme fixture already walks the extended ASCII sentence backward. It exercises repeated fast-path returns, then reaches the ASCII/CRLF edge and verifies that Backspace still removes CRLF atomically; the combining-mark, emoji/ZWJ, regional-indicator, Hangul, Indic, Prepend, SpacingMark and pointer-hit-test cases remain in the full fixture.

Actions [#952](https://github.com/GraderGamer2/NekoEdit/actions/runs/43576391933) passed all 17 workflow steps, including the complete Wayland mock and nested GNOME Shell/Mutter integration. The 11 MiB open-to-first-redraw samples were 166.8, 167.2 and 167.3 ms. That open timing does not exercise the new backward shortcut, and a controlled Left/Backspace performance comparison has not yet been run.

Commit: [43190c1](https://github.com/GraderGamer2/NekoEdit/commit/43190c1e1c0e6893e6cc2ab453c3bf1bcf881c92).

---

## 2026-11-14 — printable-ASCII grapheme fast path (CI PASS #951)

Added a small fast path in `doc_grapheme_next`: a printable ASCII byte followed by another ASCII byte, or by EOF, advances directly by one byte. It avoids UTF-8 scalar decoding and Unicode grapheme-property scans for the common ASCII run used by rendering, layout/index traversal, and editing. A high-bit successor deliberately selects the original Unicode path so ASCII bases followed by combining marks, ZWJ, or spacing marks retain their UAX #29 cluster behavior. C0 controls, DEL, CR/LF and non-ASCII current bytes are unchanged.

The Wayland grapheme fixture now appends a sentence containing spaces, letters, punctuation, and digits. Right/Left navigation traverses every appended byte and then returns to the CRLF boundary for the existing atomic Backspace check. Combining sequences and the existing Unicode 18.0 grapheme coverage remain in the same scenario.

Actions [#951](https://github.com/GraderGamer2/NekoEdit/actions/runs/43575768768) passed all 17 workflow steps, including the full Wayland mock, 11 MiB Open/Save, XKB and importer checks, Compose pack generation, nested GNOME Shell/Mutter integration, and artifact uploads. The 11 MiB open-to-first-redraw mock samples were 124.9, 125.8, and 126.7 ms; no pre-patch baseline exists, so this records workload context rather than a measured optimization delta.

Commits: [6e1c30a](https://github.com/GraderGamer2/NekoEdit/commit/6e1c30a693957bce667368d20dd72d1b51c504b4), [a888422](https://github.com/GraderGamer2/NekoEdit/commit/a8884220ed9d7fd0943b83868319a11f06019efc), [0318e43](https://github.com/GraderGamer2/NekoEdit/commit/0318e4324025755fa29bf5fcee62da1d61a9ce00).

---

## 2026-11-14 — exact fractional Wayland backing raster

Implemented exact preferred fractional rasterization on early-alpha without changing the development optimization default.

The fractional-scale/viewport path now:
- Treats the compositor's preferred scale as a numerator over 120 and uses that exact numerator for the source raster instead of binning requests into 1×/2× buffers.
- Keeps Wayland's integer protocol buffer scale at 1 while the viewport destination and surface damage remain in logical surface coordinates.
- Rounds physical source dimensions to nearest pixel with exact halves away from zero and caps them by 2× and by the preallocated two-slot SHM geometry, including swapped axes for odd transforms.
- Shares physical mapping across filled rectangles, TrueType glyphs, and the 5×7 fallback; the UI-density transform stays separate from the raster numerator.
- Includes the exact numerator in buffer-generation identity. The existing two-slot release protocol gates replacement until both old-generation buffers are released.

Expanded tests/wayland_mock.py with preferred scales 90, 120, 150, 180 and 210; a rotated 481-pixel height checks 721.5 → 722 rounding. The mocks check surface logical dimensions, viewport/damage, protocol buffer scale, buffer dimensions/stride, pixel output, and the no-seat startup path.

Actions [#945](https://github.com/GraderGamer2/NekoEdit/actions/runs/43569752292) passed all 17 steps, including ELF/CLI checks, renderer cache comparison, the complete Wayland mock suite with 11 MiB Open/Save, XKB and locale checks, and nested GNOME Shell/Mutter integration. #944 caught and led to correcting the non-zero .bss initializer; #945 also uses a logical glyph-cell ink test to account for the new physical pixel grid.

Follow-up commits:
- 3bbdd887 — implementation and mock coverage.
- 82757c0 — .bss zero-initialization correction.
- f5368cd — fractional glyph sampling test correction.
- 9e3987e — backend/rendering documentation refresh.

Remaining verification is real desktop visual/input testing, mixed-DPI output movement, scale changes while both slots are compositor-owned, and profiling. This entry records CI results only; no local desktop run is claimed.

---


## 2026-11-14 — latch buffer-generation requests across configure

Fixed the Wayland configure handler so an unchanged logical-size configure cannot clear a scale/transform generation already queued behind compositor-owned buffers. The pending flag remains latched until the newest desired generation is installed safely.

Added a separate Wayland mock case for two simultaneously busy fractional slots. It sends multiple 120ths preferred-scale values, changes to a 90-degree transform, delivers an unchanged configure followed by a resize, releases the second slot before the first, then verifies the coalesced final geometry and rendered pixel mapping.

The test validates the two independent gates: wl_buffer.release controls backing-memory reuse, while wl_callback.done controls surface commit pacing. CI validation is pending; physical mixed-DPI GNOME/Mutter testing remains a separate step.

Actions [#947](https://github.com/GraderGamer2/NekoEdit/actions/runs/43572916550) passed all workflow steps on test-harness fix [7d33087](https://github.com/GraderGamer2/NekoEdit/commit/7d330870971be5d5fa16dfcedb4e80658c4ddb34), validating implementation commit [f7191c4](https://github.com/GraderGamer2/NekoEdit/commit/f7191c45277ed9bf29cd741951c91744177d18a6). The Wayland mock suite passed with the new two-slot regression: both fractional slots stayed independently compositor-owned through rapid preferred-scale changes, a transform update, an unchanged configure, and a resize. Slot one was released before slot zero; the old generation was retained until the final release, then replaced with the coalesced 180/120 raster, 90-degree transform, and 640×360 logical destination. The workflow also passed executable inspection, native XKB tests, pinned Compose import checks, locale-pack generation, and nested GNOME Shell/Mutter integration. The earlier #946 failure was confined to the new test helper's Python variable scope; it did not reach the Wayland tests.

## 2026-11-14 — destroy removed Wayland extension managers

When a bound wp_fractional_scale_manager_v1 or wp_viewporter global disappears, NekoEdit now sends the corresponding manager destructor request and clears that bound proxy ID. Existing wp_fractional_scale_v1 and wp_viewport instances are deliberately retained: protocol-defined manager destruction does not invalidate children that were already created.

The new mock removes both globals after mapping, checks their destructor requests, then sends another per-surface preferred_scale event and a toplevel resize. It verifies the retained child proxies still drive a 180/120 physical backing buffer and update the 640×360 logical viewport destination. This scenario uses virtual protocol outputs and needs no second monitor. Actions [#948](https://github.com/GraderGamer2/NekoEdit/actions/runs/43574607904) passed all 17 workflow steps on implementation commit [9d69077](https://github.com/GraderGamer2/NekoEdit/commit/9d6907749ff2a51ea3d2d82fb1c14a61ada913b7). The new Wayland mock explicitly verified destruction of both removed manager proxies, retention of the per-surface objects, another preferred-scale event after removal, and a resized 640×360 viewport backed by a 960×540 1.5× buffer. The full test suite, nested GNOME Shell/Mutter integration, and artifact uploads also passed.

## 2026-11-15 — batch Find/Replace insertion ranges

Audited the bulk-edit paths after the gap-aware index rebuild. Clipboard paste already used `doc_insert_bytes` and deferred line-index rebuilding, but Find/Replace still removed each selected match and reinserted its replacement through a byte-at-a-time loop. In Replace All, that path could rebuild the whole line index on the first replacement byte and point-update it for the remaining bytes, then repeat after each subsequent match.

Changed `doc_replace_selection_with_buffer` to call `doc_insert_bytes` once with the contiguous `find_replacement_buffer`. The range primitive journals the replacement as one insertion operation, copies its bytes in bulk, updates the cursor/document revision, and invalidates the derived line index lazily. The Replace All search loop uses direct document-byte comparisons rather than `doc_line_index_ensure`, so it can process all matches before the next rendering pass rebuilds the index.

Expanded the Wayland mock fixture to `one fish two fish\\n` followed by 64 `row fish\\n` lines. Replace Current changes the first selected match; Replace All must then replace the remaining 65 matches. The regression checks exact final bytes, the 66 logical line spans, one visual row per short line, unique nonzero line IDs, and the byte/row Fenwick nodes. The existing Find query, highlighting, navigation, Replace Current, Replace All and Escape interactions remain in the scenario.

Actions [#985](https://github.com/GraderGamer2/NekoEdit/actions/runs/43639295631) passed all 17 workflow steps. This includes build and ELF checks, CLI/host tests, renderer equivalence, full Wayland protocol mock with 11 MiB Open/Save, native `us(intl)` XKB, X.Org importer, Compose pack generation, and nested GNOME Shell/Mutter/IBus integration. Both artifacts uploaded successfully.

The executable reports text 237,670 bytes, data 64 bytes and BSS 3,764,856 bytes. The executable artifact is 151,138 bytes and the Compose artifact is 120,536 bytes. The executable artifact is 12 bytes smaller than #984; this small section/artifact-size difference is not a measured speed improvement. No before/after end-to-end timing or manual live-desktop test is claimed.

Implementation commit: [ad18f92](https://github.com/GraderGamer2/NekoEdit/commit/ad18f921af7038afb086d73a1822407f1d2b471c).
