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

