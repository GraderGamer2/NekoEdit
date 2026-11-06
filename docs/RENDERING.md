# Software rendering and system fonts

NekoEdit will draw its own interface and text using CPU-side pixel buffers. No GPU API or external graphics/font library is required.

## Renderer

- Maintain a software surface in memory.
- Draw fills, borders, separators, selection backgrounds, caret, and glyph masks into that surface.
- Use dirty rectangles or line-level invalidation so a keypress does not require a full-window redraw.
- Convert the canonical internal pixel representation to the pixel format expected by the active display backend.
- On Wayland, present through `wl_shm` buffers and observe buffer-release events before reusing memory.
- On X11, begin with core image upload (`PutImage`) and query the server's visual masks, depth, and image byte order instead of assuming one pixel layout.

A text editor does not need OpenGL, Vulkan, EGL, or hardware acceleration. Optimize only after measuring actual redraw and typing workloads.

## System-font discovery

No Fontconfig dependency will be used. Scan a small, documented set of common directories:

- `$XDG_DATA_HOME/fonts` when set.
- `~/.local/share/fonts`.
- `/usr/local/share/fonts`.
- `/usr/share/fonts`.

The implementation should avoid following symlink loops, handle unreadable directories, and cap recursion depth and total scan work. Font discovery should happen lazily or be cached so startup does not recursively scan the entire filesystem.

Do not assume that a `.ttf` or `.otf` filename proves a font is supported. Inspect the SFNT table directory and accept only fonts with the required tables and TrueType `glyf`/`loca` outlines in the initial implementation. CFF/CFF2, bitmap-only, color, and variable font support are deferred.

## Initial font parser

Implement bounds-checked parsing for the SFNT header and table directory, followed by the required tables for glyph selection, metrics, and outlines:

- `cmap`: Unicode code point to glyph index.
- `head`: units per em and global font bounds.
- `hhea` and `hmtx`: horizontal metrics.
- `maxp`: glyph count and limits.
- `loca` and `glyf`: TrueType glyph outlines.
- `name` and `OS/2`: family/style and useful selection metadata.
- `kern` format 0 may be supported for simple pair kerning after basic layout works.

Every table offset and length must be validated against the font file length before reading. Composite glyph recursion must have depth and cycle guards. Reject malformed fonts cleanly.

## Glyph rasterization

The initial rasterizer can use a compact fixed-point pipeline:

1. Decode simple and composite TrueType glyph contours.
2. Convert quadratic Bézier curves into line segments using bounded subdivision.
3. Rasterize the contours into an 8-bit grayscale coverage mask. A small fixed supersampling grid is an acceptable first implementation; cache the result by font, glyph ID, and pixel size.
4. Composite the mask into the software surface using foreground color and coverage.

Do not implement TrueType hinting in the first pass. Use font metrics for advance widths and vertical placement. A glyph cache avoids rerasterizing the same common characters on every redraw.

## Font selection and fallback

Prefer installed monospace fonts for the editor. Since Fontconfig is intentionally excluded, selection must be deterministic and self-contained: inspect family/style metadata, rank known monospace families where present, and use glyph advance metrics as a secondary monospace check. Let the user choose a font file/family later through a small preference UI.

If a font lacks a glyph, try another discovered font before drawing a replacement box. Do not silently substitute a different font for the whole document.

## Text layout limitations

Rendering glyphs is not equivalent to shaping text. The initial renderer targets left-to-right text and common Latin editing. Extended Latin, Greek, and Cyrillic can be rendered when the chosen fonts contain the required glyphs.

Complex script shaping, Arabic joining, Indic shaping, bidirectional layout, full IME composition, variable fonts, CFF/CFF2, color glyphs, and advanced OpenType GPOS shaping are explicitly deferred. The implementation should keep decoding, shaping, line layout, and rasterization separate so those capabilities can be added without replacing the renderer.

## Correctness

- Keep UTF-8 decoding separate from glyph lookup.
- Never index a font table without validating its bounds.
- Use checked arithmetic for dimensions, strides, and allocation sizes.
- Cache glyph masks with a clear memory budget and eviction policy.
- Ensure the software renderer clips every draw operation to the surface bounds.
