## 2026-11-07 — Add transactional runtime TrueType font selection

Settings now opens a dedicated font picker. It displays directories and TTF files, reuses the existing filename prefix/suggestion navigation, and loads the selected face without touching the active document path or bytes.

The SFNT loader now treats replacement as a transaction. It snapshots the 23 parser metadata words and the prior read-only file mapping, maps and validates the candidate, and only then commits the replacement and unmaps the old face. A malformed/unsupported candidate is unmapped and the prior metadata/mapping is restored, so the existing font remains usable. Successful replacement clears the 128-slot glyph mask cache because glyph IDs are scoped to one face, recomputes line geometry, and rebuilds the indexed document layout.

The synthetic Wayland fixture adds two font files: a deliberately malformed TTF and a valid alternate face with the same glyph ID but a different A outline and horizontal advance. The regression verifies invalid replacement rollback, successful replacement, map/metric changes, cache invalidation, and index refresh. Manual GNOME/Mutter selection and visual inspection remain necessary after the CI build.

### Verification

- GitHub Actions [Build and test #464](https://github.com/GraderGamer2/NekoEdit/actions/runs/42386548727) passed all eight workflow steps on [a5b131b1b760](https://github.com/GraderGamer2/NekoEdit/commit/a5b131b1b760544549012d59bf8f933700df41ee).
- Artifact [nekoedit-linux-x86_64](https://github.com/GraderGamer2/NekoEdit/actions/runs/42386548727/artifacts/13579787461): 63,043 bytes; artifact ID 13579787461; expires 2026-11-14.
- The test is a mock-compositor result. Manually test selection and font appearance on GNOME/Mutter before treating the UI path as desktop-validated.

---

## 2026-11-07 — Fix picker navigation regressions and sync enlarged geometry

The shared UI-font and responsive picker implementation had landed, but the full mock-compositor suite exposed several stale picker-test assumptions. The failures were in test hit coordinates and old expected dimensions, not in the corresponding runtime behavior.

### Test and navigation corrections

- Replaced the autocomplete fixture's click in the toolbar/list gap with explicit list-focus keyboard navigation: Down, Down, Up, then Enter. The test verifies the selected directory path before typing the filename prefix.
- Exposed `picker_focus` in the mock state and assert that filename input leaves the Search field focused before validating both suggestions.
- Moved the popup framebuffer probe to the transformed popup's left border instead of sampling the selected suggestion's highlight.
- Updated the restored 800×480, resized 720×480, and fitted 720×480 expectations to the new 744×424 maximum modal geometry. The resized Cancel pointer and pixel probes now use the same non-identity Y transform as the application.
- Kept existing mouse double-click directory navigation, exact-file Open, Up-to-parent, zero-byte, and search-state regressions in place.

### Verification

- GitHub Actions [Build and test #458](https://github.com/GraderGamer2/NekoEdit/actions/runs/42378677591) passed all eight workflow steps, including the complete Wayland mock suite, ELF inspection, and artifact upload.
- Artifact [`nekoedit-linux-x86_64`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42378677591/artifacts/13575799654): 62,344 bytes; artifact ID 13575799654; seven-day retention.
- The result is mock-compositor validation. A manual GNOME/Mutter retest of the updated picker font sizing and dimensions remains outstanding.

---

## 2026-11-07 — Horizontal viewport and soft-wrap control

**Roadmap milestone:** implement horizontal navigation for long logical lines while preserving the existing pixel-accurate TrueType layout, indexed document navigation, and default soft-wrapped behavior.

### Implementation

- Added a session-only **Wrap Lines** toggle to Settings, enabled by default. The menu remains open while adjusting the setting.
- With wrapping disabled, every logical line contributes one visual row to the line index and Fenwick row tree. Re-enabling wrapping rebuilds the width-dependent visual-row weights and resets the horizontal origin.
- Added a horizontal pixel viewport offset. Caret visibility now tracks both the vertical visual row and the horizontal pixel column, so End and horizontal movement do not leave the insertion point off-screen.
- Wayland horizontal-axis wheel events and Shift+vertical-wheel events move the horizontal viewport in 14px increments, using an independent fixed-point remainder accumulator. The existing vertical wheel remains unchanged.
- Pointer hit-testing includes the horizontal pixel origin before mapping the pointer to the nearest grapheme boundary. The no-wrap renderer preserves proportional hmtx advances and 32px tab stops; selection backgrounds use an unwrapped path and are clipped to the document viewport.
- The existing vertical scrollbar continues to represent visual rows: wrapped mode reflects soft-wrap rows; no-wrap mode reflects logical lines. No dedicated draggable horizontal scrollbar is exposed yet.

### Regression coverage

The dedicated long-line mock-compositor scenario starts with a 200-byte line in wrapped mode, turns wrapping off through Settings, confirms the line index contains one visual row and the vertical scrollbar is hidden, presses End and checks that the caret drives a nonzero horizontal offset, scrolls left by one 14px wheel detent, hit-tests a position while the horizontal offset is nonzero, then re-enables wrapping and verifies the wrapped row count and zero horizontal origin are restored. Existing clipboard, Undo/Redo, file-picker, typography, selection, editor-index, scrollbar, resize, and protocol regressions remain in the same complete Wayland suite.

### Verification

- GitHub Actions [Build and test #447](https://github.com/GraderGamer2/NekoEdit/actions/runs/42372524911) passed the freestanding build/ELF verification, CLI smoke tests, full Wayland mock-compositor suite, executable inspection, and artifact upload on [5de2605dde0d](https://github.com/GraderGamer2/NekoEdit/commit/5de2605dde0d33e980437930e9f701f5a57e59fd).
- Artifact [nekoedit-linux-x86_64](https://github.com/GraderGamer2/NekoEdit/actions/runs/42372524911/artifacts/13574342289): 62,237 bytes; artifact ID 13574342289; expires 2026-11-14.
- The result is mock-compositor validation. A manual GNOME/Mutter test of this exact horizontal-viewport build remains outstanding.

---

## 2026-11-07 — Add runtime document font-size controls

Settings now provides minus/plus controls for the active document em size, from 8px to 24px in two-pixel steps. The default remains 12px.

A font-size change updates the shared hmtx advance size used by document layout and pointer mapping, rasterizes document glyphs at the same em size, derives the vertical line pitch from the active OS/2/hhea metrics at that size, and rebuilds the visual-row index before bringing the caret back into view. Glyph cache entries already include raster size in their key, so switching sizes does not reuse masks from the wrong em.

The synthetic-font Wayland integration exercises six increases from 12px to 24px, checks the 29px line pitch and a three-row line-index record, then decreases back to 12px and confirms the 15px pitch and two-row record are restored. The control is enabled only when a supported TrueType font is loaded; the embedded bitmap fallback remains at its legacy size.

Font-family selection and persistent typography preferences remain the next rendering follow-ups.

---

## 2026-11-07 — Give picker titles and byte-count values more room

The latest GNOME/Mutter test confirmed that the Open/Save picker selection and field typography are now aligned, but identified two remaining small spacing issues.

- Move both Open File and Save File titles down by four design pixels so their glyphs sit more comfortably inside the top title strip.
- Add an eight-pixel visual gap after the Bytes label before drawing the decimal byte count.
- Extend the synthetic-font framebuffer regression to check the title's new pixel position, confirm the former position is clear, and verify that the byte-count gap remains blank while the value is still rendered.

The broader next roadmap task remains the first runtime font-preference control. The fixed 12px document em, font switching, cache invalidation, and line-index reflow still need to be handled together.

---

## 2026-11-07 — Align picker captions, focus underlines, and row-pixel validation

The latest GNOME/Mutter feedback still identifies visible displacement in Open/Save picker text and its blue focus rule. Source inspection found that the Search/File name caption used a different vertical origin from the editable text field, while both field focus rules were painted along the top edge.

- Align the picker caption's glyph origin with the editable field's text origin.
- Draw the path and filename focus accents as bottom underlines, leaving the field's top edge clear.
- Extend the synthetic-font framebuffer test to check the caption pixel, both focus-field edges, and the transformed underline positions.
- Replace the selected-row glyph check that only scanned pixels inside the highlight with a framebuffer comparison that also inspects the area immediately above the row.

The implementation is being validated against the existing 800×360 synthetic-font Wayland fixture. This does not replace the required manual GNOME/Mutter visual check with a real installed font.

---

## 2026-11-07 — Complete and verify the font/dialog alignment pass

The latest early-alpha build passed GitHub Actions [Build and test #414](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432) on [5324e05b45c8](https://github.com/GraderGamer2/NekoEdit/commit/5324e05b45c8f1bba8906fe6a1453f05958ab2f5). All workflow steps passed: freestanding build/ELF checks, CLI smoke tests, complete Wayland protocol/editor test suite, executable inspection, and artifact upload.

The final regression covers a short, wide 800x360 window with a height-fitted 8px picker font. It confirms the input focus line and caret pixels, a proportional click boundary, selected-row highlight pixels, and filename glyph ink within the transformed row. The synthetic font also confirms OS/2 USE_TYPO_METRICS, hmtx-mapped spaces, and the derived document line pitch.

Artifact: [nekoedit-linux-x86_64 — 13570135812](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432/artifacts/13570135812), 55,797 bytes; SHA-256 0d634a43fabec59d906315b196cc50c3d3ed439b180e1ade875ed5c89a37f11a; expires 2026-11-14 09:45:13 UTC.

Implementation commit: [961e19fec1a9](https://github.com/GraderGamer2/NekoEdit/commit/961e19fec1a903e061cc7804a164fb4426145825). Current source-and-test branch tip: [5324e05b45c8](https://github.com/GraderGamer2/NekoEdit/commit/5324e05b45c8f1bba8906fe6a1453f05958ab2f5), following compact-window fixture corrections [8106dd3e109d](https://github.com/GraderGamer2/NekoEdit/commit/8106dd3e109d4b0afea3847b30503f78cca8088c) and [5324e05b45c8](https://github.com/GraderGamer2/NekoEdit/commit/5324e05b45c8f1bba8906fe6a1453f05958ab2f5).

This is automated mock-compositor verification. The user has not yet run this artifact on GNOME/Mutter, so the real desktop appearance remains unconfirmed. The intermediate CI failures #409, #410, #412, and #413 are retained in the preceding entries.

---

## 2026-11-07 — Compare selected-row glyph pixels in screen coordinates

CI [Build and test #413](https://github.com/GraderGamer2/NekoEdit/actions/runs/42360895800) reached the new compact-window picker assertions. The 8px font-size assertion, caret/focus-line pixel check, proportional mouse hit-test, selected-row click, and top/bottom highlight pixels all passed. The final glyph-containment assertion still compared screen-space glyph rows (103–109) against the old unscaled design-space row interval (144–158).

The assertion now compares glyph ink against the transformed 103–113 screen-space selected-row interval. This is a test-coordinate correction; the reported glyph pixels were already inside the selected highlight. [Build and test #414](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432) passed all workflow steps and uploaded artifact [13570135812](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432/artifacts/13570135812) (55,797 bytes; SHA-256 0d634a43fabec59d906315b196cc50c3d3ed439b180e1ade875ed5c89a37f11a). GNOME/Mutter visual retesting remains outstanding.

---

## 2026-11-07 — Make shared Wayland test helpers height-aware

CI [Build and test #412](https://github.com/GraderGamer2/NekoEdit/actions/runs/42360656059) confirmed the synthetic font parser/rasterizer checks passed, then the new 800×360 picker test stopped before reaching its caret assertions: the generic mock-compositor redraw checks still expected an 800×480 damage rectangle. The application correctly redrew at 800×360.

The initial redraw and shared keyboard/workflow redraw helpers now use the configured initial test height. Default tests remain 800×480; the constrained font-picker test can now proceed to validate the actual 8px glyph advances, caret, pointer hit-testing, and selected-row highlight.

The CI run for this harness correction is pending. No manual GNOME/Mutter visual test is claimed.

---

## 2026-11-07 — Keep dialog glyphs, advances, and caret geometry in the same scale

The first corrected build passed, but source review found a remaining resize-dependent mismatch: a dialog's font size is selected from its tighter fit axis, while horizontal glyph advances were still measured at the fixed 10px design em. When the window is short but wide, the picker is height-constrained: the glyphs shrink but their advances, caret, and hit-test cells do not.

### Implementation

- Added a shared overlay advance helper that measures at the active raster font size, then converts the resulting screen-pixel advance back through the same horizontal transform used for glyph origins.
- Added a picker-specific advance helper for rendering-time clipping, text-prefix measurement, caret placement, and pointer hit-testing. It uses the same picker font size and panel width, including when input events arrive after rendering has ended.
- Routed ordinary UI labels, bounded labels, decimal labels, the path prompt, and picker text/caret calculations through the appropriate helper. The no-font 5x7 fallback retains its previous spacing.
- Extended the synthetic-font picker test to start at 800×360, a height-constrained/wide configuration. It now verifies the 8px raster size, the measured A/B caret position, a mouse click that distinguishes 8px metrics from the old 10px metrics, and selected-row text containment against the transformed highlight.
- Updated the rendering reference to document the shared metric/transform rule.

### Verification

The test change intentionally exercises the case that was missing from the original 800×480 picker test. CI is pending; no manual GNOME/Mutter result is claimed.

---

## 2026-11-07 — Correct SFNT validation and responsive prompt geometry

The first two CI attempts for the font-alignment change exposed two defects in the new code before any build was offered for manual testing:

- Build and test [#409](https://github.com/GraderGamer2/NekoEdit/actions/runs/42359664591) built the executable and passed the CLI smoke tests, but the synthetic-font test ran against the system fallback face. The optional OS/2 lookup had changed EAX before the hmtx table-length calculation.
- The follow-up [#410](https://github.com/GraderGamer2/NekoEdit/actions/runs/42359711753) still failed the synthetic-font test: the hmtx calculation reloaded the metric count for the byte-size multiplication, but still subtracted the clobbered EAX rather than the reloaded count when calculating trailing side-bearing bytes.

### Corrections

- The hmtx length calculation now uses the stored, validated hhea metric count for both the long-metric and trailing-side-bearing terms. The OS/2 parser's temporary register values can no longer affect the table-size validation.
- The responsive path-prompt layout now reloads the panel height after computing its derived font size. This prevents the old vertical-centering calculation from accidentally using the font size as the panel height.
- The rasterizer module comment now describes OS/2 USE_TYPO_METRICS with the hhea fallback rather than claiming hhea is always used.

The existing responsive window test already asserts path-prompt Y/height at maximized, restored, edge-resized, and compact window sizes; it will exercise the centering correction. The next workflow is pending. No GNOME/Mutter visual result is claimed.

---

## 2026-11-07 — Correct TrueType vertical metrics and overlay text sizing

**User-facing issue:** the user reported that the newly loaded TTF font made the UI typography look misaligned and that text/caret/selection geometry in the Open/Save picker did not sit correctly. The existing synthetic-font tests covered glyph advances and row containment but did not exercise OS/2 typographic metrics or every overlay drawing call.

### Implementation

- The SFNT parser now honors OS/2 version 4+ sTypoAscender, sTypoDescender, and sTypoLineGap only when fsSelection.USE_TYPO_METRICS is set. Fonts without that flag/table continue using hhea metrics, so the existing fallback behavior remains.
- The text-advance path now resolves U+0020 SPACE through cmap and hmtx like other characters. It no longer forces every font's spaces to the legacy 8px advance.
- Overlay rendering now carries an explicit active transform font size. The picker and path prompt select their own size based on their fitted dimensions instead of sharing the picker's size accidentally.
- The path-prompt filename renderer now passes an explicit glyph size and measures advances at the same 10px design em. Previously it passed an unspecified ECX register value to draw_glyph while advancing at the 12px em, which could make prompt text inconsistent.

### Regression coverage

- The synthetic TrueType fixture now exposes U+0020 as a real cmap mapping with a 300-unit hmtx advance; the runtime probe must report 3px at the 10px em.
- The fixture includes OS/2 version 4 metrics with USE_TYPO_METRICS. The parser/runtime assertions verify those metrics and the resulting 15px document line pitch, while the existing hhea values differ so the test proves the preference is applied.
- The font-picker test asserts the active transform uses the expected 10px UI size and retains proportional caret/hit-testing plus selected-row glyph containment.
- Path-prompt sizing/advance consistency is covered by source-level alignment in the renderer; a GNOME/Mutter visual retest is still required.

### Verification

- Source and test changes are committed; the GitHub Actions run for the updated branch is pending and will be recorded after it completes.
- No manual GNOME/Mutter result is claimed. The user has not yet tested this corrected build.
- Remaining limitations: no hinting, kerning, shaping, combining-mark positioning, variable-font support, or runtime Font Settings controls.

---

# NekoEdit development log

## 2026-11-07 — Bounded TrueType composite-glyph expansion

**Roadmap milestone:** expand TrueType composite glyphs into the same bounded point/contour representation already used by the simple-glyph decoder. This advances the parser toward real-font outline rendering but does not yet change the visible renderer.

### Implementation

- Added a recursive composite-glyph decoder with a maximum nesting depth of 16, an explicit active-glyph stack for cycle rejection, and a 256-component limit per composite.
- Added independent per-depth snapshots of the accumulated parent outline. A child decode can no longer overwrite earlier parent components; each merge validates the resulting 4,096-point and 256-contour ceilings before copying the aggregate back to the public scratch arrays.
- Implemented signed byte/word XY offsets and unsigned byte/word point indices. Point-matched components align the selected child point with the selected point already present in the parent outline.
- Implemented uniform scale, independent X/Y scale, and the complete 2×2 F2Dot14 matrix. The matrix follows the OpenType convention: x′ = xscale·x + scale10·y; y′ = scale01·x + yscale·y. Explicit scaled component offsets are transformed; the default unscaled interpretation is retained when neither offset flag is set.
- Validated the component record span, glyph index, transform declarations, component arguments, point references, aggregate bounds, and optional composite instruction payload. Unsupported/reserved flag combinations fail cleanly.
- Composite instruction bytes are validated and skipped because the first rasterizer will not execute TrueType hinting. `ROUND_XY_TO_GRID` is not applied; composite `USE_MY_METRICS` does not yet override the composite's own `hmtx` metric.
- The live renderer still uses its embedded 5×7 bitmap. No Font or Font size Settings item is exposed until outline rasterization and renderer integration are complete.

### Regression coverage

- Expanded the deterministic SFNT fixture to cover a simple contour, an XY-offset composite, nested composite scaling, point matching, independent X/Y scales, a 2×2 90-degree rotation, signed byte XY arguments, and a self-referential cycle.
- The parser test reads the exported outline state from the running child and checks exact contour/point counts and selected transformed coordinates for each path. Existing SFNT, Unicode, grapheme, indexed-layout, large-file, save-confirmation, picker, resize, keyboard, and Wayland protocol tests remain in the suite.

### Verification

- GitHub Actions [Build and test #359](https://github.com/GraderGamer2/NekoEdit/actions/runs/42346409861) passed all eight workflow steps on commit [d40b466aa9e0](https://github.com/GraderGamer2/NekoEdit/commit/d40b466aa9e0a849591f68d5e5bee6d5d56c6c65): freestanding build and ELF checks, CLI smoke tests, full Wayland mock integration, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 50,721 bytes; SHA-256 `da01bd89bea41f56419c4c53b0d2ea46094a64088b88d72ca40c112ca05329a5`; artifact ID `13563518724`; expires 2026-11-14 06:18:42 UTC. [Download Actions #359 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42346409861/artifacts/13563518724).

---

## 2026-11-07 — Settings dropdown and save confirmation

**User-facing milestone:** add a top-level Settings dropdown and make ordinary saves explicit, cancellable actions rather than writing immediately when Ctrl+S or File > Save is selected.

### Implementation

- Added a Settings button beside File in the application title bar, with a dropdown containing **Confirm before saving** and a live ON/OFF state.
- The option defaults to ON at startup. Toggling it changes the current session's behavior; it is not yet persisted across application restarts.
- File > Save and Ctrl+S now open a centered modal with Save and Cancel actions. Escape cancels, while Enter or Y accepts; N cancels. The document is not written until the user accepts.
- Saving a new target from Save As uses the same confirmation. Saving over an existing regular file retains the existing dedicated overwrite confirmation.
- The save dialog is modal for pointer and keyboard input and is rendered above either the editor or the Save As picker. It is centered against the current surface dimensions.
- No Font or Font size menu entries are shown yet. They are planned for Settings after TrueType outlines are rasterized and integrated into document layout, so those controls can affect the actual glyphs and reflow instead of being decorative.

### Regression coverage

- The Wayland test opens Settings, toggles the save confirmation off and back on, and verifies the state.
- It exercises the dialog with both keyboard and pointer input: Escape and the pointer Cancel button leave the file untouched; Enter and the pointer Save button commit it.
- The test edits a loaded file, triggers Ctrl+S, confirms the file bytes remain unchanged while the dialog is open, cancels with Escape and verifies no write occurred, then repeats and accepts with Enter to verify the expected saved bytes.
- Existing Save As overwrite, direct Save, file-picker, large-file, line-index, grapheme, keyboard, resize, and protocol workflows run in the same suite.

### Verification and artifact

- GitHub Actions [Build and test #352](https://github.com/GraderGamer2/NekoEdit/actions/runs/42343675670) passed all eight workflow steps on commit [e1b52bd03b3a](https://github.com/GraderGamer2/NekoEdit/commit/e1b52bd03b3a5a532ddaccae7f106d94e60b15f3).
- Branch-head GitHub Actions [Build and test #355](https://github.com/GraderGamer2/NekoEdit/actions/runs/42343878770) passed all eight workflow steps on commit [a91de1c697ad](https://github.com/GraderGamer2/NekoEdit/commit/a91de1c697adb856764cb23d7d9c2d1981249664), including pointer Save/Cancel assertions.
- Artifact nekoedit-linux-x86_64: 48,371 bytes, SHA-256 ff4f0a5b72039cf1db91bfae4607c8feff236f2d26e56008461c26fcbfa91786, artifact ID 13562204322, expires 2026-11-14 05:42:53 UTC.
- Persistent preference storage remains a follow-up; the current toggle is session-only.

---

## 2026-11-07 — Bounded TrueType parsing and simple-glyph outline decoding

**Roadmap milestone:** establish the first usable data path for a dependency-free TrueType font engine without changing the current on-screen bitmap renderer yet.

### Implementation

- Added an explicit NEKOEDIT_FONT loading path. The file is opened read-only, size-capped at 64 MiB, mapped with mmap, and kept mapped only after the initial SFNT validation succeeds. Automatic font-directory discovery remains disabled until parser behavior is fully validated; an unavailable or invalid optional font preserves the existing bitmap fallback.
- Validated single-face TrueType-outline SFNT files (0x00010000) and bounded table directories. The parser validates required cmap, head, hhea, maxp, hmtx, loca, and glyf table ranges, the head magic and units-per-em, loca format, glyph count, vertical metrics, numberOfHMetrics, and the required horizontal-metric/loca storage lengths.
- Added Unicode cmap format 4 and 12 selection and lookup. The selected subtable offset is stored as an absolute file offset; table-relative and file-relative offsets are kept distinct. Horizontal advances are read from hmtx, including the repeated final advance for glyph IDs beyond numberOfHMetrics.
- Added bounded glyph-span resolution through short and long loca entries. A glyph span must be ordered and wholly contained by the glyf table before the decoder reads its header or payload.
- Added simple-glyph decoding: signed bounding box, contour endpoint indices, instruction-length bounds, repeated point-flag expansion, and cumulative X/Y deltas using TrueType short-vector and signed-16-bit encodings. Scratch storage is capped at 256 contours and 4,096 points. Empty glyphs are valid; malformed/out-of-range glyphs return an error; composite glyphs return a distinct unsupported result for a later stage.
- Kept the font engine dependency-free: no Fontconfig, FreeType, HarfBuzz, dynamic loader, or shared-library dependency has been introduced. The existing draw_glyph bitmap path remains unchanged; outline rasterization and renderer integration are future steps.

### Regression coverage

- The synthetic SFNT fixture maps Unicode A to glyph 1 through cmap format 4 and checks the expected 650-unit horizontal advance.
- The fixture now contains a real three-point simple glyph contour with expected points (0, 0), (500, 0), and (250, 700). The test checks the decoded contour/point counts and final coordinate.
- Also verifies an empty glyph span and clean rejection of a glyph index equal to numGlyphs. The rest of the existing file, editor, scrollbar, grapheme, keyboard, resize, and Wayland protocol suites run in the same CI workflow.

### Verification and artifact

- Parser pointer arithmetic was corrected to load the 32-bit cmap table offset without accidentally incorporating the following table-length field; cmap encoding metadata is preserved across that calculation.
- The table-directory lookup epilogue now uses flag-preserving stack adjustment so callers can reliably test its carry-flag result when a required table is absent.
- Temporary parser diagnostics were removed after the failing phase was isolated.
- GitHub Actions [Build and test #347](https://github.com/GraderGamer2/NekoEdit/actions/runs/42342486872) passed all eight workflow steps on commit [763dd8fcba4d](https://github.com/GraderGamer2/NekoEdit/commit/763dd8fcba4d735008c203a3be4f99b6c9f9de43).
- Artifact nekoedit-linux-x86_64: 47,266 bytes, SHA-256 ce78cdd8e22fea8ed6c19aa6b5a8063b6f2dbe8b0b9eb1f1d4bf6bb21393a510, artifact ID 13562136040, expires 2026-11-14 05:23:01 UTC.

---

## 2026-11-07 — Unicode 18.0 grapheme-aware editing

**Roadmap milestone:** make navigation, hit-testing, selection, wrapping, Backspace and Delete operate on extended grapheme clusters rather than treating every valid UTF-8 scalar as an independent cursor position.

### Implementation

- Embedded sorted Unicode 18.0 property ranges in the assembly read-only data section, sourced from the official Unicode Character Database files GraphemeBreakProperty.txt, DerivedCoreProperties.txt, and emoji-data.txt. The runtime has no new shared-library or external-data dependency.
- Added a binary-search property lookup, scalar decoder, forward/backward grapheme-boundary helpers, and UAX #29 extended grapheme segmentation. The implementation includes CRLF, Control boundaries, Hangul composition, Extend/SpacingMark, Prepend, Indic conjunct GB9c, Extended_Pictographic + Extend* + ZWJ sequences, and regional-indicator pairing.
- Kept UTF-8 scalar decoding as the low-level primitive. Invalid UTF-8 bytes remain individually addressable as one-byte replacement units; grapheme rules apply to valid scalar sequences.
- Switched Left/Right, Shift+Left/Right, Backspace and Delete to complete grapheme boundaries. A Delete or Backspace can remove multiple UTF-8 scalars as one user-visible cluster.
- Updated line-row measurement, indexed and fallback visual mapping, pointer hit-testing, selection painting, document rendering, and status-bar column counting to use the same grapheme boundaries. Each cluster occupies one visual cell for this renderer; non-ASCII clusters still display as a question-mark placeholder until the font phase.
- Treated CRLF as one deletion/navigation unit. The line index detects LF anywhere in the deleted cluster and merges line records by the complete deleted byte count. Pointer hit-testing and End placement never expose the interior boundary between CR and LF.

### Regression coverage

- Added targeted UTF-8 sequences for base + combining marks, multiple combining marks, emoji skin-tone modifiers, a family ZWJ sequence, regional-indicator pairs and an odd RI run, Hangul Jamo, an Indic conjunct, Prepend, SpacingMark, and CRLF.
- Verified every expected Right/Left boundary, mouse hit-testing after a multi-byte grapheme, full-cluster Backspace and Delete, CRLF navigation/deletion and the resulting line-index merge.
- Re-ran the existing indexed line metadata/Fenwick assertions, 65,537-byte Open/save and scrollbar tests, picker, selection, keyboard, resize, Wayland protocol, and both Wayland transport paths.

### Verification and artifact

- Grapheme segmentation implementation: [1eb5894443aa](https://github.com/GraderGamer2/NekoEdit/commit/1eb5894443aafcccd73e2463e91e7d85787dfaf1), feat: navigate and delete extended grapheme clusters.
- CRLF pointer-boundary correction: [fd8020b4fe67](https://github.com/GraderGamer2/NekoEdit/commit/fd8020b4fe67fe056e61d69e819210b41268dd7e).
- GitHub Actions [Build and test #331](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462) passed all eight workflow steps.
- Artifact: nekoedit-linux-x86_64, 43,886 bytes; SHA-256 25b80bd07ea11f7bc82816bdfae9c125878e67058f2e5ac563ae03bbfe86740c; artifact ID 13561405061; expires 2026-11-14 04:35:48 UTC. [Actions #331 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462/artifacts/13561405061).
- The mock-compositor tests do not replace manual validation on GNOME/Mutter; live desktop validation of grapheme editing remains pending.

---

## 2026-11-07 — Indexed document line navigation

**Roadmap milestone:** replace whole-document scans for byte-offset/visual-row mapping with an indexed logical-line model while keeping UTF-8 byte offsets and the existing gap buffer as canonical storage.

### Implementation

- Added a dynamically mmap-backed array of 16-byte logical-line records. Each record stores its byte span (including a terminating LF), soft-wrapped visual-row count, byte-length Fenwick node, and visual-row Fenwick node.
- Added two Fenwick prefix trees. Byte offsets resolve to a logical line in O(log N); visual rows resolve to a logical line in O(log N). Only the selected line is then scanned to map the exact character insertion point.
- Ordinary byte insertion/deletion recalculates the affected line and applies point updates to the relevant Fenwick paths. LF insertion splits a line; LF deletion merges adjacent lines. Because records are kept in a compact array, those structural edits shift the following records and rebuild the two trees.
- Window-width changes remeasure per-line visual-row counts and rebuild the visual-row tree, since soft wrapping depends on available columns.
- Integrated indexed lookup into caret/visual mapping, pointer hit-testing, scrollbar geometry, status-bar logical line calculation, and the renderer's first visible byte. Rendering no longer scans every document byte above the current viewport.
- Transactional Open now invalidates the previous document's index on successful replacement; the next indexed lookup rebuilds it for the newly committed bytes.
- The index starts with 256 records and grows geometrically up to 0x01000000 logical lines. If allocation fails or the line-count bound is exceeded, it is marked unavailable and the previous scan-based mapping remains the correctness fallback.

### Regression coverage

- Added a mixed document with hard newlines, a 100-character soft-wrapped line, and a tabbed final line. The test inspects each line's byte span/visual-row count and independently recomputes the expected Fenwick nodes.
- Verified that ordinary insertion and Backspace update the affected line/Fenwick nodes, Enter splits the line into two records, and Backspace merges them again; the exact saved bytes must match the original fixture.
- Re-ran the 65,537-byte Open/save fixture and confirmed that index invalidation on Open restores the large-file scrollbar instead of retaining stale metadata from the previous document.
- The full existing wrapping, selection, keyboard, UTF-8, file-picker, resize, editor-scrollbar, Wayland protocol, and WAYLAND_DISPLAY/WAYLAND_SOCKET integration regressions remain in the same workflow.

### Verification and artifact

- Source milestone: [87a33b203501](https://github.com/GraderGamer2/NekoEdit/commit/87a33b20350180f324b70ce1bff091deabef0bab), feat: add indexed document line navigation.
- Follow-up regression/fix commits: [62cbcf339394](https://github.com/GraderGamer2/NekoEdit/commit/62cbcf33939445e5563267b6ae452e845026ad23), [0eda4d095330](https://github.com/GraderGamer2/NekoEdit/commit/0eda4d095330f6b2726300e34573e559631dd0d1), [552d561dab6f](https://github.com/GraderGamer2/NekoEdit/commit/552d561dab6fccdb3cbd0415ec3c1c8cd9a8afe2), [89cc025cd3d7](https://github.com/GraderGamer2/NekoEdit/commit/89cc025cd3d7b10b5dd97098ee7c1684cd197cfa), [9e0d3c8c6789](https://github.com/GraderGamer2/NekoEdit/commit/9e0d3c8c67892b0e7a46dc5e6423f3ca3568a814), and [78db904b063f](https://github.com/GraderGamer2/NekoEdit/commit/78db904b063fc44cda4d2eabfd84aa5954da626c).
- GitHub Actions [Build and test #326](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320) passed all eight workflow steps: freestanding build/ELF validation, CLI smoke tests, complete Wayland mock tests, executable inspection, and artifact upload.
- Artifact: nekoedit-linux-x86_64, 34,965 bytes; SHA-256 e2e0e7b77095ece17f2b0573cb37fcb6e0823c56d95a0f4d3003e826ae40134a; artifact ID 13559973130; expires 2026-11-14. [Actions #326 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320/artifacts/13559973130).
- Manual validation of the indexed navigation path on GNOME/Mutter remains pending. The successful mock-compositor suite does not replace that desktop check.

---

## 2026-11-07 — Editor vertical scrollbar and mouse-wheel scrolling

**Roadmap milestone:** provide direct viewport navigation for documents that exceed the visible editor area, without making the caret jump back into view during manual scrolling.

### Implementation

- Added a document scrollbar whose thumb height is proportional to visible visual rows versus total visual rows, with a minimum thumb size and clamping at both document ends.
- Rendered the track and thumb only when content overflows. Short and empty documents do not expose an active scrollbar.
- Added Wayland pointer hit-testing, thumb dragging, and track-click repositioning. The gutter is inset from the compositor resize band, and the text layout reserves 24 pixels for it.
- Routed Wayland vertical-axis deltas to the editor when the picker/path prompt is inactive; the picker retains its own independent wheel and scrollbar state.
- Kept manual viewport movement separate from caret-follow logic, so scrolling does not immediately snap back to the current insertion point.
- The scrollbar total uses visual rows, so hard newlines and soft wrapping both contribute. The subsequent per-line byte/visual-row index now supplies the total through its visual-row Fenwick tree.

### Regression coverage and verification

- The integration suite verifies that the scrollbar is hidden on an empty document, checks the rendered thumb pixel for a 65,537-byte wrapped file, scrolls down three rows and up one row with wheel events, and drags the thumb to the final visual rows.
- Existing wrapping/caret expectations were updated for the 24-pixel gutter; an 800-pixel test surface now has 95 text columns rather than 97.
- Source implementation: [e3489badd178](https://github.com/GraderGamer2/NekoEdit/commit/e3489badd178d4db59c30e6660f9768f224f7e35). Zero-initialization correction: [028379b66a6b](https://github.com/GraderGamer2/NekoEdit/commit/028379b66a6bbfb0adb1d65d2c24696147258f96). Gutter/wrapping regression update: [d4c0fcc5710b](https://github.com/GraderGamer2/NekoEdit/commit/d4c0fcc5710b0ab5ff49bc5831a3a334ecfaa01e).
- GitHub Actions [Build and test #316](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333006563) passed all eight steps on the final test commit.
- Artifact: `nekoedit-linux-x86_64`, 32,919 bytes; SHA-256 `3c46b8da79b5896773caf1865118fa01cd201049d8dbb94c6df0ec8be4847646`; artifact ID `13557314756`. [Download Actions #316 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333006563/artifacts/13557314756).
- Manual scrollbar interaction on the user's GNOME/Mutter desktop remains pending; passing mock-compositor tests are not a substitute for pointer/wheel testing against the live compositor.

## 2026-11-07 — Dynamic gap-buffer growth and large-file Open

**Roadmap milestone:** remove the fixed 64 KiB document and staged-Open limits without introducing a third-party allocator or changing the logical byte-offset model.

### Implementation

- Replaced the static 64 KiB document array with an anonymous mmap-backed byte buffer. It starts at 64 KiB and doubles geometrically through mremap, with an explicit 1 GiB safety ceiling.
- Added suffix relocation when the live gap buffer grows. The old suffix moves to the new end of the mapping and the enlarged free region remains one contiguous gap; document length, cursor, and selection remain logical byte offsets.
- Replaced the fixed Open scratch array with a separate mmap-backed staging buffer that grows independently. It reads the entire file in bounded chunks and probes one byte beyond each full mapping before deciding whether to grow.
- Picker Open reserves live-document capacity before replacing the active document. A failed read, close, or allocation leaves the previous document/path intact; successful Open resets the cursor/selection and commits the loaded byte sequence.
- Initial command-line file loading also grows the live mapping rather than truncating or rejecting data at 64 KiB.
- Kept storage byte-oriented. This milestone does not yet add line indexing, grapheme semantics, Unicode input/rendering, or undo/redo.

### Regression coverage

- An exact 65,536-byte startup file fills the initial live mapping completely. The first insertion occurs at byte zero, forces growth to 131,072 bytes, relocates the 65,536-byte suffix, and checks the exact reconstructed logical byte stream before saving it across the split gap.
- The native picker opens a 65,537-byte file, verifies the committed active path, exact byte length and full contents, then saves it back and checks the on-disk bytes.
- Existing file-picker rollback/cancellation, gap movement, UTF-8 code-point editing, atomic save, Wayland protocol, responsive layout, both Wayland transports, and cursor-shape fallback tests remain in the same complete integration suite.

### Verification and artifact

- Source implementation: [8af89d509003](https://github.com/GraderGamer2/NekoEdit/commit/8af89d509003997272479ff2271542a304bdec07), feat: grow document storage beyond 64 KiB.
- Regression-test and harness commits: [41afebc4d38b](https://github.com/GraderGamer2/NekoEdit/commit/41afebc4d38b48fa17b695b6df174b16fccac5a9), [1e61fde65235](https://github.com/GraderGamer2/NekoEdit/commit/1e61fde65235dd4be79ad9620c78c4170f6a11d9), [c004f00d038e](https://github.com/GraderGamer2/NekoEdit/commit/c004f00d038ee9c5e0812f7a35967ea25e113c0a), [0bb96bd5a7b3](https://github.com/GraderGamer2/NekoEdit/commit/0bb96bd5a7b327a3f35acc2d1a7267ffa2d59220), [37650efa8930](https://github.com/GraderGamer2/NekoEdit/commit/37650efa89302cf2e5484186a18b80375e7116c1), and [53d4b2df8d0e](https://github.com/GraderGamer2/NekoEdit/commit/53d4b2df8d0ef8968ab12fd8fb9923e4e6caa218).
- GitHub Actions [Build and test #312](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234) passed all eight steps on 53d4b2df8d0e.
- Artifact: nekoedit-linux-x86_64, 32,119 bytes; SHA-256 bb5666e76505c08b90e4ffac094af79bd2d4c4078014c0e81bf98c63cc3ba0f4; artifact ID 13556529585; expires 2026-11-14 02:47:14 UTC. [Download Actions #312 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234/artifacts/13556529585).
- The user subsequently confirmed on the live GNOME/Mutter desktop that a 70 KB text file opens, accepts edits, and saves those changes correctly without crashing or exhibiting anomalous behavior. This completes the real-desktop validation of the dynamic-storage/large-file Open milestone.

## 2026-11-07 — Make the editor UI follow configured window geometry

**User report:** Maximize and interactive edge/corner resizing now work on GNOME/Mutter without crashes, but the footer and other UI elements remained at their original positions after the window changed size.

### Diagnosis

- Window geometry and the shared-memory buffer were already updated from compositor configure events. The editor document also recalculated its wrapping columns and visible rows.
- Several UI elements still had fixed design coordinates. In particular, the byte-count and mode labels in the status bar remained at x=480 and x=744 even when the footer background followed the bottom of the resized surface.
- The file picker and path prompt were drawn at fixed 720×408 and 704×176 design dimensions and fixed top-left offsets. Their pointer hit-tests used the same fixed coordinates, so simply moving or scaling the visuals would have made controls difficult to click.

### Implementation

- Recalculate footer label anchors from the current window width. The status row remains attached to `height - 20`.
- Recalculate the document's current wrap columns and visible row count from every configured geometry (the existing document renderer/cursor visibility logic consumes those values).
- Keep the picker and path prompt at their original design size when possible. If the surface is smaller, center and scale each within a 16-pixel margin.
- Add a shared drawing transform for rectangle and glyph origins. Apply its inverse to picker pointer hit-testing and vertical scrollbar dragging, preserving alignment between the visible controls and their interactive areas.
- Keep the window-management protocol unchanged: compositor configure events still determine the dimensions, and buffer replacement remains release-gated.

### Regression coverage

- Maximize geometry: 1920×1080, including footer anchors and document rows/columns.
- Restore geometry: 800×480, checking the original design anchors are restored.
- Interactive resize geometry: 720×480, checking the footer follows the width while the bottom bar follows the height.
- Minimum-size geometry: 480×360, checking responsive footer placement and fitted modal geometry.
- The mock opens the file picker at 720×480 and 480×360, checks its transformed Cancel-button background, clicks that exact button, and verifies that the picker closes. Both the optional cursor-shape and no-extension compositor paths exercise the complete workflow.

### Verification and artifact

- Responsive source and geometry-state regression: [`6eec3c4f13c2`](https://github.com/GraderGamer2/NekoEdit/commit/6eec3c4f13c2798909b64e1a166ba836cc12f9c3). The initial build exposed nonzero initializers accidentally placed in `.bss`; these were changed to zero-initialized storage before the passing run.
- Expanded small-window interaction test: [`5f03a54c693f`](https://github.com/GraderGamer2/NekoEdit/commit/5f03a54c693f6b80817dc4a7d6b2afe545374082). Its first CI run caught an overly precise pixel probe intersecting the Cancel label glyph. The probe was moved to empty button padding; the button click itself remains at its center.
- GitHub Actions [Build and test #301](https://github.com/GraderGamer2/NekoEdit/actions/runs/42328626464) passed all eight steps on [`3ae9583d34bc`](https://github.com/GraderGamer2/NekoEdit/commit/3ae9583d34bccfddfeb2d5e6e2a03f4b326186a9).
- Artifact: `nekoedit-linux-x86_64`, 31,328 bytes; SHA-256 `9be62cda309b4c460e90df2200a9963ab9e541f011c471d9510e9d1dbcbd4de4`; artifact ID `13556316772`; expires 2026-11-14 02:19:14 UTC. [Download Actions #301 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42328626464/artifacts/13556316772).
- The user has verified the Maximize and edge/corner resize behavior on the live GNOME/Mutter desktop. The responsive-layout artifact still needs the user's visual confirmation; CI verifies layout state, rendered footer/modal positions, and mouse hit targets in the mock compositor.

## 2026-11-07 — Correct cursor-shape get_pointer argument marshalling

**User report:** The Actions #297 binary exited during Wayland startup with:

```text
NekoEdit: Wayland protocol or shared-memory setup failed.
Wayland stage: event loop
NekoEdit: Wayland compositor protocol error: invalid arguments for wp_cursor_shape_manager_v1#17.get_pointer
```

### Root cause

- The cursor-shape protocol defines `get_pointer` arguments in this order: a new `wp_cursor_shape_device_v1` object ID, then the existing `wl_pointer` object ID.
- NekoEdit had allocated cursor-device ID 18 but sent only the four-byte pointer ID 15. The compositor received a malformed request and rejected it before any edge-resize drag began.
- The mock test repeated the implementation's mistake: it expected the four-byte pointer-only payload. It therefore passed while asserting invalid protocol behavior.

### Fix

- Marshal the full eight-byte payload as `(cursor_shape_device, pointer_object)` and set the request payload length to eight bytes.
- Correct the mock-compositor expectation to require `(18, 15)`, making omission or reordering of either argument a regression failure.
- Keep the optional cursor-shape extension limited to hover feedback. The actual interactive resize continues to use `xdg_toplevel.resize` with the serial from the user's button press. Compositors that do not advertise the extension continue through the no-cursor fallback.

### Verification and artifact

- Source/test fix: [`a440fd2683a8`](https://github.com/GraderGamer2/NekoEdit/commit/a440fd2683a821bf1535924b932be55b05ab58f7) (`fix: marshal cursor-shape get_pointer arguments`).
- GitHub Actions [Build and test #298](https://github.com/GraderGamer2/NekoEdit/actions/runs/42327663095) passed all eight workflow steps: freestanding build/ELF verification, CLI smoke tests, the complete Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,625 bytes; SHA-256 `91538137f998925ed72cd9d47604380be85906a17eb8af1d7dd1aaa885f49300`; artifact ID `13555438576`; expires 2026-11-14 02:08:02 UTC. [Download Actions #298 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42327663095/artifacts/13555438576).
- This validates the wire format against the mock compositor, not against the user's live GNOME/Mutter session. The corrected artifact still needs manual launch and edge-drag testing.

## 2026-11-07 — Restore edge-drag window resizing and resize cursor feedback

**User report:** The newest build no longer crashes when Maximize is clicked, but manually dragging the window edges still does not resize the window. The Maximize fix is confirmed; edge dragging is the remaining window-management defect.

### Root cause

- The edge hit-test and `xdg_toplevel.resize` request were already present, but the initial `wl_pointer.enter` event could arrive during the synchronous startup seat roundtrip, between `wl_pointer.get_pointer` and the roundtrip callback.
- The startup roundtrip handled seat capabilities and buffer release but discarded pointer events. If the pointer entered NekoEdit during that interval, `pointer_inside` remained false, and the later button handler discarded the press before it could send `xdg_toplevel.resize`.
- The previous 12-pixel hit band was also unnecessarily narrow and there was no resize-cursor feedback to show the user where the drag area begins.

### Implementation

- Capture `wl_pointer.enter`, its serial, and surface-local coordinates during the startup roundtrip; process pointer motion there too. Reuse the same capture helpers in the normal event loop.
- Share one edge/corner calculation between the resize button handler and cursor feedback. Increase the logical hit band to 16 surface units.
- Keep the app-drawn File menu and right-side window controls clickable: the top resize band excludes those titlebar controls, while the outermost top-right corner remains available for resizing.
- When the compositor advertises the optional `wp_cursor_shape_manager_v1` global, bind it and provide horizontal, vertical, and diagonal resize cursors. Cursor-shape requests use the latest pointer-enter serial; the actual interactive resize still uses the serial from the user's button press.
- Keep resizing functional when the optional cursor-shape extension is not advertised. The extension changes hover feedback, not the underlying `xdg_toplevel.resize` request.
- Keep the dense `next_client_object_id` allocator and the Maximize fix unchanged.

### Regression coverage

- The mock compositor sends `wl_pointer.enter` after `get_pointer` but before the startup sync callback. The initial pointer interaction must still be handled.
- Verify the cursor-shape manager binding, initial default cursor, side/corner cursor shapes, the updated enter serial after pointer focus is lost and regained, and `xdg_toplevel.resize` with the button serial for all four edges and corners.
- Run the complete window workflow again without advertising `wp_cursor_shape_manager_v1` to verify that edge resizing does not depend on the optional cursor extension. The same workflow verifies that a File-menu click near the top edge is not intercepted as a resize.
- See [WAYLAND_WINDOW_RESIZE.md](../docs/WAYLAND_WINDOW_RESIZE.md) for the pointer lifecycle, hit-testing, protocol, and compositor-fallback notes.

### Validation and artifact
- Initial pointer/resize change: [`3da11acf616b`](https://github.com/GraderGamer2/NekoEdit/commit/3da11acf616b694b3b0e7d00e8595b69fa0ca582). Actions #296 passed assembly/link/ELF verification and CLI smoke tests, then exposed that the widened top-edge band overlapped the File menu when the optional cursor extension was disabled.
- Follow-up titlebar exclusion: [`064af05090c4`](https://github.com/GraderGamer2/NekoEdit/commit/064af05090c455e5effe02a20bc1e1b9a9942f27). Top-edge resizing now excludes the File menu and visible window-control strip; the outermost top-right corner remains available.
- GitHub Actions [Build and test #297](https://github.com/GraderGamer2/NekoEdit/actions/runs/42326928833) passed all eight workflow steps: freestanding build/ELF verification, CLI smoke tests, full Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,636 bytes; SHA-256 `da71ce6580529b1d86117c4c90e317b10f2cfb58a7c03569460259cf7f1f4501`; artifact ID `13556041396`; expires 2026-11-14 01:59:49 UTC. [Download from Actions #297](https://github.com/GraderGamer2/NekoEdit/actions/runs/42326928833/artifacts/13556041396).
- The user confirmed Maximize no longer crashes on Actions #294. The #297 build has not yet been tested in the user’s GNOME/Mutter session; real pointer-drag resizing remains pending manual verification.
## 2026-11-07 — Remove temporary Maximize investigation instrumentation

**User retest:** The user has now confirmed that clicking the Maximize control no longer crashes NekoEdit and that the window remains usable afterward. This is the first real-desktop confirmation of the dense object-ID correction, beyond the mock-compositor suite.

### Cleanup

- Removed the one-shot wl_display.sync callback inserted after the first resized-buffer creation. Resized buffers now follow the normal configure, old-buffer-release, create, attach, damage, and commit path without an extra round trip.
- Removed its pending-callback state and the code that deferred drawing/configure handling while that diagnostic barrier was outstanding.
- Removed failed-request and last-request metadata tracking, the verbose request/event fields printed on protocol failures, and the decimal-only stderr formatter that existed solely for those fields.
- Kept the shared next_client_object_id allocator. It is the actual root-cause fix: after fixed setup IDs, pointer and keyboard consume IDs 15 and 16; the first replacement buffer is 17, followed by buffers 18 and 19 for subsequent resizes.
- Kept MSG_NOSIGNAL on Wayland sendto/sendmsg. This is transport-failure robustness, not verbose diagnostics: a closed compositor socket becomes a controlled -EPIPE return instead of terminating the process with SIGPIPE. The existing concise protocol-error and compositor-provided wl_display.error messages also remain.

### Regression coverage and debugging reference

- The mock suite still exercises Maximize, Restore, and interactive edge resizing with the dense buffer-ID sequence, but no longer expects a diagnostic sync callback or simulates the barrier-specific rejected-buffer path.
- The closed-socket regression now checks that NekoEdit exits through its normal protocol-error path (status 1), does not die from SIGPIPE, and does not print document contents.
- See [WAYLAND_MAXIMIZE_DEBUGGING.md](../docs/WAYLAND_MAXIMIZE_DEBUGGING.md) for the investigation history, the retained root-cause fix, and the commits to inspect if a similar failure returns.
- The existing startup-stage diagnostics and compositor-provided wl_display.error reporting remain available for general Wayland setup/protocol failures.

### Verification and artifact

- Cleanup commit: [`82f1e15c04c8`](https://github.com/GraderGamer2/NekoEdit/commit/82f1e15c04c87d202658eb4fda0d4c406854db93).
- GitHub Actions [Build and test #294](https://github.com/GraderGamer2/NekoEdit/actions/runs/42325108772) passed all eight steps: freestanding assembly/link and ELF checks, CLI smoke tests, the complete Wayland mock-compositor suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 29,836 bytes; SHA-256 `c375eb07c23059a45387fae3f0c67f97ef6632713bd619a67b9591464c311ba3`; artifact ID `13555196117`; expires 2026-11-14 01:38:13 UTC. [Download from Actions #294](https://github.com/GraderGamer2/NekoEdit/actions/runs/42325108772/artifacts/13555196117).
- The user subsequently tested the newest cleanup build (Actions #294) and confirmed Maximize no longer crashes. Manual edge dragging still does not work on that build; the new pointer-focus/cursor-resize work is intended to address that remaining issue.

## 2026-11-07 — Fix dense Wayland client object IDs for resized buffers

**User retest and root cause:** The Actions #290 binary returned:

```text
Wayland previous request: object=1, opcode=0
Wayland last event: object=1, opcode=0, payload bytes=64
Wayland buffer attach deferred: sync callback=257, buffer=256
NekoEdit: Wayland compositor protocol error: invalid arguments for wl_shm_pool#11.create_buffer
```

The compositor's explicit protocol error finally identified the actual fault. The resize path used a separate counter initialized to 256, then assigned callback ID 257. Those IDs skipped the unused client-object IDs 17 through 255. Wayland client-created object IDs must be allocated densely; libwayland rejected the new object ID while decoding `wl_shm_pool.create_buffer`, before checking the replacement buffer's dimensions or stride. This was not a buffer-size/stride defect.

### Fix

- Replaced the independent `next_input_object` and `window_next_buffer_id` counters with one `next_client_object_id` counter shared by pointer, keyboard, resized-buffer, and sync-callback creation.
- Initialize the shared counter to 15 after the fixed setup objects through ID 14 have been created. Pointer and keyboard consume 15 and 16, so the first replacement buffer receives 17. During the earlier diagnostic build, the one-shot sync callback consumed 18; after its removal, subsequent replacement buffers receive 18 and 19.
- Updated the Wayland integration tests to assert the dense ID sequence rather than repeating the previous sparse-ID assumption. The barrier-specific simulated compositor-rejection case was removed with the diagnostic probe.

### Verification and artifact

- Source and test changes were committed on `early-alpha` as [`2273306b519d`](https://github.com/GraderGamer2/NekoEdit/commit/2273306b519d2787d387d2013e7f32a416ff3a4b).
- GitHub Actions [Build and test #292](https://github.com/GraderGamer2/NekoEdit/actions/runs/42323572724) passed all eight workflow steps: freestanding build/ELF verification, CLI smoke tests, the complete Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,659 bytes; SHA-256 `e51c74154c953d696d95bd7fe41fc3d82b42bbef3280b3428ec7c2d0a99ff65b`; artifact ID `13553938172`; expires 2026-11-14 01:21:03 UTC. [Download from Actions #292](https://github.com/GraderGamer2/NekoEdit/actions/runs/42323572724/artifacts/13553938172).
- This is a protocol-level root-cause fix, not merely instrumentation. The user has since manually confirmed that Maximize no longer crashes and the window remains usable. The diagnostic-only sync barrier and request/event tracking have now been removed in the cleanup section above; the original launch command remains unchanged.

## 2026-11-07 — Isolate the first resized-buffer request with a one-shot sync barrier

**Observed failure sequence:** The user's clean #278 retest reproduced the same EPIPE trace: NekoEdit's first failed send was `wl_surface.attach` (object 8/opcode 1), while its last successfully written request was `wl_shm_pool.create_buffer` (object 11/opcode 0), and its last received event was `xdg_surface.configure` (object 9/opcode 0). The compositor had already closed the socket by the time attach was attempted. This narrows the issue to the configure-driven replacement-buffer sequence, but does not prove whether the compositor accepted the new buffer.

### Diagnostic change

- After creating the first replacement `wl_buffer`, NekoEdit now sends `wl_display.sync` and waits for that request's `wl_callback.done` before sending `wl_surface.attach`. The sync callback is an ordering barrier: prior requests have been processed before it is delivered, allowing a fatal compositor error associated with the pool/buffer request to be received before attach.
- The barrier is one-shot after startup; later interactive-resize frames do not incur another round-trip. While it is pending, the regular event dispatcher continues processing other Wayland events. Input-triggered redraws and newer configure-driven replacements are deferred until the callback resolves.
- If the compositor sends `wl_display.error`, diagnostics print the previous request, last event, sync callback ID, replacement buffer ID, and compositor-provided message. If the socket closes before the callback, NekoEdit prints the pending sync context without requiring journald or external logs.
- Mock coverage verifies the successful Maximize/Restore/interactive-resize path and a simulated fatal error on the replacement `wl_shm_pool.create_buffer`. The failure case asserts that NekoEdit receives and reports the compositor error before sending any `wl_surface.attach`, including the previous sync request (object 1/opcode 0), 44-byte error event, callback 257, and replacement buffer 256.
- This is diagnostic instrumentation, not yet a confirmed fix for GNOME Maximize or edge resizing.

### Verification and artifact

- Intermediate runs #280, #283, and #284 exposed test-harness gaps while the barrier and error path were being wired; these were corrected. Runs #281/#282 passed the standard successful barrier path. Run #286 passed the protocol-error reporting path. Run #289 exposed that the test still expected a barrier on every resize after the implementation became one-shot; the test expectations were corrected.
- GitHub Actions [Build and test #290](https://github.com/GraderGamer2/NekoEdit/actions/runs/42322351170) passed all eight steps on [`593ec1cdd82d`](https://github.com/GraderGamer2/NekoEdit/commit/593ec1cdd82dce7ae540818f6eae14ea610341d4): build/ELF checks, CLI smoke tests, successful one-shot synchronization, simulated compositor rejection before attach, all existing Wayland mock scenarios over both transports, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,652 bytes; SHA-256 `d59b82c487e5262745e4590a9204bcb4bebe431b0f2a09a0edf841dd434b8961`; artifact ID `13552914100`; expires 2026-11-14 01:08:14 UTC. [Download from Actions #290](https://github.com/GraderGamer2/NekoEdit/actions/runs/42322351170/artifacts/13552914100).
- The GNOME/Mutter retest remains pending. The next manual output should distinguish a compositor protocol error before attach from a disconnect while waiting for the sync callback, or a later failure after callback completion. No system logging or extra packages are needed.

## 2026-11-07 — Bound Wayland diagnostics and prevent diagnostic memory disclosure

**User retest and observed sequence:** The Actions #270 binary reported a failed `wl_surface.attach` request (object 8, opcode 1, `EPIPE`/errno 32), with the preceding locally written request at object 11/opcode 0 and the last event at object 9/opcode 0. Those IDs identify `wl_shm_pool.create_buffer` and `xdg_surface.configure`, respectively; the event's payload size is 4 bytes. This is consistent with the configure-driven buffer replacement path, but a locally successful socket write does not prove Mutter processed or accepted that request, so the disconnect's actual cause remains unconfirmed.

### Diagnostic defects found and fixed

- The diagnostic formatter calculated the byte length for `", payload bytes="` by subtracting the label address from a preceding label. The resulting length was vastly larger than the string itself, so the stderr write continued through adjacent process memory. That explains the unrelated XKB text, editor contents, and binary-looking bytes in the user's terminal output. This was an application-side out-of-bounds diagnostic write, not Wayland event payload data.
- Added an explicit end label for the payload-size string and calculate its length from the start and end of that exact string in [`5765d1dc7dc0`](https://github.com/GraderGamer2/NekoEdit/commit/5765d1dc7dc0d1cd2f6c928b91363d0b5aa2988c).
- The decimal integer printer also included one byte beyond its final digit, adding a NUL byte after every numeric field. Corrected the exclusive end address in [`c2a9f0d08597`](https://github.com/GraderGamer2/NekoEdit/commit/c2a9f0d08597ed3f2d0a8a4d7ba97b62bf38af45).
- Added a mock-compositor regression in [`ad4ec280e31e`](https://github.com/GraderGamer2/NekoEdit/commit/ad4ec280e31e8cb653abede6edbbf7b6d5ea1a47), then tightened it in [`2408b3e00983`](https://github.com/GraderGamer2/NekoEdit/commit/2408b3e009833d294d0f2233261a84e18e9b23e8) and [`a85488248ecaf3`](https://github.com/GraderGamer2/NekoEdit/commit/a85488248ecaf3f4c4742e5f0cb599d79b0e6c1b). It writes a unique sentinel to a temporary document, closes the mock compositor immediately after `xdg_surface.configure` acknowledgement, checks the failed request/previous request/last event values, rejects NUL bytes, caps stderr at 512 bytes, and ensures the document sentinel is absent.

### Verification

- Actions #274 passed all eight steps on the bounded-label source fix. Actions #275 then failed the new regression because the integer formatter appended NUL bytes; that failure identified the second off-by-one and was corrected. Intermediate runs #276 and #277 were cancelled as the fixes landed.
- GitHub Actions [Build and test #278](https://github.com/GraderGamer2/NekoEdit/actions/runs/42321400180) passed all eight steps on [`a85488248ecaf3`](https://github.com/GraderGamer2/NekoEdit/commit/a85488248ecaf3f4c4742e5f0cb599d79b0e6c1b), including the new closed-socket output-safety regression, all existing Wayland mock scenarios, CLI smoke tests, ELF inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,396 bytes; SHA-256 `ca459f68e21289cb7bd7c0deb74d1f1c36c928ccf912292848ebbe32594fcb51`; artifact ID `13553546144`; expires 2026-11-14 00:58:35 UTC. [Download from Actions #278](https://github.com/GraderGamer2/NekoEdit/actions/runs/42321400180/artifacts/13553546144).
- This CI test establishes that the diagnostic output is bounded and does not contain the opened document's sentinel. It does not establish why GNOME/Mutter closed the real client socket or demonstrate that Maximize/edge resize now work. The real GNOME retest is still required; no journald or system-log changes are needed.

This is an append-only narrative log. New entries go at the top, with the newest work first. The complete historical narrative is in [PROJECT_HISTORY.md](PROJECT_HISTORY.md); the full SHA/subject ledger is in [COMMIT_INDEX.md](COMMIT_INDEX.md).

## 2026-11-07 — Identify the request and event surrounding the GNOME disconnect

**User retest:** The `MSG_NOSIGNAL` diagnostic artifact produced:

```text
NekoEdit: Wayland protocol or shared-memory setup failed.
Wayland stage: event loop
Wayland send failed: object=8, opcode=1, errno=32
```

- Client object 8 is the `wl_surface` created during window setup; request opcode 1 is `wl_surface.attach`. `errno=32` is `EPIPE`: the compositor-side socket was already closed when NekoEdit attempted to send the attach request.
- This identifies the first send that failed, **not necessarily the request that caused the compositor to disconnect**. The server may have closed the socket after an earlier request or during configure/buffer handling. No `wl_display.error` message was included in the output.
- The user does not want journald enabled and has disabled system logging. No system logs are required for this next step.

### Additional source diagnostics

- Preserve the object ID/opcode of the last complete request NekoEdit wrote to the Wayland socket.
- On a failed request, print that preceding request and the last successfully read Wayland event (object ID, event opcode, payload byte count), in addition to the failed request and errno.
- This distinguishes whether the close happened directly after a toplevel configure, a surface configure/acknowledgement, a buffer release, or the replacement-buffer sequence. The preceding request's successful local write does not prove Mutter processed it.
- Source commits: [`41b819eae69d`](https://github.com/GraderGamer2/NekoEdit/commit/41b819eae69db66c9f61f0f313027cf056965418) and [`0dbf87cbb5d6`](https://github.com/GraderGamer2/NekoEdit/commit/0dbf87cbb5d659254e200dd69a41b6efc80a20a3); documentation: [`0501579b965d`](https://github.com/GraderGamer2/NekoEdit/commit/0501579b965dd65011ea5475fcc2b197d95946f9).

### Verification status

- GitHub Actions [Build and test #270](https://github.com/GraderGamer2/NekoEdit/actions/runs/42320683568) passed all eight workflow steps on branch head [`f7fd732d7d2fd01b67826f2b9a43c3ef767001d0`](https://github.com/GraderGamer2/NekoEdit/commit/f7fd732d7d2fd01b67826f2b9a43c3ef767001d0): assembly/link and ELF checks, CLI smoke tests, the complete Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,387 bytes; SHA-256 `b49e824bc3aba908a025286d2e54ed76c0db4e26bc338858d5f748eb1ceea9bf`; artifact ID `13552837524`; expires 2026-11-14 00:50:55 UTC. [Download from Actions #270](https://github.com/GraderGamer2/NekoEdit/actions/runs/42320683568/artifacts/13552837524).
- The user's real GNOME/Mutter retest is still pending. CI verifies assembly and mock protocol behavior; it does not establish why Mutter closed the socket or prove Maximize/resize work.

## 2026-11-07 — Report failed Wayland sends instead of terminating on SIGPIPE

**Purpose:** Continue diagnosing the user's GNOME Wayland Maximize/resize failure without asking them to enable system logging. The user confirmed the picker scrollbar correction works, while Maximize still exits NekoEdit and edge resizing still has no effect. Their original terminal run returned status 141; temporarily ignoring SIGPIPE changed this to the program's generic event-loop error and status 1.

### Diagnosis

- Exit status 141 is consistent with termination by SIGPIPE (signal 13). NekoEdit's Wayland request path previously used `write()` on the compositor socket; writing after the peer has closed that socket can raise SIGPIPE before the program's own error handler reports useful detail.
- With SIGPIPE ignored by the shell, the write can instead return a negative `EPIPE` error, but the existing error handler only printed the broad `Wayland stage: event loop` label.
- These outputs establish a broken/closed socket write path, but they do **not** yet establish why Mutter closed the connection or which request was the first trigger.

### Source changes

- Added a Wayland-specific send loop using `sendto(..., MSG_NOSIGNAL)`, including partial-send and `EINTR` handling. The `sendmsg` path used for shared-memory FD transfer also passes `MSG_NOSIGNAL`.
- A failed request now preserves its client object ID, opcode, and negative Linux errno. The common error handler prints those values to stderr, so the next manual test can identify the request that could not be sent.
- No logfile, journal, extra package, dependency, launch flag, or persistent system setting is needed. The normal launch command remains `./nekoedit --backend=wayland`.

### Verification status

- Source commits: [`10df996a0b51`](https://github.com/GraderGamer2/NekoEdit/commit/10df996a0b51de4b36287d4e78180b52dfd5c4ec), [`1331b49dde84`](https://github.com/GraderGamer2/NekoEdit/commit/1331b49dde8415d0d40dfb2d5326b4e0a3990b97), and [`2ba62dd68161`](https://github.com/GraderGamer2/NekoEdit/commit/2ba62dd681611da09673e1fffc1d81b109ac4abf).
- GitHub Actions [Build and test #261](https://github.com/GraderGamer2/NekoEdit/actions/runs/42266008250) passed all eight workflow steps on branch head [`3752714507b773c2cf07293eb5f12bf85f251f1b`](https://github.com/GraderGamer2/NekoEdit/commit/3752714507b773c2cf07293eb5f12bf85f251f1b): freestanding assembly/link and ELF checks, CLI smoke tests, the complete Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,146 bytes; SHA-256 `f2572c2aa95b92c80294fdb79406cddd7c5de4d5b107887a0d64fb62df643636`; artifact ID `13527261651`; expires 2026-11-13 17:55:26 UTC. [Download from Actions #261](https://github.com/GraderGamer2/NekoEdit/actions/runs/42266008250/artifacts/13527261651).
- The user's real GNOME/Mutter retest is still pending. CI verifies the existing mock scenarios and that the diagnostic build compiles; it does not establish why Mutter closes the socket or prove Maximize/resize now work.

## 2026-11-07 — Correct configured geometry, widen interactive resize, and hide the idle picker scrollbar

**Purpose:** Respond to the user's GNOME Wayland retest of Actions #251 and the separate picker observation. The user confirmed that title-bar movement now works, but Maximize still exits the app and edge resizing has no visible effect; the file-picker scrollbar also appeared displaced in directories that fit without scrolling.

### Source changes

- File picker: the scrollbar geometry previously set a full-height thumb but stored a top coordinate of zero when the visible list did not overflow. The picker now sets thumb height to zero, skips both track and thumb rendering, and does not treat the gutter as a scrollbar drag target when the entry count is at most 15.
- Window geometry: the client advertises its 480×360 minimum and 3840×2160 maximum surface geometry to xdg-shell. Positive compositor configure dimensions are accepted exactly within that backing-store range instead of silently clamping them to those limits. A compositor request beyond the declared pool limit is rejected rather than committing a buffer with geometry that does not match the configure.
- Renderer: rectangle and glyph writes are clipped against the active window dimensions, preventing fixed-position UI elements from writing outside a smaller configured surface.
- Interactive resize: the hit band is increased from 6 to 12 pixels. The client still sends compositor-managed `xdg_toplevel.resize` with the initiating pointer serial; no local resize simulation or launch-command change was introduced.

### Regression coverage

- The file-picker test opens a directory with fewer than 15 rows and verifies that no scrollbar thumb or track is rendered and the empty gutter cannot start a drag. The existing overflow fixture continues to exercise wheel scrolling and thumb dragging.
- The maximize test now applies a 1920×1080 configure and verifies matching buffer dimensions, stride, window controls, acknowledgement, and release-gated replacement.
- The resize test initiates a real protocol request 10 pixels from the edge (outside the old 6-pixel band), then checks right/top/bottom edges and all four corners with the correct xdg-shell edge flags.
- Both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` paths run the expanded suite.

### Verification

- GitHub Actions [Build and test #253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598) passed on [`f990dc0aa9b1d25617e0a385cafe23acbeef84f7`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7). The freestanding assembly/link and ELF checks, CLI smoke tests, complete Wayland mock suite, executable inspection, and artifact upload succeeded.
- Artifact: `nekoedit-linux-x86_64`, 29,780 bytes; artifact ID `13524092766`; expires 2026-11-13 17:17:47 UTC. [Download from Actions #253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598/artifacts/13524092766).
- The mock suite does **not** establish that Mutter's real maximize/resize behavior is fixed. The user still needs to test this artifact inside GNOME Wayland; the previous #251 artifact was confirmed to fail Maximize and interactive resize on that desktop.

**Implementation commit:** [`f990dc0aa9b1`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7).  
**Branch/PR:** `early-alpha`, PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.

## 2026-11-06 — Correct GNOME Wayland window-state sequencing and add interactive move/resize

**Purpose:** Stop all unrelated feature work and address the user's report that the current build exits when Maximize is clicked under GNOME, cannot be edge-resized, and only sends the window behind when Minimize is clicked.

### Source review and protocol diagnosis

- The previous client sent `xdg_toplevel.set_maximized`, `unset_maximized`, and `set_minimized`, then jumped to the generic keyboard-change path. That path immediately attached/damaged/committed the current buffer, even though the compositor had not yet supplied the toplevel/surface configure sequence for the requested state.
- Maximize/Restore/Minimize now return to the event loop after their xdg_toplevel request. They do not submit a stale-size frame. The next frame is scheduled by `xdg_toplevel.configure`, `xdg_surface.configure`, its `ack_configure`, and the existing release-safe buffer path.
- The previous implementation had no `xdg_toplevel.move` or `xdg_toplevel.resize` request. The client now retains the serial from `wl_pointer.button`; dragging blank title-bar space sends `move(seat=13, serial)`, and pressing within a 6-pixel edge/corner hit region sends `resize(seat=13, serial, edges)` using the xdg-shell edge enum.
- Resize requests are interactive compositor operations; NekoEdit does not locally guess a new size. The compositor supplies the configure dimensions, which are applied after `wl_buffer.release` if the prior frame is still owned.
- The app still sends `xdg_toplevel.set_minimized`. Whether and how GNOME presents minimized windows is a compositor/desktop policy; this client does not emulate minimizing by hiding or destroying its own surface.

### Regression tests added/changed

- The window-control test helper now expects the xdg_toplevel request only. It no longer treats an immediate attach/damage/commit using the old geometry as correct behavior.
- The maximize test emits a burst of toplevel configure events (with maximized and activated states) before the surface configure; the client must use the final geometry/state.
- The restore test sends configure while the maximized buffer is still busy, verifies the configure acknowledgement, and only then releases the old buffer. Reallocation/presentation must wait for that release.
- Added assertions for a title-bar move request with the original button serial and a left-edge interactive resize request with `resize_edge_left`. The resize configure is also delivered while the previous buffer remains busy.
- The tests run through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.

### Verification

- Commit: [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969).
- GitHub Actions [Build and test #251](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769) passed all workflow steps: freestanding x86-64 build/ELF checks, CLI smoke tests, complete Wayland mock integration, executable inspection, and artifact upload.
- The mock suite verified Maximize/Restore with deferred buffer replacement, title-bar move, edge resize request/serial/edge value, and the full existing file-picker/editor/protocol regressions through both transports.
- Artifact: `nekoedit-linux-x86_64`, 29,625 bytes, ZIP SHA-256 `3c3a5563fe033772d46bd9209cbfd9fd31a1ae950a69c5851e6813afba6de2c1`, artifact ID `13521663942`, expires 2026-11-13 16:46:27 UTC. [Actions #251 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769/artifacts/13521663942).

### Explicit limitation

- I could not run the executable inside the user's GNOME/Mutter session. Actions #251 proves the client-side build and mock protocol behavior, not the absence of a Mutter-specific crash on the user's machine. Manual GNOME testing of this exact artifact/commit is still required before the GNOME report can be marked resolved.
- No unrelated roadmap work, dependency changes, or launch-command changes were made. `./nekoedit --backend=wayland` remains the supported launch form.

---

## 2026-11-06 — Pass the complete two-transport Wayland and window-control suite

**Purpose:** Verify the inherited-WAYLAND_SOCKET descriptor-lifetime correction from [`69b63767d1bc`](https://github.com/GraderGamer2/NekoEdit/commit/69b63767d1bc3223ac9d300b3be056cc9c36c56f) and record the complete CI result.

### Actions #248 result

- [Build and test #248](https://github.com/GraderGamer2/NekoEdit/actions/runs/42252513357) completed with **success** on commit `69b63767d1bc3223ac9d300b3be056cc9c36c56f`.
- All workflow steps passed: toolchain inspection, freestanding x86-64 assembly/link and ELF checks, command-line smoke tests, Wayland protocol mock integration, executable inspection, artifact upload, and job cleanup.
- The full Wayland mock workflow passed through both connection mechanisms: `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- Both transport paths now complete the native picker file workflow and the app-drawn Minimize, Maximize, Restore, and Close interactions. The 1280×720 resize, release-gated buffer replacement, return to 800×480, and final Close/EOF checks all completed.
- The run also confirms the prior mock correction: the compositor releases maximized buffer 256 before the Restore click, so the test respects the client's buffer-ownership rule.

### Artifact

- Name: `nekoedit-linux-x86_64`
- Size: 29,427 bytes
- Artifact ID: `13520607975`
- Expiration: 2026-11-13 16:27:32 UTC
- [Open Actions #248 and download its artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42252513357/artifacts/13520607975)

### Scope and remaining manual validation

- No application source code or runtime dependency changed in this test-harness correction; the WAYLAND_SOCKET parent descriptor is closed immediately after the child inherits it.
- This confirms the mock-compositor integration suite, not compatibility with every real compositor. A separate manual run inside GNOME Wayland remains useful.
- The supported launch command remains `./nekoedit --backend=wayland`.

---

## 2026-11-06 — Close the parent copy of the inherited WAYLAND_SOCKET test descriptor

**Purpose:** Continue from [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419), which corrected the mock compositor's buffer-release ordering before Restore. Actions #247 then verified that the resize/control flow passed through `WAYLAND_DISPLAY`, but exposed a separate lifetime issue in the inherited-`WAYLAND_SOCKET` test.

### Actions #247 result

- [Build and test #247](https://github.com/GraderGamer2/NekoEdit/actions/runs/42251823911) used commit [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419).
- Toolchain setup, freestanding assembly/link/ELF checks, and CLI smoke tests passed.
- The complete file-workflow run over `WAYLAND_DISPLAY` passed, including app-drawn Minimize, Maximize, Restore, dynamic 1280×720 buffer replacement, restoration to 800×480, and the Close control.
- The following inherited-`WAYLAND_SOCKET` file-workflow run reached the explicit Close check but the mock compositor did not observe EOF before the test's thread-join deadline.

### Root cause and test correction

- The inherited transport is created with `socket.socketpair()`. The parent passes `client_endpoint.fileno()` to `subprocess.Popen(pass_fds=...)`, so the child inherits that descriptor.
- The parent previously kept its own `client_endpoint` copy open until the outer `finally`, which executes only after the compositor thread has been joined.
- The Close assertion in the fake compositor calls `client.recv(1)` and expects EOF after the child exits. An open duplicate of the same socket endpoint prevents EOF, even after NekoEdit closes its own descriptor. This is a test-harness descriptor-lifetime defect, not a failure in the application's Close request.
- The harness now closes the parent's copy immediately after successful `Popen` and sets `client_endpoint = None`. The child retains its inherited descriptor; when the child exits, the compositor can observe EOF as intended.
- The earlier buffer-256 release remains in place. No application source or launch behavior was changed.

### Verification and remaining validation

- Actions #247 remains a failed workflow overall because the inherited-socket EOF assertion did not complete, despite the successful `WAYLAND_DISPLAY` path and successful build/CLI checks.
- The descriptor-lifetime correction is included in the current branch update. A fresh Actions run is required to verify both transport paths.
- No real GNOME Wayland desktop test has been performed in this session; CI mock-compositor success will still need separate manual confirmation on the target desktop.
- `./nekoedit --backend=wayland` remains the supported launch form; no runtime dependency was added.

---

## 2026-11-06 — Add Wayland window controls and repair resize-test buffer release ordering

**Purpose:** Continue from the tested filename-autocomplete milestone on the live `early-alpha` branch. The repository's next implementation commit added app-drawn window controls and compositor-driven resize handling; the latest CI run exposed a missing buffer-release event in the mock workflow rather than a build failure.

### Repository state checked before the change

- Development branch: `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged into `main`.
- Autocomplete implementation [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519) was validated by [Actions #245](https://github.com/GraderGamer2/NekoEdit/actions/runs/42245683431), which passed all eight workflow steps.
- The branch then advanced to [`f516fc1a9b31`](https://github.com/GraderGamer2/NekoEdit/commit/f516fc1a9b316aa34a6c07533948822913469f02), adding Wayland title-bar controls and resize/reconfigure handling. [Actions #246](https://github.com/GraderGamer2/NekoEdit/actions/runs/42247690288) compiled/linked successfully and passed CLI smoke tests, but the mock Wayland integration test failed in the Restore sequence.

### Window-management implementation now present

- The initial surface remains 800×480. The renderer derives stride and editor/status geometry from the active window dimensions.
- The memfd mapping is bounded for a maximum 3840×2160 XRGB8888 surface; compositor-provided dimensions are clamped to 480×360 minimum and 3840×2160 maximum.
- The client captures `xdg_toplevel.configure` width, height, and maximized state, acknowledges `xdg_surface.configure`, and replaces the old `wl_buffer` only after the compositor releases it. The `wl_shm_pool` remains alive so the client can allocate replacement buffers from the same bounded mapping.
- The app-drawn title bar now exposes Minimize, Maximize/Restore, and Close controls using the corresponding xdg_toplevel requests or clean client shutdown.
- The integration scenario exercises each control, a 1280×720 maximize configure, buffer recreation/stride, restored 800×480 geometry, and close behavior.

### CI failure diagnosis and correction

- Actions #246 did not fail during assembly, linking, ELF checks, or CLI smoke tests. It timed out in `workflow_window_click(..., "restore")` while waiting for a surface attach.
- The mock had sent a 1280×720 configure and verified the new frame in buffer 256, but it did not send `wl_buffer.release` for that frame before simulating the Restore click. The client correctly kept the shared buffer busy and deferred repaint; the test incorrectly expected an immediate attach.
- Added the missing compositor-side `wl_buffer.release` event for buffer 256 before Restore. This makes the test respect the same buffer-ownership rule already followed by the application and the earlier picker-scrollbar test.
- No application-source workaround was added: the production release gate is the correct behavior and was not bypassed.

### Verification and remaining validation

- Actions #245 remains the passing validation for filename autocomplete.
- Actions #246 remains recorded as failed because of the mock-test sequencing defect described above. The corrected workflow is submitted with this change; its result and artifact must be recorded after GitHub Actions completes.
- No real GNOME Wayland desktop test was performed in this session. Mock-compositor success, when confirmed, will still not replace a manual desktop test.
- No third-party runtime dependency or launch-command change is introduced. `./nekoedit --backend=wayland` remains supported.

---

## 2026-11-06 — Strengthen zero-byte Open coverage for a non-first list row

**Purpose:** Investigate the user-reported case where opening an empty text file appeared to select another file. The active branch already contained zero-byte Open/Save tests and the completed scrolling, checkbox, and editable search-field implementation. The existing empty-file fixture, however, placed `empty.txt` at the first regular-file row. This follow-up tests the same operation with ordinary files before and after the empty target.

### Regression fixture change

- Added non-empty `aaa.txt` and `zzz.txt` fixtures around `empty.txt`, while retaining `inside.txt` and the hidden-file fixture.
- With hidden files disabled, the sorted regular-file order now places `empty.txt` at row 1, after `aaa.txt`; the Open-button test selects that second file row rather than row 0.
- The double-click route uses the same nonzero row. Both activation paths still verify the exact active path and `doc_length == 0`; the single-click/Open route then inserts one byte, saves with Ctrl+S, and checks that only that byte appears in `empty.txt`.
- Updated the separate `inside.txt` navigation/save regression to select its new row position after adding the surrounding fixtures.
- This is deliberately a test-hardening change, not a claim that a new assembly loader defect was found. Inspection of `load_document_from_path` confirmed that a successful zero-byte read sets `doc_length` and the gap-buffer start to zero. The pointer-selection path is now exercised against a nonzero row with neighboring regular files.

### Verification

- GitHub Actions [Build and test #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677) passed **all eight workflow steps** on test commit [`5e7d2d2158eb`](https://github.com/GraderGamer2/NekoEdit/commit/5e7d2d2158ebe560ab7153556e4e25672039bd3d): freestanding build/ELF checks, CLI smoke tests, complete Wayland mock-compositor integration, executable inspection, and artifact upload.
- The file-workflow test passed for both single-click/Open and double-click of `empty.txt` from row 1, with the exact active path and zero document length. The same integration sequence passed nested-file Open/Save, mouse-wheel scrolling, scrollbar dragging, editable location/search fields, and prefix matching.
- The same workflow also exercised the established Wayland, XKB punctuation/ONE_LEVEL, gap-buffer, UTF-8, selection, key-repeat, and protocol tests through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes, artifact ID `13513782459`, SHA-256 `79a0a6f56a7981ad443f0adaa75c521aa3521f48310d72d272778bb425f195ed`, expires 2026-11-13 15:10:30 UTC. [Download from Actions run #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677/artifacts/13513782459).

### Scope and remaining validation

- No application source or runtime behavior changed in this follow-up; no runtime dependencies were added. The wheel/scrollbar, checkbox, and editable path/search implementation is already present in the active `early-alpha` source and is rerun by #241.
- The mock compositor now covers the reported selection shape more closely, but it cannot reproduce every GNOME mouse/compositor interaction. The user's original desktop symptom remains **awaiting manual confirmation** against the #241 artifact.
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; no change was made to `main`.

---

## 2026-11-06 — Correct empty-file Open, add picker scrolling, and finish editable path/search fields

**Purpose:** Respond to picker testing feedback by verifying zero-byte Open behavior, adding mouse-wheel and scrollbar navigation, converting the hidden-files indicator into a normal checkbox, and making the location and filename/search fields genuinely editable. The implementation remains in the freestanding GNU assembly Wayland backend, with no third-party runtime dependency.

### Empty-file Open and stale-selection correctness

- Added a zero-byte `nested-dir/empty.txt` fixture and exercised both activation paths: single-click followed by the Open button, and double-click directly on the file.
- Each route checks the exact active document pathname and verifies `doc_length == 0`. The single-click route then types one byte, presses Ctrl+S, and verifies that the exact empty file now contains only that byte.
- Strengthened the selection/search state so keyboard movement refreshes the filename field from the newly highlighted regular file. Open confirmation uses the current explicit prefix-match state; when a typed prefix has no match, an older row selection is not silently reused.
- A successful edited-path navigation returns focus to the directory list. That keeps subsequent typing in the filename/search field rather than unexpectedly extending the location field.

### Mouse scrolling and checkbox interaction

- Routed the core Wayland `wl_pointer.axis` vertical-axis event into the picker. Smooth 24.8 fixed-point deltas are accumulated and converted into list-row movement without discarding fractional remainder.
- Added a proportional scrollbar thumb, track click/drag behavior, and a drag-state visual. The directory list remains capped at 128 entries with 15 rows visible at a time.
- Added a regression fixture with more than two viewport pages. It checks wheel-down by three rows, drag-to-bottom, and wheel-up by one row.
- The first checkbox revision left only the small box clickable; the label is now clickable too. Each new dialog starts with hidden files disabled, and the checkbox has a bordered square with a visible check mark when enabled.
- The scrollbar test harness was corrected to honor Wayland buffer lifetime: it releases the shared-memory frame after the drag redraw before requesting the separate pointer-release redraw. Earlier timeout/SIGPIPE failures were test-side buffer-release ordering, not a failure of wheel movement or thumb dragging.

### Editable location and filename/search fields

- The location and filename fields now have explicit byte cursors. Clicking positions the cursor at the nearest visible character; the text viewport follows the cursor horizontally when the field is longer than the available width.
- Both fields support insertion at the cursor, Left/Right, Home/End, Backspace, forward Delete, and Ctrl+A replacement. The UI draws the caret and a field-selection highlight.
- In Open mode, the filename field is labeled **SEARCH** and performs case-insensitive prefix matching against regular files in the current in-memory directory listing. A match selects and scrolls the first matching file into view. No match clears the previous selection; the text remains available as a literal path/name input rather than reusing an unrelated old row.
- In Save mode, the field remains **FILE NAME** and retains relative/absolute Save As and overwrite confirmation behavior.
- The path field can be edited in the middle and committed with Enter to navigate to that directory. The path is still passed directly to filesystem syscalls; no shell command or external file manager is involved.

### Regression tests and verification

- The expanded Wayland workflow verifies both zero-byte activation routes and the exact active path/document length, then checks typing and Ctrl+S against that same file.
- The same test sequence verifies wheel scrolling, proportional thumb geometry, thumb dragging, location-field mouse-positioned insertion and Backspace, explicit path navigation, filename prefix selection, mid-string insertion and Backspace, Home/End/Left, forward Delete, Ctrl+A replacement, and Enter opening the exact matching empty file.
- GitHub Actions [Build and test #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258) passed **all eight workflow steps** on head commit [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49): toolchain inspection, freestanding x86-64 build and ELF checks, CLI smoke tests, the full Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Run #235 exercised both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` test transports. The file-workflow observation confirms zero-byte Open through single-click/Open and double-click, wheel scrolling, scrollbar dragging, editable path navigation, cursor-based filename edits, Ctrl+A replacement, and filename prefix search.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes, artifact ID `13515385312`, SHA-256 `1afeefccb7c594100137e91538d30c0d8e661d026be964c956871c5a9eb64175`, expires 2026-11-13 15:00:57 UTC. [Download from Actions run #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258/artifacts/13515385312).
- Intermediate runs #224–#234 include failed or cancelled attempts while the tests were being calibrated. They exposed the BSS zero-initialization requirement, stale hidden-file test state, field-navigation focus handling, and Wayland shared-memory buffer-release ordering. The passing #235 result is the validation for the consolidated state; the intermediate history remains in GitHub Actions.

### Remaining limits and manual validation

- Path and filename editing remains ASCII-only. Non-ASCII filesystem names remain usable as raw filename bytes in the listing and filesystem calls, but non-ASCII typed input and Unicode glyph display are not supported.
- Clipboard paste is not implemented; it requires the Wayland data-device protocol and belongs in a separate clipboard milestone. There is no Shift-based partial text selection in these picker fields; Ctrl+A selects the whole field.
- Filename search is a case-insensitive prefix search over the current directory's loaded regular-file entries. It is not recursive, fuzzy, or an on-disk search index. Listings remain capped at 128 entries (15 visible rows).
- The picker does not follow symbolic links, does not ask before discarding an edited document on Open, and does not yet provide file filters, bookmarks, or incremental large-directory enumeration.
- CI uses a mock Wayland compositor. No real GNOME Wayland desktop smoke test has been performed for this updated picker. The prior shifted-symbol keyboard report also remains awaiting manual confirmation against a current artifact.

### Scope and commits

- The supported launch form remains `./nekoedit --backend=wayland`; the Makefile build output remains `./build/nekoedit`.
- The code and tests added no third-party runtime or shared-library dependency. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; no change was made to `main`.
- The picker/scroll/edit/test commits from 2026-11-06 14:39–15:00 UTC are individually recorded in [`COMMIT_INDEX.md`](COMMIT_INDEX.md).

---

## 2026-11-06 — Complete and stabilize the native directory-browser file picker

**Purpose:** Resume NekoEdit development from the repository's existing picker implementation, inspect the active source and regression tests, and bring the native Open/Save directory browser to a fully passing automated integration state without changing the established launch command or adding runtime dependencies.

### Implementation brought to a verified state

- The active `early-alpha` source already contained the native in-window picker work: a modal Open/Save browser rendered by the Wayland software renderer, with a path field, Up and Home navigation, a hidden-files toggle, directory-first/file-second listing, filename field, and Cancel/Open actions.
- The picker uses direct Linux filesystem syscalls and keeps the file workflow inside the freestanding assembly application. No GTK, Qt, portal, D-Bus, external file manager, C runtime, or third-party shared-library dependency was added.
- Open mode supports listing selection, double-click directory entry, double-click regular-file opening, and keyboard activation/navigation. Save mode uses the same browser, supports relative and absolute destinations, and asks before replacing an existing target.
- The existing mock-compositor workflow covers Untitled Save, named Save, Open, nested-directory navigation, hidden-file visibility, Save As, overwrite confirmation/cancellation, missing/oversized Open rollback, failed Save As rollback, and Escape cancellation.

### Defects found and corrected

- Early picker tests sampled an unlit column in the first row of the H/N glyphs. The final assertions sample an unobscured lit glyph column and, more importantly, also inspect the actual active path and loaded document byte. This avoids treating a pixel coincidence as proof that the correct file opened.
- Re-entering a directory could carry the previous directory's double-click row index and timestamp into the new listing. A first click on row zero could then be treated as a second click from the prior directory. `picker_scan_directory` now resets both click-history fields every time it rebuilds a listing. This is implemented in [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82).
- The strengthened test exposed stale bytes in `picker_target_buffer`: the relative filename-copy loop stopped at the source NUL but failed to write a new NUL into the destination. Opening a shorter name after a longer one could therefore generate a target such as `inside.txtte`. The loop now explicitly terminates the new target path. This is implemented in [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd).
- Test-only process-memory diagnostics were added to report the current document path, target path, picker selection, and loaded bytes when an integration assertion fails. The fixture also correctly trims those values at actual NUL bytes. These diagnostics made the mis-navigation and stale-path failures distinguishable from rendering assertions.

### Regression history and verification

- Intermediate Actions runs **#199–#207** failed during test development. The failures exposed invalid glyph-pixel samples, stale double-click state across directory scans, and the missing target-path terminator; a diagnostic-fixture NUL-escaping mistake was also corrected. Those failed runs are retained in GitHub history rather than being represented as successful validation.
- GitHub Actions [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800) passed **all eight workflow steps** on implementation commit [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd): toolchain inspection, freestanding x86-64 build and ELF checks, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload.
- The file-workflow scenario specifically verified opening the hidden file, navigating Up and re-entering the nested directory, opening the exact `inside.txt` path, replacing its document contents, and saving the exact nested file with Ctrl+S. It also verified Save As overwrite confirmation/cancellation and rollback on failed or oversized operations.
- Artifact: `nekoedit-linux-x86_64`, 24,492 bytes, artifact ID `13511065251`, SHA-256 `f157014623b7beb16b954a67a7cdcdc70304371cdeefb36f4615e0df35a62782`, expires 2026-11-13 14:13:07 UTC. [Download from Actions run #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800/artifacts/13511065251).

### Remaining limits and manual validation

- The picker currently stores at most 128 entries per directory listing and displays 15 rows at a time. It is a document Open/Save utility, not a general-purpose file manager.
- Path and filename input is currently ASCII-only and supports simple append/backspace/clear behavior; caret repositioning, in-field insertion, and clipboard paste are not implemented. Non-ASCII filename bytes remain available to filesystem operations but render through the safe replacement glyph path.
- Unsaved-document confirmation, richer path/name editing, symlink navigation, file filters, and clipboard integration remain unfinished.
- CI uses a mock Wayland compositor. No real GNOME Wayland desktop smoke test has been performed for this picker build. The previously reported shifted-symbol keyboard regression also remains awaiting confirmation against a current artifact in the user's desktop session.

### Scope and commits

- The supported launch form remains `./nekoedit --backend=wayland`; the Makefile build output remains `./build/nekoedit`.
- The picker and regression work added no runtime dependency and did not merge PR #2. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, targeting `main`.
- The individual picker implementation, regression-test, diagnostic, and correction commits are indexed in [`COMMIT_INDEX.md`](COMMIT_INDEX.md), including the final click-state fix and target-path termination fix.

---

## 2026-11-06 — Correct XKB ONE_LEVEL handling and expand shifted-punctuation tests

**Purpose:** Address the reported case where ordinary keys worked but many shifted punctuation keys displayed `?`. Inspection found that the bounded XKB type classifier collapsed ONE_LEVEL into the generic non-alphabetic path, so a one-symbol key could select an empty Level 2 slot while Shift was held.

### Implementation

- Added an explicit ONE_LEVEL type flag in `src/backend/xkb.S`. The lookup now forces Level 1 for ONE_LEVEL keys regardless of Shift, Caps Lock, or LevelThree state, instead of attempting to read a nonexistent second level.
- Kept the existing ALPHABETIC and three-/four-level handling unchanged. This is a targeted correction within the project's bounded XKB text-v1 subset, not full libxkbcommon-equivalent XKB support.
- Updated `README.md`, `docs/WAYLAND_BACKEND.md`, and `CHANGELOG/CURRENT_STATUS.md` to describe the currently supported common ONE_LEVEL/ALPHABETIC/THREE_LEVEL/FOUR_LEVEL families.

### Regression coverage and CI

- Extended `tests/wayland_mock.py` with actual Wayland key events for shifted grave/tilde, bracket/brace, semicolon/colon, apostrophe/quote, comma/less-than, period/greater-than, and slash/question keys, plus a ONE_LEVEL keypad key while Shift is active.
- The first CI attempt, [Build and test #185](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223115089), failed in the new test at the bracket key. The build/ELF verification and CLI smoke tests had passed; the Wayland integration test exposed incorrect fixture metadata: the added entries used raw evdev numbers, while the XKB fixture must declare the XKB keycode (evdev + 8).
- Corrected the fixture in [commit `b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b), also removing an accidental duplicate AB09 entry. The physical key events still use evdev keycodes as required by Wayland.
- The corrected [Build and test #186](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121) passed all eight workflow steps on `b260457007589469abdb492358b7581558c0cc5b`: freestanding build/link, ELF dependency checks, CLI smoke tests, complete Wayland mock integration, executable inspection, and artifact upload.
- The XKB scenario verified the evdev-to-XKB +8 lookup, group switching, Shift/LevelThree, all twelve shifted number-row symbols, the added shifted punctuation rows, ONE_LEVEL Shift behavior, and the exact saved document bytes. The complete suite also passed the UTF-8, gap-buffer, file-workflow, protocol-error, and sparse-keymap fallback scenarios.
- Artifact from #186: `nekoedit-linux-x86_64`, 19,009 bytes, SHA-256 `a27b9571cf9752c947ff7700f012320316db4e720bba195773ec8647644a8d7b`, artifact ID `13504771747`, expires 2026-11-13. [Run #186 artifacts](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121/artifacts/13504771747).
- The post-sync [Build and test #187](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584) also passed all eight steps on merge commit `3a1b2bb9bed50e15bbd37da634505fead4f7724c`. Artifact ID `13504384311`, 19,009 bytes, SHA-256 `f0b63d507d2057dc46c8524ffc3e4f15d01dc9b1f09005ffcb3bc700acde98e5`, expires 2026-11-13. [Run #187 artifacts](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584/artifacts/13504384311).

### Manual verification still needed

- The latest user-reported desktop issue (most shifted punctuation showing `?`) has not yet been manually re-tested against this patched artifact in the user's GNOME Wayland session. The mock compositor validates a controlled synthetic keymap, not every installed layout or GNOME modifier map.
- After downloading the #186 artifact, run it with the unchanged command `./nekoedit --backend=wayland` and test the full shifted punctuation sequence on the actual active layout. Report which physical keys still fail, if any. Do not call the user's desktop regression fully resolved until this check succeeds.

### Scope

- No third-party runtime libraries or external dependencies were added. The launch interface and document model are unchanged.
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, unmerged, and mergeable with a clean state at the time of this update.
- The changelog update was committed as [`8fa6e2282703`](https://github.com/GraderGamer2/NekoEdit/commit/8fa6e2282703d164dcab2ecb096b9416523957ac). Because `main` contained separate changelog-only commits, the PR briefly became dirty. Created synchronization merge [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c), with `main` as first parent and the previous `early-alpha` head as second parent; it preserved the entire development tree and brought the PR back to 0 commits behind / clean mergeability.
- Commits: [`267ef0557b8e`](https://github.com/GraderGamer2/NekoEdit/commit/267ef0557b8e00bd01eae004ed346dde16977e3f) (parser + regression test + docs); [`b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b) (fixture keycode correction).

---

## 2026-11-06 — Open replacement pull request #2 for early-alpha

**Purpose:** Attach the renamed development branch to an active review so GitHub's recent-push prompt has a pull-request destination. The user explicitly authorized opening a pull request if required to clear the repository notification.

### Pull request

- Opened [PR #2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2), from `early-alpha` into `main`. It replaces closed, unmerged PR #1 as the active review for this development branch.
- At creation, GitHub compared the branch as 185 commits ahead and 4 behind main; the PR contained 12 changed files, 6,804 additions, and 235 deletions.
- PR #2 is open and not draft. No merge was attempted.
- After creation and its CI run, GitHub reported `mergeable=true` and `mergeable_state=clean`.

### Validation

- PR-triggered GitHub Actions [Build and test #179](https://github.com/GraderGamer2/NekoEdit/actions/runs/42220633279) completed successfully on head commit `108d7df1e024e74c653c5bb4cdbe52fb1d1289bf`. All eight workflow steps passed, including the freestanding x86-64 build/ELF verification, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload.
- No application source or tests changed after implementation-code tip [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0); the tested head contains later changelog-only maintenance commits.
- The mock compositor does not replace a real GNOME Wayland smoke test.

### Outstanding user-reported keyboard regression

- In the latest user test of a newer Actions build, normal alphabetic keys worked again, but most shifted punctuation/symbol keys displayed `?`. The user reported only a subset (including `<>`, `:"`, and `()`) rendered correctly.
- The exact Actions run/artifact for that manual report was not identified. Do not claim the regression is fixed because automated mock-compositor tests pass.

### Scope

- This is PR creation and repository documentation only; no editor implementation, tests, or build files were changed for this task.
- PR #2 remains open and unmerged. Further feature development remains paused pending explicit user authorization.
- The PR-status documentation was committed on `early-alpha` as [`fa4725159a20`](https://github.com/GraderGamer2/NekoEdit/commit/fa4725159a202130c5fdd8d2123d1e10be35cadc) and mirrored to `main` as [`92fa00fca547`](https://github.com/GraderGamer2/NekoEdit/commit/92fa00fca547f4b5d947a645bce345f59046e9f6). Both commits touch only the four CHANGELOG files.
- The index/log follow-up commits are [`156e0ab2e53f`](https://github.com/GraderGamer2/NekoEdit/commit/156e0ab2e53fcdbcb4c8403154f577e1e41351c5) on `early-alpha` and [`4795856b1713`](https://github.com/GraderGamer2/NekoEdit/commit/4795856b1713c39103f56f3ba944f0723e3b4218) on `main`.

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


---

## 2026-11-06 — Scope Open-mode search to the current directory

**Purpose:** Correct a file-picker state leak reported during manual use, where opening an empty text file could appear to activate a different file. Preserve the existing scrollable picker, checkbox, and editable path/search interaction.

### Diagnosis and implementation

- Inspection found that picker_scan_directory reset the selected row but did not clear the Open-mode Search field when rebuilding the listing. A no-match query could therefore survive a location change. Since Open previously allowed an unmatched field value to be treated as a literal path/name regardless of which control had focus, pressing the footer Open button after navigation could open a same-named file from the new directory even though no row was selected.
- Open-mode directory scans now clear the scoped search text, caret/view state, match flag, and select-all state. Save-mode filename text is deliberately preserved during directory scans.
- picker_confirm_action now distinguishes list focus from Search-field focus. With list focus, Open can only use the explicitly selected regular-file row. A literal path/name remains supported only while the Search field has focus.
- Updated docs/FILE_PICKER.md to make the search scope, explicit-selection rule, and executable-file behavior clear. The picker lists regular files without filtering by extension or execute permission; it treats a selected executable-bit file as document bytes and never executes it.

### Regression coverage

- Added a stale.txt fixture inside the nested directory. The regression test enters stale.txt as an unmatched search in the parent directory, navigates into the directory that actually contains that file, and clicks Open with no selected row.
- The test asserts that directory navigation clears the old query, Open leaves the picker open without changing the active document, and an explicit row-1 selection then opens the exact zero-byte empty.txt.
- The earlier row-1 zero-byte Open checks remain in place for both single-click-plus-Open and double-click activation, including the exact active path and empty document length.

### Verification

- GitHub Actions [Build and test #243](https://github.com/GraderGamer2/NekoEdit/actions/runs/42241453789) passed all eight workflow steps on [51a9b4d491665406ccc695d9724889bc6834ff66](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66).
- Passed: toolchain inspection, freestanding x86-64 build/ELF checks, command-line smoke tests, the complete Wayland mock-compositor suite (including the new stale-query regression), executable inspection, and artifact upload.
- Artifact: nekoedit-linux-x86_64, 27,249 bytes; SHA-256 d5549748f2e58f95da6cc176d630c087af15efd4b7b298ce6106dce5c484c664; artifact ID 13515965431; expires 2026-11-13 15:16:20 UTC.
- A local build was not run in this runtime because outbound DNS access to GitHub was unavailable; CI built and tested the exact pushed commit.

### Remaining validation and constraints

- The user has not yet re-tested this patch in the real GNOME Wayland desktop. The mock-compositor regression is automated evidence for the specific stale-query failure mode, not a claim that the user's manual symptom has been confirmed fixed on their machine.
- Existing picker constraints remain: 128 entries maximum, 15 visible rows, ASCII-only path/name typing, no clipboard paste or partial Shift selection, and no symbolic-link traversal. Search remains a case-insensitive prefix match over the current directory's loaded regular-file entries.
- Mouse-wheel scrolling, the proportional draggable scrollbar, the bordered Show hidden checkbox, and editable location/name fields were already implemented and remain unchanged. No runtime dependencies or launch-interface changes were introduced.

**Source/test/documentation commit:** [51a9b4d49166](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66).  
**Branch/PR:** early-alpha, PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.


---

## 2026-11-07 — Render parsed TrueType glyphs in the Wayland surface

**Implementation**
- Added `src/font/rasterizer.c` to the freestanding build. It consumes the SFNT decoder's fixed outline arrays and converts TrueType contours into bounded polylines.
- Correctly handles cyclic contour starts, on-curve points, quadratic controls, and implicit on-curve midpoints between successive off-curve points. Quadratic segments use four deterministic subdivisions; flattened paths are limited to 16,384 points.
- Added non-zero winding rasterization with 4×4 subpixel coverage and a 32×32 maximum bitmap. A 128-entry glyph-ID LRU cache avoids repeated decoding during whole-surface repaints.
- Routed Wayland's glyph painting through the TrueType bitmap renderer when a font is loaded; pixels are alpha blended into the SHM framebuffer. Kept the embedded 5×7 bitmap as a safe fallback.
- Added default font attempts for common Debian font paths and retained `NEKOEDIT_FONT` as an explicit override. Document text now passes the first UTF-8 scalar of each grapheme to cmap lookup/rasterization.
- Extended the deterministic fixture with a two-control quadratic outline and startup probes for both line-only and curved glyphs.

**Current boundary**
- This enables real font glyphs to become visible, but layout is intentionally still fixed at 8×12 cells and the rasterizer currently uses a 12-pixel em. Variable-width advances, kerning, shaping, combining-mark placement, Settings font selection, and Settings font-size controls remain later steps.
- The embedded bitmap remains available if no supported system font is found, or the requested outline cannot be rasterized.
- CI still must validate the exact source commit before this milestone is considered complete.


---

## 2026-11-07 — Connect TrueType rasterization to the visible Wayland renderer

**Scope:** move the font work from parsed outlines to visible framebuffer glyphs without adding third-party runtime libraries.

### Rendering pipeline

- Added `src/font/rasterizer.c` as a freestanding compilation unit. It is compiled with `-ffreestanding`, no builtins, no stack protector, no PIE, no red zone, and no unwind metadata; the final ELF remains static with no interpreter or dynamic dependencies.
- Added TrueType contour flattening for on-curve vertices, straight edges, off-curve quadratic controls, cyclic contour starts, and implied on-curve midpoints between consecutive off-curve controls. Quadratic curves use four deterministic subdivisions and flattened outline storage is capped at 16,384 points.
- Added bounded non-zero-winding fill with 4×4 subpixel coverage sampling. The output is a grayscale glyph bitmap capped at 32×32 pixels.
- Routed Wayland's `draw_glyph` path through the rasterizer when a font is loaded. Glyph coverage is alpha-blended into the compositor's shared-memory surface, and a 128-entry glyph-ID LRU cache avoids repeated decoding/rasterization on repaint. The embedded 5×7 bitmap remains as a fallback.
- Font loading tries an explicit `NEKOEDIT_FONT` path first, then common Debian locations for DejaVu Sans Mono, Liberation Mono, and DejaVu Sans. This is deterministic path probing rather than a recursive font discovery service and does not use Fontconfig.
- The document drawing path decodes the first Unicode scalar of each grapheme cluster before cmap lookup. Full grapheme shaping is not implemented: combining marks, variation selectors, ZWJ sequences, ligatures, kerning, bidirectional text, and complex scripts remain unsupported.

### Regression coverage and verification

- Extended the deterministic synthetic SFNT fixture with a quadratic glyph containing consecutive off-curve points. It validates nonzero raster coverage for both a straight-edged glyph and a curve requiring an implied midpoint.
- Added a Wayland framebuffer assertion: a one-character document rendered with the synthetic font must contribute antialiased glyph pixels to the actual shared-memory buffer.
- Preserved the legacy fixed-coordinate bitmap UI tests with the test-only `NEKOEDIT_DISABLE_FONT=1` switch; the dedicated font test removes that switch and points `NEKOEDIT_FONT` at its generated fixture.
- The initial curve-fixture attempt incorrectly set the Y deltas to zero. The fixture flags/delta encoding were corrected; the successful CI test covers the intended curve rather than merely accepting a non-empty straight contour.
- GitHub Actions [Build and test #368](https://github.com/GraderGamer2/NekoEdit/actions/runs/42347799006) passed all eight workflow steps on [`61b0d415031c`](https://github.com/GraderGamer2/NekoEdit/commit/61b0d415031c14158b15ad99dd3dfc0209d452a7). Artifact `nekoedit-linux-x86_64`: 53,890 bytes, SHA-256 `eb1ae5c10ee5967f9f173a5804963c465f016516e7b8481d9892a7230a0350bc`, ID `13564486238`, expires 2026-11-14 06:37:10 UTC.

### Known boundaries

- The editor still advances in fixed 8-pixel cells and renders at a 12-pixel em. Horizontal metrics, variable-width layout, line reflow, Settings font selection, and font-size controls are not integrated.
- TrueType hinting instructions are not executed. OpenType CFF/CFF2 outlines, variable fonts, kerning, shaping, glyph substitution, mark positioning, bidirectional layout, color glyph layers, and Wayland text-input/IME remain unsupported.
- The rasterizer rejects oversized or malformed outline data under explicit limits; affected glyphs fall back to the embedded bitmap.
- GitHub Actions validates the mock Wayland protocol/framebuffer. A manual GNOME/Mutter desktop smoke test after this renderer change remains outstanding.


---

## 2026-11-07 — Integrate proportional font advances and vertical line metrics

**Scope:** finish the first end-to-end metric-aware text-layout path after connecting the TrueType rasterizer to the Wayland software framebuffer. This work keeps the dependency-free parser/rasterizer architecture and does not add a runtime library.

### Horizontal layout and interaction

- Exposed the parser's `hmtx` advances to a shared pixel-advance helper. At the fixed 12-pixel em, advances are rounded to the nearest pixel and bounded to 1–32 pixels; the legacy 8-pixel advance remains the no-font/invalid-metric fallback.
- Replaced fixed eight-pixel assumptions in document measurement and rendering with the same advance source. Soft wrapping, visual-row counts in the per-line/Fenwick index, byte/visual mapping, pointer hit-testing, caret placement, and text painting now operate in pixel coordinates.
- Updated selection painting to use each grapheme's measured advance and the same wrap decisions as the document renderer. Picker and path-prompt text also use font advances rather than being laid out as fixed bitmap cells.
- Corrected the pointer hit-test so the helper's returned advance cannot overwrite the pointer's target X coordinate. Regression coverage checks the midpoint decision against a mixed 8px/5px synthetic font and verifies the resulting caret offset, not private tracing state.
- Removed the temporary pointer/visual debug globals and snapshot writes in [`3bc0b93a9994`](https://github.com/GraderGamer2/NekoEdit/commit/3bc0b93a999402400111b75a8644307d6ece3141). The hit-test retains its target coordinate and glyph advance in ordinary preserved/local state; the test still asserts `doc_cursor == 2` and the indexed line's pixel-width/visual-row record.

### Vertical metrics

- Added parsing of the signed TrueType `hhea.lineGap` field alongside ascent and descent.
- Added one runtime document line-pitch value shared by window viewport geometry, visible-row count, pointer Y-to-row mapping, document rendering, selection rectangles, and caret placement. It scales `ascent - descent + lineGap` to the fixed 12-pixel em, rounds upward, and clamps to 12–32 pixels. The no-font/fallback path remains 12 pixels.
- Strengthened the deterministic SFNT fixture: ascent 900, descent −300, and lineGap 100 at 1000 units/em must produce a 16-pixel row pitch and 23 visible rows in the 800×480 test surface. The framebuffer assertion checks the final glyph on the second wrapped visual row at its new vertical position.

### Build correction and verification

- The first metric-layout commit, [`f6d735b21549`](https://github.com/GraderGamer2/NekoEdit/commit/f6d735b215493d7a67759de2f0aa269fc66d5e21), placed a nonzero initial value in a `.bss` declaration. GitHub Actions [Build and test #399](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355027188) correctly rejected it at assembly time. The follow-up [`beac1f4a9622`](https://github.com/GraderGamer2/NekoEdit/commit/beac1f4a96229817bc3444fd035330d12914cd53) zero-initializes that storage; window geometry computes the fallback or font-derived value before use.
- GitHub Actions [Build and test #400](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260) passed all eight substantive checks: freestanding assembly/link and ELF verification, CLI smoke tests, the full Wayland mock-compositor suite, executable inspection, and artifact upload. The test verifies metric-derived row geometry as well as prior editor regressions.
- Artifact [`nekoedit-linux-x86_64`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260/artifacts/13567395102): 54,527 bytes, artifact ID `13567395102`, expires 2026-11-14 08:20:56 UTC. No artifact SHA-256 was recorded in the returned Actions metadata.

### Current boundaries

- Runtime em size remains 12 pixels; the metric-derived line pitch varies within 12–32 pixels. Font and font-size menus, runtime font switching/resizing, glyph-cache invalidation for preference changes, and persistent preferences are not implemented.
- The loader uses explicit `NEKOEDIT_FONT` first, then three deterministic common Debian paths; recursive system-font discovery and family/style selection are not implemented.
- Only the first Unicode scalar of each grapheme is sent through cmap/rasterization. Kerning, GSUB/GPOS, ligatures, combining-mark placement, bidirectional layout, complex scripts, CFF/CFF2, variable/color fonts, hinting, Unicode keyboard text input, and IME remain unsupported.
- The latest automated test validates a mock Wayland compositor/framebuffer. Manual GNOME/Mutter smoke testing of the proportional font layout and vertical metrics has not been performed.


---

## 2026-11-07 — Documentation consistency and branch-head revalidation

- Refreshed `docs/RENDERING.md` to describe the active software renderer, deterministic font-path loading, bounded TrueType parser/rasterizer, proportional horizontal advances, hhea-derived vertical line pitch, and current shaping/input limitations. Updated `README.md`, `docs/ARCHITECTURE.md`, `CURRENT_STATUS.md`, and `PROJECT_HISTORY.md` so none describes the editor as fixed-width or treats the renderer as future work.
- Reconstructed and appended the 103 commits made after the last entry in the historical commit index, preserving diagnostic and test commits as well as feature commits.
- Documentation commits: [`1e58f0400f07`](https://github.com/GraderGamer2/NekoEdit/commit/1e58f0400f07d309a0eb65c6a2db2907b24e139c) and [`035d2424226a`](https://github.com/GraderGamer2/NekoEdit/commit/035d2424226a2bea1b8b8d1f2e7dd5c0c9a3dc59). The PR #2 description was updated to reflect metric-aware layout and current limitations.
- Actions [#401](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355483305), on the first documentation commit, built the ELF and passed CLI smoke tests but the Wayland mock integration exceeded its 20-second process timeout during keyboard input; the fake compositor then reported a broken pipe after the timed-out client was terminated. This run did not complete the integration suite.
- Actions [#402](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355555895) passed all eight substantive checks on documentation-only branch head [`035d2424226a`](https://github.com/GraderGamer2/NekoEdit/commit/035d2424226a2bea1b8b8d1f2e7dd5c0c9a3dc59), with no intervening source-code change. The timeout was not reproduced. Artifact [`nekoedit-linux-x86_64`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355555895/artifacts/13567202549): 54,527 bytes, artifact ID `13567202549`, expires 2026-11-14 08:27:38 UTC.


---

## 2026-11-07 — Repeat full workflow after documentation refresh

GitHub Actions [Build and test #403](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355664022) passed on [`55a96a9e999a`](https://github.com/GraderGamer2/NekoEdit/commit/55a96a9e999a5ad2ab14bd2a0f3dcf0c444ea865), a documentation/changelog-only commit after #402. The complete freestanding build, CLI smoke, Wayland mock integration, ELF inspection, and artifact upload stages succeeded. This is a second successful full workflow after the non-reproduced #401 20-second mock-test timeout; no executable source change was made between #400 and #403. Artifact [`nekoedit-linux-x86_64`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355664022/artifacts/13567696113) is 54,527 bytes, ID `13567696113`, and expires 2026-11-14 08:29:10 UTC.


---

## 2026-11-07 — Settings refinements, Wayland clipboard, and undo/redo

### Settings behavior and independent UI font size

- Changed document font-size steppers so increment/decrement no longer closes the Settings dropdown. Repeated clicks work without reopening it, including when the configured size reaches either bound.
- Added a separate UI font-size value, defaulting to 10px and adjustable from 8–14px in one-pixel steps. Document font remains 8–24px in two-pixel steps. UI-size changes affect ordinary interface text metrics and raster size without mutating document font metrics or the line index; picker-specific height fitting remains separately scaled.
- Expanded the Settings integration regression to exercise repeated button clicks while the dropdown stays open, verify both bounds, and assert that changing UI size does not change document size. Actions [#432](https://github.com/GraderGamer2/NekoEdit/actions/runs/42367881187) passed all workflow stages.

### Wayland clipboard integration

- Added `src/backend/clipboard.c` and connected it to `wl_data_device_manager`, `wl_data_device`, `wl_data_source`, and `wl_data_offer`. Added Ctrl+C, Ctrl+X, and Ctrl+V for the document editor.
- Copy/cut allocate independent immutable snapshots rather than borrowing bytes from the gap buffer. Cut publishes the source first and deletes the selection only after ownership requests succeed. MIME targets include `text/plain;charset=utf-8` and `text/plain`; Paste prefers the UTF-8 type and inserts received bytes at the caret or over the active selection.
- Added asynchronous pipe state machines to the existing poll loop: four outgoing send slots and one incoming receive slot, nonblocking reads/writes, bounded 16 KiB chunks, and a 64 MiB payload ceiling. Transfers handle short reads/writes, retryable errors, EOF and peer closure without blocking keyboard dispatch.
- Initial CI iterations exposed test-fixture newline/NUL escaping, an unrelated caret-pixel assertion unsuitable for the clipboard fixture, and a dispatcher branch that skipped the clipboard handler for non-keyboard objects. These were corrected and retained as explicit regression context; none of the actual copy/cut/paste assertions were removed.
- The end-to-end mock test uses a separate receiver for Copy/Cut, verifies that copied bytes remain available after Cut empties the document, and simulates an external MIME offer for Paste. Actions [#437](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369161877) passed the full workflow. Clipboard integration is currently Wayland-only; X11 selection support remains planned.

### Bounded undo/redo history

- Added `src/editor/history.c`, a freestanding/no-libc snapshot manager with independent mmap-backed states. Pre/post input checkpoints group a key or clipboard paste into one history operation. The history records bytes, caret position and selection state, and resets after a successful document load.
- Added Ctrl+Z Undo, Ctrl+Y Redo, and Ctrl+Shift+Z Redo. A content revision counter prevents navigation-only events from creating history entries; a same-revision checkpoint refreshes baseline caret/selection metadata. A new edit after Undo clears the redo branch.
- Explicit limits: 16 Undo/Redo states per stack, 32 MiB total retained snapshot mappings, and 4 MiB per snapshot. A document beyond the snapshot ceiling remains editable, but a full snapshot history is unavailable for that state.
- The integration test verifies selection replacement, exact Undo/Redo bytes, caret/selection restoration, collapsing the restored selection before a new edit, and Redo invalidation after branching. An intermediate #439 failure was a test expectation error: it expected the next typed character to append even though Undo correctly restored an active full-document selection. The test now verifies that selection and explicitly collapses it before typing.
- Actions [#440](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369791425) passed build/ELF verification, CLI smoke tests, the full Wayland mock suite, executable inspection, and artifact upload on branch tip [`67a7e5c66603`](https://github.com/GraderGamer2/NekoEdit/commit/67a7e5c666037fc9823bd16362ad4d2439622f48). Artifact [`13572958390`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369791425/artifacts/13572958390): 61,359 bytes, SHA-256 `e8d1c2027d934efa7dc7661819c28de22af7538a23c5c07eec00ae939d45a2e7`, expires 2026-11-14. This is mock-compositor verification only; manual GNOME/Mutter verification remains outstanding.

### Roadmap handoff

- Settings steppers, Wayland document clipboard, and bounded Undo/Redo are now implemented. The next major editor-core milestone is horizontal scrolling, which should be designed together with soft-wrap behavior, text-origin offsets, selection/caret clipping, pointer hit-testing, and scrollbar/viewport policy.
- After that, continue runtime font-family/file switching and persistent preferences, then non-ASCII keyboard text/IME and fuller shaping, output/fractional scaling and multi-buffer scheduling, and X11.
