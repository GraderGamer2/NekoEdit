## 2026-11-16 — assembly ASCII advance cache and scanline glyph rasterizer (Actions #1065 PASS)

The assembly document renderer and line-index measurement routines previously called the C advance wrapper for every character. The new src/font/advance.S helper first checks the active document-font size and reads the existing font_ascii_advance_cache[33][128] for warmed ASCII entries. Zero-valued entries remain misses; those and all non-ASCII code points fall through to font_codepoint_advance_pixels_size. The C rasterizer retains ownership of cache population and font_cache_clear; the helper does not introduce another cache or invalidation path. No-font mode still returns the established 8px advance, and invalid document sizes still normalize to 12px. Unit tests cover cold/warm entries, size changes, unknown ASCII fallback, Unicode, font disablement and invalidation.

The advance benchmark alternates assembly and C-reference lookup samples, seven times at five million lookups per sample. On the CI host, the direct assembly hit measured 2.19 ns/character versus 2.81 ns through the old C-wrapper behavior: a 22.1% reduction in isolated lookup call cost. Workload checksums matched. This is not a whole-editor rendering percentage.

The TrueType rasterizer now uses integer scanline winding events in production. It precomputes ordered horizontal subpixel coordinates, visits each active contour edge once per horizontal subpixel scanline, binary-searches the first sample at which that edge stops contributing to the non-zero winding count, and accumulates signed events while scanning left-to-right. The event comparison uses the same 64-bit cross-product relation and strict crossing condition as the original inside() routine. All four vertical and four horizontal samples accumulate into one pixel coverage value before writing the 0–255 mask. This preserves 4×4 antialiasing and the non-zero winding fill rule.

The original point-in-contour rasterizer is retained under the test-only FONT_RASTERIZER_REFERENCE define. It is not included in the production path. tests/rasterizer_scanline_equivalence.c compares complete active masks for six deterministic fixtures: an asymmetric polygon, a reversed-winding hole, quadratic curves, same-orientation overlapping contours, negative bearings with a deep descender, and an empty outline. Tests run at 8, 12, 16, 24, 32 and 64px. The resulting bit-for-bit checksum is e195ffbbe30aeef8.

On the CI runner, the paired synthetic eight-point outline benchmark measured 23,625.3 ns/glyph for the point-in-contour + legacy full-mask-storage configuration and 2,616.9 ns/glyph for the active-edge scanline + compact active-mask-storage configuration (88.9% lower). Cold 128-glyph cache fill/draw measured 24,712.3 versus 3,072.9 ns/iteration (87.6% lower). Because the paired configurations also differ in mask-storage strategy, these figures describe the combined configuration and should not be attributed solely to the scanline algorithm. All six variants agreed on cache-fill checksum 35083399697745 and warm framebuffer checksum 35084948275808.

The benchmark comparison now emits test-only exact pixel differences when a checksum gate fails. During development this exposed a coverage-loop integration error: the initial scanline draft reset coverage per vertical subrow. The reference branch was restored to its original loop, while the scanline path now retains one per-column accumulator across all four vertical subrows. The corrected independent exact-mask test and the full renderer checksum comparison both pass.

The final assembly helper includes .note.GNU-stack so its standalone test links do not produce an implicit executable-stack warning. Actions [#1064](https://github.com/GraderGamer2/NekoEdit/actions/runs/43835277268) passed the corrected scanline implementation, and Actions [#1065](https://github.com/GraderGamer2/NekoEdit/actions/runs/43836015143) passed all 18 workflow steps on final source head [a5c32a4](https://github.com/GraderGamer2/NekoEdit/commit/a5c32a4bfa3ac270208bc555338d12521ef5da77).

---

## 2026-11-16 — status-bar information grouping (Actions #43816130665 PASS)

The status bar now separates its three information groups—caret line/column, byte count, and text mode—with two muted 1px vertical rules. Their X positions are derived from the existing responsive byte-count and mode anchors, each 12px before its corresponding group. Each rule is 12px high and sits four pixels inside the status bar's top and bottom edges. Existing text placement, logical-column calculation, document rendering and runtime dependencies are unchanged.

The Wayland framebuffer mock checks the full 12px height and exact `#596273` color at x=468 and x=732 on the 800×480 startup surface. Source implementation and regression coverage are in [151f807](https://github.com/GraderGamer2/NekoEdit/commit/151f80786ab7b9d60d83fd1cfb2964c0cfe4eaf5). Actions [#43816130665](https://github.com/GraderGamer2/NekoEdit/actions/runs/43816130665) passed all 18 workflow steps, including the Wayland mock, 11 MiB Open/Save, native XKB, pinned X.Org data comparison, locale-pack generation and nested GNOME Shell/Mutter/IBus integration. No live GNOME screenshot/manual review is claimed.

---

## 2026-11-16 — O2 LTO, freestanding link and release stripping (Actions #43797788228 PASS)

The CI comparison measured compiler optimization profiles with GCC 13.3.0 on an Intel Xeon 6975P host. Each eligible benchmark used seven samples of a deterministic glyph-raster workload with 50,000 warm draws per sample. All executed variants retained identical cache-fill and warm-framebuffer checksums.

| Profile | Stripped ELF | Warm draw | vs. -O2 |
|---|---:|---:|---:|
| `-Os` | 235,000 B | 139.8 ns | 3.7% slower |
| `-O2` | 247,784 B | 134.8 ns | baseline |
| `-O3` | 272,152 B | 159.8 ns | 18.5% slower |
| `-O2 -mtune=znver3` | 251,880 B | 136.4 ns | 1.2% slower |
| `-O2 -flto` | 247,960 B | **106.9 ns** | **20.7% faster** |
| `-O3 -flto` | 272,360 B | 117.6 ns | 12.8% faster |

The winning general-purpose candidate was `-O2 -flto`: warm glyph draw fell from 134.8 ns at plain `-O2` to 106.9 ns (20.7% lower), with cold rasterization and cache population also improving by about 3%. The stripped app ELF grew by only 176 bytes, from 247,784 to 247,960 bytes. `-O3` was both larger and slower than `-O2` in this benchmark; `-Os` reduced the stripped file by about 12.8 KB but ran 3.7% slower. `-O3 -flto` improved on plain `-O2` but remained slower than `-O2 -flto` and was about 9.9% larger.

The production C objects now default to `-O2 -flto`. Since LTO requires the compiler plugin at final link, the production executable links through GCC with `-nostdlib -static`, the explicit `_start` entry, `--gc-sections`, and the no-executable-stack setting. This keeps the raw-syscall/freestanding runtime: the production ELF has no PT_INTERP or dynamic dependencies. The handwritten assembly is not recompiled by GCC and is unaffected by the C optimization level.

The test build is deliberately different. `TEST_CFLAGS` filters out `-flto`, and the instrumented test application continues to link directly through `ld`. This preserves the globals used by the Wayland process-memory harness and keeps test-only instrumentation out of the release executable.

Release cleanup is now automatic. The normal ELF is audited before stripping for the absence of a PT_INTERP segment, dynamic `NEEDED` entries, and known test-only instrumentation symbols. `strip --strip-all` then removes the symbol/debug metadata; the post-strip step verifies `.symtab` is absent. Linker `--gc-sections` and compiler `-ffunction-sections -fdata-sections` continue to discard unreferenced code/data. Stripping does not itself increase execution speed and does not delete live editor functions.

Architecture-specific profiles (`-march=x86-64-v3`, `-march=znver3`, and `-O2 -flto -march=znver3`) were built and size-measured, but runtime testing was skipped because the hosted runner is Intel and did not advertise the required feature set. No CPU-specific ISA flag was promoted to the default. The `-mtune=znver3` profile was benchmarked on Intel and did not beat generic `-O2`.

Actions [#43797788228](https://github.com/GraderGamer2/NekoEdit/actions/runs/43797788228) passed all 18 steps, including the compiler sweep, LTO release build and symbol audit, CLI tests, renderer equivalence, full Wayland/11 MiB Open-Save suite, XKB, pinned X.Org importer, locale-pack build, nested GNOME Shell/Mutter/IBus, and both artifact uploads.

Final production ELF text/data/BSS: **242,172 / 64 / 3,797,208 bytes**. Artifacts: Linux executable ZIP **124,744 bytes**, SHA-256 `6bd7c1e94220abf1420d40648a2e5eeee11270ddc30db05f890ca08365b2c19a`; Compose locale ZIP **148,799 bytes**, SHA-256 `b5030e8afe505ecf277b4943a006f8f8183b5790e42b557f9cfb55de3c7ff698`.

The measured 20.7% lower warm draw time applies to the synthetic C rasterizer benchmark only. It is not an end-to-end editor-scroll result. No manual desktop before/after test was run.


---

## 2026-11-15 — Czech Compose pack and bounded status-column lookup (Actions #1006 PASS)

The optional locale set now includes cs_CZ.UTF-8. Its source is pinned to X.Org libX11 commit ff8706a5eae25b8bafce300527079f68a201d27f, blob 022753ea937e9a1f483c9545e99ddbc6295cd485. The Czech file includes the en_US baseline and overrides two dead-caron rules: u -> ů and U -> Ů. The importer produces a flattened 4,479-record JSON table and a 304,644-byte NLP1 v2 pack. The generated JSON is compared byte-for-byte against the committed table in CI; the pinned source hash is checked in both the normal build and Release-pack workflows. The .nlp and its attribution notice remain separate assets; no locale data was added to the core executable.

The editor performance change extends the existing stable-line-ID 4 KiB sparse byte/visual checkpoints with a one-based logical column. The wrapped and unwrapped index measurement passes now record the current logical column alongside byte offset, local visual row, and pixel X. The status bar obtains the current logical line through the byte Fenwick tree, starts at the closest usable checkpoint, and scans only the remaining local segment. The column counter retains current behavior for Unicode extended grapheme clusters, four-column tab stops, and control bytes. The record stride increases from 24 to 32 bytes across 4,096 slots, adding 32 KiB to BSS. The fallback scan remains when the index or checkpoint is unavailable.

The Wayland mock adds a wrapped mixed-text fixture with tabs, a combining-mark grapheme, a control byte, and a Ctrl+End to the document end; it also adds a scan-bound assertion to the 4 MiB wrapped/unwrapped long-line case. The first run exposed a fixture error: plain End stops at the current visual row in wrap mode. The test now uses Ctrl+End, and the complete mock passes.

Source commits: [0fe2690](https://github.com/GraderGamer2/NekoEdit/commit/0fe2690763aafcba73107a24ec8d8194fa28d350), [066bd21](https://github.com/GraderGamer2/NekoEdit/commit/066bd21848d914080a4029d8483463ce91f10dd9), and [f4bbcc2](https://github.com/GraderGamer2/NekoEdit/commit/f4bbcc22e856d34b1055d4e0e3540160a1895c19).

Actions [#1006](https://github.com/GraderGamer2/NekoEdit/actions/runs/43692781059) passed all 17 steps, including build/ELF, CLI/host, renderer equivalence, Wayland mock/11 MiB Open and Save, native XKB, pinned X.Org regeneration, locale pack build, GNOME Shell/Mutter/IBus integration and both artifacts.

ELF text/data/BSS: 242,918 / 64 / 3,797,656 bytes. Linux executable ZIP: 154,091 bytes. Locale ZIP: 148,799 bytes. The pack artifact includes the five .nlp files and their notices. No controlled before/after latency benchmark or manual live-desktop test was performed.

---

## 2026-11-15 — in-app keyboard shortcut reference and modal IME handling (Actions #1003 PASS)

NekoEdit now has an in-app keyboard reference, opened with F1 or the Help item in the title bar. The responsive centered panel groups the supported commands into File and Editing, Navigation, and Find and Replace. Its list includes file operations, undo/redo, clipboard actions, character/word deletion, caret and selection movement, and the combined Ctrl+F Find/Replace workflow. It deliberately documents the editor's actual command set rather than suggesting unimplemented features.

The panel is modal: Escape, its X control, or an outside click dismisses it; an outside click is not forwarded to the editor. Keyboard input, document pointer motion, wheel scrolling and context-menu actions are blocked while it is open. F1 is available over the History view as well. Opening Help also stops the active keyboard-driven focus path from editing the document.

The optional text-input-v3 path follows the modal state. Opening Help sends text-input disable and commit requests, clears any transient preedit, and prevents the document from remaining an IME target. Closing Help restores text input, sets the normal content type, and republishes the editor-originated surrounding-text and cursor state. The test expects change cause 1 for Escape because it is a keyboard/editor action, matching the existing `.keyboard_changed` path; IME-originated updates continue to use cause 0.

The Wayland mock covers both entry points, responsive panel rendering, modal typing protection, the close control, Escape, outside-click dismissal without click-through/caret movement, and the text-input-v3 disable/restore sequence. The root README's stale statement that Ctrl+H opened a separate Find/Replace mode was replaced with the single Ctrl+F entry point and Help instructions.

Actions [#1001](https://github.com/GraderGamer2/NekoEdit/actions/runs/43688519422) passed the first Help UI implementation and its interaction tests. The follow-up IME test initially failed in #1002 due to the cause-value expectation described above. Actions [#1003](https://github.com/GraderGamer2/NekoEdit/actions/runs/43689046632) passed all 17 steps, including build/ELF, CLI/host, renderer equivalence, the full Wayland mock and 11 MiB Open/Save, native XKB, X.Org importer, Compose, nested GNOME Shell/Mutter/IBus integration, and both artifact uploads.

Final ELF text/data/BSS: **242,742 / 64 / 3,764,888 bytes**, with no dynamic section. The executable ZIP is **154,019 bytes** (SHA-256 `600b9fc617913c5641a70d59cf1a48861b4adf981cc70d0988cf991d6810cc5e`); the Compose ZIP is **120,536 bytes** (SHA-256 `9f316248901d74cd70701ba918d8231ba91827d9973fcbd33de15ed81a5ae783`). Artifacts expire 2026-11-16 14:17 WIB. No manual live-desktop retest is claimed.

---

## 2026-11-15 — unified Ctrl+F Find/Replace and gap-aware Replace Current (Actions #1000 PASS)

## 2026-11-15 — user-confirmed modular locale contract (design constraint; documentation only)

NekoEdit's built-in locale remains **en_US.UTF-8**. The application UI stays English, and the default keyboard/Compose behavior stays based on the embedded US English tables. Do not bundle additional locales into the core executable or expand the built-in baseline into a multilingual locale database.

Other locales are optional, separately distributed, data-only packs. Users obtain the pack they need and install it themselves through NekoEdit's local pack flow; installed packs live under `~/.nekoedit/locales/`. A selected pack replaces the corresponding Compose/dead-key table rather than merging into the built-in baseline. Packs are not executable plugins, do not add shared-library dependencies, and must not cause an automatic network download. These packs extend keyboard composition data; they are not UI translations or a reason to expand the editor's built-in locale.

Unicode document editing, clipboard input, and future Unicode-capable Find/Replace fields are separate capabilities. Supporting UTF-8 or IME-committed text must not silently change the application's locale, add extra built-in locale tables, or bundle optional locale data.

**Selection behavior to reconcile:** the current [Compose documentation](../docs/COMPOSE.md) describes environment-variable fallback through `NEKOEDIT_LOCALE`, `LC_ALL`, `LC_CTYPE`, and `LANG` when no saved preference exists. The user-confirmed target is explicit user choice: keep en_US active by default and activate another locale only when the user has installed and selected that pack. Review the environment fallback against this contract before further locale work; this documentation note does not change runtime behavior.

---

The Find and Replace functions previously had two entry points: Ctrl+F opened a compact search-only mode, while Ctrl+H opened a separate replacement mode. The editor now uses one combined panel opened by Ctrl+F. The independent Ctrl+H dispatch was removed so the same workflow handles both operations. The query is entered in the first field; Tab or a pointer click focuses the replacement field. Enter/F3/Shift+F3 move through matches, Ctrl+Enter performs Replace Current, and Replace All remains available in the panel.

The remaining Replace Current selection check also had a small but avoidable hot path: it called `doc_byte_at` once for every compared query byte. `doc_find_selection_matches` now translates the logical selection start to a physical pointer once, compares the query over the gap buffer's contiguous prefix and suffix, and switches directly to the suffix when the logical position reaches the gap. It rejects an empty query and checks the selection end against the current document length before reading. Search and selection matching remain byte-exact; this does not alter Unicode grapheme navigation.

The main Wayland Find/Replace fixture deliberately leaves the storage gap between the `f` and `i` in the first `fish` match. After navigating forward and backward, it returns to that split-gap selection, uses the combined Ctrl+F panel's replacement field, and checks that Replace Current changes only the first occurrence. Replace All then replaces the other 65 matches. The test checks final bytes and the derived line-index structures. The large-document Find fixture also asserts that Ctrl+F opens the combined panel.

The first full run, Actions #999, compiled the source and passed CLI/host and renderer-equivalence tests. The Wayland test then exposed one outdated assertion still expecting Find-only mode 1 in the 11 MiB scenario; the scan bounds were within their expected range. Test-only correction [328a72f](https://github.com/GraderGamer2/NekoEdit/commit/328a72fd1ccbf3de51d965252ac2289901e8a4cf) updated that assertion and its diagnostics. Actions [#1000](https://github.com/GraderGamer2/NekoEdit/actions/runs/43686472120) passed all 17 workflow steps, including the complete Wayland mock, large-file coverage, native XKB, X.Org importer, Compose generation, nested GNOME Shell/Mutter/IBus integration and both artifact uploads.

ELF text/data/BSS: 239,766 / 64 / 3,764,856 bytes. Linux executable ZIP: 152,267 bytes; Compose locale ZIP: 120,536 bytes. Artifact digests and expiry are recorded in CURRENT_STATUS and the handoff. No controlled before/after benchmark or manual live-desktop test was performed.
## 2026-11-15 — gap-aware reverse Find traversal (Actions #998 PASS)

**Branch/source head:** `early-alpha` at [f346260](https://github.com/GraderGamer2/NekoEdit/commit/f3462606b1d94e3b7f1858712ccea135ec00cbbf). **Previous forward-search commit:** [7822938](https://github.com/GraderGamer2/NekoEdit/commit/78229385b90f89a836d3476e7c209c446eb0644a). **Workflow:** [Actions #998](https://github.com/GraderGamer2/NekoEdit/actions/runs/43684728142) passed all 17 steps.

### Source changes

- `doc_find_match_reverse_bounded` now scans candidate offsets in descending order with a physical gap-buffer cursor. Query comparisons advance through the prefix and rebase directly to the suffix when the candidate crosses the gap; moving the candidate itself backwards across the gap jumps back to the prefix.
- The backward branch of `doc_find_match` uses that bounded matcher for both its initial descending range and its wrapped range. It no longer calls `doc_byte_at` once per query byte.
- Forward Find/Next and Replace All use the existing `doc_find_match_bounded` physical-pointer matcher, introduced in [7822938](https://github.com/GraderGamer2/NekoEdit/commit/78229385b90f89a836d3476e7c209c446eb0644a). The forward start bound retains the one-past-last-valid candidate so a search from EOF wraps to the beginning rather than clamping to and repeating the last candidate.
- Matching remains byte-exact. Search order and existing wrap boundaries are retained; Unicode grapheme navigation and document storage are unchanged.

### Regression coverage

The Wayland mock places the gap between the `f` and `i` of the first `fish` result. After F3 selects the second result, Shift+F3 must select the first match across the physical gap; a subsequent F3 must return to the second. The forward-only proportional-font fixture also checks that F3 wraps from the final result to the first.

### Validation

Actions [#998](https://github.com/GraderGamer2/NekoEdit/actions/runs/43684728142) passed all 17 steps: freestanding build and ELF verification; CLI/host tests; renderer-equivalence benchmark; complete Wayland protocol mock including the new reverse split-gap case, clipboard and 11 MiB Open/Save coverage; executable inspection; native `us(intl)` XKB parsing; pinned X.Org Compose importer checks; locale-pack generation; nested GNOME Shell/Mutter/IBus integration; and both artifact uploads.

ELF `size`: text **239,670**, data **64**, BSS **3,764,856** bytes. Linux x86-64 artifact ZIP: **152,225 bytes** (SHA-256 `bd2b64fb4769ffe80db2c617148e8cf02b10d59fb32b0534c9b1b978547728d3`). Compose locale ZIP: **120,536 bytes** (SHA-256 `5bd61626ac54af4b6b78c2da4ed3819513d11e1973e88e87d2e295aa556f7493`). Both artifacts expire **2026-11-16 13:20 WIB**.

A native randomized harness also compared the gap-aware forward and reverse matchers against a logical-byte reference over 50,000 generated gap layouts and search positions. No controlled before/after application benchmark was collected, so no end-to-end speedup is claimed. The GNOME Shell/Mutter/IBus result is automated integration coverage, not a manual retest on the user's live desktop.

---

## 2026-11-15 — gap-aware forward Find traversal (Actions #997 PASS)

**Source commit:** [7822938](https://github.com/GraderGamer2/NekoEdit/commit/78229385b90f89a836d3476e7c209c446eb0644a). **Workflow:** [Actions #997](https://github.com/GraderGamer2/NekoEdit/actions/runs/43684358436) passed all 17 steps.

Forward Find and Replace All now route candidate matching through `doc_find_match_bounded`, which walks the gap buffer with physical pointers and rebases across the gap instead of translating every compared byte through `doc_byte_at`. The forward wrap bound also preserves an offset immediately after the final valid candidate, fixing the EOF case where F3 could clamp back to the last match. A Wayland regression verifies that F3 from the final result wraps to the first.

Actions #997 passed the freestanding build, CLI/host tests, renderer comparison, complete Wayland protocol mock (including 11 MiB Open/Save), native XKB, X.Org importer, Compose locale generation, nested GNOME Shell/Mutter/IBus integration, and both artifact uploads. The reverse-search path was handled separately in [f346260](https://github.com/GraderGamer2/NekoEdit/commit/f3462606b1d94e3b7f1858712ccea135ec00cbbf) and validated by Actions #998 above.

No controlled before/after benchmark was collected; this is a reduction in repeated gap-buffer address translation, not a measured end-to-end speed claim.

---

## 2026-11-15 — incremental Find-highlight coordinate traversal (Actions #996 PASS)

[f64c7fc](https://github.com/GraderGamer2/NekoEdit/commit/f64c7fc2a6c4767f76bdc1494873ffe853fe9d33) replaces repeated per-byte visual-coordinate mapping for printable-ASCII Find highlights with sequential coordinate advancement. The painter maps the first byte in each match once, then carries its visual row and horizontal pixel position across the remaining matched characters. Glyph widths still come from `font_codepoint_advance_pixels`, so proportional fonts keep their actual advances. Wrapped mode applies the same next-glyph overflow predicate as the indexed mapper; unwrapped mode advances only the horizontal coordinate.

The fast path is limited to printable ASCII queries. Controls/non-ASCII retain the old mapping loop, and a match preceded by a non-ASCII document byte also falls back so the general grapheme mapper remains responsible for possible Unicode Prepend joins. Find matching and search bounds are unchanged.

The new synthetic-font Wayland regression uses A=8 px, B=5 px, space=3 px and the document `AB AB`. A 10 px wrap width forces four visual rows; the first match is split by the gap. Pixel checks assert the exact amber rectangles for A and B across both wrapped rows. The fixture then restores the original viewport width and checks proportional horizontal coordinates with Wrap Lines OFF.

Actions #995 exposed a fixture setup mistake: after moving the physical gap to byte 1, the logical caret was still at byte 1, so Find correctly started at and selected the second result. The follow-up test-only commit [55998c6](https://github.com/GraderGamer2/NekoEdit/commit/55998c623f1c34569409f74535b759142b2788c0) sends Ctrl+Home and explicitly verifies cursor=0 while gap_start remains 1. Actions [#996](https://github.com/GraderGamer2/NekoEdit/actions/runs/43674688859) passed all 17 steps, including the complete Wayland mock, 11 MiB Open/Save, renderer equivalence, native XKB, X.Org importer, Compose, nested GNOME Shell/Mutter/IBus, and both artifacts.

ELF text/data/BSS: 239,542 / 64 / 3,764,856 bytes. Executable ZIP: 152,139 bytes; Compose ZIP: 120,536 bytes. No controlled before/after performance benchmark or manual live-desktop test was performed.

Source: [f64c7fc](https://github.com/GraderGamer2/NekoEdit/commit/f64c7fc2a6c4767f76bdc1494873ffe853fe9d33). Test-fixture correction: [55998c6](https://github.com/GraderGamer2/NekoEdit/commit/55998c623f1c34569409f74535b759142b2788c0).

---

## 2026-11-15 — gap-aware Find-highlight scanning (Actions #994 PASS)

The bounded Find-highlight matcher now traverses the document with a physical gap-buffer cursor rather than calling `doc_byte_at` for every compared query byte. The candidate pointer advances in logical candidate order and is rebased to `doc_buffer + doc_gap_end` when it reaches `doc_gap_start`. The inner query pointer advances across the matched byte sequence and performs the same rebase if a match itself straddles the gap. The byte-exact match condition and bounded candidate interval remain unchanged.

After the matcher confirms a match, the highlight painter uses the identical bytes in `find_query_buffer` for glyph advances instead of fetching the document bytes a second time. This retains the existing per-byte `doc_offset_to_visual` mapping and highlight geometry; no proportional-font or wrapping rules were changed.

The Wayland Find/Replace regression first moves the physical gap to byte offset 5, between the `f` and `i` of the initial `fish`, by inserting and deleting a temporary byte. It checks that the document bytes are unchanged. Enter selects the first result, F3 moves the blue selection to the second result, and a pixel check requires the first result to be painted amber.

The initial push, [58a7dde](https://github.com/GraderGamer2/NekoEdit/commit/58a7dde4f5e459fde6043ee8ec618670ecf25102), failed at compilation in Actions #993 because one `lea` expression mixed 32-bit and 64-bit registers. The follow-up [4d9d891](https://github.com/GraderGamer2/NekoEdit/commit/4d9d891d8725107654215177e833d32a7da16429) split the 32-bit offset addition into `mov` and `add`. Actions [#994](https://github.com/GraderGamer2/NekoEdit/actions/runs/43670126104) passed all 17 workflow steps, including the new split-gap Find pixel test, full Wayland mock, renderer equivalence, 11 MiB Open/Save, XKB, importer, Compose and nested GNOME Shell/Mutter/IBus integration.

ELF text/data/BSS are 239,334 / 64 / 3,764,856 bytes. Linux x86-64 and Compose artifact ZIPs are 152,041 and 120,536 bytes. No before/after benchmark or manual live-desktop test was performed.

---

## 2026-11-15 — wrapped selection rendering optimization (Actions #992 PASS)

The wrapped selection renderer now maintains a physical cursor into the gap buffer alongside its logical byte offset. Its visible-byte reads no longer call `doc_byte_at` for every selected character. The printable-ASCII shortcut verifies the next logical byte across the gap before advancing one byte; non-ASCII, control and newline boundaries continue through the Unicode grapheme iterator and resynchronize the physical pointer. Tabs are single-byte advances. The unwrapped selection path and document representation are unchanged.

The split-gap rendering test now checks the suffix-side highlight in both Wrap Lines modes, with the same selected document retained while switching the setting. Actions [#992](https://github.com/GraderGamer2/NekoEdit/actions/runs/43669396382) passed all 17 workflow steps, including this wrapped-mode assertion, the complete Wayland mock, large-document Open/Save, renderer equivalence and nested GNOME Shell/Mutter/IBus integration.

The uploaded executable ZIP is 151,947 bytes and the Compose-pack ZIP is 120,536 bytes. No before/after benchmark or live GNOME test was performed.

---

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


---

## 2026-11-15 — gap-aware visible-text traversal

The visible document renderer previously translated every logical byte offset through `doc_byte_at` and called the grapheme iterator after each printable character. `render_document` now keeps a physical cursor in `rbp` beside the logical byte offset in `r14d`. At each visible-row mapping point and after a full Unicode grapheme advance, it synchronizes the physical cursor against the gap-buffer prefix/suffix. For one-byte advancement, it increments the pointer and rebases to the suffix start when the logical offset reaches `doc_gap_start`.

The printable-ASCII path checks the next logical byte directly, including when it is the first byte after the physical gap. If the next byte is also ASCII, it advances by one without calling `doc_grapheme_next`. If it is high-bit, the existing Unicode path is retained; an ASCII base may join a following combining Extend, ZWJ or SpacingMark scalar even when the bytes are on opposite sides of the gap. Malformed UTF-8 also remains on the established decoder/grapheme path. The gap-buffer format, line-index structures, wrapping and glyph drawing are unchanged.

Actions [#986](https://github.com/GraderGamer2/NekoEdit/actions/runs/43664719887) passed all 17 workflow steps. The Wayland mock verified gap-buffer rendering, Unicode 18.0 grapheme navigation (combining sequences, emoji modifiers/ZWJ, RI pairs, Hangul, Indic conjuncts, Prepend, SpacingMark and CRLF), dirty rendering, horizontal scrolling, 10 MiB external clipboard paste and 11 MiB / 89,414-line Open/Save. Renderer equivalence, native `us(intl)` XKB, pinned X.Org importer, Compose and nested GNOME Shell/Mutter/IBus tests also passed.

ELF section sizes are text 237,846 bytes, data 64 bytes and BSS 3,764,856 bytes. Executable artifact: 151,225 bytes; Compose pack: 120,536 bytes. No before/after end-to-end timing was collected; the CI first-presented-redraw figure is not a controlled benchmark. No manual live-desktop test is claimed.

Implementation: [4a074b6](https://github.com/GraderGamer2/NekoEdit/commit/4a074b6fab2b5709597078de0b165f62339370f9).


---

## 2026-11-15 — middle-click auto-scroll and gap-aware selection rendering

Added a middle-button document auto-scroll mode. A middle-button press inside the document viewport captures the current pointer Y as a fixed anchor. Pointer motion above/below the anchor scrolls upward/downward; the absolute displacement beyond a 12-pixel dead zone determines the number of visual rows advanced per 50 ms tick, clamped to eight rows. The timer is armed only while scrolling is needed, so a stationary pointer inside the dead zone does not wake the event loop. Returning to the dead zone disarms the timer but leaves the mode active. Another middle click exits. Left-button press, wheel input, keyboard press, and pointer leave cancel the mode. The optional cursor-shape manager displays the all-scroll cursor while active.

The mode reuses `doc_drag_timer_fd` and its timer specification, so the event loop retains its existing timer descriptors and poll layout. The new timer helper calls were aligned for the x86-64 System V ABI. The Wayland mock added a 200-line document fixture and verifies activation, the captured anchor, downward movement, periodic movement while stationary, dead-zone pause, upward reversal, second-click cancellation, and ordinary wheel-scroll recovery.

Also optimized `render_selection_unwrapped`. Each visible row establishes a physical gap-buffer cursor alongside the logical byte offset. Sequential reads fetch the byte directly; printable ASCII advances without `doc_byte_at` or a grapheme routine call when the next logical byte is ASCII. High-bit bytes and control/grapheme-sensitive cases continue through the established Unicode path and resynchronize the physical cursor. The fast path jumps from the prefix to the suffix when it reaches `doc_gap_start`. Wrapped selection rendering and the underlying storage/index/Unicode representation are unchanged. The gap-buffer fixture now disables Wrap Lines, selects across the split gap, and verifies the suffix-side selection highlight pixel.

Actions [#991](https://github.com/GraderGamer2/NekoEdit/actions/runs/43668368074) passed all 17 steps. This includes the new middle-click auto-scroll and no-wrap gap-selection regression cases, the complete Wayland mock, 10 MiB external clipboard paste, 11 MiB / 89,414-line Open/Save, renderer equivalence, native `us(intl)` keymap, pinned X.Org importer, Compose pack generation, and nested GNOME Shell/Mutter/IBus integration.

ELF section sizes: text 238,918 bytes, data 64 bytes, BSS 3,764,856 bytes. The executable artifact is 151,801 bytes and Compose packs are 120,536 bytes. The executable ZIP is 576 bytes larger than #986; this is not evidence of a performance change. The 11 MiB Open first-presented-redraw observation was about 120 ms in this CI run, but no controlled before/after timing was run. No manual live-desktop test is claimed.

Feature implementation: [a1cd860](https://github.com/GraderGamer2/NekoEdit/commit/a1cd860b855d4b719d056ccfae63309694bfc2fa).
Selection traversal optimization: [485d6fb](https://github.com/GraderGamer2/NekoEdit/commit/485d6fb05b65ef9b1f5677116dac118a2beade0b).
Final validation commit: [a79f7ee](https://github.com/GraderGamer2/NekoEdit/commit/a79f7ee1d761fe581ea03447d0347e9c9167f11d).


---

## 2026-11-16 — first UI clipping and layout-correction pass (Actions #43802500972 PASS)

The first UI pass was driven by a source audit because no screenshot was available for review in this chat. The goal was narrow: prevent text from running into adjacent controls, align visible controls with pointer hitboxes, and improve the two-column Help reference at the largest application UI font. The editor model, document layout, rasterizer and compiler configuration were not changed.

The shared pixel-bounded ASCII renderer now adds an ellipsis when the remaining width permits it. The active document-tab name is limited to its 120px text region. History title/document/error headings and result names now have window-relative bounds, so long paths and document basenames cannot paint across the right margin into other UI.

The Help panel's design surface expanded from 480×360 to 600×400. Its layout remains centered and aspect-ratio fitted. The two shortcut columns have explicit text bounds, and the Help text size is capped at 14px even when the general UI preference reaches 16px. The renderer transform and pointer coordinate conversion were updated together to preserve click alignment. The test checks exact panel dimensions and centering at 800×480, the selected Help font size, and the central divider's framebuffer pixel.

The Settings Compose-locale control row had undersized Remove and Import buttons for their labels at the 16px setting. The selector/Add/Remove/Import buttons now use widths 76/40/68/60 design pixels, with bounded label areas. Pointer hit-testing uses the same boundaries; the three four-pixel gaps are inert and are covered by actual pointer clicks in the mock. The built-in en_US dropdown label is also pixel-bounded. In the file picker, Show Hidden text is limited to its 108px region before the checkbox.

The Wayland mock raises UI font size to 16px and checks text/button gutters, checkbox spacing, popup text bounds, Help centering/font/divider, and neutral click gaps. The Help test allow-list was extended to expose its panel geometry to the test harness. An initial CI attempt failed only because those new Help symbols were missing from the test allow-list; the allow-list was corrected, and subsequent complete checkpoints passed. The final source commit 61041f0 adds the inert-gutter and built-in-dropdown checks. Actions [#43802500972](https://github.com/GraderGamer2/NekoEdit/actions/runs/43802500972) then passed all 18 workflow steps, including the full Wayland mock, native XKB and pinned X.Org checks, Compose build, nested GNOME Shell/Mutter/IBus integration, and both artifact uploads.

Source commits: 442edfc (initial layout/text changes), 1bbd28d (test symbol coverage), cf547c7 (Settings and picker layout), and 61041f0 (inert gaps and built-in popup bound). The UI remains unfinished: this milestone addresses concrete clipping/placement defects found in the code and framebuffer tests, not the entire visual hierarchy or final polish. No manual live GNOME screenshot review is claimed.
