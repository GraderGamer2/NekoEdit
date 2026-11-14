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
