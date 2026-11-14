## 2026-11-14 — latch pending Wayland buffer generations across configure (CI PASS #947)

Implementation/test/docs change on early-alpha:
- Preserve an existing pending scale/transform rebuild across an unchanged xdg_surface.configure.
- Exercise both occupied SHM slots, rapid fractional-scale updates, a preferred transform change, an unchanged configure, a logical resize, reverse-order releases, and final generation geometry/pixel rendering.
- Keep wl_buffer.release ownership separate from wl_callback.done frame pacing.

Implementation [f7191c4](https://github.com/GraderGamer2/NekoEdit/commit/f7191c45277ed9bf29cd741951c91744177d18a6); test-harness correction [7d33087](https://github.com/GraderGamer2/NekoEdit/commit/7d330870971be5d5fa16dfcedb4e80658c4ddb34). Actions [#947](https://github.com/GraderGamer2/NekoEdit/actions/runs/43572916550) passed the full workflow, including the new compositor-ownership and generation-coalescing regression.

---

## 2026-11-14 — exact fractional Wayland backing raster (CI PASS #945)

| Commit | Subject |
|---|---|
| [3bbdd8876d11974e307718cae02da92ca52bf6a2](https://github.com/GraderGamer2/NekoEdit/commit/3bbdd8876d11974e307718cae02da92ca52bf6a2) | feat: rasterize exact fractional Wayland scales |
| [82757c0eef0392b23592ab7b17f975920b8c11a9](https://github.com/GraderGamer2/NekoEdit/commit/82757c0eef0392b23592ab7b17f975920b8c11a9) | fix: zero-initialize fractional raster state |
| [f5368cd32ca02cee9091b3b48eaf6049c01ab87c](https://github.com/GraderGamer2/NekoEdit/commit/f5368cd32ca02cee9091b3b48eaf6049c01ab87c) | test: sample glyphs across fractional raster pixels |
| [9e3987e36ed542873126aa433dcf796b28759a53](https://github.com/GraderGamer2/NekoEdit/commit/9e3987e36ed542873126aa433dcf796b28759a53) | docs: describe exact fractional Wayland raster |

Actions [#945](https://github.com/GraderGamer2/NekoEdit/actions/runs/43569752292) passed all 17 workflow steps, including the real Wayland protocol mock coverage and nested GNOME Shell/Mutter integration.

The regression matrix covers preferred scales 90/120 through 210/120, exact physical backing geometry, half-away-from-zero rounding under a quarter-turn transform, logical viewport/damage coordinates, and protocol buffer scale 1. The live user GNOME session and mixed-DPI output transition still require hands-on testing.

---

