## 2026-11-09 — add three-symbol XKB Compose sequences

**Implementation commit:** [bf3a1891dd63](https://github.com/GraderGamer2/NekoEdit/commit/bf3a1891dd6318ad70f99bf7e75e4afbf481dc56)  
**CI:** [Build and test #42564500183](https://github.com/GraderGamer2/NekoEdit/actions/runs/42564500183) — first attempt passed all eight steps.

- Extended the static `en_US.UTF-8`-derived Compose data with **564 three-symbol sequences**, in addition to the **2,140 two-symbol pairs** from the previous milestone. The triple table is 9,040 bytes including its sentinel; it adds no runtime/build dependency.
- Added a second buffered scalar and prefix check. After `Multi_key`, a second input is held only when it prefixes one of the supported triples. The third input resolves the sequence; a nonmatching third input is flushed literally with the first two symbols.
- The table avoids triples whose first two symbols already resolve as a pair, so existing pair mappings still resolve immediately. The current upstream source has 106 four-symbol sequences; they remain unsupported.
- The Wayland mock verifies `minus minus period` → U+2013 EN DASH and `minus minus minus` → U+2014 EM DASH, the two-symbol-prefix buffer state, and Backspace cancellation without document mutation.
- Updated [docs/COMPOSE.md](../docs/COMPOSE.md), README, and regression coverage. Source is still a static `en_US.UTF-8` subset, not locale-aware system or user Compose-file loading.

**CI result:** all eight steps passed on the first attempt: freestanding build/ELF checks, CLI and host tests, full Wayland mock, executable inspection, and artifact upload. Artifact [13650369672](https://github.com/GraderGamer2/NekoEdit/actions/runs/42564500183/artifacts/13650369672) is 116,277 bytes; ZIP SHA-256 `4b4234c8a9a493b0f389005f55f0da9a4bd6cdd9c962cea8bd832773a1a6b174`; expiry 2026-11-16 04:57:02 UTC.

### Remaining Compose scope

Four-symbol sequences, multi-scalar output results, locale selection, locale Compose-file loading, XCompose includes/substitutions, `~/.XCompose`, and broader dead-key coverage remain future work. The real GNOME/Mutter keyboard path still needs physical-layout verification.

---

## 2026-11-09 — expand XKB Multi_key Compose baseline

**Implementation commit:** [31c1bd47575e](https://github.com/GraderGamer2/NekoEdit/commit/31c1bd47575ee776701bd106d8d25dcd33219432)  
**CI:** [Build and test #42563677349](https://github.com/GraderGamer2/NekoEdit/actions/runs/42563677349) — retry attempt 2 passed all eight workflow steps.

- Replaced the fixed 40-pair `Multi_key` lookup with **2,140 two-symbol pairs**: 2,133 distinct one-scalar-output pairs extracted from X.Org libX11's `en_US.UTF-8` Compose source, plus seven original NekoEdit pairs absent from that source.
- All 40 original NekoEdit entries take precedence on collisions, including the existing slash/slash output.
- The static table occupies **25,692 bytes** including its sentinel. No runtime or build dependency was added; the two-symbol state machine and Wayland key-event path were retained.
- Added end-to-end mock checks for `period period` → U+2026, `S S` → U+1E9E, and `period greater` → U+203A. They compare document UTF-8 bytes, independently of font glyph availability.
- Added [docs/COMPOSE.md](../docs/COMPOSE.md) with source revision, attribution, tests, and limitations.

**Scope boundary:** this is an `en_US.UTF-8`-derived static two-symbol baseline, not locale-selected Compose. It does not read locale Compose files, `~/.XCompose`, `$XCOMPOSEFILE`, or XCompose include directives. Three-/four-symbol sequences, multi-codepoint results, locale selection, and remaining dead-key actions are still open work.

**CI result:** attempt 1 failed in an earlier held-Enter caret assertion before reaching the new Compose tests; the same failed job was retried without source changes. Attempt 2 passed all eight steps, including the full Wayland mock, ELF inspection, and artifact upload. Artifact [13650009531](https://github.com/GraderGamer2/NekoEdit/actions/runs/42563677349/artifacts/13650009531) is 113,011 bytes; ZIP SHA-256 `d7cd58ba93aac6efaeb88149f497d74ce0f74d9bd5c9f4fa7811f9a237790a2d`; it expires 2026-11-16 04:48:29 UTC.

## Font rendering note

The user reported question marks when trying scripts without corresponding installed glyphs. Inspection confirms the TrueType renderer substitutes the selected font's `?` glyph when its cmap has no mapping for the requested Unicode scalar. That is a **rendering fallback**, not evidence that the keyboard inserted U+003F; integration checks inspect document bytes. Cross-font glyph fallback is not implemented yet. Correctly stored Unicode can still appear as a question mark until a font with the glyph is selected.

---

# NekoEdit current status

## 2026-11-09 — expand named XKB Unicode keysyms — Actions #695 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and mergeable against `main`.
**Implementation/test/documentation commit:** [2e50f35a1ebc](https://github.com/GraderGamer2/NekoEdit/commit/2e50f35a1ebccfb6b2feb919a35e28c0605ede79).

- Expanded the static named-key lookup from 280 retained legacy entries to **1,642 X.Org Unicode-annotated keysym/action aliases**. It is generated from X.Org `keysymdef.h` Unicode annotations, also resolving legacy aliases that share a numeric keysym value with an annotated name. No runtime library or external build dependency was introduced.
- Added the published xorgproto 2026.1 aliases: `SSHARP` (U+1E9E), single-angle quotation marks (U+2039/U+203A), XF86 phone-numeric digits/star/pound, and `dead_apostrophe` through the existing acute-accent action.
- Wayland mock parser-memory checks cover Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, German capital sharp S, angle quotation marks, phone-numeric keysym, and the dead-apostrophe marker. End-to-end key events verify UTF-8 insertion for twelve named characters/phone aliases and that `dead_apostrophe` arms and completes the existing acute composition path.
- Added `docs/KEYSYM_UNICODE.md` documenting the table, test scope, remaining limits, source provenance, and source notices. README implementation and roadmap summaries no longer describe the old 273-name curated subset.
- Actions [Build and test #695](https://github.com/GraderGamer2/NekoEdit/actions/runs/42560170496) passed all eight workflow steps: freestanding build/ELF checks, CLI and host tests, the full Wayland mock, executable inspection, and artifact upload. The mock log confirms the extended multilingual scalar table and actual UTF-8 typing tests passed.

**Artifact:** [nekoedit-linux-x86_64 — 13648893107](https://github.com/GraderGamer2/NekoEdit/actions/runs/42560170496/artifacts/13648893107)  
**Size:** 104,167 bytes  
**SHA-256:** `5762e219685c3734e77e8b2bd7e9fad0bdb39d3ca4c742d969fe330a8d407c4c`  
**Expires:** 2026-11-16 04:09:24 UTC.

### User-reported desktop behavior

The user reports that the previous build works perfectly and that no visible behavior change is apparent. The new named-key additions are CI/mock-verified; multilingual physical-key typing has not yet been separately confirmed on live GNOME/Mutter. The earlier manual confirmation that `Ctrl+Shift+Left` selects words correctly remains recorded.

### Roadmap request

The requested right-click document context menu remains a separate, unimplemented item with exactly three commands: **Copy**, **Paste**, and **Cut**. It is not part of this keyboard-layout milestone.

### Remaining keyboard-layout scope

The parser now covers the expanded named Unicode table and the previously validated bounded XKB type, modifier-map, compatibility-predicate, preserve/consumed-modifier, virtual-modifier, and repeat subsets. This is not complete libxkbcommon or locale Compose support. Stateful modifier/group actions and compatibility indicators remain compositor-owned or unfinished; advanced IME preedit attributes and full locale Compose are incomplete. Live GNOME/Mutter testing with real keymaps and an input method remains outstanding. Glyph appearance also depends on the selected font containing the mapped character.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---


---

