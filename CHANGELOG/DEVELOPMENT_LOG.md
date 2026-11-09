## 2026-11-10 — correct newline escaping in printable-ASCII keysym regression

- Build and test [#775](https://github.com/GraderGamer2/NekoEdit/actions/runs/42669004934) completed the freestanding build and earlier command-line tests, then failed in the newly added no-header ASCII keysym test.
- The fixture wrote two literal backslashes before each `n`, so the three intended Compose rules were concatenated. The parser correctly rejected the malformed result token; this was a test-fixture defect, not evidence of a parser/runtime regression.
- Reduced each source literal to one Python newline escape, preserving the three assertions for printable ASCII named inputs and keysym-only results.
- Full Build and test rerun is pending. Do not treat #775 as a passing validation.

---
## 2026-11-10 — resolve named printable ASCII keysyms without keysymdef.h — CI pending

- Inspected the current `early-alpha` source, importer specification, tests, PR head, and the #774 installer validation before changing code.
- Added a static fallback for the standard printable ASCII X keysym names. It covers named punctuation keysyms and their deprecated quote aliases; literal ASCII letters/digits continue through the existing one-character path.
- Preserved precedence for the optional caller-supplied X.Org keysym definitions. Non-ASCII named symbols still require that header, while `Uxxxx` keysyms remain self-contained.
- Added a no-header regression that checks both input-key resolution and unquoted keysym-only result resolution. Existing include, encoding, cycle, resource-limit, and installation tests are unchanged.
- Updated `docs/COMPOSE_USER_IMPORT.md` to make the no-header behavior explicit.
- Full CI and the exact revision result are pending. #774 remains the latest green baseline and does not include this fix.

---
## 2026-11-09 — one-command private user XCompose installer; Build and test #774 passed

- Rechecked the live branch before continuing: the Finnish/Serbian physical dead-key keyboard tests were already implemented in 98144943b5ae and green in #759. The offline user XCompose importer and converter-to-manager integration were also already present.
- Verified that Build and test #773 passed all 13 workflow steps on 669d552ff0ed. It closed the History long-query test's Browse-coordinate regression and passed the full Wayland History workflow.
- Added tools/install_user_xcompose.py. It calls the existing bounded ComposeImporter and compose_pack encoder in memory and installs the result directly under ~/.nekoedit/locales/<locale>.nlp. No intermediate JSON file or second pack-builder command is required.
- The utility is optional and host-side. No Python interpreter, subprocess, shell invocation, network request, or extra runtime library was added to the freestanding editor.
- Directory creation/opening uses home-relative directory file descriptors and O_NOFOLLOW checks. The installer rejects non-owned/symlinked .nekoedit path components, tightens both app directories to mode 0700, installs a 0600 pack, and fsyncs file and directory.
- The default publish is atomic and no-clobber. --replace is explicit and only replaces a regular existing pack. The selected XCompose file, included files, and keysymdef.h are protected from output collisions.
- Added tests/install_user_xcompose_test.py to verify pack header/size/locale, fixed destination, permissions, source preservation, refusal to overwrite, explicit replacement, temporary-file cleanup, and symlink rejection. Added it to make test.
- Updated docs/COMPOSE_USER_IMPORT.md and README with the one-command path and the explicit boundary: manual import only, no auto-discovery/startup merge or Settings importer UI.
- Build and test #774 passed all 13 steps on source commit b53ffd4809fa, including the new test, existing host checks, full Wayland mock, pinned X.Org regeneration, locale pack builds, and both artifact uploads. Artifacts: editor ZIP 13691852154 (127,343 bytes) and locale ZIP 13691932145 (74,021 bytes), expiring 2026-11-16.
- No live GNOME/Mutter test was run. The new tool only writes a data-only NLP1 pack; the existing Settings dropdown discovers it on refresh.

Source commit: [b53ffd4809fa](https://github.com/GraderGamer2/NekoEdit/commit/b53ffd4809fa390709f9947bde383ac570ac81d7). Validation: [Build and test #774](https://github.com/GraderGamer2/NekoEdit/actions/runs/42656480878).

---
## 2026-11-09 — correct History mock pointer coordinates after long-query test

- Build and test #772 passed the freestanding build and all host-side tests, including the user-XCompose locale-manager fixture after the quoted-result correction.
- The Wayland mock reached the new History search case: it typed all 127 query characters, saw zero matches, observed a horizontally scrolled display start and an in-field caret, and successfully cleared the query back to one match.
- The test then timed out waiting for the History Browse redraw because the follow-up edit passed the new serial value as the first `workflow_click` argument (x) instead of the third argument (serial). The application was not receiving a click inside the Browse button.
- Restored the actual History control coordinates (Browse x=700, Open Selected x=100, Undo x=100, Redo x=300, Export x=480, Delete x=660) and assigned the larger serials to the third argument. This is a test-harness correction only; no runtime behavior is changed.
- Build and test #773 passed the full History path, including the positive path match and Browse/Open/Undo/Redo/Export/Delete operations.

---

## 2026-11-09 — correct the locale-manager XCompose result fixture discovered during History-filter CI

- Build and test #771 successfully assembled and linked the freestanding executable after the History-query BSS/address corrections.
- `make test` then reached the locale-manager user-XCompose integration fixture and rejected `<Multi_key> <e> <e> : U018F U018F`. The importer intentionally accepts either a quoted output string (optionally followed by one result keysym) or a single Unicode-resolvable keysym. The two-symbol unquoted result was invalid and contradicted the public converter example.
- Corrected the synthetic fixture to `<Multi_key> <e> <e> : "Ə" U018F`, which emits U+018F as quoted Unicode text while retaining the conventional result-keysym annotation. The parser was not weakened.
- The new History filter viewport/caret assertions have not yet executed in CI; Build and test #772 must validate both the manager fixture and the long-query Wayland scenario.

---

## 2026-11-09 — make the History path filter usable with long queries

- Added a dedicated visible-query buffer for the History search field. The original 128-byte query buffer remains the source of truth for filtering.
- The display slice now follows the insertion point and horizontally scrolls when the typed path/query exceeds the available field width. A visible caret tracks pointer focus, Left/Right, Home/End, insertion, Backspace, Delete, and Ctrl+A clear.
- Extended the Wayland integration scenario to type the full 127-character query limit, assert zero matches, verify horizontal scrolling and an in-field caret, clear the query, then continue with the existing positive path-match, Browse, Open Selected, Undo/Redo, Export, and Delete checks.
- The filter remains a case-insensitive substring search over stored document paths. This change does not modify journal formats, stored paths, query limits, or runtime dependencies.

Baseline [Build and test #767](https://github.com/GraderGamer2/NekoEdit/actions/runs/42640512116) passed all 13 steps. Validation of this History filter revision is pending its push-triggered Actions run.

---

## 2026-11-09 — test the user XCompose converter through the freestanding locale manager

- Build and test #767 passed all 12 steps after a held-key mock race was corrected.
- Extended tests/compose_locale_manager_test.py to build a user pack through the actual CLI sequence: selected XCompose file → import_user_xcompose.py → JSON → compose_pack.py → NLP1.
- The fixture includes an allowed %H fragment and a root dead-key rule. It emits a Multi_key e e mapping to U+018F and dead_acute+c to ç.
- Extended tests/compose_locale_manager_test.c to receive the generated pack, install it under the temporary HOME/.nekoedit/locales directory, verify private file permissions, load the custom locale, query both kind-0 and kind-1 records, and remove the pack while confirming en_US fallback.
- This is host/runtime-manager integration coverage only; the editor assembly, pack format, and converter runtime remain unchanged. The user importer still is not wired into Settings or automatic ~/.XCompose discovery.
- The preceding #766 failure was a test event-order race: the held Enter test started before the previous printable key's repeat cancellation was acknowledged. The new wait for repeat_keycode=0 is covered by successful #767.

---

## 2026-11-09 — validate offline XCompose importer and serialize held-key mock transitions

- Build and test #766 passed the freestanding build, command-line tests, existing X.Org importer, the new bounded user XCompose importer test, all three locale table checks, and locale manager validation.
- The new importer test now separately covers repeated non-recursive includes, explicit %H/%S/%L handling, path/canonical symlink boundaries, cycle detection, per-file/aggregate bytes, lines, records, include depth/expansions/unique files, modifier skips, Unicode keysyms, Latin-1 escape decoding, UTF-8 BOM, private output, and source/output collision.
- #766 failed later in the broad Wayland test, before any new XCompose runtime integration. The held printable key's key-up was sent together with a buffer release; the test started holding Enter before the child event loop acknowledged repeat cancellation. The mock then observed document bytes aaa plus newline and repeat_keycode=28, but its caret-frame assertion saw the prior row.
- Added a bounded wait for repeat_keycode=0 immediately after the printable key-up and before initiating Enter. This serializes the mock's held-key phases without altering the runtime repeat delay or reducing assertions.
- This is a Wayland test-harness ordering fix, not an editor implementation change. Build and test #767 must confirm the entire protocol suite.

---

## 2026-11-09 — add bounded offline user XCompose conversion

- Added a separate tools/import_user_xcompose.py rather than modifying the pinned X.Org Compose.pre regeneration tool. It converts an explicitly selected user file into JSON accepted by the existing NLP1 pack builder.
- Implemented quoted-result parsing with source encodings and octal/hex byte escapes, Unicode-scalar keysyms, quoted include parsing, depth-first expansion, later duplicate overrides, same-kind prefix filtering, Multi_key/dead-key namespaces, and explicit unsupported-rule statistics.
- Include resolution is allowlisted to %H/relative, %S/relative, and exact %L with a caller-supplied Compose file. Canonical path containment prevents symlink escape; an active include stack rejects cycles while repeated non-recursive includes remain valid.
- Bounded the import at 512 KiB per file, 4 MiB aggregate expanded bytes, 32 unique files, 64 expansions, depth 16, 64 KiB per line, 32,768 records, four following Multi_key inputs, and eight output scalars. Modifier-qualified rules are skipped because NLP1 does not encode modifier-state predicates.
- JSON writes are atomic and private (file mode 0600); newly created output directories are mode 0700. The CLI blocks output collision with its imported input or keysym header. No network downloads, shell expansion, plugin loading, or runtime shared library was added.
- Added a host test covering nested %H/%S/%L includes, source order/overrides, modifier skipping, unsupported keysyms, cycles, traversal and symlink escapes, per-file/aggregate/line/count/depth/expansion limits, encoding/BOM behavior, private output, and source/output collision.
- Actions #761/#763/#764 exposed fixture escaping and a bytes-literal syntax error. #765 then reached the resource tests but failed because the unique-file-limit test reused the .XCompose file intentionally replaced by the previous cycle test. The current correction uses a separate valid root for unique-file and aggregate-byte limits; full CI remains pending.
- Documentation now distinguishes manual conversion from automatic ~/.XCompose discovery and Settings integration, neither of which is implemented yet.

Importer commits: 94d0f9661a01, 198ec64b7ab8, bf39555139a9, ac038c35eb16, df4c0d8bf3a7. The resource-fixture correction and documentation commit is listed in CURRENT_STATUS.md and COMMIT_INDEX.md.

---

## 2026-11-09 — verify Finnish and Serbian locale dead-key keyboard paths

- Build and test [#759](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236) passed every workflow step, including the full Wayland protocol mock, pinned X.Org data regeneration, optional locale-pack builds, and both artifact uploads.
- Finnish and Serbian tests now exercise the same locale dead-key input through the physical XKB mock: the fixture's `DA01` key emits `dead_apostrophe` (U+0301), and `AC08` emits `Cyrillic_ka` (U+043A). Both locale packs return U+045C (`ќ`), not a generic decomposed fallback. Tests check the armed mark before the base key, the resulting UTF-8 bytes, cleared pending state, and lookup output.
- The locale-data regression explicitly pins `[U+0301, U+043A] → U+045C` in both JSON tables. The existing Finnish `Multi_key f i` and Serbian grave-plus-Cyrillic-a tests remain in place.
- Test commit: [98144943b5ae](https://github.com/GraderGamer2/NekoEdit/commit/98144943b5aed894c103f8fa2b8049ac60e5ef52). The branch's later documentation-only commit is [5f87db08acd8](https://github.com/GraderGamer2/NekoEdit/commit/5f87db08acd85ab064a7c5b8a99a873f8f5dddaf).
- Artifacts from #759: Linux x86-64 ZIP `13681366275` (126,958 bytes) and locale packs ZIP `13681910677` (74,021 bytes), expiring 2026-11-16. No published Release was created. No runtime source or locale JSON changed in this milestone.

### Next

Begin the bounded offline `.XCompose` importer. Before implementation, document its grammar subset and safety boundary: allowlisted include roots/expansions, canonical-path cycle detection, bounded file count/bytes/records, depth and output limits compatible with NLP1, Unicode-scalar keysym resolution, and no shell expansion or code execution. Keep installation data under `~/.nekoedit/locales/`.

---
## 2026-11-09 — verify pt_BR Settings flow; add Finnish/Serbian locale dead-key event coverage

### Completed validation

- Build and test #758 passed all 12 steps on source commit `81937968d94b`: freestanding ELF/CLI, full Wayland protocol suite, executable inspection, pinned source regeneration verification, locale-pack builds, and both artifact uploads.
- The Settings integration path now covers the installed-locale dropdown, Escape and keyboard selection, actual `pt_BR` `Multi_key e e` → U+018F, locale `dead_acute + c` → ç, saved Base en_US selection, Add Pack validation/source preservation/reselection, and confirmed Remove Pack/fallback.
- The #751–#757 debugging chain was closed without a runtime patch: the synthetic-only snowman expectation was replaced with the actual pt_BR U+018F rule; its expected UTF-8 was corrected from C7 8F to C6 8F; the Settings scenario timeout was raised to 50 seconds; and the final guard was changed to require the three current observation strings.

### Finnish/Serbian physical dead-key tests

- Commit `98144943b5aed894c103f8fa2b8049ac60e5ef52` adds a data-level assertion for `[U+0301, U+043A]` → U+045C in both `fi_FI.UTF-8` and `sr_RS.UTF-8`.
- The two Wayland keyboard tests preserve their existing Multi_key coverage, then exercise the alias `dead_apostrophe` (U+0301) followed by a Cyrillic-ka keysym. The fixture maps physical AC08 to `Cyrillic_ka` and verifies the pending-mark state, clearing after insertion, `compose_locale_output == U+045C`, and exact cumulative document bytes.
- This is test-only coverage: the locale JSON source and runtime implementation were not modified by this commit.
- Build and test #759 is the first run for this new test commit and was in progress when this entry was recorded. Results are not yet claimed.

### Validation boundary

Full CI and generated artifacts are confirmed for the #758 baseline; Finnish/Serbian physical-key dead-key integration is pending #759. Live GNOME/Mutter testing remains outstanding.

Commit: [98144943b5ae](https://github.com/GraderGamer2/NekoEdit/commit/98144943b5aed894c103f8fa2b8049ac60e5ef52).

---
## 2026-11-09 — typed locale dead-key Compose rules and Settings integration debugging

- Extended NLP1's 16-bit record-reserved field with rule kind 0 (Multi_key) and kind 1 (dead-key). Existing version-1 packs with zero in this field remain backward-compatible.
- Updated the freestanding loader's validation, ordering, lower-bound lookup and prefix comparison to include kind. Updated the Wayland input path to query kind 1 after a dead-key action plus one following scalar.
- Updated the X.Org importer to normalize recognized dead_* actions to combining marks and import one following Unicode scalar. Rebuilt the three pinned locale datasets; their previous Multi_key records remain semantically unchanged.
- Host-side pack generator, importer, locale manager, and locale-data checks passed in the prior runs. Freestanding ELF build and CLI smoke tests passed in #751–#753.
- The Settings mock now installs the real pt_BR data rather than a small synthetic pt_BR pack. The earlier test's o i → snowman assertion was specific to aa_TEST, not Brazilian Portuguese. The real pt_BR check was switched to e e → U+018F, a mapping explicitly covered by the committed locale-data regression; #752 and #753 still failed there.
- Added failure diagnostics for the selected locale tag, XKB values for Multi_key/e, the runtime locale output buffer, Compose state, and document cursor/length in 0df8881843cd9ec3a16dfecaf181dddd2d78907d. Commit bbbb1c167a485702ca12f5fe6129fc54e4eb9002 corrects U+018F's UTF-8 bytes (C6 8F) in the three cumulative assertions, including after dead-key insertion and after Add/reselection.
- Corrected the locale-format docs and the data scope text; this log does not claim a green full-workflow run or live GNOME/Mutter verification.

Relevant implementation commits: 228e7c25f482, 9fc51163cac0, daed2736b4e7. Test corrections: 2d518e3f70b1, bbbb1c167a48, 820412fb8794, and 81937968d94b. Documentation: 0bb95b5c5e4f. Diagnostic: 0df8881843cd. Changelog status correction: 612ed6f9196f220cdc875f7ba476834676e0d69d.

---
## 2026-11-09 — repair missing development-branch Actions trigger

The user clarified that they were already viewing **All workflows**; this was not a sidebar filter problem. Inspection established two independent trigger blockers:

1. The earlier PR HEAD [457695f8f6ea](https://github.com/GraderGamer2/NekoEdit/commit/457695f8f6ea364a15b25b555e8c628ed6af1cbb) had `[skip ci]` in its subject. GitHub skips eligible `push` and `pull_request` workflows when the HEAD contains a skip annotation.
2. A non-skipping follow-up [8c52fc1cd09e](https://github.com/GraderGamer2/NekoEdit/commit/8c52fc1cd09ebd3116cb7afa83669a11aa952950) did not produce a PR run. PR #2 still reports `mergeable=false` and `main` is three commits ahead of `early-alpha`. GitHub's official troubleshooting documentation confirms that `pull_request` workflows do not run while the PR has a merge conflict. The old workflow only listened for pushes to `main`, so the development branch had no alternative trigger.

### Workflow correction

- [2afe1b1d9375](https://github.com/GraderGamer2/NekoEdit/commit/2afe1b1d93751a54da640c11cb8f5047e93e0215) updates `.github/workflows/build.yml`.
- Pushes to `main` and `early-alpha` now trigger Build and test directly.
- Pull-request runs are restricted to `opened`, `reopened`, and `ready_for_review`; subsequent same-repository commits are tested by the branch-push trigger rather than a second PR `synchronize` run.
- Changelog-only commits are excluded using `paths-ignore: CHANGELOG/**`; source, tests, and workflow changes still trigger builds.
- The PR has not been merged and its merge conflict has not been resolved. This change makes source validation independent of that mergeability state; it does not repair the PR merge conflict itself.

### Validation boundary

The PR-only workflow lookup returned no run for the new head, and the combined-status lookup returned no status context. That connector lookup explicitly filters to pull-request-triggered runs, so it cannot confirm the new push-triggered run. No passing CI result is claimed. The user can see the `early-alpha` push run in **All workflows**; the dead-key implementation remains unverified until it completes.

Continuity updates:
- [0b3f19cc3a78](https://github.com/GraderGamer2/NekoEdit/commit/0b3f19cc3a78af5aa71892dbba76113d6afa3754) records the skip-marker/CI policy in CHANGELOG/README.md.
- [c50b4ab02e5f](https://github.com/GraderGamer2/NekoEdit/commit/c50b4ab02e5f057a636a477c49cdf3c1e35c5405), [f42cc77768c5](https://github.com/GraderGamer2/NekoEdit/commit/f42cc77768c5dda2ee5026282c77fa7f9502bd72), [0e7d31960bc4](https://github.com/GraderGamer2/NekoEdit/commit/0e7d31960bc437656ecf49dc9d536fab91145a71), and [75f84f844aa4](https://github.com/GraderGamer2/NekoEdit/commit/75f84f844aa40f343ef20fbe86e2a3475f1986e1) update the diagnosis, continuity index, and current status.


---

## 2026-11-09 — expand XKB combining dead-key actions — CI pending

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation/test commits:** [2bfe46ee19b0](https://github.com/GraderGamer2/NekoEdit/commit/2bfe46ee19b0dda91d39fd4b208a805abebf6418) and [528b8d680652](https://github.com/GraderGamer2/NekoEdit/commit/528b8d68065213173c9bdde9ba24bf2262da0fec).
**Comment correction:** [42747acc3102](https://github.com/GraderGamer2/NekoEdit/commit/42747acc3102ab133b4a263d55f09d98b74e89d0).

- Extended the named-keysyms table from the original six dead-key actions to 35 standard combining dead-key actions. This adds macron, breve, dot/ring, double accents, caron, ogonek, iota, Japanese voiced/semi-voiced marks, below marks, overlay marks, and German T3 actions, with the X.Org aliases mapped to their canonical action.
- Preserved the existing marker IDs `0x110001`–`0x110006` and the `Multi_key` marker `0x110007`. New dead-key markers occupy `0x110008`–`0x110024`; the reserved `Multi_key` slot remains bypassed by the dead-mark lookup.
- Expanded the combining-mark table and renamed the internal Latin-1-only lookup to `doc_compose_precomposed`. The table keeps the original 52 Latin-1 pairs and adds 30 curated Latin Extended-A pairs for macron, breve, caron, ogonek, and below-dot.
- Unsupported base/mark pairs still insert the base scalar followed by its combining mark. The editor does not pretend every key has a precomposed form.
- Extended the dedicated Unicode-keyboard mock keymap with `dead_macron`, `dead_caron`, and `dead_belowdot`. Assertions check their marker values, precomposed `e + macron → U+0113` and `e + caron → U+011B`, and the decomposed `w + U+0323` fallback.
- Corrected the mock's byte-literal escapes after review: the expected values are Python byte escapes, not literal backslash sequences. Updated README and [KEYSYM_UNICODE.md](../docs/KEYSYM_UNICODE.md) with the action coverage and its limits.

**Validation status:** GitHub reports **no workflow run and no status check** for the implementation/test head `528b8d68065213173c9bdde9ba24bf2262da0fec`. The most recent successful branch workflow, Build and test #736, ran on the older installer commit `2fd44f25bde6db5ab9fd889b98a186e3fbcae18b`; it does not validate this dead-key work or the installed-locale dropdown. No live GNOME/Mutter test has been performed for these changes.

**Compatibility boundary:** the NLP1 locale-pack format still represents `Multi_key` input sequences only. Locale-specific dead-key-led Compose rules and system/user `.XCompose` import remain separate roadmap work and require a deliberate format/importer extension.

---

## 2026-11-09 — dynamic installed-locale Settings dropdown — CI pending

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation/test commits:** [748ca5ba9704](https://github.com/GraderGamer2/NekoEdit/commit/748ca5ba97042b137a64211da07a641e409a567c), [5514f193dd04](https://github.com/GraderGamer2/NekoEdit/commit/5514f193dd0436cfd9af641e0069f4069771f611), [0dbe8df16673](https://github.com/GraderGamer2/NekoEdit/commit/0dbe8df16673ea2d595f7a25c7529c2647a26062), [c6c380a08257](https://github.com/GraderGamer2/NekoEdit/commit/c6c380a08257c24ec1a19edf2bbefb8d36e9e902), [65d2a43e2f72](https://github.com/GraderGamer2/NekoEdit/commit/65d2a43e2f729526548187677c95efb6f62b847e), [1d4168b8683c](https://github.com/GraderGamer2/NekoEdit/commit/1d4168b8683cd705c701f5b5aef8b836b6048ab0), and [241391a4e279](https://github.com/GraderGamer2/NekoEdit/commit/241391a4e279bc7404e27cc0fad39566a499681a).

- Replaced the Settings locale file-picker selection action with an in-menu dropdown backed by the existing bounded scanner for `~/.nekoedit/locales/*.nlp`. Built-in en_US is the first item; installed packs follow the scanner's deterministic ordering.
- Opening Settings refreshes the installed-pack list. Successful Add and confirmed Remove refresh it immediately as well. The selected locale is matched to the saved/effective locale and highlighted.
- Mouse selection and Up/Down/Enter keyboard navigation are supported; Escape closes only the dropdown. Selecting an installed locale reuses the existing validated loader path without displaying the file picker.
- Add and Remove remain separate Settings actions. Add still copies a validated pack into `~/.nekoedit/locales/`; Remove still requires confirmation and returns to en_US.
- Added Wayland mock assertions for the installed list, no-picker selection, Escape dismissal, keyboard selection, newly installed pack visibility, selection after Add, and list refresh after Remove.

**Validation status:** No workflow run or check status was returned for the updated PR head at the time this entry was written. Build and test #736 passed the previous locale-manager implementation, but it predates this dropdown change and is not evidence for it. The new Wayland mock assertions have been added but remain unexecuted in CI.

**Remaining boundary:** no live GNOME/Mutter desktop run has been performed for the new dropdown. The feature remains on `early-alpha`; PR #2 has not been merged.

---

## 2026-11-09 — make the Compose locale installation destination visible — Build and test #736 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation/test commit:** [2fd44f25bde6](https://github.com/GraderGamer2/NekoEdit/commit/2fd44f25bde6db5ab9fd889b98a186e3fbcae18b).

- The Settings **Add** picker now distinguishes the selected source folder (**SOURCE**) from the installation destination (**TARGET: `~/.nekoedit/locales/`**).
- A selected NLP1 pack is still validated before it is atomically copied to `$HOME/.nekoedit/locales/<locale-tag>.nlp`; the original source file is not moved or consumed.
- The application and locale directories remain mode 0700, installed pack files mode 0600, and locale selection is persisted in `~/.nekoedit/preferences`.
- Extended the host manager test to assert that the directory API returns exactly `$HOME/.nekoedit/locales`. The existing test still checks valid-pack activation/lookup, CRC-corrupt and symlink rejection, permissions, and removal.
- The Wayland mock exercised the Settings locale list, Base selection, Add installation/activation, source-file preservation, and confirmed Remove restoring en_US.

**CI:** [Build and test #736](https://github.com/GraderGamer2/NekoEdit/actions/runs/42601389047) passed. The freestanding build/ELF checks, command-line and host tests, complete Wayland mock, pinned X.Org source verification/regeneration, all locale pack builds, and artifact uploads succeeded.

**Artifacts:** editor [13666405540](https://github.com/GraderGamer2/NekoEdit/actions/runs/42601389047/artifacts/13666405540), 125,184-byte ZIP, SHA-256 `8a9250a86fe2b751c45ad5270b27a4556d00a7b73c16629ea75210abafbb31f1`; locale packs [13665239303](https://github.com/GraderGamer2/NekoEdit/actions/runs/42601389047/artifacts/13665239303), 53,740-byte ZIP, SHA-256 `7a6c8edbeb28c3dbfc01c623705a2667c9d7ec7fec9ec04bae8d545353ad87ac`. Both expire 2026-11-16 10:31 UTC.

**Validation boundary:** automated host and mock-Wayland checks only; this does not claim a live GNOME/Mutter desktop retest.

---

## 2026-11-09 — report text-input-v3 change origin to the compositor — Build and test #735 passed

### Runtime change

- Added a four-byte `set_text_change_cause` request (opcode 4) to the text-input-v3 state update sequence. The cause is committed atomically with surrounding text and cursor geometry.
- Editor-originated changes routed through `.keyboard_changed` mark the cause as `other` (1). Text-input-v3 `done`, enter, and leave state resynchronization uses `input_method` (0).
- A successful state `commit` resets the local cause flag to 0, matching the protocol's initial/default value and preventing an old user edit from leaking into a later IME update.
- The request is sent before `set_surrounding_text` and `set_cursor_rectangle`. The implementation does not enable text-input-v3 by default and adds no new runtime dependency.

### Regression coverage

- Extended the Wayland mock's `expect_state` helper to require opcode 4, a four-byte payload, correct ordering before opcode 3, and the expected cause.
- The Shift+Left selection case asserts `other=1`. The following IME-originated delete-surrounding update asserts `input_method=0`, covering the reset and preventing stale cause state.
- The full mock retains the preedit UTF-8/cursor-offset, malformed event, multibyte commit, selection/deletion, surrounding-text boundary, enable/disable, and serial checks.

### Validation

- [Build and test #735](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663) passed all 12 workflow steps on [7b07ce26a158](https://github.com/GraderGamer2/NekoEdit/commit/7b07ce26a1587865e7c5c1bc203e140ee948d891), including the full Wayland mock and the three external locale pack builds.
- Locale artifacts: 53,740-byte ZIP [13663108897](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663/artifacts/13663108897), SHA-256 `b250539c4ddeb7ae321dda7aa3d4642154a456279611770988431b89d54e9586`.
- Editor artifact: 125,040-byte ZIP [13664216595](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663/artifacts/13664216595), SHA-256 `514c53ebfe0b7fe1aebf50c9004e2986eed7117c38d2503dfac2311e3d08c916`.
- Added [docs/TEXT_INPUT_V3.md](../docs/TEXT_INPUT_V3.md). The IME remains opt-in; live GNOME/Mutter verification is not claimed.

### Next work

Perform a live GNOME/Mutter text-input-v3 test when a desktop IME can be exercised, and continue the remaining XKB/locale/typography roadmap without making experimental IME input the default.

**Implementation commit:** [7b07ce26a158](https://github.com/GraderGamer2/NekoEdit/commit/7b07ce26a1587865e7c5c1bc203e140ee948d891).

---

## 2026-11-09 — automatic character-locale discovery, aliases, and precedence tests — Build and test #711 passed

### Runtime behavior

- Extended `compose_locale_load()`: a saved Settings preference remains authoritative; otherwise the first non-empty value among `NEKOEDIT_LOCALE`, `LC_ALL`, `LC_CTYPE`, and `LANG` is selected.
- Empty variables are skipped. Common pt_BR names (`pt_BR`, `pt_BR.utf8`, `pt_BR.UTF8`, and implemented lower-case-country variants) normalize to the canonical `pt_BR.UTF-8` pack tag.
- en_US and C/POSIX aliases keep the embedded default. Unsupported non-empty higher-priority values leave en_US active rather than falling through. `LC_MESSAGES` and `LANGUAGE` are intentionally ignored because they concern message translation, not character input.
- This is direct environment parsing in the freestanding C loader. No libc locale subsystem, message catalog, executable plugin, download service, or runtime library was introduced.

### Regression coverage and corrections

- Added Wayland end-to-end scenarios for LC_CTYPE after empty LC_ALL, LANG after both higher-priority variables are empty, pt_BR.utf8 and bare pt_BR aliases, and a saved en_US choice overriding pt_BR process environment.
- Each test types the Compose sequence and checks the resulting multiscalar UTF-8 bytes; it does not stop at checking the loader-active flag.
- [aa35f95ea95e](https://github.com/GraderGamer2/NekoEdit/commit/aa35f95ea95eb1eea792fa692e0be3fb3f672fe5) corrected an earlier fixture that had literal backslash-n text instead of two valid preferences lines. The final #711 run includes the corrected fixture.
- The #711 log also confirms the LC_ALL precedence and C fallback cases, plus the persistent Settings selection test.

### Validation

- [Build and test #711](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908) passed all 12 steps on the documentation-sync tree: freestanding build, CLI/host tests, full Wayland mock, ELF inspection, pinned-source blob checks, exact JSON regeneration, locale-pack generation, and both artifact uploads.
- Locale pack: 151,288 bytes; artifact [13657749061](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908/artifacts/13657749061), ZIP 17,943 bytes, SHA-256 `aed84a5b2f6622f6c1a97485bde302a9a15f6e37c6ba61d0975d3affe770bcab`.
- Editor binary: 120,558 bytes; artifact [13658670522](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908/artifacts/13658670522), ZIP SHA-256 `3e28c207ff4667d74dfdfe526aa9ffa43f4ade3c0dc2fe15afcd11455eda8619`.

### Remaining work

Add an in-app pack installer/remover, more locale tables, locale-specific dead-key data, and optional system/user Compose import. The GitHub Release attachment workflow is implemented but has not been exercised by publishing a new project Release. Live GNOME/Mutter verification remains outstanding.

**Implementation/test commits:** [74110d69492e](https://github.com/GraderGamer2/NekoEdit/commit/74110d69492eb168b93f3020890e37300afe585e), [39f61c7e27f9](https://github.com/GraderGamer2/NekoEdit/commit/39f61c7e27f9c8ba715637e41a3e3389f7051260), [aa35f95ea95e](https://github.com/GraderGamer2/NekoEdit/commit/aa35f95ea95eb1eea792fa692e0be3fb3f672fe5).

**Documentation/graph commits:** [3501b7411d98](https://github.com/GraderGamer2/NekoEdit/commit/3501b7411d98ff37b1cd2bcc69145f5f1d4d2ab7), [533700d4d45f](https://github.com/GraderGamer2/NekoEdit/commit/533700d4d45f1c13239aef3adfe332b59e07b7bd), [e14283bd3405](https://github.com/GraderGamer2/NekoEdit/commit/e14283bd34057f7f4c547e9fcc41c149f1b67744), [36edf26d251f](https://github.com/GraderGamer2/NekoEdit/commit/36edf26d251fea2edc016b46277b12629d50440f), and merge sync [fd6054789a3b](https://github.com/GraderGamer2/NekoEdit/commit/fd6054789a3bad1f1d0d4c727bc8b19248c286c7).

---

## 2026-11-09 — persistent Settings locale selector — Build and test #709 passed

### Preference and loader integration

- Added a bounded compose_locale=<tag> value to the existing per-user preferences file. The config remains version 1 and line-oriented; locale tags are validated before storage or path construction.
- A saved choice takes precedence over NEKOEDIT_LOCALE. If no preference is present, the environment override remains available as a first-run choice. Saving en_US.UTF-8 explicitly returns to the embedded table and suppresses the environment.
- Preference host tests cover both locale values, persistence, reload, and rejection of traversal, separators, newline injection, and overlong tags.

### Settings UI

- Added a COMPOSE LOCALE row in the lower part of the existing Settings dropdown. It toggles between built-in en_US and an installed pt_BR.UTF-8 pack without increasing the panel footprint.
- If pt_BR is selected but unavailable, the row displays MISSING and the embedded en_US table remains active. Selecting a locale never downloads or installs a pack.
- The new UI test exposed a title-bar hit-test conflict: the top resize band previously intercepted clicks over Settings. The shared resize hit-test now exempts the Settings button while retaining the blank top-edge resize region.

### Wayland integration and regression coverage

- The Settings mock opens the dropdown through pointer input, clicks the locale row, verifies that pt_BR is active without changing document contents, closes Settings, types the o-i Compose sequence and checks the multiscalar UTF-8 output, then returns to en_US.
- The mock checks that compose_locale=en_US.UTF-8 was saved. A guard fails the test if the Settings scenario is requested but its success observation is missing.
- The first attempts found two issues: a legitimate cursor-shape request needed to be consumed by the mock before checking surface redraw, and the application resize hit band needed to stop overlapping the Settings button. The latter is a real application fix; the former is test-harness handling.
- [Build and test #709](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652) passed all 12 steps. Its log explicitly contains Settings start/completion markers and the successful Settings/Compose/persistence observation.

### Artifacts

- pt_BR NLP1 pack: 151,288 bytes; artifact [13657516254](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652/artifacts/13657516254), ZIP 17,943 bytes.
- Editor executable artifact [13657600927](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652/artifacts/13657600927), 120,129 bytes.

**Commits:** [7343175f2584](https://github.com/GraderGamer2/NekoEdit/commit/7343175f258430e55db1252d8dcb31dbe9bce40e), [70f216f2197d](https://github.com/GraderGamer2/NekoEdit/commit/70f216f2197d30b3c6af75481d542aad864b12fe), [05d080417878](https://github.com/GraderGamer2/NekoEdit/commit/05d080417878bb71dae54fda4638cd554c3bea08), [241401ea9d1e](https://github.com/GraderGamer2/NekoEdit/commit/241401ea9d1e2529d6da9e5ada340bf64cce84e7), [ce35e0803d0a](https://github.com/GraderGamer2/NekoEdit/commit/ce35e0803d0a586074aa5ddb11d65208cb24fb99).

### Remaining work

Add a Settings-based pack installer/remover, provide more locale datasets, consider automatic system-locale selection, and evaluate system/user Compose-file imports and locale-specific dead-key rules. Live GNOME/Mutter manual verification remains outstanding.

---

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

