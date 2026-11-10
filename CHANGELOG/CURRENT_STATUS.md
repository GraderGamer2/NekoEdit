## 2026-11-10 — installed X.Org Compose corpus compatibility test — Build and test #781 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation:** [a11a4b0ede67](https://github.com/GraderGamer2/NekoEdit/commit/a11a4b0ede6711f5abed47f8e8c2cf666fb5a841).
**CI:** [Build and test #781](https://github.com/GraderGamer2/NekoEdit/actions/runs/42728278622) passed the freestanding build, command-line and host tests, complete Wayland protocol mock, executable inspection, pinned X.Org source regeneration, optional locale-pack build, and both artifact uploads.

- Added `tests/system_xcompose_import_test.py` to exercise the installed X.Org `en_US.UTF-8/Compose` database through a temporary user `.XCompose` containing an explicit `include "%L"`.
- The real system corpus test scanned **5,127** rules and produced **3,747** final records from two files. It verified the system dead-key mapping `dead_acute + e → é`, a user override of `Multi_key o c`, a user-only rule, and two include-order overrides. The resulting **194,916-byte** NLP1 pack passed the existing encoder/runtime-format validation in memory.
- CI installs `libx11-data` and `x11proto-dev` solely to provide the system Compose corpus and keysym definitions for this test. These packages are not linked into NekoEdit and are not runtime dependencies. On developer systems without those optional files, the integration test reports a skip; the deterministic synthetic parser tests still run.
- The test writes only inside a temporary directory, does not install the generated pack, and does not modify the system Compose data or the user's real home directory.
- **Modular locale boundary preserved:** the editor continues to contain only its built-in en_US baseline. The generated optional locale packs are still separate downloadable assets, not linked into the editor executable. Build and test #781 uploaded `nekoedit-linux-x86_64` (127,343 bytes; artifact 13723627010) separately from `nekoedit-compose-locales` (74,021 bytes; artifact 13723811429). Both have the configured one-day artifact retention and expire on 2026-11-11 at 00:27 UTC.
- No application runtime source or locale dataset changed.

## 2026-11-10 — early-alpha artifact retention set to one day — push-run metadata unavailable

**Branch:** `early-alpha`; PR #2 remains open and unmerged.
**Build and test workflow:** [a0d707c5a30c](https://github.com/GraderGamer2/NekoEdit/commit/a0d707c5a30ca6ff27b4005939ffa80fc4678cc1) sets both the Linux executable and Compose locale-pack uploads to `retention-days: 1`.
**Manual/release locale workflow:** [9859912d75d3](https://github.com/GraderGamer2/NekoEdit/commit/9859912d75d3d8dc8941653e09316e141fc0ac3f) sets its locale-pack upload to `retention-days: 1`.

This applies to newly uploaded artifacts only. Existing Build and test #777 artifacts 13722915782 and 13721843648 keep their original 2027-02-08 expiry; they were not deleted or retroactively shortened. The editor build workflow ignores changelog-only updates and changes confined to the separate manual/release locale-pack workflow. No application source or runtime behavior changed.

**Validation boundary:** the workflow YAML is verified, but the GitHub connector available in this session only exposes pull-request-triggered workflow-run lookup. It did not provide the push-triggered run ID or the new artifacts' `expires_at` values. Check [Build and test runs on early-alpha](https://github.com/GraderGamer2/NekoEdit/actions/workflows/build.yml?query=branch%3Aearly-alpha) to confirm the push run and its artifacts.

---

## 2026-11-10 — retain Actions artifacts for the public-repository maximum — Build and test #777 passed

**Branch:** `early-alpha`; PR #2 remains open and unmerged.
**Workflow change:** commit [d9a2d9cca407](https://github.com/GraderGamer2/NekoEdit/commit/d9a2d9cca407f5dc60f7d5e2947600b9329bd0f5) sets the two Build and test artifact uploads and the optional locale-pack workflow upload to `retention-days: 90`, the documented maximum for public repositories.
**CI:** [Build and test #777](https://github.com/GraderGamer2/NekoEdit/actions/runs/42725593861) passed all 13 workflow steps on this commit.

- The Build and test workflow previously set both the executable and Compose locale-pack artifacts to 7 days. The separate manual/release locale-pack workflow used 30 days.
- All three workflow artifact uploads now request 90 days. This affects newly uploaded artifacts only; GitHub does not retroactively extend existing artifacts when workflow retention is changed.
- Existing artifacts from Build and test #776 (IDs 13697074317 and 13698660427) retain their existing 2026-11-16 expiry. Build and test #777 confirms the repository accepts 90 days. Its newly uploaded editor artifact [13722915782](https://github.com/GraderGamer2/NekoEdit/actions/runs/42725593861/artifacts/13722915782) (127,343 bytes) and locale artifact [13721843648](https://github.com/GraderGamer2/NekoEdit/actions/runs/42725593861/artifacts/13721843648) (74,021 bytes) both expire **2027-02-08 00:05:31 UTC**.
- The latest #776 artifacts total 201,364 bytes. GitHub Free includes 500 MB of Actions/Packages storage shared across those products; longer retention does not itself incur a fee, but storage beyond the included allowance may be billable.
- No application source, binary, or runtime behavior changes in this work.

**Validation:** the push-triggered Build and test run is pending. The existing #776 run remains the last fully passing application-source build.

---

## 2026-11-10 — built-in printable ASCII X keysym names — Build and test #776 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation:** [f05a54158632](https://github.com/GraderGamer2/NekoEdit/commit/f05a541586329b0c05097aa5078944e6db0d7187).
**Test-fixture correction:** [74a0a7780885](https://github.com/GraderGamer2/NekoEdit/commit/74a0a7780885f95ffcd1a709d3d2ae55c66d1898).
**CI:** [Build and test #776](https://github.com/GraderGamer2/NekoEdit/actions/runs/42669196064) passed all 13 workflow steps on the corrected head, including freestanding build, all command-line/host tests, full Wayland protocol mock, executable inspection, pinned X.Org source verification, locale-pack build, and both artifact uploads.

- The user XCompose importer now resolves standard printable ASCII X keysym names without requiring the optional X.Org `keysymdef.h`. Added names include punctuation names and the `quoteleft`/`quoteright` aliases; single-character ASCII and `Uxxxx` handling are unchanged.
- Resolution order preserves caller-supplied keysym definitions first, then the built-in printable ASCII fallback. Other named non-ASCII symbols still require a Unicode-annotated keysymdef header.
- The new no-header regression covers named event inputs and keysym-only outputs, including `space`, `quotedbl`, `grave`, `asciitilde`, `quoteleft`, `quoteright`, and `apostrophe`.
- Build and test #775 initially failed only because this new fixture double-escaped its line terminators. The importer rejected the malformed concatenated rule as designed. Commit 74a0a778 corrects the fixture, and #776 passes the complete workflow.
- The user separately confirmed that the installed-locale Settings dropdown works in the desktop build. This manual confirmation is distinct from the automated mock test.
- Artifacts from #776: Linux x86-64 ZIP [13697074317](https://github.com/GraderGamer2/NekoEdit/actions/runs/42669196064/artifacts/13697074317) (127,343 bytes); locale-pack ZIP [13698660427](https://github.com/GraderGamer2/NekoEdit/actions/runs/42669196064/artifacts/13698660427) (74,021 bytes). Both expire 2026-11-16; neither is a published GitHub Release.
- No live GNOME/Mutter keyboard-layout or IME validation was performed.

**Next:** broaden validation against actual user-authored Compose files and clarify any additional syntax/encoding limitations. Keep import explicit and offline; do not add automatic startup discovery as part of this compatibility change.

---

## 2026-11-09 — one-command user XCompose installer — Build and test #774 passed

**Branch:** early-alpha; PR #2 remains open and unmerged.
**Source implementation:** [b53ffd4809fa](https://github.com/GraderGamer2/NekoEdit/commit/b53ffd4809fa390709f9947bde383ac570ac81d7).
**CI:** [Build and test #774](https://github.com/GraderGamer2/NekoEdit/actions/runs/42656480878) passed all 13 steps on b53ffd4809fa, including the freestanding ELF build, command-line/host tests, new installer test, complete Wayland mock, pinned X.Org regeneration, three locale-pack builds, and both artifact uploads.
**Artifacts:** Linux x86-64 ZIP [13691852154](https://github.com/GraderGamer2/NekoEdit/actions/runs/42656480878/artifacts/13691852154) (127,343 bytes); locale-pack ZIP [13691932145](https://github.com/GraderGamer2/NekoEdit/actions/runs/42656480878/artifacts/13691932145) (74,021 bytes). Both expire 2026-11-16; neither is a published GitHub Release.

- Added tools/install_user_xcompose.py. It runs the existing bounded offline ComposeImporter and NLP1 encoder in memory, then installs the binary directly as ~/.nekoedit/locales/<locale>.nlp. The lower-level JSON converter remains available.
- NekoEdit's editor binary remains freestanding. The new utility is an optional Python-standard-library host command; the editor does not launch Python, execute shell commands, discover XCompose files at startup, or add a runtime library.
- The installer opens ~/.nekoedit/locales relative to directory file descriptors, rejects symlinked or non-owned directory components, enforces 0700 directories and 0600 packs, and fsyncs the installed file and directory.
- Existing packs are not silently overwritten. The default no-clobber install uses an atomic hard-link publish; --replace explicitly replaces an existing regular file atomically. Imported source/include files and keysymdef.h cannot be replaced by the output.
- Added tests/install_user_xcompose_test.py and included it in make test. The test validates NLP1 structure, path placement, private modes, source preservation, no-clobber, explicit replacement, temporary-file cleanup, and symlink rejection.
- The installed pack is visible to the existing Settings locale dropdown on its next list refresh. There is still no automatic ~/.XCompose/$XCOMPOSEFILE discovery, system startup merge, or Settings import UI.
- Build and test #773 [passed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42645272935) before this feature. #774 is the first full workflow for the installer and is green. The History long-query/Browse/Open/Undo/Redo/Export/Delete path also passed in #773.
- Finnish/Serbian physical dead-key coverage already passed in #759; do not duplicate that work. Live GNOME/Mutter keyboard-layout and IME behavior remain unverified.

**Next:** exercise the one-command installer against a broader set of actual user Compose files and confirm documented include/encoding behavior. Consider a Settings affordance only if it can invoke the host converter without weakening the freestanding runtime policy. Do not add automatic startup import implicitly.

---
## 2026-11-09 — improve History path-filter usability

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open.
**Baseline:** [216e466a48d8](https://github.com/GraderGamer2/NekoEdit/commit/216e466a48d862d0fdcc908f1e2e329373f7a583); follow-up [Build and test #773](https://github.com/GraderGamer2/NekoEdit/actions/runs/42645272935) passed all 13 steps, including the full Wayland mock and executable/locale artifact uploads.
**Current change:** add a visible History search caret and horizontally scrolled query display; leave the full 127-byte filter buffer and path matching logic unchanged. The Wayland test types a 127-character non-match, verifies zero results and an in-field caret after horizontal scrolling, clears the query, then verifies the path-match sequence.

**Validation:** Actions #768–#770 exposed and corrected the assembly/BSS and indexed-address issues. Build #771 passed `make clean all` but stopped in the locale-manager fixture because its synthetic rule used invalid unquoted `U018F U018F` result syntax; commit 5fcb5f8 corrected it to a quoted Unicode result with one keysym annotation. Action #772 passed all host tests and reached the new History filter scenario, but the Browse click timed out because the test mistakenly put the serial in the x-coordinate argument. Commit 669d552 restored the pointer coordinates. Build and test #773 then passed the complete History flow: 127-character query/caret, clear, Browse, Open Selected, Undo/Redo, Export, and Delete.

---

## 2026-11-09 — end-to-end user XCompose pack-to-runtime coverage added

- Build and test [#767](https://github.com/GraderGamer2/NekoEdit/actions/runs/42640512116) passed all 12 workflow steps. The offline user XCompose importer host test, complete Wayland mock, pinned X.Org regeneration, locale-pack builds, and editor/locale artifact uploads are green.
- Added a second integration boundary to the existing freestanding C locale-manager test. It invokes the user XCompose CLI on a selected file containing a permitted %H include, converts the resulting JSON with the real compose_pack CLI, then passes that generated binary into the C manager.
- The C manager test installs the generated user_TEST.UTF-8 pack beneath HOME/.nekoedit/locales, checks mode 0600, activates it, verifies Multi_key e e → U+018F and dead_acute + c → ç through the actual binary lookup functions, removes it, and confirms en_US fallback. This exercises the converter-to-runtime pack ABI without changing the editor runtime.
- The preceding #766 Wayland failure was fixed by waiting for repeat_keycode=0 after the held printable-key release before starting the held Enter test. #767 confirms the full Wayland mock now passes.
- The importer remains manually invoked. Automatic ~/.XCompose/$XCOMPOSEFILE discovery, system startup merging, and Settings UI integration remain outside this milestone. Live GNOME/Mutter behavior is not claimed.

**Next:** validate the converter's integration against a wider real-world set of user Compose files and decide whether a Settings-driven local import workflow is worth implementing without adding a runtime dependency.

---

## 2026-11-09 — XCompose parser host tests pass; Wayland mock release ordering correction pending

**Branch:** early-alpha; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Importer implementation series:** 94d0f9661a01, 198ec64b7ab8, bf39555139a9, ac038c35eb16, df4c0d8bf3a7.
**Resource-fixture correction:** f850b786ddfe.

- The offline user XCompose converter is implemented as a separate manually invoked tool. It handles bounded, depth-first includes from explicit %H/%S/%L roots, supported Multi_key/dead-key records, safe canonical path containment, cycles, resource limits, Unicode filtering, override order, private atomic JSON output, and NLP1 validation.
- Build and test #766 passed the freestanding build, command-line smoke tests, existing Compose tests, the new user XCompose importer test, locale-data/pack tests, and locale-manager tests. In particular, the new importer test completed successfully, including the separate valid root now used for unique-file/aggregate-byte tests.
- #766 then failed later in the existing Wayland repeat mock: after the printable held-key test sent key-up and released the buffer, the Enter test began before the app acknowledged repeat cancellation. It failed at the initial Enter caret assertion with document bytes aaa + newline and repeat_keycode=28. This is a test event-order issue; no editor runtime failure was established.
- The current harness patch waits for repeat_keycode=0 after the printable key-up before starting the held Enter test. It preserves the original caret and repeat assertions instead of weakening them. Full CI validation is pending the next push-triggered run.
- The importer remains CLI-only. Automatic ~/.XCompose/$XCOMPOSEFILE discovery, startup merging, and Settings UI integration are not implemented. No live GNOME/Mutter verification is claimed.

**Next:** verify Build and test #767. If the full mock passes, the parser milestone is ready for a later Settings import design; do not add startup auto-loading implicitly.

---

## 2026-11-09 — offline user XCompose converter added; fixture validation in progress

**Branch:** early-alpha; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Importer commits:** [94d0f9661a01](https://github.com/GraderGamer2/NekoEdit/commit/94d0f9661a01c3d420850478e4be6327b217e2db), [198ec64b7ab8](https://github.com/GraderGamer2/NekoEdit/commit/198ec64b7ab8622a7dc1fc8c6dec1aa800f6c64d), [bf39555139a9](https://github.com/GraderGamer2/NekoEdit/commit/bf39555139a9ed8fe9b25df8ab370f5f85b04c1c), [ac038c35eb16](https://github.com/GraderGamer2/NekoEdit/commit/ac038c35eb16f76e57daacc835ef38224ff708e9), and [df4c0d8bf3a7](https://github.com/GraderGamer2/NekoEdit/commit/df4c0d8bf3a788388f205f9cfd190b525449bc69).

- Added tools/import_user_xcompose.py, a manually invoked offline converter from a selected user file to NLP1-compatible JSON. It is separate from the pinned X.Org Compose.pre dataset importer.
- The accepted include subset is depth-first %H/relative, %S/relative, and exact %L supplied with --locale-compose. Canonical path checks enforce root containment and active-cycle detection; repeated non-active includes are allowed.
- The converter imports unqualified Unicode Multi_key rules and recognized dead-key-plus-one-scalar rules. Later duplicate entries override earlier ones; same-kind prefixes are removed to fit the immediate-lookup NLP1 model. Modifier-qualified rules and unsupported/non-Unicode symbols are counted and skipped.
- Bounds: 512 KiB per file, 4 MiB expanded bytes, 32 unique files, 64 include expansions, depth 16, line length 64 KiB, 32,768 records, four following Multi_key inputs, and eight output scalars. There is no shell expansion, network access, executable plugin loading, automatic file discovery, or new runtime dependency.
- JSON output is atomic and private (file mode 0600); missing output directories are created with mode 0700. The CLI refuses output collisions with imported inputs or the supplied keysym header. Generated .nlp packs still use the existing pack builder and install under ~/.nekoedit/locales/.
- Actions #761–#765 are not green for this milestone. #764 failed at a non-ASCII character in a Python bytes literal; that was corrected. #765 progressed into resource tests but failed because the unique-file-limit test reused the .XCompose file deliberately replaced by the earlier self-cycle test. The new fixture change uses a separate valid include tree for unique-file and aggregate-byte tests.
- This is a CLI converter only. Automatic ~/.XCompose/$XCOMPOSEFILE discovery, system startup merging, and a Settings import UI remain unimplemented. Live GNOME/Mutter validation is not claimed.

**Next:** validate the corrected user-import tests and complete the full workflow before wiring the converter into Settings.

---

## 2026-11-09 — Finnish/Serbian locale dead-key integration green

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Latest source/test commit:** [98144943b5ae](https://github.com/GraderGamer2/NekoEdit/commit/98144943b5aed894c103f8fa2b8049ac60e5ef52). The later branch commit `5f87db08acd8` only updates continuity documentation.

- Build and test [#759](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236) passed all 12 steps: freestanding ELF build, CLI smoke tests, complete Wayland mock, executable inspection, pinned X.Org source regeneration/verification, locale-pack build, and both artifact uploads.
- The Finnish and Serbian Wayland cases retained their existing Multi_key checks and now also send `dead_apostrophe` (U+0301) followed by `Cyrillic_ka` (U+043A). Both packs resolve the typed dead-key record to U+045C (`ќ`). The tests assert pending-mark state, document insertion, pending-mark clearing, and `compose_locale_output`.
- The generated-data test explicitly checks `[U+0301, U+043A] → U+045C` in both `fi_FI.UTF-8` and `sr_RS.UTF-8`.
- The earlier pt_BR Settings regression is also closed: #758 passed the dynamic locale dropdown, keyboard selection, `Multi_key e e` → U+018F, `dead_acute + c` → ç, Base persistence, Add Pack/source preservation/reselection, and confirmed Remove Pack/fallback.
- Artifacts from #759: [Linux x86-64 executable ZIP](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236/artifacts/13681366275) (126,958 bytes) and [Compose locale pack ZIP](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236/artifacts/13681910677) (74,021 bytes). They expire on 2026-11-16 and are not a published GitHub Release.
- Commit `98144943b5ae` changed tests only; no runtime assembly/C or locale JSON source changed. The complete #759 run confirms the existing runtime handles these records.

### Next bounded roadmap item

System/user `.XCompose` import remains the next locale gap. Start with a bounded, offline build-time importer/parser and comprehensive fixture tests; explicitly define include handling, cycle/size limits, Unicode keysym filtering, depth/output limits, and deterministic failure behavior before wiring any UI. Preserve the data-only NLP1 runtime and the user's `~/.nekoedit/` storage boundary. Do not add network access or executable plugin loading.

### Known boundary

- NLP1 dead-key records support one following Unicode scalar. Longer dead-key chains, non-Unicode input symbols, and system/user `.XCompose` import are not implemented yet.
- Live GNOME/Mutter input and actual physical keyboard-layout behavior remain unverified. The mock tests NekoEdit's XKB parsing and dispatch, not all compositor/IME combinations.

---
---
## 2026-11-09 — enable branch-push CI for early-alpha — validation status not yet confirmed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Workflow change:** [2afe1b1d9375](https://github.com/GraderGamer2/NekoEdit/commit/2afe1b1d93751a54da640c11cb8f5047e93e0215).

- GitHub's official workflow troubleshooting guidance confirms that a PR with a merge conflict does not trigger `pull_request` workflows, and that skip annotations suppress eligible `push`/ `pull_request` runs. The previous PR HEAD [457695f8f6ea](https://github.com/GraderGamer2/NekoEdit/commit/457695f8f6ea364a15b25b555e8c628ed6af1cbb) contained `[skip ci]`.
- A non-skipping follow-up is [8c52fc1cd09e](https://github.com/GraderGamer2/NekoEdit/commit/8c52fc1cd09ebd3116cb7afa83669a11aa952950). PR #2 still reports `mergeable=false` and is three commits behind `main`; its merge conflict has not been resolved in this trigger-only repair.
- Updated `.github/workflows/build.yml`: `push` now includes `main` and `early-alpha`; `pull_request` is limited to `opened`, `reopened`, and `ready_for_review`, so a same-repository branch push does not also create a second synchronize run. Changelog-only commits are excluded from the push/PR workflow path filters.
- This makes the development branch independently testable even while PR mergeability is false. It avoids depending solely on a PR merge ref that GitHub does not create for conflicted PRs.

**CI result:** the new workflow file is on the current branch. The available GitHub connector's commit-run lookup returns only pull-request-triggered runs, not push-triggered runs; its combined-status lookup also returned no status context for the new head. Therefore the push-run itself cannot be confirmed through those two reads, and no passing build is claimed. Check the **All workflows** list for the new `Build and test` run associated with the `early-alpha` push. The dead-key source/test milestone remains unverified until that run completes.

---


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

## 2026-11-09 — report text-input-v3 change origin — Build and test #735 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, unmerged, and clean.
**Implementation:** [7b07ce26a158](https://github.com/GraderGamer2/NekoEdit/commit/7b07ce26a1587865e7c5c1bc203e140ee948d891).

**CI:** [Build and test #735](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663) passed all 12 workflow steps: freestanding build, CLI smoke tests, full Wayland protocol mock, ELF inspection, pinned X.Org source/blob verification, exact locale JSON regeneration, all three pack builds, and separate locale/editor artifact uploads.

- Added text-input-v3 `set_text_change_cause` (opcode 4) to every committed surrounding-text/cursor-state update. It is sent before `set_surrounding_text` and `set_cursor_rectangle`, all within the same state commit.
- Editor-originated keyboard and pointer changes set cause **`other` (1)**. Text-input-v3 `done`/focus synchronization uses **`input_method` (0)**. The local flag resets to the protocol default after each successful commit.
- The mock checks request ordering and the transmitted cause on every text-input state refresh. Shift+Left selection must send cause 1; the subsequent IME-driven delete/resync must return to cause 0. Existing preedit byte-offset, malformed UTF-8 rejection, multibyte commit, delete-surrounding, serial, enable/disable, and redraw tests remain in the full suite.
- Added [docs/TEXT_INPUT_V3.md](../docs/TEXT_INPUT_V3.md), documenting state synchronization, cause semantics, preedit byte offsets, and the live-compositor validation boundary.
- The IME integration remains explicitly opt-in with `NEKOEDIT_ENABLE_TEXT_INPUT=1`; this CI result does not claim a live GNOME/Mutter physical-keyboard/IME test.

**Artifacts from #735:**
- Locale packs ZIP [13663108897](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663/artifacts/13663108897), 53,740 bytes; SHA-256 `b250539c4ddeb7ae321dda7aa3d4642154a456279611770988431b89d54e9586`. Contains the separate `pt_BR.UTF-8`, `fi_FI.UTF-8`, and `sr_RS.UTF-8` pack assets and notices.
- Editor ZIP [13664216595](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663/artifacts/13664216595), 125,040 bytes; SHA-256 `514c53ebfe0b7fe1aebf50c9004e2986eed7117c38d2503dfac2311e3d08c916`.
- Both artifacts expire 2026-11-16 09:56 UTC.

### Remaining text-input work

The text-input-v3 path still needs live GNOME/Mutter validation with an installed input method, broader interaction testing while focus moves between editor and modal surfaces, and any additional cursor/selection edge cases uncovered by desktop testing. Complex-script shaping remains a separate typography milestone; text-input-v3 does not expose arbitrary rich-text attribute runs.

---

## 2026-11-09 — automatic character-locale discovery and precedence — Build and test #711 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, unmerged, and clean.
**Implementation/test commits:** [74110d69492e](https://github.com/GraderGamer2/NekoEdit/commit/74110d69492eb168b93f3020890e37300afe585e), [39f61c7e27f9](https://github.com/GraderGamer2/NekoEdit/commit/39f61c7e27f9c8ba715637e41a3e3389f7051260), and [aa35f95ea95e](https://github.com/GraderGamer2/NekoEdit/commit/aa35f95ea95eb1eea792fa692e0be3fb3f672fe5).
**Branch-history sync:** [fd6054789a3b](https://github.com/GraderGamer2/NekoEdit/commit/fd6054789a3bad1f1d0d4c727bc8b19248c286c7) is a two-parent documentation-only sync from `main`; it did not move source changes into `main`.

**CI:** [Build and test #711](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908) passed all 12 workflow steps. In addition to the freestanding build, CLI/host tests, full Wayland mock, ELF inspection, pinned X.Org source verification, exact JSON regeneration, pack build, and artifact uploads, the mock log explicitly confirms:

- `LC_ALL` selects pt_BR ahead of `LC_CTYPE` and `LANG`.
- `LC_ALL=C` selects embedded en_US even when lower-priority variables specify pt_BR.
- With empty `LC_ALL`, `LC_CTYPE=pt_BR.utf8` selects the canonical pt_BR pack and resolves a real Compose sequence.
- With both higher-priority variables empty, bare `LANG=pt_BR` selects the canonical pack and resolves Compose input.
- A saved `compose_locale=en_US.UTF-8` setting overrides pt_BR process locale variables.
- The Settings selector still activates pt_BR, routes Compose through it, and persists a return to en_US.

### Runtime precedence

A valid saved Settings choice is authoritative. Otherwise, the first non-empty value in this order is selected: `NEKOEDIT_LOCALE`, `LC_ALL`, `LC_CTYPE`, `LANG`. Empty values are ignored. Common pt_BR spellings (`pt_BR`, `pt_BR.utf8`, `pt_BR.UTF8`, and implemented lower-case-country variants) normalize to the canonical `pt_BR.UTF-8.nlp` filename. en_US and C/POSIX aliases keep the embedded tables active. An unsupported non-empty higher-priority locale leaves built-in en_US active rather than falling through. `LC_MESSAGES` and `LANGUAGE` are ignored because they concern message translation, not character input.

### Artifacts

- Locale pack: 151,288 bytes; artifact [13657749061](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908/artifacts/13657749061), ZIP 17,943 bytes, SHA-256 `aed84a5b2f6622f6c1a97485bde302a9a15f6e37c6ba61d0975d3affe770bcab`.
- Editor binary: 120,558 bytes; artifact [13658670522](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908/artifacts/13658670522), ZIP SHA-256 `3e28c207ff4667d74dfdfe526aa9ffa43f4ade3c0dc2fe15afcd11455eda8619`.

**Validation boundary:** automated Wayland mock/CI only; no live GNOME/Mutter desktop test is claimed for locale discovery or aliases.

### Remaining locale work

The Settings locale picker now lists every installed NLP1 pack, supports local Add and confirmed Remove, and can select built-in en_US. Current external data sets are pt_BR.UTF-8, fi_FI.UTF-8, and sr_RS.UTF-8. Automatic character-locale discovery checks `NEKOEDIT_LOCALE`, `LC_ALL`, `LC_CTYPE`, and `LANG` after any saved Settings choice. Locale-specific dead-key tables and system/user Compose-file import remain outstanding; the Release attachment workflow still needs a published-release test. Keep the editor offline-capable and packs data-only.

---

## 2026-11-09 — persistent Settings locale selector — Build and test #709 passed

**Branch:** early-alpha; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, unmerged, and clean.
**Implementation/test commits:** [7343175f2584](https://github.com/GraderGamer2/NekoEdit/commit/7343175f258430e55db1252d8dcb31dbe9bce40e), [70f216f2197d](https://github.com/GraderGamer2/NekoEdit/commit/70f216f2197d30b3c6af75481d542aad864b12fe), [05d080417878](https://github.com/GraderGamer2/NekoEdit/commit/05d080417878bb71dae54fda4638cd554c3bea08), [241401ea9d1e](https://github.com/GraderGamer2/NekoEdit/commit/241401ea9d1e2529d6da9e5ada340bf64cce84e7), and [ce35e0803d0a](https://github.com/GraderGamer2/NekoEdit/commit/ce35e0803d0a586074aa5ddb11d65208cb24fb99).

**CI:** [Build and test #709](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652) passed all 12 workflow steps. The job log explicitly shows the Settings scenario starting and completing. Its Wayland observation confirms the installed pt_BR pack was activated, used for Compose input, and the return to built-in en_US was persisted.

- Added a validated compose_locale preference to the existing per-user preferences file. The line-oriented version-1 format is retained. Locale values use bounded safe ASCII tags; traversal, separators, newline injection, and overlong values are rejected.
- A stored locale preference takes precedence over NEKOEDIT_LOCALE. When no preference exists, the environment variable remains a first-run override. An explicit en_US.UTF-8 selection suppresses an environment override.
- Added a COMPOSE LOCALE row at the bottom of the existing Settings dropdown. It toggles between built-in en_US and an installed pt_BR.UTF-8 pack without increasing the panel footprint. The row reports pt_BR when active and MISSING when pt_BR is selected but its data file is absent or invalid.
- Corrected the title-bar top-edge resize hit band to exempt both File and Settings buttons. Previously, a Settings press at the top of the window could be intercepted as xdg_toplevel.resize before the menu handler received it.
- Preference host tests verify pt_BR/en_US save, reload, and unsafe-tag rejection. The Wayland mock clicks the Settings header and locale row, activates a fixture pack, types its two-input Compose mapping, switches back to en_US, and checks the stored preference. A guard makes the test fail if the Settings scenario does not append its success observation.
- Locale selection does not install or download data. Install the separate NLP1 file under the user's locale directory first. The editor still works offline with built-in en_US.

**Artifacts from #709:**
- pt_BR NLP1 pack: 151,288 bytes uncompressed; artifact [13657516254](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652/artifacts/13657516254), ZIP size 17,943 bytes. Expires 2026-11-16 07:46:33 UTC.
- NekoEdit editor: artifact [13657600927](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652/artifacts/13657600927), 120,129 bytes. Expires 2026-11-16 07:46:35 UTC.

### Remaining locale work and validation boundary

The first pt_BR data pack and Release attachment workflow are implemented. The persistent Settings selector for en_US/pt_BR is now implemented and CI/mock-tested. Remaining work: GUI pack installer/remover, additional locale datasets, automatic system-locale discovery, system/user Compose-file imports, locale-specific dead-key actions, and live GNOME/Mutter manual testing. No new project Release was published in this task, so no versioned end-user Release asset has been exercised. The editor remains offline-capable with built-in en_US.

---

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

The NLP1 loader, pack builder, pt_BR data, and persistent Settings selector are implemented on early-alpha. Settings stores compose_locale, overrides NEKOEDIT_LOCALE when saved, and toggles between built-in en_US and an installed pt_BR pack. The Release workflow attaches the separate data-only pack on publish. A GUI installer/remover, additional locales, automatic system-locale discovery, system/user Compose imports, and locale-specific dead keys remain future work.

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

The parser now covers the expanded named Unicode table and the previously validated bounded XKB type, modifier-map, compatibility-predicate, preserve/consumed-modifier, virtual-modifier, and repeat subsets. This is not complete libxkbcommon or full locale Compose support. At that earlier snapshot, automatic system-locale discovery had not yet been implemented; see the newer #711 milestone above. System/user Compose-file import and locale-specific dead-key actions remain outstanding. Stateful modifier/group actions and compatibility indicators remain compositor-owned or unfinished; advanced IME preedit attributes also remain incomplete. Live GNOME/Mutter testing with real keymaps and an input method remains outstanding. Glyph appearance also depends on the selected font containing the mapped character.

**Snapshot date:** 2026-11-09 (Asia/Jakarta).

---


---

