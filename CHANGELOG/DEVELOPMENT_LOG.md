## 2026-11-09 — add three-symbol XKB Compose sequences — Actions passed

### Implementation

- Added **564 three-symbol sequences** from X.Org libX11's `en_US.UTF-8` Compose source on top of the prior 2,140 two-symbol pairs. The four-long table records (first scalar, second scalar, third scalar, result) occupy 9,040 bytes including a zero sentinel.
- Introduced `doc_compose_second` as one additional buffered scalar. After a `Multi_key` prefix, a pair is held only if it prefixes a known triple. The third symbol resolves through the three-scalar lookup. If it does not match, all three symbols are inserted literally.
- No supported triple has a first-two-scalar prefix which is already a complete two-symbol pair. This lets the editor preserve immediate resolution of the full two-symbol table. All 40 historical NekoEdit pair mappings still retain priority over upstream entries.
- Interrupted or cancelled sequences flush or clear both buffered scalars correctly: dead-key interruption and repeated `Multi_key` preserve pending text literally, while Backspace/Escape and keyboard-focus loss clear pending state without inserting it.

### Regression coverage and validation

- The Wayland mock now exercises `minus minus period` → U+2013 and `minus minus minus` → U+2014. It verifies that the second minus is buffered without changing document bytes, then that the third key inserts one three-byte UTF-8 scalar.
- Added Backspace coverage after a two-scalar triple prefix; it verifies both buffered scalar fields clear and document length remains unchanged.
- Actions [Build and test #42564500183](https://github.com/GraderGamer2/NekoEdit/actions/runs/42564500183) passed all eight workflow steps on the first attempt: freestanding build, CLI/host tests, complete Wayland mock, ELF inspection, and artifact upload.
- Artifact [13650369672](https://github.com/GraderGamer2/NekoEdit/actions/runs/42564500183/artifacts/13650369672): 116,277 bytes; ZIP SHA-256 `4b4234c8a9a493b0f389005f55f0da9a4bd6cdd9c962cea8bd832773a1a6b174`; expires 2026-11-16 04:57:02 UTC.

### Limitations

The table remains a static `en_US.UTF-8` snapshot. Four-symbol sequences (106 present in the upstream source), multi-scalar output strings, runtime locale selection, system Compose files, `~/.XCompose`, include rules, and full dead-key coverage remain unsupported.

### Commit

- [bf3a1891dd63](https://github.com/GraderGamer2/NekoEdit/commit/bf3a1891dd6318ad70f99bf7e75e4afbf481dc56) — add three-symbol XKB Compose sequences.

## 2026-11-09 — expand XKB Multi_key Compose coverage — CI retry passed

### Implementation

- Replaced the fixed two-symbol Compose list with 2,140 pairs. The source contributes 2,133 unique two-symbol sequences from X.Org libX11 `nls/en_US.UTF-8/Compose.pre` that resolve through the current keysym mapping to two Unicode scalars and one Unicode-scalar result. Seven legacy NekoEdit pairs are retained because they are not in the source.
- All original 40 NekoEdit records remain authoritative on overlap. One upstream pair differed from the original output (slash/slash), so the established editor result was deliberately preserved.
- The lookup remains a static triple table: first scalar, second scalar, result scalar. It adds 25,692 bytes including the terminator and no runtime/build dependency. No Wayland keyboard protocol or Compose state-machine behavior changed.
- Added mock keycodes and end-to-end typing for `period period` → U+2026, `S S` → U+1E9E, and `period greater` → U+203A. Each assertion checks UTF-8 document length/content; font coverage is not part of these tests.
- Added `docs/COMPOSE.md` with source pin, scope, test behavior, attribution, and unsupported features.

### Validation

- Actions [Build and test #42563677349](https://github.com/GraderGamer2/NekoEdit/actions/runs/42563677349), retry attempt 2, passed all eight workflow steps: freestanding assembly/link/ELF inspection, CLI and host tests, full Wayland mock, executable inspection, and artifact upload.
- The initial attempt failed a pre-existing held-Enter caret-location assertion before reaching the new Compose checks. Retrying only the failed job with the same source commit passed; no test or implementation change was needed.
- Artifact [13650009531](https://github.com/GraderGamer2/NekoEdit/actions/runs/42563677349/artifacts/13650009531): 113,011 bytes; ZIP SHA-256 `d7cd58ba93aac6efaeb88149f497d74ce0f74d9bd5c9f4fa7811f9a237790a2d`; expiry 2026-11-16 04:48:29 UTC.

### Limitations and user observation

- This is an `en_US.UTF-8`-derived **two-symbol** baseline only. It is not locale-aware runtime selection, does not load system locale Compose files or `~/.XCompose`, does not process includes or `$XCOMPOSEFILE`, and does not yet accept three-/four-symbol sequences or multi-scalar results.
- The user reported that some inserted script characters display as question marks without matching fonts. The renderer substitutes the chosen font's question-mark glyph on cmap misses. This is independent of Unicode insertion; full cross-font fallback and complex-script shaping remain separate rendering work.

### Commit

- [31c1bd47575e](https://github.com/GraderGamer2/NekoEdit/commit/31c1bd47575ee776701bd106d8d25dcd33219432) — expand default XKB Compose pair coverage.

## 2026-11-09 — expand named XKB Unicode keysyms — Actions #695 passed

### Source data and implementation

- Expanded `.Lxkb_unicode_symbols` in `src/backend/xkb.S` from 280 retained legacy entries to 1,642 names with Unicode scalar or existing action-marker values.
- The mapping derives from X.Org `keysymdef.h` Unicode annotations. Aliases that share a numeric keysym value with an annotated canonical entry inherit the same scalar. Control/function keysyms without printable Unicode scalars stay on their existing key/action paths.
- Added xorgproto 2026.1 named aliases for German capital sharp S, single-angle quotation marks, XF86 phone numeric digits/star/pound, and `dead_apostrophe`. The dead-apostrophe name reuses the already-supported acute-mark action; it does not introduce a new accent behavior.
- The implementation remains a compile-time static table. It adds no runtime dependency and does not change the established Wayland event or modifier-state model.

### Regression coverage and validation

- Added representative synthetic keycodes for Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, SSHARP, a single-angle quote, an XF86 phone numeric key, and dead_apostrophe.
- The mock inspects all thirteen scalar/action entries in process memory and then types twelve character/phone aliases through the Wayland keyboard-event path, checking the exact resulting UTF-8. It separately confirms dead_apostrophe arms U+0301 and composes with `e` to U+00E9.
- Actions [Build and test #695](https://github.com/GraderGamer2/NekoEdit/actions/runs/42560170496) passed all eight steps: freestanding build/ELF checks, command-line and host tests, complete Wayland mock, executable inspection, and artifact upload. The run log explicitly reports the expanded named-key coverage and successful Wayland mock.
- Artifact [13648893107](https://github.com/GraderGamer2/NekoEdit/actions/runs/42560170496/artifacts/13648893107) is 104,167 bytes; uploaded ZIP SHA-256 `5762e219685c3734e77e8b2bd7e9fad0bdb39d3ca4c742d969fe330a8d407c4c`; it expires 2026-11-16 04:09:24 UTC.

### Documentation and user feedback

- Added `docs/KEYSYM_UNICODE.md` with scope, regression coverage, source provenance and license notices. Updated README descriptions that referred to the previous curated 273-name subset or described already-implemented virtual/compatibility lookup as deferred.
- The user reports that the previous build works perfectly and sees no visible behavior change. This is expected for a backend coverage expansion but does not confirm that the additional script layouts have been manually tested on a live desktop. The earlier manual `Ctrl+Shift+Left` confirmation remains separate.
- The requested minimal right-click context menu remains a distinct roadmap task containing exactly Copy, Paste and Cut.

### Commit

- [2e50f35a1ebc](https://github.com/GraderGamer2/NekoEdit/commit/2e50f35a1ebccfb6b2feb919a35e28c0605ede79) — expand XKB named Unicode keysym coverage.

Live GNOME/Mutter layout and input-method validation remains outstanding.

---

## 2026-11-09 — support omitted XKB interpret matching operator — Actions #694 passed

### Specification and implementation

- The official XKB text-v1 format defines the default matching operation as `Exactly` when the modifier predicate's mask is present but its matching operation is omitted. This differs from omitting the entire predicate, whose default remains `AnyOfOrNone(all)`.
- The bounded `xkb_compat` parser now recognizes a direct opening parenthesis immediately after the `+` separator, sets the stored predicate to the existing `Exactly` enum value, and parses the following real-modifier mask through the same mask reader used by named operations. Explicit named predicates retain their existing parsing path.
- General XKB actions remain skipped/compositor-owned; this change only extends the matching-condition grammar.

### Regression coverage and validation

- Added synthetic keycode 209 (`<IMPL>`) with `Control_L` and a Mod2 real modifier map. `interpret Control_L + (Mod2)` must assign V17 to that key. The mock reads the raw keysym, real modifier mask, stored predicate enum, key virtual map, and aggregate virtual-modifier mask from the running process.
- The existing Control_L / Mod1 fixture remains covered by explicit `Exactly(Mod1)`; it must retain V13 rather than matching the new Mod2-only rule.
- Actions #693 passed assembly build/ELF and command-line tests but initially failed a test assertion that read the new rule from record 14 instead of record 12. The default-any scope assertion was adjusted from record 12 to record 13. The observed key mask, keysym, and V17 virtual map were already correct in that failed run.
- Actions [Build and test #694](https://github.com/GraderGamer2/NekoEdit/actions/runs/42555001320) passed all eight workflow steps. The Wayland mock explicitly reported that the omitted matching operator defaults to `Exactly(mask)` and matches only the exact modifier map.
- Artifact [13646668835](https://github.com/GraderGamer2/NekoEdit/actions/runs/42555001320/artifacts/13646668835) is 95,370 bytes; uploaded ZIP SHA-256 `5c4e9da79a371c2aa15807a3dd555774974c6d17f132908d31b615cb7a958cd9`; it expires 2026-11-16 03:11:56 UTC.

### User feedback and roadmap separation

- The user previously confirmed real-build word selection with `Ctrl+Shift+Left`. That remains a manual desktop confirmation, not an automated CI claim.
- The requested right-click document context menu is still a separate roadmap item and must contain exactly **Copy**, **Paste**, and **Cut**. It is not implemented by this XKB change.

### Commits

- [488e8e995dd9](https://github.com/GraderGamer2/NekoEdit/commit/488e8e995dd9f788fdc442af6c52b305ea70e73e) — implement the omitted matching-operator default as Exactly.
- [bc1b83a9608d](https://github.com/GraderGamer2/NekoEdit/commit/bc1b83a9608d6ddd37d1f0d4be3229bdc55dac2d) — correct the mock's shifted rule-record indices.

Live GNOME/Mutter validation against real layout keymaps remains outstanding.

---

## 2026-11-09 — validate XKB useModMapMods level1/any scopes — Actions #691 passed

### Specification boundary and implementation coverage

- The existing bounded XKB text-v1 reader already parsed `useModMapMods = level1` and `useModMapMods = any`; omitted scope defaults to `any`. This work extends the synthetic keymap and process-memory assertions rather than changing parser or runtime application code.
- The fixture gives the same `ISO_Level3_Shift` keysym real modifier maps at Group 1 / Level 1, Group 1 / Level 2, and Group 2 / Level 1. Equal-specificity rules are deliberately declared with `level1` first and `any` second. The first rule must win for Group 1 / Level 1, while `any` handles the two other occurrences.
- A second key has `ISO_Group_Shift` only in Group 2 and no explicit `useModMapMods` field. Its Mod2 real map must be resolved by the default `any` behavior.
- Parser-memory assertions verify explicit rule scope values, implicit default scope, the selected virtual modifier assignments, key real-modifier masks, and aggregate virtual encodings. V16 receives Mod5 (0x80) from alternate-level/group occurrences; V14 receives Mod2 (0x10) on the default-any Group 2 key.

### Test corrections and validation

- Actions #688 and #689 stopped before reaching the custom XKB fixture in the existing default Wayland scenario. The mock's `pointer_click` helper queued a new click immediately after sending `wl_buffer.release`, without waiting for the single-buffer client to consume it. Added `buffer_busy=0` waits before and after pointer clicks. The wrapped-row caret/pixel assertion was preserved.
- Actions #690 passed the pointer scenario and reached the new XKB fixture; its failure was an incomplete expected virtual-modifier table, not parser behavior. The fixture now expects V16's valid Mod5 aggregate (0x80).
- Actions [Build and test #691](https://github.com/GraderGamer2/NekoEdit/actions/runs/42553348336) passed all eight workflow steps. The full Wayland mock, CLI/host tests, ELF inspection, and artifact upload completed successfully.
- Artifact [13646371299](https://github.com/GraderGamer2/NekoEdit/actions/runs/42553348336/artifacts/13646371299) is 95,324 bytes; SHA-256 `70148ff518fe7f22f73209fdf3477cfe1d80bd27fe9221567a92866d4c2a500c`; it expires 2026-11-16 02:53:37 UTC.

### User feedback and requested roadmap item

- The user manually confirmed that `Ctrl+Shift+Left` selects words correctly in the current build. This desktop confirmation is distinct from automated mock coverage.
- The user requested a minimal right-click document context menu containing exactly Copy, Paste, and Cut. This is recorded in the root README roadmap and is not implemented in this milestone. Do not add other context-menu commands unless requested.

### Commits

- [4ad4291e5230](https://github.com/GraderGamer2/NekoEdit/commit/4ad4291e52303e6145e2847e7e921d198735aea4) — add explicit/default any-scope fixture and roadmap item.
- [d64f3d8a3a1e](https://github.com/GraderGamer2/NekoEdit/commit/d64f3d8a3a1e3c9c6f513f2f8fb9009581d1bbc9) — assert the default-any rule scope.
- [fb04b1e5d218](https://github.com/GraderGamer2/NekoEdit/commit/fb04b1e5d218230d5cd647e528019e0f504e2161) — synchronize pointer clicks with single-buffer releases.
- [1a57acd950c5](https://github.com/GraderGamer2/NekoEdit/commit/1a57acd950c508c991bb2e7157da5dfc70c681f7) — correct the expected V16 Mod5 aggregate after the any-scope fixture expanded effective virtual masks.

Live GNOME/Mutter validation against real layout keymaps remains outstanding.

---

