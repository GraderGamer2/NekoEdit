# Software rendering and TrueType fonts

NekoEdit's Wayland backend draws the interface and document into CPU-side pixel buffers and presents them through `wl_shm`. It does not use OpenGL, Vulkan, EGL, a GUI toolkit, or a third-party runtime font library. The application remains a freestanding Linux x86-64 executable; the outline rasterizer is a small freestanding C translation unit linked with the assembly implementation.

## Active software renderer

- Draw fills, borders, separators, selection backgrounds, caret, and glyph masks into the shared-memory surface.
- Wait for the compositor's buffer-release event before reusing a buffer.
- Rasterize TrueType outlines into bounded grayscale glyph masks, then alpha-blend coverage into the software surface.
- Keep a 128-entry glyph-ID cache to avoid decoding and rasterizing the same glyph on every redraw.
- Keep the embedded 5×7 bitmap renderer as a fallback when no supported TrueType font is loaded or the outline path cannot draw a glyph.

The current implementation is Wayland-only. The X11 backend is not ready. A text editor does not need a GPU API; performance changes should be based on measured redraw and typing workloads.

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

Quadratic contours are flattened with bounded deterministic subdivisions, including implied on-curve midpoints between consecutive off-curve points. The rasterizer applies a non-zero-winding fill rule and a 4×4 subpixel coverage grid. Its output is an 8-bit grayscale bitmap bounded to 32×32 pixels, which the Wayland renderer alpha-blends into the surface.

## Metric-aware text layout

The document layout now consumes the same TrueType metrics that the renderer uses:

- **Horizontal advance:** each code point, including U+0020 SPACE, uses its cmap-mapped glyph's `hmtx` advance scaled to the fixed 12-pixel em and rounded to the nearest pixel. The resulting advance is bounded to 1–32 pixels. If no font is loaded or the metric is invalid/unmapped, layout falls back to the legacy eight-pixel advance.
- **Wrapping and indexing:** pixel advances determine soft-wrap boundaries and per-line visual-row counts. The per-line index/Fenwick tree therefore reflects the same pixel width that the renderer paints.
- **Hit-testing and selection:** pointer X mapping, caret placement, selection rectangles, and document painting use the same advance and wrapping decisions. Picker and path-prompt text also use font advances.
- **Vertical line box:** the parser uses OS/2 sTypoAscender/sTypoDescender/sTypoLineGap when a version 4+ OS/2 table sets `USE_TYPO_METRICS`; otherwise it uses hhea ascent, descent, and line gap. The combined line box (`ascent - descent + lineGap`) is scaled to the 12-pixel em, rounded upward, and clamped to 12–32 pixels. One runtime row-pitch value drives visible-row calculations, pointer Y mapping, line movement geometry, document/selection painting, and caret placement. Without a loaded font, the row pitch remains 12 pixels.
- **Tabs:** document tabs retain 32-pixel stops; they are not shaped glyph runs.

The document em defaults to 12 pixels and can be changed during the session from Settings in the 8–24px range, in two-pixel steps. A size change updates hmtx advances, raster glyph size, OS/2/hhea-derived line pitch, and rebuilds the visual-row index before repainting. The Settings dropdown remains open during repeated size adjustments. A separate UI font-size setting defaults to 10px and adjusts from 8px to 14px in one-pixel steps; it changes ordinary interface text sizing without changing document metrics or the file picker's height-fitted dialog font. Glyph cache entries are keyed by both glyph ID and raster size, so sizes can coexist safely in the bounded cache. Font-family switching and persistent font preferences remain unimplemented.

## Soft wrapping and horizontal viewport

Soft wrapping is enabled by default. In this mode, the available document width and the same TrueType pixel advances used for glyph rendering determine wrap boundaries and per-line visual-row weights in the line index/Fenwick tree.

The session-only **Wrap Lines** setting can disable soft wrapping. In no-wrap mode each logical line contributes exactly one visual row to the vertical index, while doc_view_left_px represents the horizontal pixel origin of the viewport. Native Wayland horizontal-axis events and Shift+vertical-wheel events move that origin in 14px increments. The caret is kept horizontally visible as it moves; pointer hit-testing adds the current pixel offset before resolving the nearest grapheme boundary; tabs retain their 32px stops; and unwrapped selection backgrounds are clipped to the document viewport. Re-enabling wrapping resets the horizontal offset and rebuilds wrapped visual-row weights. The horizontal viewport currently has wheel/Shift+wheel navigation but no dedicated draggable horizontal scrollbar.

## Preferences and unfinished font controls

The Settings menu exposes **Confirm before saving**, **Font size**, **UI font size**, and **Wrap Lines**. These preferences currently apply to the running session and are not yet persisted across launches. The document-size range is 8–24px in two-pixel steps; UI text size is independent at 8–14px in one-pixel steps; Wrap Lines defaults to ON. Both font-size steppers keep the dropdown open for consecutive adjustments. Runtime font-family/file selection still needs a validated font-loading path, safe replacement of mapped SFNT state, and coordinated cmap/metrics/outline-cache refresh. The current NEKOEDIT_FONT environment variable remains the font-file override.

## Text-rendering limits

The document renderer decodes the first Unicode scalar of each grapheme cluster for cmap lookup and rasterization. Grapheme-aware editing/navigation is implemented separately, but that does not constitute full grapheme shaping. Combining marks are not positioned over a base glyph; ZWJ sequences, variation selectors, and multi-scalar emoji are not composed into shaped glyph runs.

The current renderer does not implement:

- TrueType hinting;
- OpenType CFF/CFF2, WOFF, variable fonts, bitmap/color fonts, or color glyph layers;
- kerning, GSUB/GPOS, ligatures, script shaping, or bidirectional text;
- combining-mark positioning or complete emoji ZWJ rendering;
- non-ASCII keyboard text entry, dead-key/compose input, or Wayland text-input/IME.

Glyph fallback and the embedded bitmap keep unsupported content from requiring a third-party font stack, but the result is not typographically equivalent to a shaping engine such as HarfBuzz or a complete rasterizer such as FreeType.

## Verification and correctness

The mock Wayland integration test builds a deterministic synthetic TrueType font and checks SFNT table/outline parsing, simple and composite glyph decoding, curve rasterization, antialiased pixels in the shared-memory framebuffer, horizontal 8px/5px glyph advances, a cmap-mapped 3px space advance, wrapping/indexed visual rows, proportional pointer hit-testing, and OS/2 `USE_TYPO_METRICS` vertical line pitch (with hhea retained as fallback). GitHub Actions [Build and test #400](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260) passed the complete workflow on the metric-layout implementation. This is mock-compositor coverage; a manual GNOME/Mutter smoke test of the latest font layout remains outstanding.

Bounds checks must precede font-table reads and allocation arithmetic. Surface drawing must clip to its bounds. Cache memory and outline scratch storage remain explicitly capped.

## Overlay text and horizontal scaling

Overlay glyphs are rasterized at the active UI font size. Their advances are converted back through the same horizontal transform applied to glyph origins, so the screen-space advance remains consistent when the dialog's height constrains the font size. The Open/Save picker uses this same advance for text clipping, visible-prefix measurement, caret placement, and pointer hit-testing. The path prompt and other transformed labels use the corresponding active-overlay helper. The no-font 5x7 fallback retains its legacy spacing.
