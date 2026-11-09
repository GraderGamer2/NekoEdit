## 2026-11-09 — add the first external Compose locale pack — Build and test #704 passed

### Source data and import pipeline

- Added `data/locales/pt_BR.UTF-8.json` as a complete table, not an overlay. It flattens the en_US Compose include and then applies pt_BR locale rules, with locale entries replacing matching base keys.
- Pinned libX11 to `mirror/libX11` commit `ff8706a5eae25b8bafce300527079f68a201d27f` and xorgproto to `X11Libre/mirror.fdo.xorgproto` commit `6d3907b6d5dc4aa7d7ee6ee5d7d8714e7466630b`. Exact upstream Git blob IDs are stored in source metadata and verified in CI before import.
- `tools/import_xcompose.py` resolves named and aliased input keysyms to Unicode scalars, decodes Compose quoted strings, supports only the expected en_US include, applies locale overrides, and deterministically drops shorter keys that prefix longer keys.
- The source contains 2,904 valid base rule lines and 9 valid locale lines. Three locale rules replace existing keys; 2,908 final entries remain after one ambiguous shorter prefix is removed. Final lengths are 2,220 pairs, 582 triples, and 106 four-input rules. One hundred results contain multiple scalars.
- Dead-key-led rules and non-scalar input keysyms are intentionally excluded; NLP1 v1 is a scalar-only Multi_key table. JSON statistics include accepted/skipped source lines, upstream pins, and import policy. A companion notice records provenance and license references.

### Tests and build integration

- Added importer tests for aliases, duplicate source definitions, locale override priority, multi-scalar output, prefix handling, unsupported keysyms, and unknown include rejection.
- Added a committed-data test for pt_BR-specific mappings, counts/depth distribution, and NLP1 header construction.
- `make test` runs both locale tests. `make locale-packs` builds the 151,288-byte pack and copies its notice to `build/locales/`.
- The regular Build and test workflow verifies source blob IDs, regenerates the JSON, requires byte-for-byte equality, and uploads the optional pack separately from the editor executable. A dedicated Release workflow attaches the pack and notice when a project Release is published.

### Corrections retained in history

- [15cf37c949fa](https://github.com/GraderGamer2/NekoEdit/commit/15cf37c949facfeb5038915f90b8f1917cf3afdf) corrected importer provenance wording to match the committed JSON.
- The first exact-generation run exposed a mismatch in the meaning of `base_rules`. [7871f5256b89](https://github.com/GraderGamer2/NekoEdit/commit/7871f5256b89789e348b52801ebaecbca86e2a0a) changed the statistic to count valid source lines before duplicate-key replacement and added a duplicate-line regression test. The JSON then matched byte-for-byte.

### Validation

- [Build and test #704](https://github.com/GraderGamer2/NekoEdit/actions/runs/42579353889) passed all 12 workflow steps: freestanding build, CLI/host tests, complete Wayland mock, ELF inspection, source fetch/blob verification, exact importer regeneration, pack build, and both uploads.
- The mock confirms read-only pt_BR pack activation and pair/multi-output, triple, four-input, literal fallback, Escape, and Backspace behavior.
- Locale pack: 151,288 bytes; artifact [13656596918](https://github.com/GraderGamer2/NekoEdit/actions/runs/42579353889/artifacts/13656596918), ZIP size 17,943 bytes, SHA-256 `e644d2d0f20f499a0ce6b50872ca2aa688243ebdffaaaa6f7431c5f4b9bfb132`.
- Editor binary: 119,239 bytes; artifact [13657030709](https://github.com/GraderGamer2/NekoEdit/actions/runs/42579353889/artifacts/13657030709), ZIP SHA-256 `1ea57032f6db13c84ddcfafcf4b5bd8dc1973b518164c91a2e969b6ff16dfb01`.

### Remaining work

Publish a project Release to exercise attachment to an actual versioned release; create more locale datasets; add Settings-based install/select/remove; optionally follow system locale variables; evaluate system/user Compose import and locale-specific dead keys. Live GNOME/Mutter testing of an installed pt_BR pack remains outstanding.

**Source commits:** [d5f96921ef9e](https://github.com/GraderGamer2/NekoEdit/commit/d5f96921ef9e9cf1e052a6509003b827769af9ca), [15cf37c949fa](https://github.com/GraderGamer2/NekoEdit/commit/15cf37c949facfeb5038915f90b8f1917cf3afdf), [7871f5256b89](https://github.com/GraderGamer2/NekoEdit/commit/7871f5256b89789e348b52801ebaecbca86e2a0a).

---

## 2026-11-09 — implement bounded Compose locale packs — Build and test #701 passed

### Implementation

- Added `src/backend/compose_locale.c`, a freestanding runtime loader using direct Linux syscalls. It reads an explicitly selected `NEKOEDIT_LOCALE` pack from `$HOME/.nekoedit/locales/<tag>.nlp`, maps it read-only, and activates it only after complete validation.
- Defined NLP1: 72-byte header, 52-byte records, little-endian fields, version 1, CRC-32 payload check, exact locale tag, bounded record/byte counts, zero reserved fields, and strict Unicode-scalar/sequence validation.
- Each record has 2–4 input scalars and 1–8 output scalars. Records must be sorted and unique; prefix-ambiguous sequences are rejected to avoid delayed resolution timers.
- The pack replaces the selected locale's active Compose table; it is not an overlay on en_US. Built-in en_US remains the default and the failure fallback. No shared libraries, executable plugins, runtime Python, or network activity were added.
- Extended the keyboard Compose state to four buffered scalars and routed active optional packs through pair/triple/four-input resolution. Output strings are inserted scalar-by-scalar through the existing UTF-8 insertion path.
- Added `tools/compose_pack.py` to build NLP1 packs from JSON, plus host-side format/generator validation tests.

### Regression coverage and fixes

- The host test verifies header layout, payload CRC, record ordering, one-/multi-scalar outputs, and rejection of duplicates, prefix ambiguity, surrogate scalars, unsafe locale tags, oversized output sequences, and packs claiming built-in en_US.
- The Wayland mock verifies valid-pack loading and actual keyboard-event resolution of a two-input/two-output rule, a three-input rule, and a four-input rule. It also checks unknown-input literal fallback, Escape/Backspace cancellation, and a CRC-corrupt pack falling back to built-in en_US.
- The first test run exposed a wrong tuple offset in the new generator test; [f461a9da7cb2](https://github.com/GraderGamer2/NekoEdit/commit/f461a9da7cb2ef9108bb2b19b4c06e697df8f64a) corrected the test field index.
- The next Wayland run exposed that the literal-fallback source pointed at Compose slots which were cleared before insertion. [8e4e53bcd678](https://github.com/GraderGamer2/NekoEdit/commit/8e4e53bcd678bb9d281f69e5aaaa7a9432408a0f) moves the slot reset after the insertion loop. The regression remains in the final mock.
- Final [Build and test #701](https://github.com/GraderGamer2/NekoEdit/actions/runs/42576739750) passed all eight workflow steps, including the complete Wayland mock, ELF checks, and artifact upload.

**Source commits:** [77f1df75cb0d](https://github.com/GraderGamer2/NekoEdit/commit/77f1df75cb0dba7042119b3c158a8d618a4dce27), [f461a9da7cb2](https://github.com/GraderGamer2/NekoEdit/commit/f461a9da7cb2ef9108bb2b19b4c06e697df8f64a), [8e4e53bcd678](https://github.com/GraderGamer2/NekoEdit/commit/8e4e53bcd678bb9d281f69e5aaaa7a9432408a0f).

**Artifact:** [13656010309](https://github.com/GraderGamer2/NekoEdit/actions/runs/42576739750/artifacts/13656010309), 119,239 bytes; expires 2026-11-16 07:02:43 UTC.

### Remaining work

Publish actual localized pack assets with accurate provenance/licensing, add GUI locale selection and explicit install/remove flows, evaluate system/user Compose-file import, and extend locale-specific dead-key behavior. No live GNOME/Mutter test of an installed external locale pack is claimed.

---

## 2026-11-09 — context-menu implementation and locale-pack design decision (before NLP1 loader)

### Implementation

- Added right-button (BTN_RIGHT) handling for the document viewport only. A right-click opens a compact 128×78 in-surface popup anchored at the pointer and clamped to the usable document area.
- The popup contains exactly three 26-pixel rows: **Copy**, **Paste**, and **Cut**. It is painted above document content and the other surface UI.
- Opening it does not call the document hit-test/caret-placement path, so an existing selection remains intact.
- Menu actions call the existing clipboard command API. Copy retains the selected range in an immutable snapshot; Cut publishes that snapshot before deleting the range; Paste starts the existing data-offer receive operation.
- Added a distinct clipboard_serial handoff from the most recent input event. Keyboard commands update it from the keyboard event; menu Copy/Cut update it from the menu-item pointer-press event. The clipboard C module uses that value for wl_data_device.set_selection, avoiding reuse of an unrelated keyboard serial for a pointer-originated request.
- Escape, a second right-click, or an outside left-click closes the popup. The outside click is intentionally consumed rather than passed through to the document or another control.
- Added no new executable, service, library, or runtime dependency.

### Regression coverage

The added Wayland mock scenario uses the real pointer event and data-device exchange. It validates:
- right-click opens the menu at the requested location;
- Escape closes it;
- opening the menu preserves an active select-all selection;
- Copy sends the selected bytes without changing document contents or clearing selection;
- Cut sends an independent snapshot before deleting the selection;
- Paste requests the external UTF-8 MIME offer, receives asynchronously, and inserts the text;
- Ctrl+Z / Ctrl+Y undo and redo the menu-initiated asynchronous paste;
- outside click closes the popup without click-through.

### Validation

- [Build and test #698](https://github.com/GraderGamer2/NekoEdit/actions/runs/42571651703) passed all eight steps on the first attempt: freestanding build, CLI/host checks, complete Wayland mock (including the new context-menu scenario), ELF inspection, and artifact upload.
- Artifact [13653517472](https://github.com/GraderGamer2/NekoEdit/actions/runs/42571651703/artifacts/13653517472): 116,962 bytes; ZIP SHA-256 8fef7f76439a09c662161cc65b24241a6efc425dd6ee3ea942243a72059d2b80; expires 2026-11-16 06:12:58 UTC.
- No live GNOME/Mutter desktop test is claimed. The user has not yet reported a manual test of this newly added popup.

### Roadmap decision: modular Compose locales

- Keep en_US.UTF-8 as the default, built-in Compose dataset in the core binary.
- Keep every other locale optional and separately distributed as a versioned, data-only pack in GitHub Releases.
- Add a bounded runtime data loader in a later milestone; reject incompatible versions, invalid records, excessive sizes/counts, and bad Unicode scalars, and fall back to built-in en_US.
- Do not load native libraries or arbitrary executable plugin code. Do not require network access or automatic downloads for the editor to function.
- Treat optional locale download/install as a separate explicit workflow. Four-symbol sequences and multi-codepoint results should be generated into packs rather than inflating the core binary.
- The format, pack builder, release assets, installation UX, and loader are all future work; this milestone only records the architecture.

### Files changed

- src/backend/wayland.S
- src/backend/clipboard.c
- tests/wayland_mock.py
- README.md
- docs/COMPOSE.md

---

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

