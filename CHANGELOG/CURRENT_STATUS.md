# NekoEdit current status

## 2026-11-09 — XKB useModMapMods scope validation passed — Actions #691

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open against `main`.
**Implementation/test commits:** [4ad4291e5230](https://github.com/GraderGamer2/NekoEdit/commit/4ad4291e52303e6145e2847e7e921d198735aea4), [d64f3d8a3a1e](https://github.com/GraderGamer2/NekoEdit/commit/d64f3d8a3a1e3c9c6f513f2f8fb9009581d1bbc9), [fb04b1e5d218](https://github.com/GraderGamer2/NekoEdit/commit/fb04b1e5d218230d5cd647e528019e0f504e2161), [1a57acd950c5](https://github.com/GraderGamer2/NekoEdit/commit/1a57acd950c508c991bb2e7157da5dfc70c681f7).

- Extended the synthetic `xkb_compat` fixture to cover `useModMapMods = level1`, explicit `useModMapMods = any`, and the omitted-attribute default (`any`). It verifies `level1` wins the equal-specificity first-declaration tie for Group 1 / Level 1, while the lower-priority `any` rule applies to the same keysym on Group 1 / Level 2 and Group 2 / Level 1.
- The fixture also verifies implicit `any` on a separate key whose `ISO_Group_Shift` symbol occurs only in Group 2. Memory assertions check the stored rule scopes, key real-modifier maps, virtual-modifier assignments, and effective masks. `V16` correctly aggregates Mod5 (`0x80`) from the alternate-level/group matches; the default-`any` V14 case aggregates Mod2 (`0x10`).
- No XKB runtime behavior was changed in this milestone; the parser already implemented both scopes. This adds coverage against regressions in scope parsing, specificity/tie ordering, and virtual-modifier aggregation.
- Actions #688 and #689 stopped in the older soft-wrap mouse hit-test scenario because the mock injected a new pointer click before confirming that the previous single `wl_buffer` release had been consumed. The test helper now waits for `buffer_busy=0` before and after a pointer click; the caret/pixel assertions remain unchanged.
- Actions #690 then reached the new XKB fixture and exposed a missing expected value: the new V16 rule legitimately contributes Mod5 from alternate-level/group matches. The expected virtual-modifier table was corrected to include `V16=0x80`; no application-source change was required.
- Actions [Build and test #691](https://github.com/GraderGamer2/NekoEdit/actions/runs/42553348336) passed all eight workflow steps, including build/ELF verification, command-line and host tests, the complete Wayland mock, executable inspection, and artifact upload.

**Artifact:** [nekoedit-linux-x86_64 — 13646371299](https://github.com/GraderGamer2/NekoEdit/actions/runs/42553348336/artifacts/13646371299)  
**Size:** 95,324 bytes  
**SHA-256:** `70148ff518fe7f22f73209fdf3477cfe1d80bd27fe9221567a92866d4c2a500c`  
**Expires:** 2026-11-16 02:53:37 UTC.

### User-reported desktop behavior

The user confirmed that `Ctrl+Shift+Left` selects words correctly in the current build. This is a manual desktop confirmation and is recorded separately from the automated mock results.

### Roadmap request

Add a minimal right-click context menu in the document area with exactly three commands: **Copy**, **Paste**, and **Cut**. It remains roadmap-only; this milestone does not implement the menu, and no other context-menu commands should be added unless requested.

### Remaining scope

The bounded `xkb_compat` reader supports `virtualModifier`, `useModMapMods=level1|any` (including the implicit `any` default), specificity/tie handling, and repeat policy. It does not execute general stateful XKB actions, compatibility indicators, or full locale Compose behavior. Modifier/group transitions remain compositor-owned. Live GNOME/Mutter validation against real keymaps remains outstanding.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---


---

