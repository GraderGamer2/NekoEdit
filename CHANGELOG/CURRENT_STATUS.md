## 2026-11-09 — implement optional Compose locale packs

**Implementation:** [77f1df75cb0d](https://github.com/GraderGamer2/NekoEdit/commit/77f1df75cb0dba7042119b3c158a8d618a4dce27); test correction [f461a9da7cb2](https://github.com/GraderGamer2/NekoEdit/commit/f461a9da7cb2ef9108bb2b19b4c06e697df8f64a); runtime fallback correction [8e4e53bcd678](https://github.com/GraderGamer2/NekoEdit/commit/8e4e53bcd678bb9d281f69e5aaaa7a9432408a0f). Branch `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.

**CI:** [Build and test #701](https://github.com/GraderGamer2/NekoEdit/actions/runs/42576739750) — all eight workflow steps passed, including the complete Wayland mock, ELF inspection, and artifact upload.

- Kept **en_US.UTF-8** as the embedded default. A non-default locale is selected explicitly through `NEKOEDIT_LOCALE=<locale-tag>`; its data file is loaded from `$HOME/.nekoedit/locales/<locale-tag>.nlp`.
- Added NLP1, a versioned, data-only format with a 72-byte header and 52-byte records. It supports 2–4 input Unicode scalars and 1–8 output scalars. The runtime caps packs at 2 MiB and 32,768 records.
- The loader checks magic/version, header and record sizes, locale-tag match, file/payload length, CRC-32, flags/reserved bytes, strict sequence ordering, duplicate/prefix ambiguity, output/input counts, Unicode scalar validity, and zero-filled unused slots. Invalid/missing packs fall back atomically to built-in en_US.
- A selected pack replaces the active Compose table; it does not merge with en_US. This avoids precedence and timeout ambiguity. The existing six dead-key actions remain separate.
- Added `tools/compose_pack.py`, a standard-library-only JSON-to-NLP1 builder. Python is a build/release tool and test dependency only, not a runtime dependency.
- The Wayland mock validates a real loaded pack through keyboard events: a pair producing two scalars, a three-key rule, a four-key rule, literal fallback for an unknown pair, and Escape/Backspace cancellation. A CRC-corrupt pack is rejected and leaves en_US active. Host tests cover header/CRC encoding, sorting, duplicate/prefix rejection, unsafe locale tags, invalid scalars, and output limits.
- No executable plugin code, shared object, network access, or automatic download was introduced.

**Artifact:** [nekoedit-linux-x86_64 — 13656010309](https://github.com/GraderGamer2/NekoEdit/actions/runs/42576739750/artifacts/13656010309)  
**Size:** 119,239 bytes  
**Expires:** 2026-11-16 07:02:43 UTC.

### Remaining locale work and validation boundary

Actual non-en_US release assets, a Settings locale selector/installer, automatic selection from system locale variables, system/user Compose-file import, locale-specific dead-key rules, and release-pack provenance/licensing workflows remain future work. The pack loader and test fixture have passed CI; this does not claim manual testing of an installed non-en_US pack in live GNOME/Mutter. The core editor remains usable offline with built-in en_US.

---

## 2026-11-09 — implement minimal document context menu

**Implementation:** [0c9fee44200b](https://github.com/GraderGamer2/NekoEdit/commit/0c9fee44200b1528c1c3d148dd525c5319c6dd7d) on the early-alpha branch; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open.  
**CI:** [Build and test #698](https://github.com/GraderGamer2/NekoEdit/actions/runs/42571651703) — all eight workflow steps passed on the first attempt.

- Added a small in-surface right-click menu in the document viewport with exactly three commands: **Copy**, **Paste**, and **Cut**. The popup is positioned at the pointer and clamped to the document viewport/window.
- Opening the popup does not move the caret or discard the current selection. Escape, another right-click, and an outside left-click dismiss it; the outside click does not activate the covered control.
- Copy and Cut reuse the existing immutable Wayland clipboard snapshots and data-source implementation. The clipboard code now uses the most recent input serial, including the menu-item pointer-press serial required for a pointer-triggered Wayland set_selection request.
- Paste reuses the existing asynchronous Wayland data-offer receive path. The mock verifies insertion, one Undo action, and Redo.
- Added an end-to-end mock scenario for right-click opening, Escape dismissal, selection retention, Copy snapshot contents, Cut snapshot-before-delete behavior, external asynchronous Paste, Undo/Redo, and outside-click dismissal. The scenario tests the real data-device protocol rather than only checking UI state.
- No new build/runtime dependency or separate clipboard process was introduced for the menu.
- **Artifact:** [nekoedit-linux-x86_64 — 13653517472](https://github.com/GraderGamer2/NekoEdit/actions/runs/42571651703/artifacts/13653517472), 116,962 bytes; SHA-256 8fef7f76439a09c662161cc65b24241a6efc425dd6ee3ea942243a72059d2b80.

### Validation boundary

The complete Wayland mock and ELF checks passed in CI. This is not a claim that the menu has already been manually checked on the user's live GNOME/Mutter desktop; that visual/input retest remains separate.

### Locale-pack implementation update

The NLP1 runtime loader and release-time generator are now implemented on `early-alpha`; see the newer status entry at the top of this file. The core keeps en_US.UTF-8 embedded, optional packs are selected explicitly with `NEKOEDIT_LOCALE`, and invalid/missing packs fall back to the built-in tables. Packs are data-only, bounded to 2 MiB/32,768 records, and support 2–4 input scalars with up to eight output scalars. Actual localized Release assets, GUI selection/installation, system/user Compose import, and locale-specific dead keys remain future work.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---

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

# Earlier NekoEdit status snapshot — before the locale-pack implementation

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

### Roadmap request at this earlier snapshot

At this snapshot, the right-click document context menu had not yet been implemented. It was delivered in the subsequent context-menu milestone recorded above. The currently verified menu contains exactly **Copy**, **Paste**, and **Cut**.

### Remaining keyboard-layout scope

The parser now covers the expanded named Unicode table and the previously validated bounded XKB type, modifier-map, compatibility-predicate, preserve/consumed-modifier, virtual-modifier, and repeat subsets. This is not complete libxkbcommon or full locale Compose support. The optional NLP1 loader supports installed locale tables, but system/user Compose-file import, automatic system-locale selection, locale-specific dead-key actions, and release-pack selection UI remain unfinished. Stateful modifier/group actions and compatibility indicators remain compositor-owned or unfinished; advanced IME preedit attributes also remain incomplete. Live GNOME/Mutter testing with real keymaps and an input method remains outstanding. Glyph appearance also depends on the selected font containing the mapped character.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---


---

