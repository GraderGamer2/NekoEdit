# NekoEdit current status

## 2026-11-09 — XKB omitted matching operator defaults to Exactly — Actions #694 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open against `main`.
**Implementation commit:** [488e8e995dd9](https://github.com/GraderGamer2/NekoEdit/commit/488e8e995dd9f788fdc442af6c52b305ea70e73e).
**Regression-index correction:** [bc1b83a9608d](https://github.com/GraderGamer2/NekoEdit/commit/bc1b83a9608d6ddd37d1f0d4be3229bdc55dac2d).

- Extended the bounded XKB text-v1 `xkb_compat` parser to accept a bare parenthesized real-modifier mask after the `+` separator. Under XKB text-v1 this omitted matching operator is equivalent to `Exactly`; the parser stores the same predicate value used by an explicit `Exactly(mask)` expression.
- The Wayland mock adds keycode 209 with keysym `Control_L` and real modifier map Mod2. The new interpretation assigns V17 only to that exact Mod2 key. Process-memory assertions verify the keysym (0xffe3), real mask (0x10), compatibility predicate (Exactly = 4), virtual map (1 << 17), and effective V17 encoding (Mod2 = 0x10). The existing Mod1 Control key continues to resolve through the explicit Exactly(Mod1) rule.
- The first run, Actions #693, built the binary and passed command-line tests but stopped in the mock because the assertion read record 14 after the newly inserted rule had shifted the expected row to record 12. The default-any scope assertion was likewise moved to record 13. This was a test-fixture index correction, not a parser behavior fix.
- Actions [Build and test #694](https://github.com/GraderGamer2/NekoEdit/actions/runs/42555001320) passed all eight workflow steps: freestanding build/ELF checks, command-line and host tests, full Wayland protocol mock, executable inspection, and artifact upload.

**Artifact:** [nekoedit-linux-x86_64 — 13646668835](https://github.com/GraderGamer2/NekoEdit/actions/runs/42555001320/artifacts/13646668835)  
**Size:** 95,370 bytes  
**SHA-256:** `5c4e9da79a371c2aa15807a3dd555774974c6d17f132908d31b615cb7a958cd9`  
**Expires:** 2026-11-16 03:11:56 UTC.

### User-reported desktop behavior

The user confirmed that `Ctrl+Shift+Left` selects words correctly in the current build. This manual confirmation is separate from automated mock coverage. The new XKB shorthand is verified by CI/mock tests; no new live desktop confirmation has been reported for it.

### Roadmap request

Add a minimal right-click context menu in the document area with exactly three commands: **Copy**, **Paste**, and **Cut**. It remains roadmap-only; this XKB milestone does not implement the menu, and no other context-menu commands should be added unless requested.

### Remaining scope

The bounded `xkb_compat` reader supports recognized modifier-keysyms and wildcards, `AnyOfOrNone`, `AnyOf`, `Any`, `NoneOf`, `AllOf`, `Exactly`, the omitted-operator `Exactly` shorthand, keysym/predicate specificity and tie handling, `virtualModifier`, `useModMapMods=level1|any` (including the implicit `any` default), and repeat policy. It does not execute general stateful XKB actions or implement compatibility indicators and full locale Compose behavior. Modifier/group transitions remain compositor-owned. Live GNOME/Mutter validation against real keymaps remains outstanding.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---


---

