## 2026-11-14 — printable-ASCII reverse grapheme fast path (CI PASS #952)

- [43190c1e1c0e](https://github.com/GraderGamer2/NekoEdit/commit/43190c1e1c0e6893e6cc2ab453c3bf1bcf881c92) — `perf: fast-path adjacent printable ASCII grapheme reverse`
- `doc_grapheme_prev` returns the prior byte directly only when both adjacent bytes are printable ASCII; CR/LF, controls, and non-ASCII pairs retain the original boundary scan.
- Actions [#952](https://github.com/GraderGamer2/NekoEdit/actions/runs/43576391933) passed all 17 workflow steps, including the full Wayland grapheme and 11 MiB Open/Save mock, XKB/importer checks, Compose build, GNOME Shell/Mutter integration, and artifact uploads.
- No Left/Backspace timing benchmark was collected; the 11 MiB Open timing is unrelated to this path.

---

## 2026-11-14 — printable-ASCII grapheme fast path (CI PASS #951)

| Commit | Subject |
|---|---|
| [6e1c30a69395](https://github.com/GraderGamer2/NekoEdit/commit/6e1c30a693957bce667368d20dd72d1b51c504b4) | perf: fast-path printable ASCII grapheme boundaries |
| [a8884220ed9d](https://github.com/GraderGamer2/NekoEdit/commit/a8884220ed9d7fd0943b83868319a11f06019efc) | fix: preserve ASCII base plus combining grapheme clusters |
| [0318e4324025](https://github.com/GraderGamer2/NekoEdit/commit/0318e4324025755fa29bf5fcee62da1d61a9ce00) | test: include ASCII grapheme run in fixture document |

Actions [#951](https://github.com/GraderGamer2/NekoEdit/actions/runs/43575768768) passed all 17 workflow steps. The Wayland mock verifies forward/reverse navigation across each appended printable ASCII byte while preserving combining marks, ZWJ sequences, other Unicode grapheme cases, and atomic CRLF deletion. The three 11 MiB Open-to-first-redraw samples were 124.9, 125.8, and 126.7 ms; no before/after performance comparison was run.

The separate `optimization-early-alpha` branch and normal `-O2` build configuration are unchanged.

---

## 2026-11-14 — destroy bound Wayland extension managers on global removal (CI PASS #948)

- Send `wp_fractional_scale_manager_v1.destroy` and `wp_viewporter.destroy` when their bound registry globals are removed.
- Preserve the already-created per-surface `wp_fractional_scale_v1` and `wp_viewport` objects.
- Add a protocol mock that removes both globals, then proves fractional-scale updates and viewport destination changes still work.
- Physical multi-output validation remains a separate compositor/desktop check.

Implementation [9d69077](https://github.com/GraderGamer2/NekoEdit/commit/9d6907749ff2a51ea3d2d82fb1c14a61ada913b7). Actions [#948](https://github.com/GraderGamer2/NekoEdit/actions/runs/43574607904) passed the full workflow, including the new manager-removal and retained-child-object regression.

---

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

