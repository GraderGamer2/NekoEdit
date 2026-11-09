# NekoEdit current status

## 2026-11-09 — XKB preserve/consumed Control and Shift validated — Actions #686 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open against `main`.
**Feature commit:** [1b9d2da39977](https://github.com/GraderGamer2/NekoEdit/commit/1b9d2da399779ae306011e04e0509748b17afd87).
**Documentation commit:** [29bada7cd1d8](https://github.com/GraderGamer2/NekoEdit/commit/29bada7cd1d8b153d4aa1c895e600c2cc68bbe82).
**Test synchronization commit:** [97cc62949fb7](https://github.com/GraderGamer2/NekoEdit/commit/97cc62949fb794c632242ea8c4c289d91aab8628).

- The `xkb_types` parser retains a 32-bit preserve mask beside each exact `map[]` entry. A preserve declaration without a matching preceding map creates the implicit Level1 entry; a later matching map updates it in place. Preserved masks are validated against the type's declared modifier set.
- Lookup computes the consumed modifier mask as the selected type's modifier mask AND NOT the matching entry's preserve mask. The same exact key/group/type-map selection is used for symbol lookup and consumed-modifier lookup.
- Wayland retains the complete compositor-provided XKB state for keysym selection. Shortcut-visible Control and Shift are filtered separately using the current key's consumed mask; raw compositor/physical state is restored on key release. Modifier and group actions remain compositor-owned. Alt is not currently filtered because the implemented shortcut set does not use it.
- The mock adds paired Shift-only types and assigns them to Left and Right. It verifies parser type IDs, type masks, exact map masks and preserve masks; runtime coverage proves consumed Shift does not extend selection for Ctrl+Shift+Left, while `preserve[Shift]` retains selection for Ctrl+Shift+Right. The earlier Control tests continue to verify preserved Ctrl+A and consumed-Control EuroSign insertion rather than Ctrl+Z.
- Actions #684 and #685 stopped in the new test's post-release synchronization: a modifier release does not guarantee a repaint. The test now waits for the actual Control and Shift shortcut-state reset instead of waiting for a frame. This correction changes test synchronization, not editor behavior.
- Actions [Build and test #686](`https://github.com/GraderGamer2/NekoEdit/actions/runs/42550654163`) passed all eight workflow steps, including ELF inspection, command-line tests, the complete Wayland mock and artifact upload. The mock log explicitly records both consumed-Shift filtering and preserved-Shift selection.

**Artifact:** [nekoedit-linux-x86_64 — 13645133185](https://github.com/GraderGamer2/NekoEdit/actions/runs/42550654163/artifacts/13645133185)  
**Size:** 95,324 bytes  
**SHA-256:** `4817ba43f7015796080a570879664407b0b51578a7f501d3ddaf2c166fb22035`  
**Expires:** 2026-11-16 02:23:52 UTC.

### Remaining scope

General XKB stateful key-action interpretation remains compositor-owned and is not executed by NekoEdit. Broader shortcut filtering beyond the Control/Shift shortcuts currently implemented is not yet applicable; Alt and other modifier policies still need real-keymap evaluation if those modifiers are added to shortcut bindings. Validation against real GNOME/Mutter keymaps and a live desktop session remains outstanding.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---

