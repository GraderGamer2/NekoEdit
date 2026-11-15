## 2026-11-15 — gap-aware reverse Find traversal (CI PASS #998)

| Commit | Subject |
|---|---|
| [f3462606b1d9](https://github.com/GraderGamer2/NekoEdit/commit/f3462606b1d94e3b7f1858712ccea135ec00cbbf) | perf: traverse reverse Find with gap-aware pointers |

The reverse matcher traverses candidate offsets with a physical cursor, rebasing from the suffix to the prefix at the gap boundary. The Wayland mock verifies Shift+F3 across a query split by the gap and then F3 back to the next result. Actions [#998](https://github.com/GraderGamer2/NekoEdit/actions/runs/43684728142) passed all 17 workflow steps, including the full Wayland suite and nested GNOME Shell/Mutter/IBus integration.

ELF text/data/BSS: 239,670 / 64 / 3,764,856 bytes. Executable ZIP: 152,225 bytes; Compose locale ZIP: 120,536 bytes. No controlled end-to-end benchmark is claimed.

---

## 2026-11-15 — gap-aware forward Find traversal (CI PASS #997)

| Commit | Subject |
|---|---|
| [78229385b90f](https://github.com/GraderGamer2/NekoEdit/commit/78229385b90f89a836d3476e7c209c446eb0644a) | perf: reuse gap-aware matcher for forward Find |

Forward Find and Replace All now reuse the bounded physical-pointer matcher. The F3 wrap regression covers a search initiated at EOF. Actions [#997](https://github.com/GraderGamer2/NekoEdit/actions/runs/43684358436) passed all 17 workflow steps.

No controlled before/after benchmark was collected.

---

## 2026-11-15 — incremental Find-highlight coordinate traversal (CI PASS #996)

| Commit | Subject |
|---|---|
| [f64c7fc2a6c4](https://github.com/GraderGamer2/NekoEdit/commit/f64c7fc2a6c4767f76bdc1494873ffe853fe9d33) | perf: traverse Find highlight coordinates incrementally |
| [55998c623f1c](https://github.com/GraderGamer2/NekoEdit/commit/55998c623f1c34569409f74535b759142b2788c0) | test: reset Find search origin after gap setup |

The printable-ASCII highlight path now maps the start of each match once and advances visual row/X coordinates using actual per-glyph font widths. The wrapped path uses the same next-glyph overflow rule as the indexed visual mapper; no-wrap advances the horizontal pixel coordinate. Control/non-ASCII queries and ASCII matches preceded by non-ASCII bytes retain the original mapper.

The deterministic proportional-font Wayland regression checks A=8 px, B=5 px, space=3 px, a 10 px wrap width, four visual rows, a physical gap inside the first match, exact amber glyph rectangles, and unwrapped horizontal positions. The first test run left the logical caret at byte 1 after creating the gap and therefore correctly selected the second match. The follow-up test commit resets the caret to byte 0 while asserting the gap is still at byte 1.

Actions [#996](https://github.com/GraderGamer2/NekoEdit/actions/runs/43674688859) passed all 17 workflow steps: build/ELF, CLI/host, renderer equivalence, complete Wayland mock including 11 MiB Open/Save, native XKB, X.Org importer, Compose, nested GNOME Shell/Mutter/IBus, and both uploads.

ELF text/data/BSS: 239,542 / 64 / 3,764,856 bytes. Executable ZIP 152,139 bytes; Compose ZIP 120,536 bytes. No controlled before/after speed benchmark or live desktop retest is claimed.

---

## 2026-11-15 — gap-aware Find-highlight scanning (CI PASS #994)

| Commit | Subject |
|---|---|
| [58a7dde4f5e4](https://github.com/GraderGamer2/NekoEdit/commit/58a7dde4f5e459fde6043ee8ec618670ecf25102) | perf: traverse Find highlights with gap-aware cursor |
| [4d9d891d8725](https://github.com/GraderGamer2/NekoEdit/commit/4d9d891d8725107654215177e833d32a7da16429) | fix: correct Find matcher register-width arithmetic |
| [1f061c79d102](https://github.com/GraderGamer2/NekoEdit/commit/1f061c79d102c469f0e3e95f157cda99cffb6adc) | docs: record gap-aware Find highlight validation |

The bounded Find-highlight matcher now keeps physical pointers for candidate and query traversal, rebasing across the gap. The painter uses confirmed query bytes for glyph advances instead of fetching each matched document byte again. The Wayland Find/Replace regression puts the gap between the `f` and `i` of the first `fish`, moves selection with F3, and checks the first match's amber pixels.

The first build attempt failed in assembly because one address expression mixed 32-bit and 64-bit registers; the fix commit uses a separate 32-bit addition. Actions [#994](https://github.com/GraderGamer2/NekoEdit/actions/runs/43670126104) passed all 17 workflow steps, including build/ELF, host tests, renderer comparison, the full Wayland mock, XKB, X.Org importer, Compose and nested GNOME Shell/Mutter/IBus.

ELF text/data/BSS: 239,334 / 64 / 3,764,856 bytes. Artifacts: executable ZIP 152,041 bytes; Compose ZIP 120,536 bytes. No before/after speed benchmark is claimed.

---

## 2026-11-15 — wrapped selection rendering optimization (Actions #992 PASS)

| Commit | Subject |
|---|---|
| [b5cf6f13a3ef](https://github.com/GraderGamer2/NekoEdit/commit/b5cf6f13a3efb8c33d0221e96ef875fb6a060c47) | perf: optimize wrapped selection rendering |

The wrapped selection renderer now keeps a gap-aware physical cursor beside its logical byte position and uses a guarded ASCII fast path, a one-byte tab advance, and the existing Unicode grapheme path for sensitive boundaries. Regression coverage checks the suffix-side highlight pixel with both Wrap Lines settings. Actions [#992](https://github.com/GraderGamer2/NekoEdit/actions/runs/43669396382) passed all 17 steps.

ELF size and artifacts are recorded in CURRENT_STATUS.md. No measured end-to-end speed improvement is claimed.

---

## 2026-11-15 — middle-click auto-scroll and gap-aware selection rendering (Actions #991 PASS)

| Commit | Subject |
|---|---|
| [a1cd860b855d](https://github.com/GraderGamer2/NekoEdit/commit/a1cd860b855d4b719d056ccfae63309694bfc2fa) | feat: add middle-click document auto-scroll |
| [485d6fb05b65](https://github.com/GraderGamer2/NekoEdit/commit/485d6fb05b65ef9b1f5677116dac118a2beade0b) | perf: traverse unwrapped selection with gap-aware cursor |
| [a79f7ee1d761](https://github.com/GraderGamer2/NekoEdit/commit/a79f7ee1d761fe581ea03447d0347e9c9167f11d) | test: wait for upward auto-scroll activation |

Middle-click now toggles document auto-scroll around a fixed pointer-Y anchor. Pointer displacement controls direction and rate; returning to the dead zone pauses, another middle click exits. The existing drag timerfd is reused; left click, wheel, key press, and pointer leave cancel. The no-wrap selection renderer also gained sequential physical-pointer traversal and an ASCII fast path, retaining the Unicode grapheme fallback and rebasing at the gap.

Actions [#991](https://github.com/GraderGamer2/NekoEdit/actions/runs/43668368074) passed all 17 steps, including the new middle-click tests, split-gap selection pixel check, complete Wayland mock, renderer equivalence, 11 MiB Open/Save, XKB, X.Org importer, Compose, and GNOME Shell/Mutter/IBus integration.

ELF `size`: text 238,918, data 64, BSS 3,764,856 bytes. Executable artifact: 151,801 bytes; Compose artifact: 120,536 bytes. No before/after performance claim is made.

Artifacts: [Linux x86-64 executable](https://github.com/GraderGamer2/NekoEdit/actions/runs/43668368074/artifacts/14142963938); [Compose locale packs](https://github.com/GraderGamer2/NekoEdit/actions/runs/43668368074/artifacts/14142834214). Expiry: 2026-11-16 09:38 WIB.

---

## 2026-11-15 — gap-aware visible-text traversal (Actions #986 PASS)

| Commit | Subject |
|---|---|
| [4a074b6fab2b](https://github.com/GraderGamer2/NekoEdit/commit/4a074b6fab2b5709597078de0b165f62339370f9) | perf: traverse visible text through gap-aware cursor |

`render_document` now tracks the physical address beside its logical offset, reads visible bytes directly, and rebases when sequential traversal crosses the gap. Printable ASCII advances directly when the next logical byte is ASCII; non-ASCII continuation uses the full grapheme routine. Gap-buffer representation and Unicode 18.0 segmentation are unchanged.

Actions [#986](https://github.com/GraderGamer2/NekoEdit/actions/runs/43664719887) passed all 17 steps, including the Wayland mock, grapheme coverage, 10 MiB external paste, 11 MiB Open/Save, renderer equivalence, native XKB, X.Org importer, Compose, and GNOME Shell/Mutter/IBus integration.

ELF `size`: text 237,846, data 64, BSS 3,764,856 bytes. Executable artifact: 151,225 bytes; Compose artifact: 120,536 bytes. This build is 87 bytes larger than #985; no speed or size gain is claimed.

Artifacts: [Linux x86-64 executable](https://github.com/GraderGamer2/NekoEdit/actions/runs/43664719887/artifacts/14141397148); [Compose locale packs](https://github.com/GraderGamer2/NekoEdit/actions/runs/43664719887/artifacts/14142255098). Expiry: 2026-11-16 08:50 WIB.

---

## 2026-11-15 — batch Find/Replace index maintenance (Actions #985 PASS)

| Commit | Subject |
|---|---|
| [ad18f921af70](https://github.com/GraderGamer2/NekoEdit/commit/ad18f921af7038afb086d73a1822407f1d2b471c) | perf: batch find-and-replace insertions |

`doc_replace_selection_with_buffer` now inserts the contiguous replacement buffer with one `doc_insert_bytes` call rather than issuing one `doc_insert_byte` call for every byte. Each replacement is stored as a range history operation. Since Find/Replace searches the document directly without ensuring the line index, Replace All leaves the index invalid through the full batch and the next render performs one lazy rebuild.

The Wayland mock extends the fixture to 65 remaining matches after Replace Current. It verifies both replacement modes, exact content, 66 logical line spans, visual-row counts, stable unique line IDs, Fenwick nodes and the Replace All count.

Actions [#985](https://github.com/GraderGamer2/NekoEdit/actions/runs/43639295631) passed all 17 workflow steps, including the complete Wayland mock, 11 MiB Open/Save, renderer checks, native XKB, X.Org importer, Compose, nested GNOME Shell/Mutter/IBus and both artifact uploads.

ELF `size`: text 237,670, data 64, BSS 3,764,856 bytes. Executable artifact: 151,138 bytes; Compose artifact: 120,536 bytes. The executable is 12 bytes smaller than #984; no end-to-end speed gain is claimed.

Artifacts: [Linux x86-64 executable](https://github.com/GraderGamer2/NekoEdit/actions/runs/43639295631/artifacts/14131304250); [Compose locale packs](https://github.com/GraderGamer2/NekoEdit/actions/runs/43639295631/artifacts/14131676146). Expiry: 2026-11-16 03:51 WIB.

---

## 2026-11-15 — gap-aware line-index rebuild (Actions #984 PASS)

| Commit | Subject |
|---|---|
| [f8ff3f8df057](https://github.com/GraderGamer2/NekoEdit/commit/f8ff3f8df0575a5349a3f5d7acec020890661983) | perf: scan gap-buffer spans when rebuilding line index |

The EOF-gap fast path remains unchanged. For an internal gap, newline counting and line-record discovery now scan the physical prefix/suffix with `REPNE SCASB`, carrying logical offsets across the gap so a split physical line remains one logical record. The Wayland mock forces rebuilds with the gap inside a line and directly after LF, then checks record spans, row counts, IDs and Fenwick nodes.

Actions [#984](https://github.com/GraderGamer2/NekoEdit/actions/runs/43638409180) passed all 17 steps, including the full Wayland mock, 11 MiB Open/Save, XKB, importer, Compose and nested GNOME Shell/Mutter/IBus integration.

ELF `size`: text 237,686, data 64, BSS 3,764,856 bytes. Executable artifact: 151,150 bytes; Compose artifact: 120,536 bytes. No end-to-end performance gain is claimed.

---

## 2026-11-15 — whole-tree low-level optimization pass (Actions #983 PASS)

| Commit | Subject |
|---|---|
| [4ea34cfd6ee5](https://github.com/GraderGamer2/NekoEdit/commit/4ea34cfd6ee502ad7bb1a6dfdb1b103d5cc6c1d9) | perf: streamline row fills and gap-buffer copies |
| [0e32b6a4e519](https://github.com/GraderGamer2/NekoEdit/commit/0e32b6a4e51911ebdc543d4cc365889ff566f6f2) | perf: bulk process gap-buffer history data |
| [aa4d6e4808dc](https://github.com/GraderGamer2/NekoEdit/commit/aa4d6e4808dcf83e028de72bfcc6605498a531b2) | build: isolate assembly functions for section garbage collection |
| [cb2ebe5fd798](https://github.com/GraderGamer2/NekoEdit/commit/cb2ebe5fd798e5989dcee608ea1518ebfa92cd53) | test: remove stale clipboard fixture state |

`draw_rect` now advances a prepared row pointer; Fenwick tree nodes are initialized without redundant own-value additions. The new shared `gap_buffer.h` copies logical ranges in at most two `REP MOVSB` spans and is used by clipboard and history. History hashing and base snapshot creation process the physical spans directly, removing per-byte document lookup and per-byte write syscalls. C and all 308 typed assembly functions are sectionized for linker garbage collection; `make inspect` reports the ELF section sizes. Development stays `-O2`.

Actions [#983](https://github.com/GraderGamer2/NekoEdit/actions/runs/43636763115) passed all 17 workflow steps, including the full Wayland mock and 11 MiB Open/Save coverage, renderer checks, native XKB, X.Org importer, Compose, nested GNOME Shell/Mutter, and artifact uploads. The gap-copy unit test checks all ranges across all gap positions for four different gap sizes.

ELF `size`: text 237,542, data 64, BSS 3,764,856 bytes. Uploaded executable artifact: 151,072 bytes, compared with 151,261 bytes in #979 (189-byte decrease). Compose packs: 120,536 bytes. No end-to-end speed claim is made.

Artifacts: [Linux x86-64 executable](https://github.com/GraderGamer2/NekoEdit/actions/runs/43636763115/artifacts/14130417080); [Compose locale packs](https://github.com/GraderGamer2/NekoEdit/actions/runs/43636763115/artifacts/14129999886). Expiry: 2026-11-16 03:21 WIB.

---

## 2026-11-15 — clipped rectangle row traversal (Actions #979 PASS)

| Commit | Subject |
|---|---|
| [2d7248f](https://github.com/GraderGamer2/NekoEdit/commit/2d7248f3328fa7eac027bf1c7ca702446357537c) | perf: skip clean rows in clipped rectangle rendering |

During caret-only partial rendering, `draw_rect` now intersects each rectangle with the two ordered dirty Y bands before iterating rows. The full-window background therefore visits only dirty-band rows rather than scanning the full surface height. The full-frame path has a separate unclipped loop. The Wayland mock measures background-row visits and asserts fewer than one full surface height for every partial caret frame; fallback frames leave the clipped counter unchanged.

Actions #979 passed the complete build, Wayland, XKB, X.Org, Compose, nested GNOME Shell/Mutter and artifact-upload workflow. This verifies reduced row-loop work, not an end-to-end frame-time/FPS gain.

Artifacts: [Linux x86-64, 151,261 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43633743211/artifacts/14128774572); [Compose packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43633743211/artifacts/14129257247).

---

## 2026-11-15 — compact TrueType glyph-cache metadata (Actions #978 PASS)

| Commit | Subject |
|---|---|
| [8fa73ea](https://github.com/GraderGamer2/NekoEdit/commit/8fa73eada67d274e0b495fcfbe791a2c42b29f53) | perf: compact TrueType glyph cache metadata |

Actions #978 passed the full workflow. The TrueType cache's 128-entry metadata now lives separately from the per-slot 16 KiB glyph masks. The matched compact AoS/SoA benchmark measured 182.0 ns versus 176.6 ns per warm glyph draw (3.0% lower) with identical cache-fill and framebuffer checksums. The result is a synthetic microbenchmark, not an end-to-end editor performance claim.

Artifacts: [Linux x86-64, 151,091 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43632872689/artifacts/14128074614); [Compose packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43632872689/artifacts/14128294260).

---

## 2026-11-15 — provider-safe large clipboard paste and 30 Hz key repeat (Actions #977 PASS)

| Commit | Subject |
|---|---|
| [675bb06](https://github.com/GraderGamer2/NekoEdit/commit/675bb060abdbbaf69f562f4d95990e21a536c83c) | fix: make large clipboard transfers provider-safe and repeat all ordinary keys |
| [8095dd5](https://github.com/GraderGamer2/NekoEdit/commit/8095dd5ffa50119910154b7650840688037799b2) | test: clarify compositor repeat delay coverage |

Actions #977 passed all 17 steps. The 10 MiB Wayland clipboard test now offers only `UTF8_STRING`, verifies that the provider receives a blocking write FD, and checks the complete byte payload, line index and Undo/Redo. Clipboard receive limit remains 64 MiB. The user should still verify a direct paste from their installed l3afpad build.

All ordinary non-modifier keys now repeat at a fixed 30 Hz; compositor delay remains configurable. The Wayland mock verifies Left, Backspace, Delete, Enter, Tab and printable-key repeat, including XKB `repeat=False` cases. Modifier/lock/Compose keys and Ctrl shortcuts remain non-repeating.

Artifacts: [Linux x86-64, 151,038 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43630643206/artifacts/14127667227); [Compose packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43630643206/artifacts/14128111687).

---

## 2026-11-15 — opaque glyph pixel fast path (Actions #973 PASS)

| Commit | Subject |
|---|---|
| [e873215](https://github.com/GraderGamer2/NekoEdit/commit/e873215ad4e1519b72c686cfa07398a6bfe85776) | perf: skip blending fully opaque glyph pixels |

Actions #973 passed all 17 steps. Warm draw measured 169.2 ns with the opaque-pixel fast path versus 239.5 ns for the same identity renderer with the original blend (29.4% lower); all four framebuffer checksums matched.

---
---

## 2026-11-15 — signed pointer coordinates for selection edge auto-scroll (Actions #972 PASS)

| Commit | Subject |
|---|---|
| [d0f0360](https://github.com/GraderGamer2/NekoEdit/commit/d0f036054360a2d5f8d5a8e49a828b7b75ed66f3) | fix: preserve negative pointer coordinates during selection drag |
| [d3e7938](https://github.com/GraderGamer2/NekoEdit/commit/d3e7938ca6a889133e1304cda36deecc3fa62688) | test: allow more time for full hosted Wayland smoke |

Actions #972 passed all 17 workflow steps, including the full Wayland mock, 11 MiB Open/Save, and nested GNOME Shell/Mutter integration. The user confirms selection auto-scroll now works correctly at both screen edges.

---

## 2026-11-15 — signed pointer coordinates for selection edge auto-scroll (Actions #972 PASS)

| Commit | Subject |
|---|---|
| [d0f0360](https://github.com/GraderGamer2/NekoEdit/commit/d0f036054360a2d5f8d5a8e49a828b7b75ed66f3) | fix: preserve negative pointer coordinates during selection drag |
| [d3e7938](https://github.com/GraderGamer2/NekoEdit/commit/d3e7938ca6a889133e1304cda36deecc3fa62688) | test: allow more time for full hosted Wayland smoke |

Actions #972 passed all 17 workflow steps, including the full Wayland mock, 11 MiB Open/Save, and nested GNOME Shell/Mutter integration. The user confirms selection auto-scroll now works correctly at both screen edges.

---
---

## 2026-11-15 — dirty caret-band document traversal bounded (CI PASS #970)

| Commit | Subject |
|---|---|
| [09cf984](https://github.com/GraderGamer2/NekoEdit/commit/09cf98497c60eefef3beeaee767d072efe19defd) | perf: bound caret-only document repaint traversal |
| [05e56a9](https://github.com/GraderGamer2/NekoEdit/commit/05e56a924a61ab0f6ac5a3393a779077651276bf) | test: isolate dirty-render long-document scenario |
| [9420d2c](https://github.com/GraderGamer2/NekoEdit/commit/9420d2ce6fe4670bcf155c0306ee4fb77a122b05) | test: split dirty traversal and edit fallback cases |

The renderer maps to the dirty visual-row interval and stops document traversal at its end. The 4,096-row Wayland fixture requires a maximum 512-byte scan near EOF during plain unselected caret navigation. A separate 11-byte test ensures text insertion still uses full-frame damage and preserves the appended byte. Actions #970 passed all build, CLI, renderer equivalence, Wayland, ELF, XKB, X.Org importer, Compose and nested GNOME Shell/Mutter checks.

Artifacts: [Linux x86-64, 150,886 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43619977492/artifacts/14123966705); [Compose packs, 120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43619977492/artifacts/14123123164).

No end-to-end latency claim is made; target-machine visual testing and controlled input-to-present timing remain outstanding.

---

## 2026-11-14 — dirty caret-band rendering validated (CI PASS #967)

| Commit | Subject |
|---|---|
| [863196e](https://github.com/GraderGamer2/NekoEdit/commit/863196ef9bae96b6216b41315ba42871cbc9edac) | perf: add conservative dirty caret-band repaint |
| [d682b6b](https://github.com/GraderGamer2/NekoEdit/commit/d682b6b547d9dd252b0d0f4e4830a8de2ea2a989) | test: accept dirty caret damage in held-key mock |
| [b7eda36](https://github.com/GraderGamer2/NekoEdit/commit/b7eda36205316e244382fd675d8ec59e33c9d534) | test: inspect active SHM slot in caret assertions |
| [52be775](https://github.com/GraderGamer2/NekoEdit/commit/52be775a96d2daf68ffa42fc54f7ff7ba1802792) | test: align dirty render fixture click position |
| [a786d7b](https://github.com/GraderGamer2/NekoEdit/commit/a786d7b522126121bef8d0d60df940bd3fb8c1bf) | test: keep dirty fixture click within caret assertion range |

Actions #967 passed the complete workflow, including build/ELF inspection, CLI smoke tests, rasterizer equivalence, the Wayland protocol mock (focused dirty-render and dual-SHM cases plus 11 MiB Open/Save), XKB verification, X.Org importer checks, Compose-pack build, and nested GNOME Shell/Mutter Wayland integration. Compose and Linux x86-64 artifacts uploaded successfully. The change reduces software pixel writes and compositor damage; visible-row layout traversal and end-to-end latency have not yet been optimized/measured.

---

## 2026-11-14 — dirty caret-band rendering and mock corrections (Actions pending)

| Commit | Subject |
|---|---|
| [863196e](https://github.com/GraderGamer2/NekoEdit/commit/863196ef9bae96b6216b41315ba42871cbc9edac) | perf: add conservative dirty caret-band repaint |
| [d682b6b](https://github.com/GraderGamer2/NekoEdit/commit/d682b6b547d9dd252b0d0f4e4830a8de2ea2a989) | test: accept dirty caret damage in held-key mock |
| [b7eda36](https://github.com/GraderGamer2/NekoEdit/commit/b7eda36205316e244382fd675d8ec59e33c9d534) | test: inspect active SHM slot in caret assertions |
| [52be775](https://github.com/GraderGamer2/NekoEdit/commit/52be775a96d2daf68ffa42fc54f7ff7ba1802792) | test: align dirty render fixture click position |
| [a786d7b](https://github.com/GraderGamer2/NekoEdit/commit/a786d7b522126121bef8d0d60df940bd3fb8c1bf) | test: keep dirty fixture click within caret assertion range |

The renderer uses per-SHM-slot snapshots to gate partial caret-row and footer repaint. The mock accepts narrow two-band damage for held Left navigation, allows one safe full repaint while warming the alternate slot, and reads pixel data from the attached buffer's pool offset. Actions #965/#966 passed build, command-line smoke and rasterizer comparison. The focused scenario's initial-click assertion samples columns 9–11; the twelve-character fixture used in #966 clamped the click to column 12, so the test fixture is reduced to eleven characters. The test then navigates to EOF explicitly before partial-render assertions.

---

## 2026-11-14 — dirty caret-band rendering and mock corrections (Actions pending)

| Commit | Subject |
|---|---|
| [863196e](https://github.com/GraderGamer2/NekoEdit/commit/863196ef9bae96b6216b41315ba42871cbc9edac) | perf: add conservative dirty caret-band repaint |
| [d682b6b](https://github.com/GraderGamer2/NekoEdit/commit/d682b6b547d9dd252b0d0f4e4830a8de2ea2a989) | test: accept dirty caret damage in held-key mock |
| [b7eda36](https://github.com/GraderGamer2/NekoEdit/commit/b7eda36205316e244382fd675d8ec59e33c9d534) | test: inspect active SHM slot in caret assertions |
| [52be775](https://github.com/GraderGamer2/NekoEdit/commit/52be775a96d2daf68ffa42fc54f7ff7ba1802792) | test: align dirty-render fixture click position |

The renderer uses per-SHM-slot snapshots to gate partial caret-row and footer repaint. The mock accepts narrow two-band damage for held Left navigation, allows one safe full repaint while warming the alternate slot, and reads pixel data from the attached buffer's pool offset. Actions #965 passed build, command-line smoke, rasterizer comparison, and the regular Wayland mock cases. The focused dirty-render test's shared click assertion expected columns 9–11 while its six-character fixture correctly placed the caret at column 6; the fixture now uses twelve characters and still explicitly moves to EOF before the dirty-render checks. The next Actions run is pending.

---

## 2026-11-14 — dirty caret-band rendering and mock corrections (Actions pending)

| Commit | Subject |
|---|---|
| [863196e](https://github.com/GraderGamer2/NekoEdit/commit/863196ef9bae96b6216b41315ba42871cbc9edac) | perf: add conservative dirty caret-band repaint |
| [d682b6b](https://github.com/GraderGamer2/NekoEdit/commit/d682b6b547d9dd252b0d0f4e4830a8de2ea2a989) | test: accept dirty caret damage in held-key mock |
| [b7eda36](https://github.com/GraderGamer2/NekoEdit/commit/b7eda36205316e244382fd675d8ec59e33c9d534) | test: inspect active SHM slot in caret assertions |

The renderer uses per-SHM-slot snapshots to gate partial caret-row and footer repaint. The mock accepts narrow two-band damage for held Left navigation, tolerates the first safe full repaint while an alternate slot is initialized, and inspects pixel data at the currently attached buffer's pool offset. Actions #963 and #964 passed compilation, CLI smoke and rasterizer comparison; the Wayland mock revealed test expectation/slot-observation issues now corrected. The current run is pending.

---

## 2026-11-14 — dirty caret-band repaint (mock correction pending)

| Commit | Subject |
|---|---|
| [863196e](https://github.com/GraderGamer2/NekoEdit/commit/863196ef9bae96b6216b41315ba42871cbc9edac) | perf: add conservative dirty caret-band repaint |
| [d682b6b](https://github.com/GraderGamer2/NekoEdit/commit/d682b6b547d9dd252b0d0f4e4830a8de2ea2a989) | test: accept dirty caret damage in held-key mock |

The renderer uses per-SHM-slot snapshots to gate partial caret-row and footer repaint. The Wayland mock now recognizes the two damage rectangles on held Left repeats and permits an initial full repaint while warming the alternate slot. Actions #963 compiled and passed CLI/rasterizer checks; the mock expectation correction is awaiting the next run.

---

## 2026-11-14 — wrapped visual-row-to-byte checkpoints (CI PASS #961)

| Commit | Subject |
|---|---|
| [9509f33ac2ae](https://github.com/GraderGamer2/NekoEdit/commit/9509f33ac2aecf64be27858c19d32973a6dadf61) | perf: checkpoint wrapped visual-row to byte mapping |
| [c8eba1a2bca7](https://github.com/GraderGamer2/NekoEdit/commit/c8eba1a2bca7d8225fea466e8f2d4e5b568fb8c5) | perf: respect pixel position in wrapped row checkpoints |
| [090cad8f9c2e](https://github.com/GraderGamer2/NekoEdit/commit/090cad8f9c2e1621bda8ac07f43b31f95ae65fc4) | perf: pass target X to wrapped row lookup |

The 4 MiB single-line Wayland fixture verifies that the reverse mapper resumes from a checkpoint near the final wrapped rows and scans no more than 4 KiB. It also retains caret byte-to-visual bounds in both wrap modes and the no-wrap horizontal glyph traversal assertion. Actions [#961](https://github.com/GraderGamer2/NekoEdit/actions/runs/43586060233) passed all 17 steps, including the full Wayland suite and nested GNOME Shell/Mutter integration.

Artifacts: Linux x86-64 [149,288 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43586060233/artifacts/14109863343); Compose packs [120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43586060233/artifacts/14110002983).

No before/after latency benchmark was collected. Full-frame software-surface repaint remains future work.

---

## 2026-11-14 — sparse byte-to-visual checkpoints for long logical lines (CI PASS #959)

| Commit | Subject |
|---|---|
| [73c65219ef98](https://github.com/GraderGamer2/NekoEdit/commit/73c65219ef98f6a4ffe084294710c17b1513b104) | perf: checkpoint caret mapping within long logical lines |
| [4e7e88df0306](https://github.com/GraderGamer2/NekoEdit/commit/4e7e88df03069a9f8b51425d72c3b4158dbbf970) | test: use document-end shortcut for wrapped caret mapping |
| [07f28ae4ccf5](https://github.com/GraderGamer2/NekoEdit/commit/07f28ae4ccf5bab14aa8ff683a3acfc93a9da8e3) | test: send wrapped document-end shortcut directly |

The 4 MiB single-line regression checks byte-to-visual caret mapping at EOF in both Wrap Lines modes; each measured scan must remain within 4 KiB. The no-wrap horizontal renderer retains its own 4 KiB glyph-traversal assertion. The first test attempt used plain End in wrapped mode (which correctly ends the current visual row); the final test uses Ctrl+End. Actions [#959](https://github.com/GraderGamer2/NekoEdit/actions/runs/43584742359) passed all 17 workflow steps, including the complete Wayland suite and nested GNOME Shell/Mutter integration.

Artifacts: Linux x86-64 [148,935 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43584742359/artifacts/14110291102); Compose packs [120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43584742359/artifacts/14110286091).

No before/after latency benchmark was collected. Sparse visual-row-to-byte checkpoints for a very long wrapped logical line and full-frame software repaint remain future work.

---

## 2026-11-14 — sparse horizontal checkpoints and bounded no-wrap painting (CI PASS #956)

| Commit | Subject |
|---|---|
| [deb968026df2](https://github.com/GraderGamer2/NekoEdit/commit/deb968026df279b1b11d3a60490802197e9eba6a) | perf: cache horizontal glyph positions and bound no-wrap painting |
| [4f6acac6255e](https://github.com/GraderGamer2/NekoEdit/commit/4f6acac6255e404d36d8ba95a775f1c0da3b856c) | test: verify bounded no-wrap rendering on multi-megabyte lines |

A 4 MiB single-line Wayland fixture disables Wrap Lines, moves to End, and scrolls horizontally in both directions. The glyph-paint traversal stays within 4 KiB on each checked repaint. Stable line IDs are checked across ordinary edits and newline split/merge. Actions [#956](https://github.com/GraderGamer2/NekoEdit/actions/runs/43580042865) passed all 17 workflow steps.

Artifacts: Linux x86-64 [148,575 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43580042865/artifacts/14107887437); Compose packs [120,536 bytes](https://github.com/GraderGamer2/NekoEdit/actions/runs/43580042865/artifacts/14108071561).

No before/after speed benchmark was collected. Caret-to-pixel mapping on very long lines and sparse row checkpoints for a single very long wrapped line remain open performance work.

---

## 2026-11-14 — viewport-bounded document painting (CI PASS #954)

| Commit | Subject |
|---|---|
| [213ad8cc5364](https://github.com/GraderGamer2/NekoEdit/commit/213ad8cc5364b46ba132779269c49445e7c7105c) | perf: bound selection and find painting to visible viewport |
| [ab34e2fe9f43](https://github.com/GraderGamer2/NekoEdit/commit/ab34e2fe9f4326f0e84ccd72b5d333915c191263) | test: assert glyph renderer stays within visible document rows |

The 11 MiB / 89,414-line Wayland regression verifies a 1,935-byte glyph-paint span and a 1,935-byte selection-paint span after a middle-of-document scrollbar jump. Find highlighting is checked against a 16,384-byte scan-span limit after a 4,096-row fast wheel scroll. Actions [#954](https://github.com/GraderGamer2/NekoEdit/actions/runs/43578215465) passed all 17 workflow steps.

No pre-change timing baseline was collected: 11 MiB Open-to-first-redraw samples were 119.2, 118.2 and 117.3 ms. Long horizontally scrolled lines with Wrap Lines disabled remain a future sparse-index optimization.

---

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

