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

The new mock removes both globals after mapping, checks their destructor requests, then sends another per-surface preferred_scale event and a toplevel resize. It verifies the retained child proxies still drive a 180/120 physical backing buffer and update the 640×360 logical viewport destination. This scenario uses virtual protocol outputs and needs no second monitor. CI validation is pending.
