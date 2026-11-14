# Software rendering and TrueType fonts

NekoEdit's Wayland backend draws the interface and document into CPU-side pixel buffers and presents them through `wl_shm`. It does not use OpenGL, Vulkan, EGL, a GUI toolkit, or a third-party runtime font library. The application remains a freestanding Linux x86-64 executable; the outline rasterizer is a small freestanding C translation unit linked with the assembly implementation.

## Active software renderer

- Draw fills, borders, separators, selection backgrounds, caret, and glyph masks into the shared-memory surface.
- Track each buffer's `wl_buffer.release` independently from the surface's one-shot `wl_surface.frame` pacing callback; mutate only released backing storage.
- Keep a two-slot shared-memory pool, creating the second `wl_buffer` lazily only when the first slot is still compositor-owned at the next frame boundary.
- Rasterize TrueType outlines into bounded grayscale glyph masks, then alpha-blend coverage into the software surface.
- Keep a 128-entry glyph-ID cache to avoid decoding and rasterizing the same glyph on every redraw.
- Keep the embedded 5×7 bitmap renderer as a fallback when no supported TrueType font is loaded or the outline path cannot draw a glyph.

The current implementation is Wayland-only; the X11 backend is not ready. The CPU renderer uses a release-tracked two-slot shared-memory pool sized for two 3840×2160×4-byte buffers. Integer-only compositors use their preferred integer buffer scale. When fractional-scale-v1 and wp_viewporter are both available, wl_surface.set_buffer_scale remains 1 while the backing raster uses the exact preferred 120ths numerator. Each physical source dimension is rounded to nearest pixel with halves away from zero, and the ratio is capped by 2× and by the pool dimensions including rotated-axis swaps. The viewport destination and wl_surface.damage remain in logical surface coordinates. Rectangle near/far edges, TrueType glyph origins/em sizes, and the bitmap fallback use consistent raster scaling. Buffer replacement is generation-tracked and waits for both old slots to be released; the second slot is allocated lazily on contention. The pool has a maximum capacity of 66,355,200 bytes (about 63.3 MiB) for two 3840×2160×4-byte buffers; the second buffer object and its touched pages remain lazy. This is a correctness and scheduling implementation, not a measured performance claim. It adds no runtime library or GPU dependency. Representative redraw, typing, scrolling, and mixed-DPI transition measurements remain future work.

## Responsive application UI density

The application layout retains a virtual 800×480 reference coordinate system while the compositor surface has its own logical pixel dimensions. At startup, NekoEdit uses two-thirds of the largest current logical output when the compositor leaves the initial size unspecified; a 1920×1080 output therefore produces a 1280×720 surface. An explicit compositor configure dimension or a maximized/fullscreen/tiled state wins for that axis, and the original 800×480 window remains the fallback if no usable output mode is reported.

`window_ui_scale_120` stores the uniform virtual-to-surface density in 120ths. It follows the smaller surface/base axis so the UI does not distort, and is bounded between 0.75× and 2×. At 1280×720, the density is 180/120 (1.5×) and the virtual layout becomes approximately 853×480. Central rectangle drawing scales boxes, fills, borders, selection and caret geometry; glyph drawing scales TrueType font size and origins; Wayland pointer coordinates are converted back into the same virtual space before hit-testing. This also scales the file picker, Settings, Find/Replace, the status bar, and all menu hit targets through the shared paths.

The 5×7 fallback font uses whole-cell upscaling, so its pixels are approximate at densities such as 1.5×. The TrueType path rasterizes the glyph at the density-adjusted em size. The renderer composes this UI density with the backing-raster numerator when mapping glyph pixels into the physical buffer. Neither the gap-buffer byte offsets nor Unicode grapheme boundaries are scaled. The logical surface dimensions remain authoritative for viewport destination and Wayland damage; physical buffer allocation uses the derived backing extents.

## Rasterizer microbenchmark

Run `make bench-renderer` to build three variants from the same `src/font/rasterizer.c` and compiler flags:

1. **Linear reference:** pre-hash linear-LRU lookup plus the generic transform mapper.
2. **Hash-indexed reference:** 64-bucket warm-cache lookup plus the generic transform mapper.
3. **Current renderer:** hash-indexed lookup plus a dedicated identity-transform glyph blit.

The identity path is used when the Wayland buffer transform is normal (0). It clips the glyph rectangle once against the effective surface bounds and writes rows directly, avoiding a general eight-way coordinate-mapping dispatch for every covered pixel. Rotated and reflected buffers continue using the existing generic mapper. The test-only `FONT_DRAW_GENERIC_REFERENCE` switch compiles the prior implementation unchanged for the paired comparison; it is not present in the production build.

All variants use a deterministic synthetic eight-point outline provider; no system font, Wayland server, compositor, Fontconfig, or third-party font library is needed. Each reports the median of seven independent samples and prints the per-sample values. The comparison script checks that all three framebuffer checksums are identical before reporting timing deltas.

The benchmark reports two separate measurements:

- **Cold rasterization:** direct `font_rasterize_glyph()` calls, covering outline flattening, 4×4 coverage sampling, and mask generation without the glyph cache.
- **Warm cache draw:** `font_draw_codepoint_size()` calls over a fully populated 128-glyph working set, covering cmap lookup, cache lookup, and pixel alpha blending. This measures the glyph-level draw path, not the complete document frame. Each variant also exercises bucket collisions (where applicable), full LRU eviction, cache hits after replacement, and `font_cache_clear()`; those correctness checks are outside the timed warm loop.

Timing uses Linux `CLOCK_MONOTONIC_RAW`. The three variants run consecutively in the same job to reduce cross-run hardware and runner variance. Results are diagnostic, not pass/fail thresholds; compare the paired medians and inspect the seven samples for outliers. The benchmark is intentionally not a CI speed gate. The synthetic outline is deterministic and does not model real-font contour diversity. These figures do not measure full-frame `render_surface()`, the assembly rectangle path, document layout, Wayland dispatch, compositor scheduling, startup, or memory residency. Use this target to compare glyph-paint changes; gather separate on-device end-to-end timings before making application-wide optimization claims.

## Large-document Open and index construction

Picker Open reads into a separate geometrically growing staging mapping so a read error cannot destroy the current document. Once EOF and close succeed, NekoEdit swaps the staging and live mapping pointers and capacities; the new document's gap begins at EOF. This avoids a second full-file copy and leaves the former live mapping available as the next staging area. The original active document remains unchanged until this commit point.

When the gap is at EOF, line-index construction uses `repne scasb` to locate LF delimiters directly in the contiguous document bytes for the line-count and line-boundary passes. If the gap is inside the document, the original logical-byte scan remains active. Common ASCII hmtx advances are cached per code point and document em size; the cache is invalidated when the active font is replaced. The Wayland regression harness exercises an 11 MiB multi-line Open, verifies its complete line index and bytes, saves it again, and reports the elapsed time through the first presented redraw.

## Font selection and loading

No Fontconfig, FreeType, or HarfBuzz dependency is used. Font loading is deterministic rather than a recursive system-font scan:

1. If `NEKOEDIT_FONT` is set, NekoEdit attempts that file first.
2. Otherwise it tries these common Debian font paths, in order:
   - `/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf`
   - `/usr/share/fonts/truetype/liberation2/LiberationMono-Regular.ttf`
   - `/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf`

To test a specific TrueType font:

~~~sh
NEKOEDIT_FONT=/absolute/path/to/font.ttf ./build/nekoedit [file]
~~~

The test-only `NEKOEDIT_DISABLE_FONT=1` environment variable bypasses font loading so legacy fixed-bitmap UI tests can use their original pixel expectations. It is not a user-facing preference.

The loader maps the font read-only and validates the SFNT directory and required `cmap`, `head`, `hhea`, `maxp`, `hmtx`, `loca`, and `glyf` tables. Unicode cmap formats 4 and 12 are supported. An optional OS/2 version 4+ table supplies typographic ascent, descent, and line gap when `fsSelection.USE_TYPO_METRICS` is set; otherwise hhea metrics remain active. The implementation accepts bounded single-face TrueType-outline SFNT files; a filename extension alone is not treated as proof of support.

## Outline decoding and rasterization

The parser supports TrueType `glyf` simple and composite glyphs:

- Simple outlines validate contour endpoints, instruction bounds, repeated flags, and signed/short X/Y deltas.
- Composite outlines are expanded with a 16-level recursion limit and cycle detection. The decoder handles XY offsets, point matching, uniform and independent scales, and the complete 2×2 F2Dot14 transform within bounded component/contour/point storage.
- Composite instructions are bounds-checked and skipped; TrueType hinting is not executed.
- Empty glyphs are valid. Malformed or over-limit data is rejected rather than read past the mapped file.

Quadratic contours are flattened with bounded deterministic subdivisions, including implied on-curve midpoints between consecutive off-curve points. The rasterizer applies a non-zero-winding fill rule and a 4×4 subpixel coverage grid. Its output is an 8-bit grayscale bitmap bounded to 128×128 pixels. At 1×, the logical document em remains limited to 32px; at 2×, the mask raster size doubles to 64 physical pixels. The larger mask envelope leaves room for descenders and outer padding while the Wayland renderer alpha-blends coverage into the physical backing buffer.

## Metric-aware text layout

The document layout now consumes the same TrueType metrics that the renderer uses:

- **Horizontal advance:** each code point, including U+0020 SPACE, uses its cmap-mapped glyph's `hmtx` advance scaled to the fixed 12-pixel em and rounded to the nearest pixel. The resulting advance is bounded to 1–32 pixels. If no font is loaded or the metric is invalid/unmapped, layout falls back to the legacy eight-pixel advance.
- **Wrapping and indexing:** pixel advances determine soft-wrap boundaries and per-line visual-row counts. The per-line index/Fenwick tree therefore reflects the same pixel width that the renderer paints.
- **Hit-testing and selection:** pointer X mapping, caret placement, selection rectangles, and document painting use the same advance and wrapping decisions. Picker and path-prompt text also use font advances.
- **Vertical line box:** the parser uses OS/2 sTypoAscender/sTypoDescender/sTypoLineGap when a version 4+ OS/2 table sets `USE_TYPO_METRICS`; otherwise it uses hhea ascent, descent, and line gap. The combined line box (`ascent - descent + lineGap`) is scaled to the 12-pixel em, rounded upward, and clamped to 12–32 pixels. One runtime row-pitch value drives visible-row calculations, pointer Y mapping, line movement geometry, document/selection painting, and caret placement. Without a loaded font, the row pitch remains 12 pixels.
- **Tabs:** document tabs retain 32-pixel stops; they are not shaped glyph runs.

The document em defaults to 12 pixels and can be changed during the session from Settings in the 8–32px range, in two-pixel steps. A size change updates hmtx advances, raster glyph size, OS/2/hhea-derived line pitch, and rebuilds the visual-row index before repainting. The Settings dropdown remains open during repeated size adjustments. A separate UI font-size setting defaults to 10px and adjusts from 8px to 16px in one-pixel steps; it changes ordinary interface text sizing without changing document metrics or the file picker's height-fitted dialog font. Glyph cache entries are keyed by both glyph ID and raster size, so sizes can coexist safely in the bounded cache. Runtime font-file switching is available from Settings through a dedicated TTF picker. Candidate SFNT files are validated transactionally: failed replacements preserve the active mapping and metrics, while successful replacements clear face-local glyph masks and rebuild document layout. Font preferences are still session-only.

## Soft wrapping and horizontal viewport

Soft wrapping is enabled by default. In this mode, the available document width and the same TrueType pixel advances used for glyph rendering determine wrap boundaries and per-line visual-row weights in the line index/Fenwick tree.

The session-only **Wrap Lines** setting can disable soft wrapping. In no-wrap mode each logical line contributes exactly one visual row to the vertical index, while doc_view_left_px represents the horizontal pixel origin of the viewport. Native Wayland horizontal-axis events and Shift+vertical-wheel events move that origin in 14px increments. The caret is kept horizontally visible as it moves; pointer hit-testing adds the current pixel offset before resolving the nearest grapheme boundary; tabs retain their 32px stops; and unwrapped selection backgrounds are clipped to the document viewport. Re-enabling wrapping resets the horizontal offset and rebuilds wrapped visual-row weights. A dedicated bottom horizontal scrollbar now appears when a no-wrap logical line overflows the viewport. Clicking the rail positions the thumb; dragging the thumb preserves its grab offset and updates doc_view_left_px proportionally. Horizontal wheel and Shift+vertical-wheel input use the same 14px scroll step.

Caret byte-to-visual mapping also has a separate sparse checkpoint working set: 4 KiB buckets store line-relative byte offsets, local visual-row numbers, and pixel X positions under each logical line's stable ID. The line-index metric pass populates it for both wrapped and unwrapped text; the caret mapper resumes from the nearest cached checkpoint among the preceding 16 buckets. Relative offsets keep untouched lines valid when earlier document edits shift their absolute positions, while fresh IDs for edited/split/merged lines and the shared cache epoch prevent stale positions from being reused. The 4 MiB single-line Wayland regression verifies that End-to-caret mapping scans no more than 4 KiB in both Wrap Lines modes. This is a bounded-work assertion, not a measured latency claim.

## Preferences

The Settings menu exposes **Confirm before saving**, **Font file**, **Font size**, **UI font size**, and **Wrap Lines**. These preferences currently apply to the running session and are not yet persisted across launches. The document-size range is 8–32px in two-pixel steps; UI text size is independent at 8–16px in one-pixel steps; Wrap Lines defaults to ON. Both font-size steppers keep the dropdown open for consecutive adjustments. The Font File row opens a directory picker that lists directories and TTF files. Selecting a font validates the full SFNT before committing it; failed candidates restore the previous parser state and keep the prior read-only mapping alive. On success, the old mapping is unmapped, the 128-slot glyph-mask cache is cleared, and the document's line metrics and indexed visual rows are rebuilt. NEKOEDIT_FONT remains the startup override.

## Responsive overlays, selection, and Find/Replace

Settings and Find/Replace use centered design-coordinate panels. The window layout computes one uniform scale that fits both available width and height; panel dimensions, overlay glyph raster size, and pointer hit-testing all use that scale. This keeps button targets aligned with labels and avoids scaling the text twice as the UI font changes. Settings is modal: its backdrop clears the document/History workspace below the tab strip before the panel is drawn, and an outside click dismisses it without activating the covered page. The backdrop is painted with transforms disabled; the panel and its hit targets use the same scaled design coordinates. The file picker and path prompt retain their available-space fitting behavior. The modal backdrop and click-through regression are covered by the History UI test in [Build and test #676](https://github.com/GraderGamer2/NekoEdit/actions/runs/42543083558).

Double-clicking a word selects its complete word span. Ctrl+Left/Right moves by word, Ctrl+Up/Down moves between logical newline-delimited lines, and Shift variants extend the current selection. Ctrl+Home/End jumps to document boundaries, while Ctrl+Backspace/Delete removes a word.

Ctrl+F opens Find and Ctrl+H opens Find/Replace. Enter and F3 move to the next literal match; Shift+F3 moves to the previous match; Ctrl+Enter replaces the selected match; Replace All processes the remaining matches through the document. Search uses byte-exact matching and the modal's query/replacement keyboard entry currently supports the same ASCII XKB subset as the editor. Case folding and non-ASCII keyboard/IME entry remain future work.

## Text-rendering limits

The document renderer decodes the first Unicode scalar of each grapheme cluster for cmap lookup and rasterization. Grapheme-aware editing/navigation is implemented separately, but that does not constitute full grapheme shaping. Combining marks are not positioned over a base glyph; ZWJ sequences, variation selectors, and multi-scalar emoji are not composed into shaped glyph runs.

The current renderer does not implement:

- TrueType hinting;
- OpenType CFF/CFF2, WOFF, variable fonts, bitmap/color fonts, or color glyph layers;
- kerning, GSUB/GPOS, ligatures, script shaping, or bidirectional text;
- combining-mark positioning or complete emoji ZWJ rendering;
- full OpenType shaping, bidirectional layout, and general combining-mark positioning; XKB, Compose, and text-input-v3 support remain bounded subsets rather than a complete shaping engine.

Glyph fallback and the embedded bitmap keep unsupported content from requiring a third-party font stack, but the result is not typographically equivalent to a shaping engine such as HarfBuzz or a complete rasterizer such as FreeType.

## Printable-ASCII grapheme boundary fast paths

The shared `doc_grapheme_next` iterator has a narrow forward shortcut for printable ASCII bytes U+0020 through U+007E. It advances one byte directly only when the following byte is also ASCII or the current byte is at EOF. A following high-bit byte sends the current ASCII base through the general Unicode algorithm, preserving UAX #29 joins to Extend, ZWJ, and SpacingMark characters.

The matching `doc_grapheme_prev` shortcut returns the previous scalar start directly only when both that scalar and the immediately preceding byte are printable ASCII. This guarantees a grapheme boundary for the pair. C0 controls, DEL, CR/LF, and non-ASCII bytes in either direction retain the full grapheme-boundary path, so CRLF and multi-scalar clusters keep their existing editing semantics.

The Wayland regression traverses an appended printable-ASCII sentence with Right and Left, then checks Backspace at the ASCII/CRLF edge. Combining sequences, emoji modifiers/ZWJ, regional indicators, Hangul, Indic conjuncts, Prepend, SpacingMark and pointer hit-testing remain covered. Actions [#952](https://github.com/GraderGamer2/NekoEdit/actions/runs/43576391933) passed the full workflow.

No isolated timing comparison was collected for either fast path. The 11 MiB Open-to-first-presented-redraw mock measured 166.8–167.3 ms in #952, but that does not exercise the reverse-navigation shortcut and cannot establish its effect. Separate real-font redraw, line/index and repeated navigation/editing benchmarks remain future work.

## Verification and correctness

The mock Wayland integration test builds a deterministic synthetic TrueType font and checks SFNT table/outline parsing, simple and composite glyph decoding, curve rasterization, antialiased pixels in the shared-memory framebuffer, horizontal 8px/5px glyph advances, a cmap-mapped 3px space advance, a 32px lowercase-j descender mask exceeding 32px height, transactional runtime font rejection and replacement, face-local glyph-cache invalidation, wrapping/indexed visual rows, proportional pointer hit-testing, and OS/2 `USE_TYPO_METRICS` vertical line pitch (with hhea retained as fallback). GitHub Actions [Build and test #400](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260) passed the complete workflow on the metric-layout implementation. This is mock-compositor coverage; a manual GNOME/Mutter smoke test of the latest font layout remains outstanding.

Bounds checks must precede font-table reads and allocation arithmetic. Surface drawing must clip to its bounds. Cache memory and outline scratch storage remain explicitly capped.

## Overlay text and horizontal scaling

Overlay glyphs are rasterized at the active UI font size. Their advances are converted back through the same horizontal transform applied to glyph origins, so the screen-space advance remains consistent when the dialog's height constrains the font size. The Open/Save picker uses this same advance for text clipping, visible-prefix measurement, caret placement, and pointer hit-testing. The path prompt and other transformed labels use the corresponding active-overlay helper. The no-font 5x7 fallback retains its legacy spacing.


## Latest interaction verification

GitHub Actions [Build and test #493](https://github.com/GraderGamer2/NekoEdit/actions/runs/42391111760) passed the complete Wayland mock-compositor suite. It verifies the draggable bottom scrollbar, both horizontal wheel paths, adaptive overlay sizing and centering, Ctrl+word and logical-line navigation, Shift-extended selection, double-click word selection, and Find/Replace document contents. Artifact [13581805940](https://github.com/GraderGamer2/NekoEdit/actions/runs/42391111760/artifacts/13581805940) is 67,298 bytes. This remains protocol/mock verification; manual GNOME/Mutter testing of these interactions is still outstanding.
