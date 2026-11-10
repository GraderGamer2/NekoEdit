## 2026-11-10 — bounded sibling includes in the in-app XCompose importer

The native Settings → Locale → Import path now expands quoted sibling include files from the directory containing the selected root .XCompose file. Expansion is depth-first and preserves textual override order, including repeated includes after an earlier expansion returns. It rejects path traversal, absolute or cross-directory paths, percent/environment substitutions, symlinks, non-regular files, and active cycles. Bounded limits cap aggregate expanded bytes, file count, include expansions, recursion depth, line size, and NLP1 records. The importer validates the resulting data pack before its existing no-clobber atomic publish operation.

The host-side converter remains available for include forms that need explicit home/system roots (%H, %S, %L), non-UTF-8 source encodings, and broader keysym resolution. No Python, shell, native library, or executable plugin was added to the editor. Locale tables remain separate .nlp files; the binary still embeds only the en_US baseline.

Build and test #786 exposed only a duplicated /locales segment in a new expected test path. The fixture was corrected in [752c24664911](https://github.com/GraderGamer2/NekoEdit/commit/752c24664911f672c7c672cfd2a01fc33ad6cdd9), and Build and test [#787](https://github.com/GraderGamer2/NekoEdit/actions/runs/42736381984) passed the complete 14-step workflow.

## 2026-11-09 — History filter validated; direct user XCompose installer added

Build and test #773 passed the complete History path-filter flow after the test mock's Browse coordinates were corrected. The 127-character non-matching query, horizontal viewport/caret, Ctrl+A clear, positive stored-path match, Browse/Open Selected, Undo/Redo, Export, and selected-history Delete all passed in the full Wayland mock.

The user XCompose path now includes an optional one-command host installer, tools/install_user_xcompose.py. It uses the existing bounded offline parser and NLP1 encoder, creates or opens only the user's private ~/.nekoedit/locales directory, and atomically installs a data-only pack. It refuses to overwrite by default and offers an explicit --replace for regular existing packs. Source/include/keysyms files are protected from output collision. This does not change the editor's freestanding runtime and does not introduce automatic ~/.XCompose discovery or Settings import UI.

Build and test [#774](https://github.com/GraderGamer2/NekoEdit/actions/runs/42656480878) passed all 13 steps on source commit [b53ffd4809fa](https://github.com/GraderGamer2/NekoEdit/commit/b53ffd4809fa390709f9947bde383ac570ac81d7). The run validated the installer regression test, all existing host tests, the complete Wayland mock, pinned Compose data regeneration, optional locale packs, and both uploaded artifacts. Live GNOME/Mutter input behavior remains separate and unverified.

---
## 2026-11-09 — History long-query test reaches real UI; correct mock click argument order

Build and test #772 passed build and host-side tests, including converter-to-NLP1 manager integration. The new History test successfully entered a 127-character non-match, observed zero results, confirmed horizontal scrolling and caret visibility, and used Ctrl+A to restore the unfiltered result. It then failed waiting for Browse because the modified test passed its pointer serial as the x coordinate rather than the serial argument. The control coordinates have been restored in the follow-up test revision; the History runtime itself has not yet been shown to fail.

---

## 2026-11-09 — correct locale-manager user XCompose fixture syntax

The locale-manager integration fixture had used two unquoted result keysyms, a result form that the bounded user XCompose converter intentionally does not implement. It now uses a quoted Unicode result plus one keysym annotation, matching the documented syntax and preserving the narrow parser grammar. Build and test #771 confirmed that the History-filter assembly compiles and links after the BSS correction, but host tests stopped at the invalid fixture before the Wayland History filter scenario. The follow-up workflow must cover both.

---

## 2026-11-09 — improve History path-filter usability

The History search field now keeps a visible insertion caret and displays a horizontally scrolled query slice when its 127-byte search buffer exceeds the available pixel width. The underlying case-insensitive path substring match and full query buffer are unchanged. The Wayland mock now checks a 127-character non-matching query, zero results, a visible in-field caret after scrolling, Ctrl+A clearing back to the unfiltered result, and the existing positive path match plus History operations.

Baseline [Build and test #767](https://github.com/GraderGamer2/NekoEdit/actions/runs/42640512116) passed the complete 13-step workflow. This revision has not yet completed CI validation.

---

## 2026-11-09 — exercise user XCompose conversion through pack installation and runtime lookup

The offline user XCompose importer is now validated beyond JSON and binary encoding. The locale-manager integration fixture builds a small user file with an allowlisted home include, converts it with the public CLI, builds an NLP1 file with the pack CLI, and sends the result through the freestanding C locale manager. That manager installs the custom pack under the isolated HOME/.nekoedit/locales directory, verifies private permissions, activates the locale, checks Multi_key e e → U+018F and dead_acute+c → ç through the binary lookup API, then removes the pack and restores built-in en_US.

Build and test #767 passed all 12 workflow steps, including the full Wayland protocol mock, all host tests, pinned X.Org source regeneration, three shipped locale packs, and both artifact uploads. The next boundary is testing user files from a broader set of real-world Compose syntax and evaluating whether a manual Settings import UI can be added without bringing Python or other runtime dependencies into the editor.

---

## 2026-11-09 — validate bounded user XCompose importer and stabilize held-key test sequencing

The new offline XCompose converter's host tests now pass, including include traversal, resource bounds, escaping, Unicode resolution, safe output, and NLP1 encoding. Build and test #766 passed the entire command-line/host test set. The first remaining failure occurred in the existing Wayland keyboard-repeat test: the mock began the held Enter phase before the application had acknowledged key-up/repeat cancellation for the preceding printable key. The document had received the newline, but the frame assertion observed a stale caret row.

The test now waits for the shared repeat_keycode state to clear before starting the next held key. This preserves the test's assertions and runtime behavior; it only makes the event sequence deterministic. The complete Build and test #767 run is the validation boundary.

The converter remains an explicit, offline CLI step. It does not auto-read ~/.XCompose or $XCOMPOSEFILE, merge locale tables at startup, or add a Settings import UI.

---

## 2026-11-09 — bounded offline user XCompose conversion

NekoEdit now has a separate standard-library-only converter for a user-selected XCompose file. It emits the same typed, data-only NLP1 JSON accepted by the existing pack builder. Includes expand depth-first from explicitly allowlisted %H, %S, and %L roots; canonical path containment, symlink escape rejection, active-cycle detection, and independent file/byte/depth/expansion/line/record bounds protect traversal. Later duplicate records override earlier ones. Supported unqualified Multi_key and one-following-scalar dead-key records become NLP1 records; modifier-qualified rules are skipped because the format does not represent modifier state.

The converter has no shell expansion, network downloads, executable plugins, or runtime shared-library requirement. Output JSON is written atomically with private permissions under the caller-selected path. The selected input is not moved or modified. A user can build the generated JSON with compose_pack.py and install the resulting pack under ~/.nekoedit/locales/.

This is manual conversion only. Automatic ~/.XCompose discovery, $XCOMPOSEFILE, system startup merging, and a Settings import UI remain future work. Build and test #765 failed in a resource-limit fixture because it reused the self-cycle source path; the current test correction uses a separate valid root and is not yet CI-verified.

Implementation series: [94d0f9661a01](https://github.com/GraderGamer2/NekoEdit/commit/94d0f9661a01c3d420850478e4be6327b217e2db), [198ec64b7ab8](https://github.com/GraderGamer2/NekoEdit/commit/198ec64b7ab8622a7dc1fc8c6dec1aa800f6c64d), [bf39555139a9](https://github.com/GraderGamer2/NekoEdit/commit/bf39555139a9ed8fe9b25df8ab370f5f85b04c1c), [ac038c35eb16](https://github.com/GraderGamer2/NekoEdit/commit/ac038c35eb16f76e57daacc835ef38224ff708e9), and [df4c0d8bf3a7](https://github.com/GraderGamer2/NekoEdit/commit/df4c0d8bf3a788388f205f9cfd190b525449bc69).

---

## 2026-11-09 — complete Finnish/Serbian locale dead-key integration coverage

Build and test [#759](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236) passed all 12 workflow steps. The run verified the freestanding editor build, command-line tests, complete Wayland suite, source regeneration against pinned X.Org libX11/xorgproto inputs, locale-pack builds, and upload of both the Linux binary and external locale packs.

The Finnish and Serbian scenarios now exercise locale dead-key records through mocked physical XKB input, not only through data-level lookup. The test fixture maps its `DA01` key to `dead_apostrophe` (U+0301) and its `AC08` key to `Cyrillic_ka` (U+043A). Each locale pack resolves the sequence to U+045C (`ќ`). Assertions verify the pending mark arms without inserting document bytes, the following Cyrillic scalar triggers the locale lookup, the lookup output is U+045C, the pending mark clears, and the document contains the expected UTF-8. The data-level test independently pins the same mapping in both generated locale JSONs.

Implementation scope did not expand: [98144943b5ae](https://github.com/GraderGamer2/NekoEdit/commit/98144943b5aed894c103f8fa2b8049ac60e5ef52) changed tests only. The runtime implementation and source datasets were unchanged. The earlier pt_BR Settings installer/remover path is green as part of #758. Artifacts from #759 are [Linux x86-64 ZIP 13681366275](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236/artifacts/13681366275) and [locale-pack ZIP 13681910677](https://github.com/GraderGamer2/NekoEdit/actions/runs/42631934236/artifacts/13681910677), each expiring November 16, 2026.

The next locale milestone is a safe, offline `.XCompose` importer. Its initial scope must be bounded and data-only: include resolution with allowlisted roots and cycle detection, strict byte/file/record limits, Unicode-only input filtering, maximum sequence/output lengths compatible with NLP1, and no shell expansion or execution. GUI integration can follow after parser/fixture behavior is stable.

---
## 2026-11-09 — verify locale Settings installer and extend Finnish/Serbian dead-key integration tests

Build and test [#758](https://github.com/GraderGamer2/NekoEdit/actions/runs/42629086891) passed its complete 12-step workflow. This closes the pt_BR Settings regression chain: the installed-locale dropdown, keyboard activation, the actual Brazilian `Multi_key e e` → U+018F mapping, the `dead_acute + c` → ç locale mapping, Base en_US preference persistence, local Add Pack copy/source preservation/reselection, and confirmed Remove Pack/fallback all passed. The build also regenerated/verified all pinned X.Org inputs, built the three optional locale packs, inspected the executable, and uploaded the Linux binary and locale-pack artifacts.

Commit [98144943b5ae](https://github.com/GraderGamer2/NekoEdit/commit/98144943b5aed894c103f8fa2b8049ac60e5ef52) adds coverage for the other two real locale datasets. Finnish and Serbian data tests explicitly check `[dead_acute, Cyrillic_ka] → U+045C`. Their Wayland scenarios retain the previous Multi_key checks, then generate `dead_apostrophe` followed by `Cyrillic_ka` through an adjusted XKB mock keymap. Tests verify no text is inserted while the mark is pending, the pending mark is cleared after the base scalar, the locale lookup returns U+045C, and the final document bytes contain the expected precomposed Cyrillic output.

This latest change only modifies test fixtures and data assertions; no runtime implementation or locale JSON was changed. Build and test #759 is running for this commit. Actual GNOME/Mutter and physical keyboard-layout behavior remains a separate manual validation boundary.

---
## 2026-11-09 — expand XKB combining dead-key actions

NekoEdit now recognizes 35 standard combining dead-key actions through the XKB named-keysym path. The original six action marker IDs and the dedicated `Multi_key` marker were preserved; the additional actions occupy a contiguous range after the reserved Compose marker. The generic input layer maps actions to Unicode combining marks, precomposes a curated set of Latin Extended-A characters, and falls back to base-plus-mark when no precomposed scalar is available. The mock covers the new actions through both parser state and actual document input. This is not yet locale-specific Compose support: NLP1 remains a `Multi_key` data format, and dead-key-led locale rules plus `.XCompose` import remain future work.

Implementation/test: [2bfe46ee19b0](https://github.com/GraderGamer2/NekoEdit/commit/2bfe46ee19b0dda91d39fd4b208a805abebf6418) and [528b8d680652](https://github.com/GraderGamer2/NekoEdit/commit/528b8d68065213173c9bdde9ba24bf2262da0fec). Comment correction: [42747acc3102](https://github.com/GraderGamer2/NekoEdit/commit/42747acc3102ab133b4a263d55f09d98b74e89d0). CI has not reported a run for the new implementation head; the older Build and test #736 belongs to the prior locale-manager commit and is not evidence for this milestone.

---

## 2026-11-09 — select installed Compose locales directly in Settings

Implementation/test commits: [748ca5ba9704](https://github.com/GraderGamer2/NekoEdit/commit/748ca5ba97042b137a64211da07a641e409a567c), [5514f193dd04](https://github.com/GraderGamer2/NekoEdit/commit/5514f193dd0436cfd9af641e0069f4069771f611), [0dbe8df16673](https://github.com/GraderGamer2/NekoEdit/commit/0dbe8df16673ea2d595f7a25c7529c2647a26062), [c6c380a08257](https://github.com/GraderGamer2/NekoEdit/commit/c6c380a08257c24ec1a19edf2bbefb8d36e9e902), [65d2a43e2f72](https://github.com/GraderGamer2/NekoEdit/commit/65d2a43e2f729526548187677c95efb6f62b847e), [1d4168b8683c](https://github.com/GraderGamer2/NekoEdit/commit/1d4168b8683cd705c701f5b5aef8b836b6048ab0), [241391a4e279](https://github.com/GraderGamer2/NekoEdit/commit/241391a4e279bc7404e27cc0fad39566a499681a).

Settings now uses a dropdown populated from the user's private `~/.nekoedit/locales/` directory instead of opening the file picker to select a locale. Built-in en_US is always the first entry. Installed `.nlp` packs follow the existing deterministic directory scan. Opening Settings refreshes the list; Add and confirmed Remove refresh it again after changing the directory. The currently selected saved/effective locale is highlighted.

Mouse selection and Up/Down/Enter are supported, and Escape dismisses the dropdown. Activating an installed locale reuses the existing pack validation/loading path without showing the file picker. Add and Remove remain separate controls; pack installation still validates and atomically copies to `~/.nekoedit/locales/`, and removal still confirms before deleting.

The Wayland mock was expanded to cover dynamic enumeration, selection without picker mode, Escape dismissal, keyboard navigation, Add refreshing the list, reselecting a newly installed pack from the dropdown, and Remove refreshing the list. No workflow run or check status was returned for the updated PR head at the time this entry was written. Build and test #736 passed the previous locale-manager implementation, but it predates this dropdown change and is not evidence for it. The new Wayland mock assertions have been added but remain unexecuted in CI.

This records the implemented behavior and test additions; automated CI and live GNOME/Mutter validation are still outstanding for this milestone.

---

## 2026-11-09 — make the Compose locale installation destination visible

Implementation/test commit: [2fd44f25bde6](https://github.com/GraderGamer2/NekoEdit/commit/2fd44f25bde6db5ab9fd889b98a186e3fbcae18b).

The Settings Add picker now labels the selected local file's directory as **SOURCE** and displays **TARGET: `~/.nekoedit/locales/`** beside it. The validated pack is atomically copied to `$HOME/.nekoedit/locales/<locale-tag>.nlp`; the source file remains where it was selected. The application/locale directories use mode 0700, installed pack files use mode 0600, and the selected locale remains persisted in `~/.nekoedit/preferences`.

The host-side locale-manager regression now checks the exact destination path. The full Wayland mock already exercises generic pack selection, Add, source preservation, activation, confirmed Remove, and fallback to en_US. Build and test [#736](https://github.com/GraderGamer2/NekoEdit/actions/runs/42601389047) passed the complete build, host and Wayland tests, source verification, pack builds, and artifact uploads.

This is a UI clarification and regression milestone, not a change to the NLP1 format or locale precedence. Live GNOME/Mutter desktop validation remains outstanding.

---

## 2026-11-09 — synchronize the text-input-v3 change origin with the compositor

Implementation: [7b07ce26a158](https://github.com/GraderGamer2/NekoEdit/commit/7b07ce26a1587865e7c5c1bc203e140ee948d891).

NekoEdit now sends text-input-v3 `set_text_change_cause` before its surrounding-text and cursor-rectangle updates. Keyboard and pointer changes made by the editor are identified as `other`; changes applied from input-method events and text-input focus synchronization are identified as `input_method`. The local cause state resets after the corresponding commit, so an editor-generated cause cannot persist into a later IME event.

The Wayland mock asserts both request order and payload. A keyboard Shift+Left selection change must report cause 1; a subsequent IME deletion/state refresh must report cause 0. This extends the existing preedit byte-offset, UTF-8 validation, multibyte commit, delete-surrounding, and serial tests.

Build and test [#735](https://github.com/GraderGamer2/NekoEdit/actions/runs/42597142663) passed all 12 steps. It also rebuilt the pt_BR, fi_FI, and sr_RS locale packs and uploaded them separately from the editor. The new protocol note is [docs/TEXT_INPUT_V3.md](../docs/TEXT_INPUT_V3.md).

The IME path remains opt-in. The mock does not substitute for the outstanding live GNOME/Mutter test with a physical keyboard and installed input method.

---

## 2026-11-09 — automatic Compose locale discovery from character-locale variables

Implementation/test commits: [74110d69492e](https://github.com/GraderGamer2/NekoEdit/commit/74110d69492eb168b93f3020890e37300afe585e), [39f61c7e27f9](https://github.com/GraderGamer2/NekoEdit/commit/39f61c7e27f9c8ba715637e41a3e3389f7051260), and [aa35f95ea95e](https://github.com/GraderGamer2/NekoEdit/commit/aa35f95ea95eb1eea792fa692e0be3fb3f672fe5).

A saved Settings choice is authoritative; otherwise NekoEdit selects the first non-empty value among `NEKOEDIT_LOCALE`, `LC_ALL`, `LC_CTYPE`, and `LANG`. Empty values are skipped. Common Brazilian Portuguese spellings normalize to the canonical `pt_BR.UTF-8` pack tag. C/POSIX and en_US aliases use the embedded default. An unsupported non-empty higher-priority value does not fall through to a lower-priority variable. Message-translation variables are ignored because they do not represent the character input locale.

The Wayland mock validates actual Compose keystrokes selected by LC_ALL, LC_CTYPE, and LANG, plus an explicit saved en_US setting overriding a pt_BR environment. It checks the resulting document UTF-8, not just loader state. The saved-preference fixture correction ensures the preferences file contains valid separate lines.

Build and test [#711](https://github.com/GraderGamer2/NekoEdit/actions/runs/42583637908) passed all 12 steps, including the full Wayland suite, source-blob checks, byte-for-byte locale regeneration, and separate locale/editor artifact uploads. The application remains offline-capable and no dynamic runtime dependency was added.

The next locale milestone is GUI installation/removal of external data-only packs. More datasets, locale-specific dead keys, system/user Compose import, actual Release attachment testing, and live GNOME/Mutter verification remain future work.

---

## 2026-11-09 — add persistent Settings selection for Compose locales

Implementation/test commits: [7343175f2584](https://github.com/GraderGamer2/NekoEdit/commit/7343175f258430e55db1252d8dcb31dbe9bce40e), [70f216f2197d](https://github.com/GraderGamer2/NekoEdit/commit/70f216f2197d30b3c6af75481d542aad864b12fe), [05d080417878](https://github.com/GraderGamer2/NekoEdit/commit/05d080417878bb71dae54fda4638cd554c3bea08), [241401ea9d1e](https://github.com/GraderGamer2/NekoEdit/commit/241401ea9d1e2529d6da9e5ada340bf64cce84e7), and [ce35e0803d0a](https://github.com/GraderGamer2/NekoEdit/commit/ce35e0803d0a586074aa5ddb11d65208cb24fb99).

NekoEdit's Settings dropdown now has a persistent COMPOSE LOCALE row. It switches between the embedded en_US table and an installed pt_BR pack. The choice is stored in the per-user preferences file; a saved selection overrides NEKOEDIT_LOCALE, while the environment variable remains a first-run override when no preference exists. A missing/invalid selected pack leaves en_US active and displays MISSING. Selection is local only and does not download or install data.

This UI test exposed and fixed a title-bar hit-test conflict: the window resize band previously claimed the top strip over Settings. The Settings button is now exempt from that resize hit band. The Wayland mock clicks the header and locale row, checks that the real loader activates the installed pt_BR fixture, verifies the Compose o-i output, then selects en_US and verifies the saved preference.

Build and test [#709](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652) passed all 12 steps. The job log explicitly reports the Settings scenario start/completion and the success observation for the UI, Compose, and persistence assertions. The run also rechecks pinned source regeneration and builds/uploads the pt_BR pack.

Artifacts: locale pack [13657516254](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652/artifacts/13657516254), 17,943-byte ZIP for a 151,288-byte NLP1 file; editor [13657600927](https://github.com/GraderGamer2/NekoEdit/actions/runs/42581390652/artifacts/13657600927), 120,129 bytes.

A GUI pack installer/remover, additional locales, automatic system-locale discovery, system/user Compose-file import, locale-specific dead keys, a published end-user Release, and live GNOME/Mutter testing remain outstanding.

---

## 2026-11-09 — ship the first separately packaged locale data set

Source work: [d5f96921ef9e](https://github.com/GraderGamer2/NekoEdit/commit/d5f96921ef9e9cf1e052a6509003b827769af9ca), [15cf37c949fa](https://github.com/GraderGamer2/NekoEdit/commit/15cf37c949facfeb5038915f90b8f1917cf3afdf), and [7871f5256b89](https://github.com/GraderGamer2/NekoEdit/commit/7871f5256b89789e348b52801ebaecbca86e2a0a).

NekoEdit now has its first external Compose data set: `pt_BR.UTF-8`. It is a complete table derived from the pinned X.Org libX11 en_US source plus pt_BR additions/overrides, with input keysyms converted using pinned xorgproto definitions. The reproducible importer validates the expected include, scalar inputs, output strings, source ordering, and prefix policy. The JSON includes upstream revision/blob identifiers and filter statistics; the repository also includes source/license notices.

The final table has 2,908 rules (2,220 pairs, 582 triples, 106 four-input sequences), including 100 multi-scalar outputs. It is built as a 151,288-byte NLP1 file separately from the core executable. The standard build verifies pinned source blob hashes and byte-for-byte importer output, then uploads the pack as a distinct artifact. A separate workflow attaches it and its notice when a project GitHub Release is published.

Build and test [#704](https://github.com/GraderGamer2/NekoEdit/actions/runs/42579353889) passed all 12 steps, including the Wayland mock, importer regeneration, pack build, ELF inspection, and both artifact uploads. The locale ZIP is [13656596918](https://github.com/GraderGamer2/NekoEdit/actions/runs/42579353889/artifacts/13656596918); the editor ZIP is [13657030709](https://github.com/GraderGamer2/NekoEdit/actions/runs/42579353889/artifacts/13657030709).

The Release attachment workflow has been committed, but no new project Release was published in this task, so the pack is not yet attached to a versioned release. More locales, GUI selection/install/remove, automatic system-locale detection, system/user Compose-file import, locale-specific dead keys, and live GNOME/Mutter validation remain future work.

---

## 2026-11-09 — implement the bounded Compose locale-pack runtime

Implementation: [77f1df75cb0d](https://github.com/GraderGamer2/NekoEdit/commit/77f1df75cb0dba7042119b3c158a8d618a4dce27), with regression fixes [f461a9da7cb2](https://github.com/GraderGamer2/NekoEdit/commit/f461a9da7cb2ef9108bb2b19b4c06e697df8f64a) and [8e4e53bcd678](https://github.com/GraderGamer2/NekoEdit/commit/8e4e53bcd678bb9d281f69e5aaaa7a9432408a0f).

The built-in `en_US.UTF-8` Compose tables remain the default. NekoEdit can now load an explicitly selected optional locale pack from `~/.nekoedit/locales/<tag>.nlp` using `NEKOEDIT_LOCALE`. A loaded pack replaces the active Compose table; it does not merge with en_US. A missing or invalid pack leaves the embedded default active.

The new NLP1 format is versioned, little-endian, CRC-32 checked, and bounded to 2 MiB and 32,768 records. Each record maps 2–4 Unicode input scalars to 1–8 output scalars. Duplicate or prefix-ambiguous keys, invalid scalar values, invalid padding/reserved fields, mismatched tags, and malformed lengths are rejected. The runtime maps validated data read-only. The Python generator is a release/build tool only.

The Wayland mock sends real key events through a valid pack and verifies a pair with multi-scalar output, a three-input sequence, a four-input sequence, unknown-input literal fallback, and Escape/Backspace cancellation. A CRC-corrupt pack is rejected and leaves en_US active. Host generator tests cover the binary format and invalid source records.

Build and test [#701](https://github.com/GraderGamer2/NekoEdit/actions/runs/42576739750) passed all eight workflow steps. Artifact [13656010309](https://github.com/GraderGamer2/NekoEdit/actions/runs/42576739750/artifacts/13656010309) is 119,239 bytes.

This milestone implements the pack format, builder, loader, and sequence resolver; actual non-en_US GitHub Release assets, Settings locale selection/installation, system/user Compose import, and locale-specific dead-key rules remain future work. The user-facing editor stays offline-capable and no executable plugin or native-library loader is introduced.

---

## 2026-11-09 — implement the three-command document context menu

Commit: [0c9fee44200b](https://github.com/GraderGamer2/NekoEdit/commit/0c9fee44200b1528c1c3d148dd525c5319c6dd7d).

NekoEdit now has a small native in-surface context menu opened by right-clicking inside the document viewport. The menu contains only Copy, Paste, and Cut. It preserves the current selection when opened, reuses the existing Wayland clipboard/data-device machinery, and closes with Escape, another right-click, or an outside click. An outside click is consumed so the underlying editor control is not activated.

Clipboard Copy and Cut continue to use immutable snapshots; Cut publishes the selected bytes before deleting them. Pointer-originated Copy/Cut now supply the serial from the menu-item pointer press to wl_data_device.set_selection. Paste uses the existing asynchronous external-offer path and remains one Undo/Redo action.

The new Wayland mock validates popup opening/dismissal, selection preservation, Copy bytes, Cut snapshot/delete ordering, asynchronous external Paste, Undo/Redo, and outside-click isolation. Build and test [#698](https://github.com/GraderGamer2/NekoEdit/actions/runs/42571651703) passed all eight workflow steps. The 116,962-byte artifact [13653517472](https://github.com/GraderGamer2/NekoEdit/actions/runs/42571651703/artifacts/13653517472) has ZIP SHA-256 8fef7f76439a09c662161cc65b24241a6efc425dd6ee3ea942243a72059d2b80.

At this earlier context-menu milestone, the NLP1 locale loader was still a roadmap item. The later locale-pack milestone at the top of this file adds the format, generator, bounded runtime loader, fallback behavior, and Wayland test coverage.

---

## 2026-11-09 — support three-symbol XKB Compose sequences

Implementation: [bf3a1891dd63](https://github.com/GraderGamer2/NekoEdit/commit/bf3a1891dd6318ad70f99bf7e75e4afbf481dc56).

The previous 2,140 two-symbol pairs were retained and supplemented with 564 three-symbol entries from the X.Org libX11 `en_US.UTF-8` Compose source. The Wayland backend now buffers a recognized two-symbol prefix and waits for its third scalar. Existing complete pair mappings are excluded from triple-prefix ambiguity, and the original NekoEdit pair outputs still take precedence.

The mock verifies the en-dash and em-dash sequences, pending second-scalar state, literal fallback, and Backspace cancellation. Actions [Build and test #42564500183](https://github.com/GraderGamer2/NekoEdit/actions/runs/42564500183) passed all eight steps on the first attempt. Artifact [13650369672](https://github.com/GraderGamer2/NekoEdit/actions/runs/42564500183/artifacts/13650369672) has ZIP SHA-256 `4b4234c8a9a493b0f389005f55f0da9a4bd6cdd9c962cea8bd832773a1a6b174`.

Compose remains a static `en_US.UTF-8` snapshot. 106 four-symbol upstream sequences, multi-scalar outputs, locale selection, system and per-user Compose files, include directives, and broader dead-key semantics are still future work. This is a sequence-depth improvement, not full locale awareness.

---

## 2026-11-09 — expand XKB Multi_key Compose coverage

Commit: [31c1bd47575e](https://github.com/GraderGamer2/NekoEdit/commit/31c1bd47575ee776701bd106d8d25dcd33219432).

The fixed 40-pair Compose list was expanded to 2,140 distinct two-symbol mappings derived from the X.Org libX11 `en_US.UTF-8` Compose source plus seven historical NekoEdit-only mappings. The original 40 outputs retain priority on collisions. The test suite exercises the expanded scalar insertion path with ellipsis, capital sharp S, and single right angle quotation mark sequences. The implementation adds a static table only and no new runtime dependency.

This is not yet locale-aware Compose or general XCompose support. Only two-symbol sequences with one-scalar output are represented. Locale selection, system and per-user Compose file loading, include directives, longer input sequences, multi-scalar output, and broader dead-key actions remain future work. See [docs/COMPOSE.md](../docs/COMPOSE.md).

Actions [Build and test #42563677349](https://github.com/GraderGamer2/NekoEdit/actions/runs/42563677349) passed all eight steps on retry attempt 2. Artifact [13650009531](https://github.com/GraderGamer2/NekoEdit/actions/runs/42563677349/artifacts/13650009531) has ZIP SHA-256 `d7cd58ba93aac6efaeb88149f497d74ce0f74d9bd5c9f4fa7811f9a237790a2d`.

The user also noted question-mark rendering for scripts whose font glyphs may be missing. Inspection confirms cmap misses are currently rendered using the selected typeface's `?` glyph; this is a renderer fallback, not proof that the document stores a question mark. Cross-font fallback is future rendering work.

---

## 2026-11-09 — align XKB repeat defaults with libxkbcommon

A follow-up audit corrected two separate XKB repeat defaults that had been conflated. An `xkb_compat` section's `interpret.repeat` default is `False`; the fallback/default interpretation enables repeat only for keys with an actual Group 1 / Level 1 symbol. Keys without that base-level symbol retain the ordinary false repeat default. Direct `xkb_symbols` per-key repeat properties override compatibility interpretation results, and key-wide compatibility repeat is derived only from Group 1 / Level 1.

The audit also caught two non-zero repeat initializers that had been reintroduced into `.bss` by a later test commit after the first zero-storage correction. They are now zero-filled storage with explicit reset initialization. The Wayland query rejects unmapped keycodes, and a non-repeatable key cancels any stale repeat timer.

Regression coverage now includes a keycode with an empty key block and a second parser/integration run with the `interpret.repeat` section assignment omitted. Source/test correction: [2816c9f0a0c4](https://github.com/GraderGamer2/NekoEdit/commit/2816c9f0a0c44c6619174deab7878177258f9644). Full CI validation is pending.


# NekoEdit project history

## 2026-11-09 — validate repeat policy through the Wayland key event path

The first CI attempt for the per-key repeat milestone stopped at assembly because two repeat defaults were incorrectly initialized with non-zero values in the `.bss` section. They are now zero-filled declarations with explicit runtime initialization in `xkb_reset_keymap` ([4bedb424cff2](https://github.com/GraderGamer2/NekoEdit/commit/4bedb424cff2804e64da879d280b26db7db9182d)).

The mock now tests more than the parser's internal tables. It holds four synthetic keys through the same Wayland key-down and repeat-timer path used by the editor: inherited `False` and explicit key-level `False` must not repeat, while a compatibility `True` and a direct key-level `True` must repeat. This checks policy-to-timer integration and explicit-key precedence. Test commit: [fd41479a9268](https://github.com/GraderGamer2/NekoEdit/commit/fd41479a926812a83c9243b014ff6bca8866fd27). The next full workflow is pending.

## 2026-11-09 — apply XKB per-key repeat policy in the Wayland backend

The XKB text-v1 reader now distinguishes three levels of repeat configuration: the default (enabled), the `interpret.repeat` section default and per-interpret overrides in `xkb_compat`, and explicit per-key `repeat = True/False` properties in `xkb_symbols`. The matching compatibility rule is selected using the existing keysym and real-modifier specificity algorithm. Its repeat value is applied only from Group 1 / Level 1 because repeat is a property of the whole key; a direct key property wins.

The Wayland key-down path checks that policy before starting the timer configured by `wl_keyboard.repeat_info`. The client does not execute stateful modifier/group actions: the compositor remains authoritative for those transitions and sends their resulting modifier/group state to the client. The new mock fixture covers the false section default, true compatibility override, both direct-key precedence cases, and an ordinary default-repeat key.

Source/test commits: [81ec309c6ffd](https://github.com/GraderGamer2/NekoEdit/commit/81ec309c6ff2da92e19fcdaa895c03cd9538e426) and [05b45faa9eee](https://github.com/GraderGamer2/NekoEdit/commit/05b45faa9eeec21d3b4b7985a41bc4bba6004104). Full validation is pending.

**Historical reconstruction date:** 2026-11-06  
**Repository:** [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)  
**Development branch:** `early-alpha` (renamed from `feat/wayland-socket-error-handling`)  
**Current development PR:** [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) — open against main  
**Previous PR:** [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) — closed, unmerged

This document reconstructs the development of NekoEdit from the first repository prototype through the current Wayland window-management and picker milestones. The exact history is retained in [COMMIT_INDEX.md](COMMIT_INDEX.md), including the original prototype, PR #1 implementation, changelog setup, and subsequent maintenance commits captured on 2026-11-06. This document explains what those changes built.


## 2026-11-09 — make Settings a true modal over the editor and History

A repository screenshot revealed that opening Settings while the History tab was active left History controls visible around the Settings panel. The root cause was the render stack: the History page was painted first, but the Settings menu only painted its centered 256×192 rectangle. There was no opaque layer between the panel and the rest of the workspace. A related pointer-dispatch path closed Settings after an outside click but continued hit-testing the underlying page.

The Settings renderer now clears the entire workspace below the tab strip before drawing the centered panel, with the coordinate transform disabled for the backdrop and restored for panel content. Outside clicks dismiss Settings without activating covered controls. The title bar and tabs remain visible, while the underlying editor/History workspace is hidden until dismissal.

The mock History-page workflow now checks framebuffer pixels on the covered Open Selected action and inside the panel, tests that outside-click dismissal does not activate the History Browse control, and confirms Browse works after dismissal. Implementation commit: [015a3e60c374](https://github.com/GraderGamer2/NekoEdit/commit/015a3e60c3749493dc94f3235c46b640947c5fe0); test-harness synchronization follow-up: [ad2aad837634](https://github.com/GraderGamer2/NekoEdit/commit/ad2aad837634aa54e72c3a8f3f16bb6f68f85b04). Actions [Build and test #676](https://github.com/GraderGamer2/NekoEdit/actions/runs/42543083558) passed all eight workflow steps, including the new History/Settings framebuffer and click-through assertions. Artifact [13642440538](https://github.com/GraderGamer2/NekoEdit/actions/runs/42543083558/artifacts/13642440538) is 94,472 bytes; SHA-256 `1959b61ef8050d10472b59a5a14ec8ed61eb885ccc2fe3c1216c9d2de86eed0f`.

The user also confirmed that normal physical typing works again following the separate text-input-v3 default-off fix. That input milestone was validated by Actions #667; this modal work does not change keyboard or IME behavior.


## 2026-11-08 — Extend named XKB Unicode coverage

The bounded XKB named-symbol table now resolves 273 case-sensitive non-ASCII aliases. Alongside the pre-existing Latin-1, EuroSign, and punctuation entries, the parser now recognizes the Greek upper/lower alphabets and accented forms; core Cyrillic upper/lower alphabets; and common Ukrainian, Belarusian, Serbian, and Macedonian letters.

The new entries reuse the existing scalar table and UTF-8 insertion path. Mock-compositor coverage reads U+03B1 from `Greek_alpha` and U+044F from `Cyrillic_ya`, then verifies the inserted document bytes as part of the full Unicode/dead-key fixture. This expands named alias coverage; it does not make the parser fully xkbcommon-compatible. General custom key types, virtual modifiers and actions, other unlisted scripts/aliases, general Compose tables, and Wayland text-input/IME remain future work.


## 2026-11-08 — Add bounded XKB Multi_key Compose input

NekoEdit now recognizes the XKB `Multi_key` symbol as an editor-side Compose action. After it is pressed, the next two printable symbols are buffered and matched against a curated 20-pair table. Covered pairs include `oe/OE` → œ/Œ, `ae/AE` → æ/Æ, `ss` → ß, common accent-letter pairs, plus/minus, right arrow, guillemets, one-half, and cedilla-c. Successful matches insert a single Unicode scalar. Unsupported pairs are inserted unchanged as two literal characters.

Compose state is transient: Backspace and Escape cancel an unfinished sequence without deleting document text, and losing keyboard focus clears the pending sequence. Mock-compositor tests verify successful composition, literal fallback, and both cancellation keys. This is not general Compose support: multi-stage/longer sequences, locale-provided Compose tables, full XKB type/modifier/action semantics, and Wayland text-input/IME are still future work.


## 2026-11-08 — Selection confirmed; clipboard persistence and scalable history requested

The user manually confirmed that the latest selection behavior now feels like a conventional text editor: selecting text works as expected, and edge auto-scroll follows the drag correctly. This is a user-reported desktop result and should not be conflated with mock-compositor CI.

The user requested a future improvement to make sequential copy/paste effectively unlimited and keep the latest copied text available after NekoEdit closes. Current clipboard code already snapshots selected bytes independently and recycles bounded source/send records, but clipboard data is not guaranteed to survive process exit unless a desktop clipboard manager captures the offer. The review direction is to investigate manager handoff first and consider a first-party companion only if necessary.

The user also requested practically unlimited Undo/Redo. Current history stores full-document snapshots, with a 4 MiB per-snapshot ceiling, a 32 MiB aggregate memory budget, and 16 entries per stack; it clears history when a new snapshot cannot be captured. A delta-based, preferably disk-backed journal is the recommended direction to reduce RAM usage and avoid an arbitrary operation-count limit.

These requirements were reviewed and documented only. No clipboard, history, editor, or test implementation was changed. Undo history surviving NekoEdit restart remains an unresolved scope question. Wait for explicit user authorization before implementing either feature.

---

## 1. Original project goals and constraints

NekoEdit began as a small native plain-text editor for Linux, with a deliberately constrained implementation:

- Target: Linux x86-64 / System V AMD64 ABI.
- Language and assembler: GNU assembler, Intel syntax, freestanding assembly.
- Startup: custom `_start`, without C runtime startup code.
- System interface: direct Linux syscalls.
- Runtime: no third-party shared-library dependencies; no GTK, Qt, libc, libwayland, Xlib, XCB, Fontconfig, FreeType, HarfBuzz, or toolkit file chooser.
- Graphics: CPU software rendering into shared-memory buffers; no OpenGL, Vulkan, EGL, or GPU requirement.
- Display architecture: native Wayland first, X11 planned. The application is intended to be desktop-environment-independent.
- Document purpose: lightweight UTF-8 plain-text editing, not rich text or an IDE.

The original architecture describes distinct UI, editor-core, platform-neutral service, display-backend, and Linux syscall layers. The editor core should not depend on whether Wayland or X11 is active. The eventual document model is UTF-8 bytes with a gap buffer and byte offsets constrained to valid character boundaries.

These goals remain the design direction. Some planned layers and facilities are not yet implemented; see [CURRENT_STATUS.md](CURRENT_STATUS.md).

## 2. Phase A — freestanding Wayland window prototype

**Original `main` prototype history: 20 commits.**  
**Starting point:** the initial `feat: add freestanding Wayland window prototype and CI` commit (2026-11-06).

The first implementation proved that a standalone assembly executable could create a native Wayland toplevel and render a basic surface without a GUI toolkit or shared library.

Implemented in this phase:

- Command-line entry point with `--help`, `--version`, `--backend=wayland`, and an explicit not-yet-implemented X11 response.
- Small Linux syscall helpers for process exit, reads/writes, and related low-level operations.
- Environment lookup for `WAYLAND_DISPLAY` and `XDG_RUNTIME_DIR`; default `wayland-0` and absolute `WAYLAND_DISPLAY` paths.
- AF_UNIX/SOCK_STREAM connection to the Wayland display.
- Raw Wayland wire-message serialization and parsing.
- Registry discovery and binding of `wl_compositor`, `wl_shm`, and `xdg_wm_base`.
- Creation of `wl_surface`, `xdg_surface`, and `xdg_toplevel`.
- Initial empty surface commit, `xdg_surface.configure` acknowledgement, and handling of `xdg_wm_base.ping`.
- 800×480 XRGB8888 CPU-rendered buffer backed by `memfd`, mapped with `mmap`, transferred to the compositor through `sendmsg` and `SCM_RIGHTS`.
- Buffer attachment, surface damage/commit, and clean exit on `xdg_toplevel.close`.
- Dense client-side Wayland object-ID allocation. The development history includes fixes and tests for strict compositors that reject skipped IDs.
- Build checks that reject an ELF with a `PT_INTERP` program header or `DT_NEEDED` shared-library dependencies.
- GNU Make targets for build, smoke tests, Wayland mock tests, ELF inspection, and cleanup.
- GitHub Actions CI on Ubuntu 24.04, which assembles and links the freestanding binary, runs tests, inspects the ELF, and uploads a Linux x86-64 artifact.

At the end of this phase NekoEdit was only a window/rendering proof of concept. It had no editor input, document buffer, or file workflow.

## 3. Phase B — inherited Wayland sockets and protocol diagnostics

The first development PR extended the prototype's connection and failure handling:

- Supports a launcher-provided, already-connected `WAYLAND_SOCKET` descriptor as well as the normal `WAYLAND_DISPLAY` connection path.
- Handles Wayland protocol error events and reports compositor-provided diagnostics instead of silently failing.
- Adds bounded error-message handling and clearer setup-stage diagnostics.
- Retains the socket and protocol behavior across the later editor work.

Tests exercise both `WAYLAND_DISPLAY` and `WAYLAND_SOCKET` transports and simulate compositor protocol errors. This phase also established more useful diagnostics for failures during setup.

## 4. Phase C — Wayland seat, pointer, and keyboard input

The next milestone made the window interactive:

- Discovers `wl_seat` and handles advertised seat capabilities.
- Creates `wl_pointer` and `wl_keyboard` objects when those capabilities are available.
- Tracks keyboard focus and processes keyboard enter, leave, key, and modifier events.
- Processes pointer enter/leave/motion/button events.
- Tracks Shift, Ctrl, Caps Lock, and the physical Right-Alt/LevelThree state needed by the currently supported keyboard mapping.
- Keeps redraws safe with compositor buffer-release handling. The client must not rewrite shared memory while the compositor still owns the submitted buffer.
- Uses raw Wayland protocol messages and syscalls; no libwayland or other runtime library is introduced.

Pointer and keyboard focus/input were first tested independently before being connected to document editing. The commit index preserves the intermediate debugging, protocol serialization corrections, and test-harness synchronization fixes from this phase.

## 5. Phase D — initial text editing and editor UI

NekoEdit then became an actual, though still early, interactive editor.

### Document and rendering

- Added a bounded 64 KiB document byte array.
- Added an embedded 5×7 bitmap font covering printable ASCII.
- Added ASCII insertion and software rendering, with a visible caret.
- Added Left/Right/Up/Down, Home/End, Backspace, Delete, Enter, and four-space Tab.
- Added a compact application header, document area, active document tab, clickable File menu, and status/footer area.
- Added live logical line, column, and document byte-count status.
- The current window/document viewport is software-rendered at 800×480.
- Long lines soft-wrap; the active caret follows vertical movement through a 30-row document viewport.
- Pointer clicks position the caret in the document. Pointer coordinate conversion accounts for the document origin and visual row/column.
- Left-button drag selects text, including reverse-direction and multi-line ranges. Typing or Backspace/Delete replaces the selected range.
- Shift+Arrow and Shift+Home/End extend keyboard selections from a stable anchor; unshifted Left/Right collapse an active selection to the relevant edge.
- Ctrl+A selects the complete document.

### Keyboard repeat

- Added delayed repeat for ordinary non-modifier/non-lock keys, including printable input, navigation, Backspace, Delete, Enter, and Tab.
- Uses compositor `wl_keyboard.repeat_info` rate/delay when the seat version supports it.
- Retains a 300 ms / 30 Hz fallback for older seat versions.
- Cancels repeat on key release or keyboard focus loss; handles changed repeat settings.

### Test coverage

The Wayland mock compositor checks keyboard/pointer input, buffer release sequencing, caret and glyph pixels, selection highlighting/replacement, wrapping, vertical scrolling, and repeat timing. The editor tests are protocol-level integration tests; they do not replace running the program against a real GNOME/Wayland session.

## 6. Phase E — startup file loading and in-window file operations

File access was added without introducing a toolkit file chooser.

### Launch-time loading

- A single non-option argument is interpreted as the document path.
- Existing files are loaded into the bounded document buffer.
- A nonexistent path is retained as the target for a later save.
- The startup file path determines the active document name/tab label.

### In-window file workflow

- Added a clickable File menu with Open, Save, and Save As actions.
- Added an in-window path-entry prompt with character input, Backspace, Enter to confirm, and Escape to cancel.
- Added `Ctrl+O`, `Ctrl+S`, and `Ctrl+Shift+S`.
- Ctrl+S on an Untitled document opens Save As.
- Relative paths resolve from the process working directory; absolute paths are accepted.

### File safety

- Open reads into a separate staging buffer and only replaces the active document after a complete successful read and close.
- Partial reads and `EINTR` are handled.
- Files larger than the supported 64 KiB limit are rejected without replacing the active document.
- Save writes to a unique same-directory temporary file opened exclusively, handles partial writes and `EINTR`, fsyncs and closes the temporary file, then atomically renames it over the destination.
- Failed writes clean up the temporary file and do not truncate the existing target.

Current limitations remain: the path prompt is ASCII-only; there is no graphical directory browser, file filtering, or unsaved-changes confirmation. The temporary file uses mode 0644 subject to umask; existing mode/ownership/ACLs/xattrs are not preserved, and the parent directory is not fsynced after rename.

## 7. Phase F — XKB keymap transport and bounded layout parser

Keyboard layout support progressed from raw physical key handling to a dependency-free subset of XKB text-v1.

### Keymap descriptor transport

- Receives Wayland socket data with `recvmsg` so attached `SCM_RIGHTS` descriptors are not discarded.
- Receives `wl_keyboard.keymap` XKB_V1 file descriptors.
- Checks descriptor state, size bounds, expected keymap signature, and NUL termination.
- Maps the keymap read-only using `MAP_PRIVATE` and closes the received FD appropriately.
- Handles event EOF and descriptor cleanup.

### XKB text-v1 subset

The assembly parser handles a bounded common subset, including:

- Compiled keycodes and key names/aliases.
- Common named ASCII keysyms, including punctuation.
- Shorthand arrays such as `key <AE01> { [ ... ] }`.
- Explicit `symbols[GroupN]` arrays.
- Up to four groups and four levels.
- Common `ALPHABETIC`, `FOUR_LEVEL`, `THREE_LEVEL`, `EIGHT_LEVEL`, and related simplified type families.

Translation uses the XKB keycode +8 offset, active layout group, Shift/Caps behavior for alphabetic keys, and physical Right Alt as a LevelThree selector. Named punctuation keysyms are resolved into ASCII, including the twelve shifted US number-row symbols `!@#$%^&*()_+`.

### Safe fallback behavior

A keymap must contain sufficient recognized ASCII symbols and alphabetic keys before it is activated. Sparse or unsupported maps are rejected so they do not disable normal typing; NekoEdit retains its built-in US-QWERTY fallback. Tests cover incomplete/punctuation-only maps, parser table contents, all 26 ASCII letters, groups, Shift, Right-Alt LevelThree, and shifted number-row symbols.

This is not full XKB semantics. Custom type/modifier mappings, virtual modifier resolution, modifier actions, keypad behavior, compose/dead keys, non-ASCII keysyms, and IME integration are not implemented.

## 8. Phase G — printable ASCII punctuation rendering

A separate regression milestone completed the embedded bitmap glyph coverage for every printable ASCII punctuation character. The test checks that all 32 punctuation glyphs produce a nonblank bitmap and do not incorrectly fall back to the question-mark glyph.

The user tested a recent Actions build and reported that typing the symbol set `!@#$%^&*()_+{}|:"<>?` works. This is user-reported desktop behavior and is distinct from the automated bitmap test.

## 9. Phase H — initial UTF-8 code-point-safe editing

**Code milestone commit:** `70a333fc5392` — `feat: navigate and edit UTF-8 code points safely`.  
**Verified code/test commit:** `6cd9e08fada0` (Actions #160 passed).

This milestone begins safe editing around UTF-8 text already present in a file. The canonical document storage remains bytes; cursor positions are byte offsets, but operations now advance across valid Unicode code points instead of blindly incrementing one byte at a time.

Implemented:

- Added bounded `doc_utf8_next` and `doc_utf8_prev` helpers.
- Validates 2-, 3-, and 4-byte UTF-8 sequences, including restrictions that reject overlong encodings, surrogate code points, and values beyond U+10FFFF.
- Treats malformed bytes as individual one-byte editing units so invalid source bytes are not silently merged with adjacent characters.
- Left/Right and Shift+Left/Right move by complete valid code points.
- Backspace removes the previous complete code point.
- Delete removes the next complete code point.
- Selection and its visual rendering advance across code points rather than continuation bytes.
- Document rendering assigns one visual placeholder cell to a valid non-ASCII code point instead of one cell per encoded byte.
- Pointer hit-testing maps a visible text column back to the correct byte offset across variable-width UTF-8 sequences.
- Non-ASCII code points and malformed bytes still render as `?`; this is not Unicode glyph support.
- Text insertion from the physical keyboard/XKB path remains ASCII-only. There is no IME or Wayland text-input integration.
- The data structure remains a fixed 64 KiB byte array, not a gap buffer.
- Cursor positions are code-point-aware, not grapheme-cluster-aware. Combining sequences and multi-code-point emoji are not yet one navigation unit.

### Regression coverage added

The mock Wayland integration suite checks exact file bytes after operations on 2-, 3-, and 4-byte sequences. It covers:

- Right/Left movement across mixed-width code points.
- Shift selection of a complete four-byte code point.
- Backspace of 2-, 3-, and 4-byte code points.
- Delete-forward across ASCII and 2-, 3-, and 4-byte code points.
- Malformed UTF-8 bytes remaining independently editable.
- Pointer hit-testing after multiple multibyte code points, ensuring visual columns are translated to byte offsets correctly.

The test harness also received corrections to fixture positioning, dedicated UTF-8 test dispatch, malformed-byte deletion count, and failure diagnostics. These intermediate test/fix commits are all preserved in [COMMIT_INDEX.md](COMMIT_INDEX.md).

The user subsequently reported that the UTF-8 formatting/editing changes looked fine and that earlier functionality remained usable. This is recorded as user feedback, not as a substitute for the automated tests.

## 10. Phase I — fixed-capacity gap-buffer document storage

**Implementation commit:** [776a72c07579](https://github.com/GraderGamer2/NekoEdit/commit/776a72c07579ced1e54929946de65cea6271267e)  
**Verification:** [Build and test #169](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216369360), successful.

The editor replaces its contiguous document-editing array with a byte-oriented gap buffer inside the existing 65,536-byte allocation.

- doc_gap_start and doc_gap_end delimit the unused interval. Bytes before and after the interval form the logical document; document length, cursor, and selection offsets remain logical byte offsets.
- doc_move_gap moves the interval to a requested logical offset using backwards copying for leftward moves and forwards copying for rightward moves.
- doc_byte_at centralizes logical-to-physical offset translation. UTF-8 scalar validation, visual mapping, status calculation, selection rendering, and normal document rendering now use it instead of assuming the text is contiguous.
- Insertions consume available gap bytes. Backspace, Delete, and selection deletion enlarge the gap at the deletion point rather than shifting all remaining bytes.
- Startup load and successful staged Open place the gap after the loaded data. Save writes the prefix and suffix separately, omitting the gap while retaining the atomic temporary-file workflow.

A new mock-compositor regression case places the gap immediately after a two-byte UTF-8 character in AéBC, performs insertion on both sides, cursor movement, Backspace, Delete, and selection deletion, then verifies the exact saved byte sequence AéC. The complete CI workflow passed, including the full existing Wayland integration suite and artifact upload.

This is a real gap-buffer editing structure, but it is **not yet dynamically growing**. Its allocation is still 64 KiB, oversized files remain unsupported, and document/visual row mapping still uses linear scans rather than a line-start index. The existing code-point policy is unchanged: malformed bytes are individually editable, valid UTF-8 scalars remain whole, but grapheme clusters, non-ASCII rendering/input, and IME are not implemented.

## 11. Build, test, and artifact history

The Makefile provides these principal operations:

- `make` / `make clean all`: assemble and statically link the application, then verify the ELF has no interpreter or dynamic library dependencies.
- `make test`: run command-line smoke tests.
- `make test-wayland`: run the Python mock-compositor integration suite.
- `make inspect`: inspect ELF metadata.

GitHub Actions builds on Ubuntu 24.04 and uploads the Linux x86-64 executable as `nekoedit-linux-x86_64` with a seven-day artifact retention period. The Python test harness is test infrastructure, not a runtime dependency of NekoEdit.

On **2026-11-06**, Actions run [#160](https://github.com/GraderGamer2/NekoEdit/actions/runs/42213034086) passed for code commit `6cd9e08fada059ae3e24c9cdab7cf86762b24414`. The build, smoke tests, complete Wayland mock integration suite, executable inspection, and artifact upload succeeded. Artifact: `nekoedit-linux-x86_64`; reported archive SHA-256: `aa47ef8e0645e734f7dd7bd072cd31f51cc755907113603de6aebf8ab48917a7`; expiry: 2026-11-13.

## 12. Current milestone boundary

NekoEdit is an early interactive Wayland text-editor prototype with file operations, ASCII XKB translation, selection, scrolling, code-point-safe UTF-8 editing, and a fixed-capacity gap buffer. It is not yet dynamically growing, a complete editor, or a complete Unicode text stack.

Important items still on the roadmap include:

- Add dynamic gap-buffer growth beyond 64 KiB and a line-start index.
- Implement Unicode glyph lookup/rendering instead of question-mark placeholders.
- Implement non-ASCII text input, Wayland text-input/IME, compose and dead-key behavior.
- Add grapheme-cluster-aware navigation and deletion.
- Add undo/redo.
- Add clipboard integration using Wayland data-device protocols and immutable copy snapshots.
- Add horizontal scrolling and more complete viewport handling.
- Add resize/reconfigure and output scale handling.
- Add a directory-browser file picker and unsaved-changes protection.
- Expand XKB semantics beyond the currently supported common ASCII subset.
- Implement the X11 backend.
- Continue real-desktop smoke testing in addition to mock-compositor CI.

See [CURRENT_STATUS.md](CURRENT_STATUS.md) for the concise state to use before any further coding.


---

## 13. Repository administration — development branch renamed to `early-alpha`

On 2026-11-06, the development branch was renamed in GitHub from `feat/wayland-socket-error-handling` to `early-alpha`. The rename preserved the existing implementation tip, `6f9d17a3a09eaabf1393db214868fe57716ac7c0`; the former branch ref no longer appears in GitHub's branch search. No application implementation was changed by the rename.

GitHub Actions run [#174](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217617434) had already passed against that exact commit before the rename. Its eight workflow steps completed successfully. This is the last verified test result for the unchanged implementation tip, not a post-rename test run.

At the time of verification, PR [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) was closed and unmerged. Its API metadata still reported the former branch name in `head.ref`; this document records the observed metadata without assuming the reason for closure or treating the PR as merged. The rename and this documentation refresh did not merge editor code into `main`.

This administrative milestone changed no editor source, tests, build configuration, or runtime behavior. The project remains at the early interactive Wayland-editor milestone described above. Future implementation work remains paused pending explicit user authorization.


---

## 14. Review continuation — replacement PR #2

On 2026-11-06, [PR #2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) was opened from early-alpha into main. It provides a current review target for the renamed branch after PR #1 was closed without merging.

At creation, GitHub compared 185 commits ahead and 4 behind the target branch, with 12 changed files (6,804 additions and 235 deletions). PR-triggered Actions run [#179](https://github.com/GraderGamer2/NekoEdit/actions/runs/42220633279) passed all eight steps on head `108d7df1e024e74c653c5bb4cdbe52fb1d1289bf`. After CI, GitHub reported the PR mergeable with a clean merge state. The PR remains open and unmerged.

The PR description records the implementation, limitations, and the latest user-reported punctuation-key regression. The user's latest manual test reported that alphabetic input worked again but most shifted symbols produced `?`; this remains unresolved and is not negated by mock-compositor CI.

No source or test code was changed as part of opening the PR. Future implementation work remains paused pending explicit authorization.


---

## 15. Phase J — native directory-browser file picker

**Implementation milestone:** the native in-window Open/Save browser implementation, with final correctness fixes in [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82) and [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd).  
**Verification:** [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800), all eight workflow steps successful.

The native picker is an in-process modal directory browser drawn by the existing Wayland software renderer. It uses direct Linux filesystem syscalls and does not call GTK, Qt, a desktop portal, D-Bus, or an external file manager.

The interface contains an editable location field, Up and Home controls, Show hidden toggle, directory-first/file-second list, filename field, and Cancel/Open or Save actions. Directories are entered on double-click, regular files are opened on double-click or explicit activation, and Save As confirms replacement of an existing regular file. Failed or oversized Open and failed Save As preserve the previously active document/path.

The mock-compositor tests exercised Untitled Save, named Save, Open, nested-directory navigation, hidden-file visibility, Save As, overwrite confirmation/cancellation, missing/oversized Open rollback, failed Save As rollback, and Escape cancellation.

The strengthened exact-path test exposed two real defects: directory scans retained the prior row/time double-click history, and the relative path builder did not write a new terminating NUL after copying a shorter filename. Both were corrected. The test now checks the selected active pathname and loaded bytes, not only a rendered glyph.

The picker is intentionally small. At this milestone it was capped at 128 entries with 15 visible rows. Path/name entry was append/backspace-oriented, file filters and unsaved-document confirmation were absent, and real GNOME Wayland smoke testing remained separate from mock-compositor CI. These limitations and the full intermediate failure history are recorded in [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md).

---

## 16. Phase K — robust empty-file Open, scrollable picker, and editable location/search fields

**Implementation and validation:** [Build and test #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258), all eight workflow steps successful on [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49).

The file workflow now explicitly tests empty documents through both single-click-plus-Open and double-click activation. It asserts the exact active path and zero document length, then verifies that typing and Ctrl+S write to that same empty file. Keyboard selection now refreshes the filename field from the selected row, and Open confirmation uses the current search-match state rather than silently reusing an unrelated previous row.

The picker list responds to vertical `wl_pointer.axis` events, accumulates fixed-point scroll deltas, and uses a proportional draggable scrollbar. The Show hidden control is a bordered checkbox with a visible check mark; both the control and label toggle it, and every new picker session starts with dotfiles hidden.

The location and filename/search fields now support mouse-positioned caret placement, Left/Right, Home/End, insertion, Backspace, forward Delete, Ctrl+A replacement, and horizontal follow as the cursor moves. In Open mode, the filename field provides case-insensitive prefix matching over regular files in the current directory listing; the first match is selected and brought into view. A no-match query clears the old selection. The editable path field can commit a directory navigation with Enter and returns focus to the listing after success.

The integration suite covers zero-byte Open by both routes, exact path and document state, wheel movement, scrollbar thumb geometry/dragging, path middle insertion and Backspace, edited-path navigation, filename prefix matching, middle insertion/deletion, Home/End, Ctrl+A replacement, and opening the exact matched empty file. All of these run alongside the established editor, XKB, UTF-8, gap-buffer, repeat, selection, and protocol tests.

Actions run #235 passed all eight steps and uploaded `nekoedit-linux-x86_64` (27,216 bytes; SHA-256 `1afeefccb7c594100137e91538d30c0d8e661d026be964c956871c5a9eb64175`; artifact ID `13515385312`; expires 2026-11-13). Path/name input remains ASCII-only; clipboard paste and partial Shift selection are future work. Prefix search is limited to the current loaded directory listing, and the 128-entry limit remains. No third-party runtime library was added, and the launch form remains `./nekoedit --backend=wayland`.

Real GNOME Wayland desktop validation is still distinct from the passing mock-compositor suite. The user's previous report about shifted punctuation keys also remains awaiting manual confirmation against a recent artifact.

---

## 17. Phase L — filename autocomplete and native Wayland window management

**Autocomplete implementation:** [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519), validated by [Actions #245](https://github.com/GraderGamer2/NekoEdit/actions/runs/42245683431), all eight workflow steps successful.

The Open-mode filename Search field renders up to five matching filenames as a visible suggestion popup. Suggestions update while typing, Up/Down changes the highlighted result, Tab accepts it, and mouse selection is supported. Enter opens the highlighted entry. The integration fixture includes similarly named files and checks that choosing the second result opens that exact path and contents rather than defaulting to the first prefix match.

**Window-management implementation:** [`f516fc1a9b31`](https://github.com/GraderGamer2/NekoEdit/commit/f516fc1a9b316aa34a6c07533948822913469f02), subsequently corrected by [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969).

The Wayland window draws Minimize, Maximize/Restore, and Close controls in its title bar. It starts at 800×480, and renderer geometry, hit testing, status area, and editor viewport use the compositor-configured dimensions. The client retains a bounded memfd mapping and replaces its shared-memory buffer only after compositor release.

The GNOME window-management report prompted a focused correction. Maximize/Restore/Minimize no longer trigger an immediate stale-size attach/damage/commit after the state request; the client waits for the compositor's `xdg_toplevel.configure` / `xdg_surface.configure` sequence, acknowledges it, then redraws using the configured dimensions. Blank title-bar dragging now sends `xdg_toplevel.move`; a 6-pixel edge/corner hit region sends `xdg_toplevel.resize` using the serial from the initiating pointer press. Resize configures are applied through the existing buffer-release gate. Minimize remains a compositor request, so the resulting GNOME presentation is still subject to Mutter policy.

Actions [#251](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769) passed the full freestanding build, CLI, and Wayland mock suite through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`. The expanded scenario checks multiple toplevel configures, final state selection, configure-before-release deferral, title-bar move, and edge resize. Artifact `13521663942` (29,625 bytes) was uploaded. The user has not yet confirmed the fix in a real GNOME session; CI does not substitute for Mutter testing.

The one-active-buffer rendering model remains release-safe but can stall redraws while the compositor owns the buffer. Output-scale handling, fractional scaling, and a multi-buffer/frame-scheduling strategy remain future work. The supported launch command and freestanding/no-third-party-runtime design are unchanged.

## 18. Phase M — correct compositor geometry, edge resize targeting, and idle picker scrollbar

The user's real GNOME Wayland test exposed that the preceding mock-tested implementation had only fixed title-bar movement: Maximize still terminated the app and edge resizing did not take effect. The same report identified a scrollbar drawn outside its track when a directory had no overflow.

Implementation [`f990dc0aa9b1`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7) addresses those reports. The picker now omits the entire scrollbar when 15 or fewer entries fit, and the gutter cannot start a drag in that state. The Wayland client advertises its supported min/max window geometry, uses positive compositor-configured dimensions exactly within its preallocated shared-memory bound instead of silently clamping them, and clips rectangle/glyph writes to the active surface. Interactive resize hit targets are 12 pixels wide, with explicit tests for all four edges and four corners.

Actions [#253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598) passed the build, CLI checks, and expanded mock-compositor suite through both Wayland transports. The suite covers the 1920×1080 maximize/restore path, configure/acknowledge and buffer replacement, non-overflow scrollbar behavior, and resize request serialization. Artifact [`13524092766`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598/artifacts/13524092766) was uploaded.

This is not yet a confirmed GNOME fix. The user must retest the new artifact in Mutter; the #251 artifact was confirmed to crash on Maximize and fail to resize on the user's desktop. No unrelated feature work was started.
---

## 19. Phase N — dynamically growing document storage and large-file Open

**Implementation:** [8af89d509003](https://github.com/GraderGamer2/NekoEdit/commit/8af89d509003997272479ff2271542a304bdec07).  
**Verification:** [Build and test #312](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234), all eight workflow steps successful.

The fixed-capacity document array and separate fixed-capacity Open scratch area are replaced by independent mmap-backed buffers. Each starts at 64 KiB and doubles geometrically through mremap as data requires, with a 1 GiB safety ceiling. The document remains a byte-oriented gap buffer: when growth occurs, the suffix is relocated to the high end of the enlarged mapping, expanding the free interval into one contiguous gap while preserving logical byte offsets.

Initial command-line loading can now exceed 64 KiB. Picker Open reads into its own growable staging buffer, grows for larger files, reserves live document capacity before committing, and only changes the active document/path after a successful read and close. Failed Open continues to preserve the previous document.

The mock suite fills the initial 65,536-byte document exactly, inserts at byte zero, checks that capacity doubles to 131,072 bytes, verifies that all original suffix bytes survive, and saves the split gap as the exact expected byte stream. A second workflow opens and saves a 65,537-byte file through the native picker, confirming the active path, length, full contents, and on-disk result. Actions #312 also reruns the existing file-picker, UTF-8, gap-buffer, window-management, responsive-layout, protocol, and both Wayland-transport regressions.

Artifact [13556529585](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234/artifacts/13556529585) contains the freestanding Linux x86-64 executable (32,119 bytes; SHA-256 bb5666e76505c08b90e4ffac094af79bd2d4c4078014c0e81bf98c63cc3ba0f4). The user subsequently confirmed that a 70 KB file opens, accepts edits, and saves correctly on the live GNOME/Mutter desktop without crashing or behaving anomalously. This completes the real-desktop dynamic-storage/large-file verification.

The indexed line-navigation implementation is recorded in Phase P and grapheme-aware editing in Phase Q. The next rendering milestone is the installed-font parser and software glyph rasterizer; Unicode input/IME, shaping, undo/redo, horizontal scrolling, and clipboard integration remain unfinished.

---

## 20. Phase O — editor vertical scrollbar and mouse-wheel navigation

**Implementation:** [e3489badd178](https://github.com/GraderGamer2/NekoEdit/commit/e3489badd178d4db59c30e6660f9768f224f7e35), with initialization correction [028379b66a6b](https://github.com/GraderGamer2/NekoEdit/commit/028379b66a6bbfb0adb1d65d2c24696147258f96).
**Regression coverage:** [d4c0fcc5710b](https://github.com/GraderGamer2/NekoEdit/commit/d4c0fcc5710b0ab5ff49bc5831a3a334ecfaa01e).
**Verification:** [Build and test #316](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333006563), all eight workflow steps successful.

The document area now has a proportional vertical scrollbar when its visual content exceeds the viewport. Thumb height reflects visible visual rows relative to total rows, including soft-wrapped text, and the track is omitted when scrolling is unnecessary. The user can drag the thumb or click another point on the track to reposition it. Wayland vertical-axis events scroll the editor when the picker and path prompt are inactive; the directory picker keeps its independent scrolling. Manual scrolling redraws the viewport without forcing the caret back into view.

The editor reserves a 24-pixel gutter for the scrollbar, and line wrapping, selection clipping, and caret clipping use the reduced text width. Mock-compositor tests check empty-document hiding, the rendered thumb pixel on a 65,537-byte wrapped file, three-row wheel movement, drag-to-bottom, and one-row reverse scrolling. The full existing wrapping, resizing, selection, file, and protocol suite passes in Actions #316.

Artifact [13557973435](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333808492/artifacts/13557973435) contains the freestanding Linux x86-64 executable (32,919 bytes; SHA-256 `34ab58c1e8e3ebade7a85bdef2656900c7f2fa7595af15119b85cac8a24189ef`). The live GNOME/Mutter scrollbar check has not yet been performed. The user's separate 70 KB file edit/save test confirms the preceding dynamic-storage phase, but does not validate this new pointer and wheel interaction.

The next document-core milestone is a dynamic per-line index for byte lengths and visual-row counts, using prefix-sum trees so normal character edits do not shift all subsequent line offsets. Grapheme-aware cursor movement and Unicode input/rendering follow. The custom system-font parser and glyph rasterizer remain in the later rendering/font phase.


---

## 21. Phase P — indexed document line navigation

**Implementation:** [87a33b203501](https://github.com/GraderGamer2/NekoEdit/commit/87a33b20350180f324b70ce1bff091deabef0bab), feat: add indexed document line navigation.  
**Transactional Open correction:** [78db904b063f](https://github.com/GraderGamer2/NekoEdit/commit/78db904b063fc44cda4d2eabfd84aa5954da626c), invalidate the old index when a new document is committed.  
**Verification:** [Build and test #326](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320), all eight workflow steps successful.

The document core now maintains one compact record per logical line. Each 16-byte record stores the line's byte span (including LF), its soft-wrapped visual-row count, and the corresponding nodes of two Fenwick prefix trees. One tree indexes byte lengths; the other indexes visual-row counts. Both byte-offset-to-line and visual-row-to-line lookups use O(log N) prefix searches, then scan only within the selected logical line to locate the exact character boundary.

Ordinary byte insertion and deletion update the current line's metadata and point-update the Fenwick paths. Inserting LF splits a record; deleting LF merges two records. Since records remain in a compact contiguous array, structural newline edits shift the following records and rebuild the prefix trees. A window-width change recalculates the visual-row count for each logical line and rebuilds the row tree.

The index is integrated into caret/visual mapping, pointer hit-testing, scrollbar geometry, logical line status, and the renderer's first visible byte. As a result, painting a scrolled viewport no longer has to walk all preceding document bytes. The mmap-backed index starts at 256 records and grows geometrically to a bounded maximum of 0x01000000 lines. If it cannot be allocated or the document exceeds that line bound, the editor marks the index unavailable and retains the previous scan-based mapping as a fallback. Successful transactional Open invalidates the previous file's records before the next lookup rebuilds the index for the new document.

The regression suite inspects the actual per-line records and independently verifies both Fenwick node arrays on a document containing hard newlines, a soft-wrapped line, and a tab. It exercises ordinary insert/delete, newline split/merge, and exact save preservation. The complete Actions #326 run also confirms the existing 65,537-byte Open/save and editor-scrollbar path, including visibility, proportional thumb geometry, wheel movement, and thumb dragging. The live GNOME/Mutter index path still requires manual confirmation.

Artifact [13559973130](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320/artifacts/13559973130) contains the freestanding Linux x86-64 executable (34,965 bytes; SHA-256 e2e0e7b77095ece17f2b0573cb37fcb6e0823c56d95a0f4d3003e826ae40134a).


---

## 22. Phase Q — Unicode 18.0 extended grapheme-cluster editing

**Implementation:** [1eb5894443aa](https://github.com/GraderGamer2/NekoEdit/commit/1eb5894443aafcccd73e2463e91e7d85787dfaf1), navigate and delete extended grapheme clusters.  
**CRLF pointer correction:** [fd8020b4fe67](https://github.com/GraderGamer2/NekoEdit/commit/fd8020b4fe67fe056e61d69e819210b41268dd7e), keep hit-testing outside CRLF graphemes.  
**Verification:** [Build and test #331](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462), all eight workflow steps successful.

The document model now distinguishes UTF-8 scalar decoding from user-visible cursor positions. Valid scalar sequences are segmented into Unicode 18.0 extended grapheme clusters using embedded Grapheme_Cluster_Break, Indic_Conjunct_Break, and Extended_Pictographic property tables. The implementation follows the extended grapheme boundary rules in UAX #29, including CRLF, combining and spacing marks, Hangul syllable composition, Prepend, Indic conjuncts, emoji modifier and ZWJ sequences, and regional-indicator pairing. The tables are embedded in the assembly read-only section; no third-party runtime library or external property file is needed.

Left/Right and Shift+Left/Right now move between grapheme boundaries. Backspace and Delete remove the entire previous/next cluster, including clusters formed from several scalars. The same segmentation is used by visual-row measurement, byte/visual mapping, pointer hit-testing, selection painting, document rendering, and status-bar column counting. This keeps the line index and the rendered text layout consistent with the editing model. A grapheme occupies one cell in the current bitmap renderer; non-ASCII clusters still render as a question-mark placeholder until the custom font phase.

CRLF is one extended grapheme cluster. Deleting it removes both bytes, and the line-index merge uses the complete deleted byte span. Pointer hit-testing at the end of a CRLF-terminated line lands before the pair rather than between CR and LF.

The mock-compositor regression uses mixed UTF-8 cases for combining marks, emoji modifiers, family ZWJ, regional-indicator pairing, Hangul, Indic conjuncts, Prepend, SpacingMark, and CRLF. It checks each expected forward/backward boundary, pointer placement, whole-cluster Backspace/Delete, and line-index state after CRLF removal. The complete Actions #331 run also passes the existing line-index, large-file Open/scrollbar, picker, selection, keyboard, resize, and Wayland protocol regressions. Manual GNOME/Mutter validation of grapheme editing remains pending.

Artifact [13561405061](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462/artifacts/13561405061) contains the freestanding Linux x86-64 executable (43,886 bytes; SHA-256 25b80bd07ea11f7bc82816bdfae9c125878e67058f2e5ac563ae03bbfe86740c).



---

## 23. Phase R — proportional TrueType layout and font-metric line boxes

**Horizontal metric integration:** [`0cc839c72181`](https://github.com/GraderGamer2/NekoEdit/commit/0cc839c72181c8ac0ec6792db01996e1ebafa8fd) exposes TrueType horizontal advances; [`3b566344ee8a`](https://github.com/GraderGamer2/NekoEdit/commit/3b566344ee8aaf83fa3f89f4d0ffa5ec9463771d) applies them to document layout and hit-testing; [`fd2e4793aa3d`](https://github.com/GraderGamer2/NekoEdit/commit/fd2e4793aa3d0b16920f90429c289f57eeb27a8f) aligns selection painting; [`3efdcbc537a4`](https://github.com/GraderGamer2/NekoEdit/commit/3efdcbc537a4b9a63224d8b68c34d24a16fe9a8e) applies advances to picker and path-prompt text.  
**Cleanup:** [`3bc0b93a9994`](https://github.com/GraderGamer2/NekoEdit/commit/3bc0b93a999402400111b75a8644307d6ece3141) removes temporary pointer/visual hit-test diagnostics.  
**Vertical metric integration:** [`f6d735b21549`](https://github.com/GraderGamer2/NekoEdit/commit/f6d735b215493d7a67759de2f0aa269fc66d5e21), derives document line pitch from hhea ascent, descent, and line gap; [`beac1f4a9622`](https://github.com/GraderGamer2/NekoEdit/commit/beac1f4a96229817bc3444fd035330d12914cd53), zero-initializes its runtime state for the freestanding BSS section.  
**Verification:** [Build and test #400](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260), all eight substantive checks successful.

The first variable-width document layout now uses each grapheme's first decoded Unicode scalar to obtain a TrueType glyph advance from `hmtx`. At the fixed 12-pixel em, the advance is scaled to pixels, rounded to the nearest integer, and bounded to 1–32 pixels. This one measurement is shared by soft wrapping, indexed visual-row counts, byte/visual mapping, pointer hit-testing, selection painting, and document rendering. Picker and path-prompt text also consume these advances. The no-font/invalid-metric fallback retains the legacy eight-pixel advance.

Vertical document geometry uses OS/2 sTypoAscender, sTypoDescender, and sTypoLineGap when a version 4+ OS/2 table declares USE_TYPO_METRICS; otherwise it falls back to hhea ascent, descent, and line gap. The selected line box is scaled to the fixed 12-pixel em, rounded upward, and clamped to 12–32 pixels. A single runtime line-pitch value is used by viewport row counts, pointer row selection, document/selection painting, and caret placement. With no loaded font, the original 12-pixel row pitch is retained.

The synthetic-font regression deliberately assigns 900-unit ascent, −300-unit descent, and 100-unit line gap in a 1000-unit em. It verifies the resulting 16-pixel line pitch, 23 visible rows in an 800×480 surface, proportional 8px/5px advances, a correct pointer-to-caret result, the indexed wrapping record, and actual glyph pixels on both visual rows. The initial attempt failed at assembly because a nonzero value was emitted in `.bss`; the state was changed to zero initialization and Actions #400 then passed the complete workflow.

Font selection and font-size controls remain unimplemented. The em size is fixed at 12 pixels, and layout currently handles only the first Unicode scalar of a grapheme; full shaping, kerning, ligatures, combining-mark positioning, bidirectional/complex-script layout, hinting, variable/color fonts, and IME remain future work. Manual GNOME/Mutter validation of the metric-aware font rendering is still pending.

---

## 24. Phase S — TrueType typographic metrics and responsive picker text alignment

**Metric parsing and layout:** [32e54ad242d5](https://github.com/GraderGamer2/NekoEdit/commit/32e54ad242d5a95f100946629e43d6d214a8fe83) adds OS/2 typographic line metrics and cmap/hmtx-based space advances; [668da6cafbe7](https://github.com/GraderGamer2/NekoEdit/commit/668da6cafbe7d6aadf4e40c21c3b10c508a712c9) corrects SFNT hmtx validation and path-prompt centering after CI exposed register-lifetime errors.
**Dialog metric/transform alignment:** [961e19fec1a9](https://github.com/GraderGamer2/NekoEdit/commit/961e19fec1a903e061cc7804a164fb4426145825) measures picker and overlay glyph advances at the active raster size and converts them through the same horizontal transform used by glyph origins. Caret position, visible-text clipping, and pointer hit-testing therefore share the rendered glyph widths, including when the dialog is height-constrained.
**Regression and verification:** [8106dd3e109d](https://github.com/GraderGamer2/NekoEdit/commit/8106dd3e109d4b0afea3847b30503f78cca8088c) and [5324e05b45c8](https://github.com/GraderGamer2/NekoEdit/commit/5324e05b45c8f1bba8906fe6a1453f05958ab2f5) adapt the compact mock-compositor fixture and assert transformed row geometry. GitHub Actions [Build and test #414](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432) passed the complete workflow and uploaded artifact [13570135812](https://github.com/GraderGamer2/NekoEdit/actions/runs/42361027432/artifacts/13570135812).

The font parser now uses OS/2 typographic ascent, descent, and line gap when a version 4+ OS/2 table sets USE_TYPO_METRICS, while retaining hhea as a fallback. U+0020 SPACE resolves through cmap and hmtx like other glyphs, so proportional fonts no longer inherit a hard-coded space width. The Open/Save picker and path prompt keep glyph raster size and advance calculations in one coordinate system: advances are measured at the actual UI font size, then mapped back through the dialog's horizontal scale before later glyph origins are transformed. Picker prefix measurement, clipping, caret position, and mouse hit-testing all use this same metric.

The compact 800x360 synthetic-font test deliberately constrains the picker by height. It verifies the 8px rendered size, exact caret and focus-line pixels, a pointer coordinate that distinguishes the 8px metrics from the previous fixed 10px advance, and filename glyph pixels inside the selected-row highlight. It also retains selected-row top/bottom pixel checks.

The intermediate CI failures were preserved and corrected rather than bypassed: #409 and #410 exposed incorrect SFNT table-length validation after OS/2 parsing; #412 and #413 exposed stale 480px and unscaled-row assumptions in the new compact-window test. The final #414 run passed the full build, CLI, mock Wayland, ELF inspection, and artifact-upload workflow.

The result is verified in the mock compositor only. A live GNOME/Mutter run is still needed to confirm the user's original appearance issue is fully resolved. Font-size selection UI, runtime font switching, hinting, kerning, script shaping, and combining-mark positioning remain unfinished.

---

## 25. Phase T — Persistent-open font Settings and native Wayland clipboard shortcuts

**Implementation:** [`6a1db52996c8`](https://github.com/GraderGamer2/NekoEdit/commit/6a1db52996c8c134f11736d0f173eaf70ca1af11) keeps the Settings dropdown open during repeated font-size changes and adds an independent UI font-size control. [`b5c52ecca8a1`](https://github.com/GraderGamer2/NekoEdit/commit/b5c52ecca8a1973ffb97f5541b119103887cad46) adds the native Wayland clipboard backend; [`78a67be968b3`](https://github.com/GraderGamer2/NekoEdit/commit/78a67be968b39bf9b123952fcef311584be73170) corrects event dispatch so data-device events reach the clipboard state machine.

The Settings dropdown exposes two independent controls: document em size from 8–24px in two-pixel steps and UI text size from 8–14px in one-pixel steps. Neither plus/minus action closes the menu, including at its limits. The UI size affects ordinary interface text without changing document layout metrics; picker height-fitted text remains separately scaled. Preferences currently remain session-only.

The Wayland clipboard manager creates a data device for the application seat. Ctrl+C publishes an immutable copy of the selected bytes; Ctrl+X first establishes clipboard ownership from that snapshot and only then deletes the range; Ctrl+V requests UTF-8 plain text (or plain-text fallback) and receives the response asynchronously through a nonblocking pipe. Outgoing snapshots are independent of the document gap buffer and remain alive through in-flight sends. A 64 MiB transfer cap bounds clipboard payloads. The poll loop services send and receive descriptors without blocking key handling.

**Regression coverage:** the Settings test performs repeated increments/decrements without reopening the dropdown and checks the two settings independently. The clipboard test runs a separate compositor-side receiver for Copy/Cut, verifies the original bytes remain transferable after Cut deletes the document selection, and sends an external MIME offer through Ctrl+V to verify asynchronous insertion. Actions [#432](https://github.com/GraderGamer2/NekoEdit/actions/runs/42367881187) passed the settings milestone; Actions [#437](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369161877) passed the clipboard end-to-end test. The initial clipboard test exposed fixture/dispatcher defects, which were fixed before #437 rather than bypassed.

## 26. Phase U — Bounded undo/redo history and core editor shortcuts

**Implementation:** [`4fa444ef96d8`](https://github.com/GraderGamer2/NekoEdit/commit/4fa444ef96d8a3f9ef70ede628db6d1b34ec28af) adds `src/editor/history.c`, an independent bounded snapshot-history module. The Wayland keyboard path maps Ctrl+Z to Undo, Ctrl+Y and Ctrl+Shift+Z to Redo. Document edits are grouped by input action, rather than recording a new history state for each inserted byte. Snapshots store document bytes, caret offset, selection anchor and selection-active state. Loading a different document resets history; a new edit after Undo invalidates the Redo branch.

The history store is intentionally bounded: 16 entries per Undo/Redo stack, a 32 MiB aggregate snapshot budget, and a 4 MiB per-snapshot ceiling. Each snapshot is an independent mmap allocation; restoring a state reserves sufficient gap-buffer capacity, replaces its contents, invalidates the per-line index, and refreshes caret visibility. Documents larger than the snapshot ceiling remain editable but cannot be fully represented by this history implementation.

**Regression coverage and verification:** the Wayland integration test replaces a selected document, checks Undo and Redo byte-for-byte, verifies restoration of the prior caret and active selection, collapses that selection with Right Arrow, then types a new character and checks that a stale Redo action cannot alter the new branch. An intermediate #439 failure was a test-expectation error: it expected typing after Undo to append despite Undo correctly restoring the selected range; the test was corrected to collapse that range before branching. Actions [#440](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369791425) passed all build, CLI, Wayland mock, ELF inspection and artifact-upload stages. Artifact [`13572958390`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42369791425/artifacts/13572958390) is 61,359 bytes with SHA-256 `e8d1c2027d934efa7dc7661819c28de22af7538a23c5c07eec00ae939d45a2e7`. Live GNOME/Mutter validation of this artifact remains outstanding.


---

## 15. Phase V — soft-wrap control and horizontal document viewport

**Implementation:** [80c2fdc6916f](https://github.com/GraderGamer2/NekoEdit/commit/80c2fdc6916f8403350d10826043f90936642f0a) adds horizontal scrolling for unwrapped document lines; follow-up fixes and integration-test corrections are recorded in [COMMIT_INDEX.md](COMMIT_INDEX.md).

The Settings menu now includes a session-only **Wrap Lines** switch, enabled by default. In wrapped mode, long logical lines continue to use pixel-advance-based soft wrapping and the line index records the resulting visual rows. In no-wrap mode, each logical line maps to one visual row and the editor maintains a horizontal pixel origin for the document viewport.

Wayland horizontal-axis wheel events and Shift+vertical-wheel events scroll the viewport horizontally. The caret is kept visible as it moves along a long line. Pointer hit-testing includes the horizontal offset and continues to use the same font advances and grapheme-boundary mapping as the renderer. No-wrap selection backgrounds are painted through a viewport-clipped path. Turning wrapping back on resets the horizontal origin and rebuilds the wrapped row index. The existing vertical scrollbar represents wrapped visual rows in wrapped mode and logical lines in no-wrap mode; a dedicated draggable horizontal scrollbar remains future work.

The dedicated 200-byte-line mock-compositor scenario verifies the Settings toggle, one-row no-wrap index, caret-following horizontal offset, 14px horizontal wheel movement, pointer hit-testing with a nonzero horizontal origin, and restoration of wrapped layout. GitHub Actions [#447](https://github.com/GraderGamer2/NekoEdit/actions/runs/42372524911) passed the complete freestanding build, CLI, Wayland mock, ELF inspection, and artifact-upload workflow. Artifact [13574342289](https://github.com/GraderGamer2/NekoEdit/actions/runs/42372524911/artifacts/13574342289) is 62,237 bytes. Manual GNOME/Mutter verification of this exact build remains outstanding.


---

## 27. Phase W — Responsive controls, horizontal scrollbar, selection, and search

**Responsive interface:** [`4b116c25e730`](https://github.com/GraderGamer2/NekoEdit/commit/4b116c25e7304743ff54cd3c731da887cbd0eb01) scales Settings controls with the selected UI typography. Follow-up layout fixes use a centered, aspect-ratio-preserving panel transform so the panel, glyph raster size, and pointer hit map stay in the same coordinate system. Find/Replace follows the same sizing policy.

**Horizontal document scrollbar:** [`ed9f432dca08`](https://github.com/GraderGamer2/NekoEdit/commit/ed9f432dca0883be6c2e1d76b3ecbca589703466) adds the bottom horizontal rail for no-wrap documents. The thumb maps the widest logical line to the document viewport; track clicks reposition it and mouse dragging retains the thumb grab offset. Horizontal-wheel and Shift+vertical-wheel inputs use the same pixel-scroll path. The viewport height is reduced while the rail is visible so it never obscures document content.

**Selection and keyboard navigation:** [`9ba8ec298672`](https://github.com/GraderGamer2/NekoEdit/NekoEdit/commit/9ba8ec298672201d31551eb5bacd90116eeaf098) adds word selection on double-click and Ctrl+Left/Right word navigation. [`844da8f8a8fb`](https://github.com/GraderGamer2/NekoEdit/commit/844da8f8a8fbaeb447f03e99480fb13ad541f4b7) adds Ctrl+Up/Down movement between logical lines; Shift variants extend selections. Ctrl+Home/End and Ctrl+Backspace/Delete provide document-boundary and word-deletion operations.

**Find/Replace:** [`a8bd382bbd75`](https://github.com/GraderGamer2/NekoEdit/commit/a8bd382bbd75b4fb99786ae8c83cf91a83cfd3f2) adds a centered Find/Replace modal. Ctrl+F/ Ctrl+H open Find and Replace, Enter/F3/Shift+F3 navigate literal matches, Ctrl+Enter replaces a selected match, and Replace All iterates through the document. Query text entry follows the currently supported ASCII XKB subset.

**Verification:** the full Wayland mock-compositor suite checks horizontal track dragging and both wheel paths, panel centering and UI-font scale, Ctrl+word and logical-line movement, Shift-extended selection, double-click word selection, and Find/Replace byte results. Actions [Build and test #493](https://github.com/GraderGamer2/NekoEdit/actions/runs/42391111760) passed all workflow stages and uploaded artifact [13581805940](https://github.com/GraderGamer2/NekoEdit/NekoEdit/actions/runs/42391111760/artifacts/13581805940), 67,298 bytes. The user has manually confirmed runtime font selection; the newly added interactions still need a GNOME/Mutter desktop smoke test.


---

## 28. Phase X — persistent typography, font, and editor preferences

The responsive editor controls and search interactions were followed by a small persistent-settings layer. The implementation lives in `src/editor/preferences.c` and follows the project's freestanding design: it uses raw Linux syscalls rather than libc or a third-party configuration dependency.

The preference file is stored at `$XDG_CONFIG_HOME/nekoedit/preferences`, or `~/.config/nekoedit/preferences` when `XDG_CONFIG_HOME` is unset. It records document font size, UI font size, Wrap Lines, Confirm before saving, and the last successfully loaded TrueType path. Startup restores these values before the first layout calculation and before font initialization. An explicit `NEKOEDIT_FONT` environment setting continues to take priority over the saved font; the saved path is tried before the deterministic system-font candidates.

Values are parsed with bounded input and range checks. Font paths must be absolute and cannot contain carriage returns or newlines. The application directory is created with mode 0700 and the file is mode 0600. Updates go to a same-directory temporary file, handle partial writes and EINTR, fsync the file, atomically rename it, and fsync the containing directory. `NEKOEDIT_DISABLE_PREFERENCES=1` leaves runtime defaults/settings alone and bypasses persistence.

The preference-specific unit test verifies initial defaults, persistence and reload of every supported setting, the TTF path, restrictive file mode, invalid/range-out-of-bounds values, path-format rejection, and the disable switch. The Wayland mock-compositor test sets the disable switch so machine-specific user settings cannot change the expected pixel/input fixtures.

GitHub Actions [Build and test #505](https://github.com/GraderGamer2/NekoEdit/actions/runs/42391762592) passed the full build, ELF, CLI, preferences, Wayland, executable-inspection, and artifact-upload workflow on commit [`8dc43ea3a1a3`](https://github.com/GraderGamer2/NekoEdit/commit/8dc43ea3a1a34350d45aa016e8c815e58e713ef7). The artifact is 70,250 bytes with SHA-256 `796dc4ceb118b364eccd37ff58db88c5bf33e50dbd5263b76ffaf314ce4c2279`. This remains mock-compositor/automated verification; manual GNOME/Mutter testing of the scrollbar, responsive overlays, Find/Replace, and preference restoration is still required.


---

## 29. Phase Y — home-level settings, document-wide search highlighting, and Unicode keyboard input

### Home-level settings storage

The preferences implementation was moved from the XDG-style configuration directories to a single hidden application folder directly under the user's home directory: `$HOME/.nekoedit/preferences`. The application no longer reads XDG_CONFIG_HOME. The directory retains mode 0700 and the preference file mode 0600; same-directory temporary writes, fsync, atomic rename, and directory fsync are retained. The preferences test sets both HOME and XDG_CONFIG_HOME and proves that only the HOME-level `.nekoedit` directory is created.

### Typography panel refinement

Settings and Find/Replace no longer scale their outer panel dimensions with the UI font-size preference. They retain 256×168 and 448×192 design dimensions respectively, centered and fitted to the available window. The actual glyph size follows the selected UI font and the pointer transform remains in the same coordinate space. The regression test sets the UI font to 16px and checks the two panel dimensions stay at their fixed values while both overlay font-size values report 16px.

### Document-wide Find highlighting

The renderer now runs a literal query scan over the document while Find/Replace is open. Every occurrence is highlighted in amber, including repeated and overlapping results. The active result is painted afterward using the selection renderer, so the current match remains distinct. The Find integration test inspects the framebuffer to prove that the second non-active occurrence is also painted.

### Unicode keysyms and UTF-8 document insertion

The XKB text-v1 parser now maintains a parallel Unicode-scalar table in addition to its existing ASCII byte lookup table. It recognizes explicit Unicode keysym tokens in Uxxxx, Uxxxxx, and Uxxxxxx form, rejects values outside Unicode's scalar range, surrogate values and control characters, and stores each value by keycode, group and level. Document keyboard input uses the Unicode lookup path when a parsed keymap is available and encodes the selected scalar into one to four UTF-8 bytes through the normal document insertion path. The built-in US-QWERTY fallback remains unchanged.

The regression map maps one physical key to U+00E9 (é) and its Shift level to U+1F600 (😀). The mock test verifies the document contains the exact byte sequence C3 A9 F0 9F 98 80. Existing ASCII layout tests still exercise keycode offset, group switching, Shift, LevelThree, and the shifted punctuation rows. This is explicit Unicode-keysym support only; named keysym aliases, full XKB modifier/type/action handling, compose/dead keys and Wayland text-input/IME remain future work.

### Verification and boundaries

Actions [Build and test #518](https://github.com/GraderGamer2/NekoEdit/actions/runs/42393599670) passed the three requested refinement tests. After the Unicode-input work, Actions [Build and test #523](https://github.com/GraderGamer2/NekoEdit/actions/runs/42393972784) passed the complete build, CLI, preferences, Wayland mock, ELF inspection, and artifact-upload workflow on [`72695a3d9f3d`](https://github.com/GraderGamer2/NekoEdit/commit/72695a3d9f3dd7a714c5f80bf014b9e1d7fd28e6). Artifact [13582597118](https://github.com/GraderGamer2/NekoEdit/actions/runs/42393972784/artifacts/13582597118) is 70,702 bytes. This is automated mock-compositor verification; GNOME/Mutter desktop testing of the latest settings restoration, responsive panels, search highlights, and Unicode typing remains outstanding.


---

## 30. Phase Z — whole-word pointer dragging, edge auto-scroll, and named Unicode keysyms

### Whole-word mouse dragging

Double-click now creates a complete word selection while preserving the active pointer grab. Dragging the held button extends the selection by whole words; moving to the left of the original word retains its right boundary and extends toward earlier words, while moving right retains the original left boundary. Single-click dragging continues to operate at character/grapheme boundaries.

### Selection edge auto-scroll

Selection motion is handled even when the pointer is outside the document viewport or the application surface. NekoEdit clamps the hit-test position to the nearest document edge while retaining the actual pointer location to determine the scroll direction. A separate timerfd drives scrolling while the mouse button is held and the pointer is outside the viewport. Vertical scrolling works in both soft-wrap modes; horizontal scrolling follows the pointer when Wrap Lines is disabled. Timer-driven scrolling continues if the pointer stops moving at the edge and stops on button release.

### Named XKB Unicode keysyms

The parser now resolves a curated set of 105 common named non-ASCII keysyms, covering Latin-1 symbol/letter names and selected currency, punctuation, quotation-mark, and typographic symbols such as EuroSign, endash, emdash, bullet, ellipsis, and trademark. These aliases populate the same per-key/group/level scalar table as explicit Uxxxx/Uxxxxx/Uxxxxxx tokens and use the existing UTF-8 document insertion path. This is a deliberate subset rather than full XKB support; complete virtual-modifier and action semantics, arbitrary custom type maps, compose/dead keys, and text-input/IME remain future work.

### Regression coverage and verification

The mock compositor verifies forward and reverse whole-word dragging after double-click; character-selection continuation after pointer-leave; vertical auto-scroll both immediately and while the pointer is stationary; horizontal auto-scroll with Wrap Lines disabled; and timer cleanup on release. XKB tests inspect the parsed scalar table and confirm explicit U+00E9/U+1F600 plus EuroSign/eacute/emdash insertion. GitHub Actions [Build and test #544](https://github.com/GraderGamer2/NekoEdit/actions/runs/42396964885) passed the complete freestanding build, CLI, preferences, Wayland integration, ELF inspection, and artifact-upload workflow on [e9bbc7a6ff04](https://github.com/GraderGamer2/NekoEdit/commit/e9bbc7a6ff048b53e4961d2bd9014cac45a7569a). Artifact [13583613881](https://github.com/GraderGamer2/NekoEdit/actions/runs/42396964885/artifacts/13583613881) is 72,303 bytes with SHA-256 `4d01116a148ed94405a5f6623927a7d7bf41c6b207f02e8ab105a9d6ec318a13`. A GNOME/Mutter desktop test of the new mouse interaction remains outstanding.


---

## 31. Phase AA — bounded XKB dead-key composition

Six common XKB dead-key names are now recognized: grave, acute, circumflex, tilde, diaeresis, and cedilla. Their keysyms use reserved action tokens rather than pretending to be ordinary Unicode scalars. The Wayland keyboard path stores a pending combining mark and applies it to the next printable scalar. A 52-pair mapping produces common Latin-1 precomposed letters. When no precomposed result exists, the editor inserts the base scalar followed by the combining mark, preserving the input. Backspace and Escape cancel a pending mark without modifying the document, and keyboard focus loss clears it.

The mock compositor verifies that AC04 maps to the reserved dead_acute action, dead acute followed by e inserts UTF-8 for é, dead acute followed by g preserves g plus U+0301, and Backspace/Escape cancellation leaves document bytes and length unchanged. This is a deliberately bounded first compose implementation: general Compose sequences/tables, locale-specific mappings, full XKB actions/types, and Wayland text-input/IME remain unimplemented.

GitHub Actions [Build and test #551](https://github.com/GraderGamer2/NekoEdit/actions/runs/42397866256) passed the full build/ELF, CLI, preferences, Wayland mock-compositor, executable-inspection, and artifact-upload workflow on [cb469d616f8b](https://github.com/GraderGamer2/NekoEdit/commit/cb469d616f8b40cd27e4d37fe2e1320169a826ad). Artifact [13584292417](https://github.com/GraderGamer2/NekoEdit/actions/runs/42397866256/artifacts/13584292417) is 72,887 bytes with uploaded ZIP SHA-256 947dd732391b1f7f792ca60c0b60b28114f81cff0e8a4b066989d3a64705a6f8. Automated verification is complete; live GNOME/Mutter testing remains outstanding.


---

## 32. Phase AB — process-exit clipboard service and disk-backed edit history

### Clipboard service bundled into NekoEdit

The optional Clipboard Service preference is stored in ~/.nekoedit/preferences and defaults to enabled. When NekoEdit owns a clipboard selection at window close, the existing executable forks a small child and labels the process nekoedit-clip. It inherits the original Wayland connection, existing wl_data_source, and independent immutable clipboard snapshot; it does not reconnect as another client or attempt to reacquire ownership. The service handles future wl_data_source.send requests through the existing nonblocking transfer state machine.

The helper exits when the compositor reports that the selection has changed, the source is cancelled, or the Wayland connection closes. It only retains the latest selection for the current session; it is not a clipboard manager or persistent clipboard history. The helper is not running beside the editor during normal editing; the fork occurs in the editor's window-close path. The feature is disabled when the persisted setting is off.

The first post-exit integration test failed with an empty transfer pipe. Inspection found that the assembly application_exit call site did not align the stack for the nested C handoff call under the SysV x86-64 ABI. The call is now bracketed by an eight-byte stack adjustment. Actions [Build and test #600](https://github.com/GraderGamer2/NekoEdit/actions/runs/42445630695) then passed and the mock log confirmed the helper served the copied bytes after the parent exited, then disconnected after selection replacement.

### Disk-backed per-document Undo/Redo

Replaced the former full-document snapshot stacks with a disk-backed delta journal in src/editor/history.c. Each named document receives a private .history file under ~/.nekoedit/, keyed by a hash of the pathname identity. The journal stores baseline bytes, grouped changed ranges, the bytes removed/inserted, before/after caret and selection state, an Undo/Redo cursor, and a checksum of the last successfully saved document. The directory is created mode 0700; journal/export files use 0600.

Undo/Redo now scales with changed bytes and edit metadata instead of copying the entire document for each history entry. New edits after Undo discard the obsolete Redo branch. A saved-document checksum protects recovery: on restart, the journal is replayed only if the current file still matches the last successful save. External modifications reset the journal rather than allowing stale edits to replace external content. Untitled documents use a per-process identity, so restart recovery requires a named document path.

The History tab beside the document tab displays Undo/Redo counts and exposes Undo, Redo, Export, and Delete. Export copies the current journal through the native Save picker with atomic replacement. Delete removes the journal without changing the open document; future edits start a new journal. An isolated host test covers grouping/replacement, Redo invalidation, more than 16 actions, restart recovery, export, deletion, and permissions.

External Wayland paste arrives asynchronously after the Ctrl+V key event, so the insertion routine now wraps the actual received-byte mutation in its own history transaction. This makes delayed external paste one Undo/Redo action, like local paste. The Wayland mock checks Ctrl+Z removes that paste and Ctrl+Y restores it.

### Regression coverage and verification

The Wayland mock now verifies the helper lifetime after parent exit and selection replacement, asynchronous paste Undo/Redo, and the visible History-tab controls (tab switch, Undo/Redo buttons, Export picker open/cancel, Delete). The host history test verifies persistent journal recovery and file management independently of Wayland.

Actions [Build and test #601](https://github.com/GraderGamer2/NekoEdit/actions/runs/42445779246) passed the complete suite after the asynchronous paste transaction fix. The first History-page test iteration passed its UI assertions but failed during teardown after a redundant no-op Ctrl+Z following Delete; that extra shortcut was removed because the host test already verifies that a deleted journal no longer has Undo entries. Actions [Build and test #603](https://github.com/GraderGamer2/NekoEdit/actions/runs/42446143746) then passed all eight workflow steps on [ae633fa5d654](https://github.com/GraderGamer2/NekoEdit/commit/ae633fa5d6545d64dbdeca25f68392abb5b37440), including build/ELF checks, CLI/preferences/history tests, the entire Wayland mock, executable inspection, and artifact upload. Artifact [nekoedit-linux-x86_64](https://github.com/GraderGamer2/NekoEdit/actions/runs/42446143746/artifacts/13602839495) is 80,540 bytes (artifact ID 13602839495).

The helper and History tab are validated by the mock compositor. A live GNOME/Mutter session check remains outstanding; do not claim user-side desktop behavior until the user reports it.

## 2026-11-08 — lazy history files, document path search, and copy regression coverage

The History subsystem now creates a document journal only when a byte is first inserted or removed. Opening an unedited/empty document, navigating, selecting, and copying should not create an empty `.history` file. Existing journals are still recovered when the corresponding document is opened.

A new History search reads and validates original paths stored in the journal headers. It lists named document histories, filters by path, and opens the selected document so its own Undo/Redo state can be managed. Untitled process identities are omitted from the reopenable search list. The page is arranged to fit the default 800×480 window.

The keyboard path now closes the empty history transaction after Ctrl+C, and the Wayland mock repeats Ctrl+C while verifying superseded Wayland data sources are retired. These changes target the reported crash path and improve regression coverage, but live GNOME/Mutter validation is still necessary to establish whether the desktop crash is fixed.


---

## 33. Phase AC — clipboard-helper teardown, compact History records, launcher and expanded Compose input (2026-11-08)

The latest user review found three usability issues that the existing mock suite did not fully cover: the clipboard helper could leave the inherited editor window objects alive; the History page's fixed controls and search affordances did not form a usable layout; and small edits still accumulated substantial record metadata. The editor now destroys the inherited xdg_toplevel/xdg_surface/wl_surface/wl_buffer in the post-exit clipboard child, detaches that child from the launching terminal, and clears its history-journal state while retaining the original clipboard data-device/source and snapshot. The event loop treats `poll()` interruption by EINTR as a retry rather than a fatal Wayland failure.

The History page now has a true path filter, a separate Browse picker, Open Selected, visible Undo/Redo counters, responsive action controls, and Delete Selected History semantics. Deleting a highlighted non-active history removes only that hashed journal. New version-2 journals compress the common per-action metadata with a 24-byte record header and variable-length operation fields; a one-byte typing action at a short offset takes 28 bytes, compared with 49 bytes for the previous v1 record. Version-1 journals remain readable and writable. Host tests assert the compact record size, simulate a v1 legacy journal and test its recovery/Undo/Redo path, and delete a non-active journal without disturbing the active history.

The build now includes a per-user install/uninstall workflow and desktop launcher/icon, with an install smoke test integrated into `make test`. The XKB `Multi_key` subset has advanced from 20 to 40 two-symbol pairs; extra tests validate degree, paragraph, registered-mark and ø output. This remains a bounded subset, not complete locale XCompose, XKB actions, or an IME.

Implementation commit: [f3f6da21af1c](https://github.com/GraderGamer2/NekoEdit/commit/f3f6da21af1c50a1716a1ef684321e219116c333). Automated validation of this follow-up is pending on the final PR branch update. GNOME/Mutter live testing remains the user's desktop milestone.


### Build correction for the compact journal encoder

The first complete branch Actions attempt for Phase AC stopped in the strict C build: `encode_transaction_v2()` referenced the existing `map_mem()` helper before a prototype, triggering `-Werror=implicit-function-declaration`. Added a forward declaration without changing the v2 disk layout or the version-1 compatibility path. Corrected source commit: [55c28440d88a](https://github.com/GraderGamer2/NekoEdit/commit/55c28440d88ad251f5898293e58722b54f000fe6). The complete corrected workflow is pending; no downstream tests from failed Actions #608 ran.


### Compact collapsed-caret metadata correction

Actions #609 found that the compact record encoder was writing its optional 10-byte state extension whenever the selection anchor differed from the caret, even when no selection was active. Such an inactive anchor is not semantically used by Undo/Redo. The writer now includes before/after anchors only when either state has an active selection, and playback normalizes the collapsed anchor to the caret. Source correction: [9454373ea04e](https://github.com/GraderGamer2/NekoEdit/commit/9454373ea04eb2fb3ad41dcbc73f4cf7ab5a1df1). The 28-byte compact-record host test covers a collapsed caret with a stale anchor. Full host and Wayland validation is pending.


### Phase AC automated validation result

The corrected branch snapshot [5a5ea78458e4](https://github.com/GraderGamer2/NekoEdit/commit/5a5ea78458e4daa71fb9e4f3fc2eaf23daca0ea9) passed all eight steps in GitHub Actions [Build and test #610](https://github.com/GraderGamer2/NekoEdit/actions/runs/42453763428). This includes the freestanding/ELF build, CLI and preferences tests, compact-history/legacy-v1 host tests, install/uninstall smoke, full Wayland mock coverage, executable inspection, and artifact upload. Artifact [13606921648](https://github.com/GraderGamer2/NekoEdit/actions/runs/42453763428/artifacts/13606921648) is 86,304 bytes, SHA-256 `fc4216b2c0a57ac3bced774b8d1d7bdb6aef912f843f10e9704f6cfd98a76792`. The mock suite passed; manual GNOME/Mutter verification remains open.


## 2026-11-08 — Optional Wayland text-input-v3 integration

NekoEdit now discovers `zwp_text_input_manager_v3` when the compositor advertises it and creates a text-input object for its active seat. The existing `wl_keyboard` Unicode path remains the fallback on compositors without the extension. When enabled, text-input-v3 is scoped to the focused document; other application panels retain their previous input behavior.

The implementation sends bounded UTF-8 surrounding text with caret/anchor byte offsets, normal content type, a cursor rectangle, and commit serials. It stages preedit, committed text, and surrounding deletion until the protocol's `done` event. Preedit is displayed as a transient underlined overlay. Commit text is validated as UTF-8; surrounding deletion is bounds-checked and rejected if either endpoint would split a scalar. Valid delete-plus-commit edits form one history action.

The mock compositor now exercises the complete protocol lifecycle, including enable/disable, preedit, a multibyte commit, valid and invalid deletion, serial handling, and redraw sequencing. Actions #621 passed all eight steps on the initial fully tested IME snapshot. A subsequent audit moved history transaction creation after deletion validation and added a dedicated invalid-range test; those last hardening changes await a fresh CI run. Live GNOME/Mutter testing with a real input method remains necessary.

This is basic text-input-v3 integration, not complete IME presentation or Unicode text layout. Preedit attributes/cursor-end styling, candidate positioning at the preedit caret, complex shaping, and bidirectional layout remain future work. Clipboard, History UI/storage, and source-independent desktop installation packaging are unaffected by this milestone.

 
## 2026-11-08 — XKB declared modifier maps and eight-level key types

The physical keyboard path now evaluates declared XKB text-v1 key types from their actual modifier maps. Each key retains per-group type assignment, and type-map selection uses the full 32-bit modifier-index state delivered by Wayland. The parser supports up to four groups, eight symbol levels per group, 64 type definitions, 32 map entries per type, and 24 declared virtual modifiers. It handles named and numeric modifier masks and both numeric and `LevelN` level values.

A deliberately custom eight-level fixture exercises combinations that cannot be inferred from conventional type names, including a virtual modifier at bit 31. Assertions inspect the parsed type tables and verify actual UTF-8 output for each level. Built-in family records remain as fallback for conventional keymaps; unknown/malformed types do not silently fall through to a guessed type.

This remains a bounded XKB implementation rather than a reimplementation of libxkbcommon. The compositor supplies the modifier state; NekoEdit does not yet interpret `xkb_compat` rules, derive automatic virtual-modifier bindings, evaluate arbitrary key actions, or implement preserve/consumed-modifier reporting. The new source/test snapshot awaits its own complete Actions validation; live GNOME/Mutter and real IME behavior remain user-side checks.


### Declared XKB type-map implementation — Actions #649 passed

Actions #648 first stopped in the generic Wayland mock at the soft-wrap caret pixel check, before the custom XKB fixture ran. The test failure path was made more diagnostic in commit [7d02040aabea](https://github.com/GraderGamer2/NekoEdit/commit/7d02040aabea72734a45f4d7a3813d227ba98f8d). Actions #649 then passed the complete eight-step workflow on that snapshot, including custom eight-level type-map assertions, the high virtual-modifier bit, saved UTF-8 verification, all existing Wayland/IME cases, host tests, ELF checks, and artifact upload. No executable-source change was made between the #648 and #649 workflow attempts, so the first pixel failure remains an unreproduced test observation rather than a confirmed fix.

The resulting artifact is 91,295 bytes with SHA-256 `20deebd4e34ef86a00ad789bb333602165878c3cca059c4c3e1cee19d0f33c91`. Live GNOME/Mutter input-method and candidate-position testing remains outstanding.


## 2026-11-08 — arbitrary alphabetic XKB types and final validation

The parser's accepted-keymap threshold now recognizes alphabetic keys from the actual Group 1 lowercase/uppercase symbol pair rather than requiring the type to resolve to the built-in `ALPHABETIC` identifier. This supports real layouts using `FOUR_LEVEL_ALPHABETIC` and user-named custom types. Twelve keys in the Wayland fixture are now assigned the arbitrary type `CUSTOM_ALPHA`; the mock confirms its parsed map and an actual Shift-selected uppercase insertion. The independent eight-level custom-type test remains.

The test suite also replaces the old fixed wrapped-caret x coordinate with a row-based caret-presence assertion, and its Unicode fixture replacements now match the changed key definitions. The final [Actions #653](https://github.com/GraderGamer2/NekoEdit/actions/runs/42471600041) run passed all eight workflow steps, including the complete Wayland mock, host tests, build/ELF checks, install smoke, and artifact upload. Artifact [13613378978](https://github.com/GraderGamer2/NekoEdit/actions/runs/42471600041/artifacts/13613378978) is 91,292 bytes with SHA-256 `88e13f511c210a092b9efc4f8c08bd5682d5eea9a1731d83f82141f939a5a97e`. Live GNOME/Mutter input-method testing remains outstanding.


### Repeat-test synchronization and Actions #655

The mock now waits for the client to consume an Enter key release and clear the active repeat key before beginning the following Tab repeat case. This prevents a queued release/timer race in the test harness and preserves the same repeat behavior assertions. Actions #655 passed the complete workflow on commit [9824b62d8507](https://github.com/GraderGamer2/NekoEdit/commit/9824b62d85072d852cbf73e8ec31782c6f46480a), including the custom XKB type-map tests and Wayland text-input-v3 mock. Artifact [13614540028](https://github.com/GraderGamer2/NekoEdit/actions/runs/42472328636/artifacts/13614540028) is 91,292 bytes.


## 2026-11-08 — explicit virtual-modifier masks

The XKB reader no longer equates a virtual modifier's declaration order with the bit used in the compositor's state mask. It keeps a separate effective 32-bit encoding per declared virtual modifier and parses explicit text-v1 assignments from real modifier names, plus-separated masks, numeric literals, and `none`. The lookup path uses that effective mask when expanding a virtual name in a key type's `modifiers` or `map[]` statement.

The expanded mock uses `LevelThree = Mod5`, `NumLock = Mod2`, `V02 = Mod4+Mod5`, and a high-bit `V23 = 0x80000000`; remaining declared virtual names are explicitly unbound. It verifies the mask table, modifier-to-level lookup, and repeated declarations in a later component. Automatic virtual-modifier bindings through key `virtualModifiers`/`modifier_map` and `xkb_compat` remain deferred, as do general actions and `preserve[]` semantics. The new parser/test snapshot is pending its complete Actions run.


### Explicit virtual-modifier encoding validation — Actions #657

Actions #657 passed all eight workflow steps on the explicit virtual-modifier parser snapshot. The Wayland mock verified independent effective masks for LevelThree/Mod5, NumLock/Mod2, a combined Mod4+Mod5 virtual modifier, an unbound virtual modifier, and a bit-31 numeric mask; it also verified that repeated declarations in later components preserve earlier encodings. The same run passed the type-map, arbitrary alphabetic type, eight-level, IME, editing, clipboard, history, font, host, ELF, and installation checks. Artifact 13615510231 is 91,474 bytes with SHA-256 `374f97796d2633b81ffc356e1e4a330278f5aedfca99478db614b6107ad72e9e`. Live GNOME/Mutter validation remains outstanding.


## 2026-11-08 — direct implicit virtual-modifier mapping

The reader now parses direct `virtualModifiers` properties on keys and direct keycode `modifier_map` entries. It stores the per-key virtual map and real modifier separately, then computes each virtual modifier's effective encoding by ORing the explicit encoding with the real modifiers attached to all keys in that virtual map. Declared XKB types are reparsed against those effective masks, ensuring custom type maps resolve the same way as the compositor's state.

The regression fixture assigns a virtual modifier with explicit encoding `none` to two keys, binds one key to Mod4 and the other to Mod2, and asserts the effective mask becomes `0x50`. It also sends Mod2+Mod4 through the Wayland mock and checks the associated custom type selects Level2 and inserts the expected symbol. Indirect keysym-based modifier-map lookup, `xkb_compat`-driven virtual binding, general key actions, and preserve/consumed-modifier behavior remain deferred. The current implementation snapshot awaits its complete Actions run.


### Direct implicit virtual-modifier aggregation — Actions #659 passed

Actions #659 passed all eight workflow steps on the direct implicit-binding implementation. The mock verified that V03, explicitly encoded as none, receives Mod4 from one key and Mod2 from a second key via key-level `virtualModifiers` and direct keycode `modifier_map` statements. The effective encoding is 0x50; the type maps were reparsed against that mask, and a Wayland modifier-state event containing Mod2+Mod4 caused the test key to insert its Level2 symbol. All prior XKB, IME, editor, clipboard, History, font, host, ELF, and install tests passed. Artifact 13615747665 is 91,922 bytes with SHA-256 `8b58ca484f0012aa2c55837fce148915b176dbe2ea92c073bbae4ab4ebbf4bcc`. Indirect keysym modifier-map entries and xkb_compat interpret resolution remain future work; live GNOME/Mutter verification remains outstanding.


## 2026-11-08 — bounded XKB compatibility interpretation and virtual modifiers

The XKB reader now resolves a bounded subset of `xkb_compat` interpretation rules after key symbols and real modifier maps are available. A fixed rule table stores recognized modifier-keysyms or wildcard selectors, real-modifier predicates, optional virtual-modifier assignments, and the `useModMapMods` scope. Evaluation applies keysym specificity first and predicate specificity second, with declaration order retained for equal-specificity ties. Direct key-level `virtualModifiers` values continue to override inferred compatibility assignments.

The new fixture exercises five interpretations, supported predicates, nested action-block skipping, direct-key precedence, and the rule's Group 1/Level 1 restriction using otherwise identical symbols at different levels/groups. Inferred compatibility mappings feed the same existing effective-encoding aggregation and custom-type reparse path as direct key virtual maps. Actions are deliberately not executed; action semantics, repeat settings, and `preserve[]` remain outside this milestone.

Implementation commit [25865bc26754](https://github.com/GraderGamer2/NekoEdit/commit/25865bc267549dd3fb788801dd3e38f78d9e3e8e) passed all nine steps in Actions [Build and test #662](https://github.com/GraderGamer2/NekoEdit/actions/runs/42485461332). The 94,032-byte artifact [13619186848](https://github.com/GraderGamer2/NekoEdit/actions/runs/42485461332/artifacts/13619186848) has SHA-256 `8f013c5c6ae54dfca8e57dba489fecfcc8e39632d262bea554615bb7547ff25d`. The earlier #661 seat-v3 event-loop failure was not reproduced; its root cause remains unconfirmed. Real GNOME/Mutter and IME testing remains outstanding.


## 2026-11-08 — XKB compatibility specificity and ISO group/level keysyms

The bounded XKB modifier-keysym table now recognizes additional standard group/level selectors: `Shift_Lock`, `ISO_Lock`, `ISO_Level2_Latch`, `ISO_Group_Shift` and its `Greek_switch`/`script_switch` aliases, plus ISO group latch/lock and next/previous/first/last group variants. These names participate in the existing deferred indirect `modifier_map` lookup, so their key association can be resolved after symbols are read.

The Wayland mock's compatibility fixture now contains twelve interpretations. In addition to the earlier `AnyOf`/`NoneOf`, wildcard/specific keysym, action-skipping, direct-key precedence, and `useModMapMods=level1` checks, it verifies `AllOf`, `Exactly` priority over `AllOf`, first-declaration precedence for equally specific `NoneOf` matches, and indirect modifier maps for `ISO_Group_Shift` and `ISO_Next_Group`. Each fixture key has at most one real modifier assignment, as required by the XKB format.

Implementation commit [a1791e03bdb0](https://github.com/GraderGamer2/NekoEdit/commit/a1791e03bdb0608a082f7d7d5a3c5f23e1b7bba6) passed all nine steps in Actions [Build and test #664](https://github.com/GraderGamer2/NekoEdit/actions/runs/42486931592). Artifact [13619847523](https://github.com/GraderGamer2/NekoEdit/actions/runs/42486931592/artifacts/13619847523) is 94,317 bytes and has SHA-256 `54d23fd997cd19fbec58a9281b4e3bf75a2afb443e3cd2638a792de0ae8257a4`. Real GNOME/Mutter and IME testing remains outstanding.

 
## 2026-11-09 — XKB type preserve and consumed-modifier handling

The bounded XKB text-v1 type parser now reads preserve[modifier-combination] = modifier-mask entries and stores a 32-bit preserve mask beside each exact map[] entry. Preserve entries are associated by their left-hand modifier combination. If no matching map entry has been declared, the parser creates the implicit Level1 entry; a later map[] statement for that combination updates the same entry in place. Preserved masks are validated against the type's declared modifiers set.

The shared level-selection routine now returns the selected map's preserved mask and computes consumed modifiers as the type modifier mask minus that preserve mask. The Wayland path retains the full compositor-provided XKB state for keysym selection, but filters Control from shortcut dispatch when the current key consumes it. A preserved Control mapping therefore still permits Ctrl+A; an unpreserved Control mapping can use its alternate symbol without accidentally triggering Ctrl+Z. Raw physical/compositor Control state is restored when the key is released. The compositor remains responsible for applying stateful modifier and group actions.

The regression fixture verifies the parser table and the important declaration-order case, with preserve[Control] before map[Control]. Its Wayland event sequence verifies both preserved and consumed Control outcomes. Actions #680 and #681 stopped in test-harness support paths before the custom assertions could complete; after adding the preserve table to the mock's exported-symbol allow-list and synchronizing the legacy seat-v3 Tab release, Actions [Build and test #682](https://github.com/GraderGamer2/NekoEdit/actions/runs/42549249275) passed the complete eight-step workflow. Artifact [13644083218](https://github.com/GraderGamer2/NekoEdit/actions/runs/42549249275/artifacts/13644083218) is 95,246 bytes with SHA-256 e7707ab4c100bd5415ef0ea2184419b48d86ec0851e8d58992b4d396121d7216.

This milestone covers type-map preserve semantics for the existing Control shortcut path. General XKB key-action execution and consumed Shift/Alt shortcut policy remain unfinished. Live GNOME/Mutter testing against real keymaps remains outstanding.


## 2026-11-09 — XKB consumed Shift and preserve[Shift] shortcut behavior

The existing XKB type parser stores preserve masks against exact modifier-map entries and calculates a consumed mask from the selected type's declared modifier set. The Wayland keyboard path previously used that result only for Control shortcut visibility. This milestone applies the same per-key policy to Shift.

The editor now keeps raw Control and Shift state separate from shortcut-visible state. For each non-modifier key press, it queries the selected type map, removes active Control or Shift only when that modifier is consumed, and restores the raw/compositor state on key release. The complete compositor state still determines the symbol inserted into the document. Stateful modifier/group actions remain the compositor's responsibility.

The mock adds Shift-only types assigned to Left and Right. It verifies that a consumed Shift does not turn Ctrl+Left into a selection operation, while `preserve[Shift]` allows Ctrl+Shift+Right to extend the selection. Parser memory checks verify the exact mapping and preserve tables. Source implementation: [1b9d2da39977](https://github.com/GraderGamer2/NekoEdit/commit/1b9d2da399779ae306011e04e0509748b17afd87); documentation: [29bada7cd1d8](https://github.com/GraderGamer2/NekoEdit/commit/29bada7cd1d8b153d4aa1c895e600c2cc68bbe82); test synchronization correction: [97cc62949fb7](https://github.com/GraderGamer2/NekoEdit/commit/97cc62949fb794c632242ea8c4c289d91aab8628).

The first two CI attempts (#684 and #685) stopped because the test waited for a redraw after key release, although the protocol/event path does not promise a repaint for release-only events. The mock now waits for the actual modifier-state reset. Actions [Build and test #686](https://github.com/GraderGamer2/NekoEdit/actions/runs/42550654163) passed the complete eight-step workflow, including the Wayland mock. Its log confirms “XKB consumed Shift is filtered from shortcuts while preserve[Shift] keeps it”. Artifact [13645133185](https://github.com/GraderGamer2/NekoEdit/actions/runs/42550654163/artifacts/13645133185) is 95,324 bytes with SHA-256 `4817ba43f7015796080a570879664407b0b51578a7f501d3ddaf2c166fb22035`.

The user had already confirmed that the preceding build worked and that `clipboard_persistence` appeared in the preference file. That setting is the expected Clipboard Service toggle documented in `docs/CLIPBOARD.md`; it is independent of this XKB work. Real GNOME/Mutter keyboard-map validation remains separate from mock coverage.


 
## 2026-11-09 — verify XKB useModMapMods level1/any scope and default

The bounded XKB compatibility parser already accepted `useModMapMods = level1` and `useModMapMods = any`, with omitted scope defaulting to `any`. The synthetic keymap now protects this behavior with an explicit equal-specificity precedence case: the earlier `level1` interpretation handles Group 1 / Level 1, while the lower-priority `any` interpretation handles the same keysym at Group 1 / Level 2 and Group 2 / Level 1. A separate key containing `ISO_Group_Shift` only in Group 2 omits the attribute and proves the implicit default still applies.

The process-memory assertions verify the interpretation scopes, real modifier maps, virtual-modifier assignments, and effective aggregate masks. The any-scope rule yields V16=Mod5 (0x80) from alternate-level/group occurrences; the default-any Group 2 case yields V14=Mod2 (0x10). The parser and Wayland application source were unchanged; this is a regression-coverage milestone.

The first two CI attempts (#688 and #689) stopped at an older soft-wrap pointer-click assertion before the custom XKB fixture. The mock did not wait for the previous single `wl_buffer` release to be consumed before injecting another click. The helper now waits for `buffer_busy=0` before and after a click, without weakening the caret/pixel assertions. Actions #690 then reached the XKB fixture and caught a missing V16=0x80 expected value. After correcting that expectation, Actions [Build and test #691](https://github.com/GraderGamer2/NekoEdit/actions/runs/42553348336) passed the complete eight-step workflow. Artifact [13646371299](https://github.com/GraderGamer2/NekoEdit/actions/runs/42553348336/artifacts/13646371299) is 95,324 bytes with SHA-256 `70148ff518fe7f22f73209fdf3477cfe1d80bd27fe9221567a92866d4c2a500c`.

The user separately confirmed real-build word selection with `Ctrl+Shift+Left`. The user also requested a minimal right-click document context menu with exactly Copy, Paste, and Cut. The request is in the README remaining roadmap and is not part of this milestone.

## 2026-11-09 — XKB omitted matching operator defaults to Exactly

The bounded XKB text-v1 `xkb_compat` parser previously recognized the named matching operations, but rejected the valid shorthand in which an `interpret` rule supplies a parenthesized real-modifier mask without naming the operation. The XKB format defines this omitted operation as `Exactly`; omitting the entire predicate remains a different default, `AnyOfOrNone(all)`.

The parser now detects the opening parenthesis immediately after the `+` separator and stores the existing Exactly predicate value before invoking the shared real-modifier-mask reader. The synthetic Wayland keymap adds keycode 209, whose Group 1 / Level 1 keysym is Control_L and whose real modifier map is Mod2. Its shorthand interpretation assigns V17 only when the modmap is exactly Mod2. The mock checks the raw keysym, real mask, stored predicate enum, per-key virtual map, and aggregate V17=Mod2 (0x10). The existing Control_L / Mod1 key continues to resolve through the explicit Exactly(Mod1) rule.

Actions #693 compiled the implementation and passed command-line tests, then exposed an off-by-two test-fixture record index after the new interpretation was inserted before the existing group-key rules. The new rule is record 12 and the shifted default-any rule is record 13; the correction changed only the mock's memory offsets. Actions [Build and test #694](https://github.com/GraderGamer2/NekoEdit/actions/runs/42555001320) passed all eight workflow steps, including the full Wayland mock, executable inspection, and artifact upload. Artifact [13646668835](https://github.com/GraderGamer2/NekoEdit/actions/runs/42555001320/artifacts/13646668835) is 95,370 bytes with uploaded ZIP SHA-256 `5c4e9da79a371c2aa15807a3dd555774974c6d17f132908d31b615cb7a958cd9`.

This milestone does not execute general XKB actions or change compositor-owned modifier/group transitions. The user-reported `Ctrl+Shift+Left` desktop confirmation remains separately recorded. The requested document-area context menu with exactly Copy, Paste, and Cut remains a separate, unimplemented roadmap task.

## 2026-11-09 — expanded X.Org named Unicode keysym coverage

The static XKB named-character lookup was expanded from NekoEdit's previous small, curated set to 1,642 name-to-scalar/action records derived from X.Org `keysymdef.h` Unicode annotations. Where an older alias shares a numeric keysym value with a canonical entry that carries a Unicode annotation, the alias receives that same scalar. Control and function keysyms without printable Unicode mappings remain on the existing command/key-action routes.

The table adds broad script coverage including Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, and Braille, alongside the existing Latin, Greek, Cyrillic, punctuation, and regional aliases. It also includes the xorgproto 2026.1 additions `SSHARP`, single-angle quotation marks, XF86 phone-numeric aliases, and `dead_apostrophe`. The latter routes through the existing acute accent state; it does not add a new compose algorithm. This remains a compile-time table with no new runtime or build dependency.

The Wayland mock checks thirteen additional keysym scalar/action cells directly in the running process and types twelve representative aliases through actual keyboard events, verifying the resulting UTF-8. It also types `dead_apostrophe`, verifies the pending U+0301 state, and composes it with `e`. The new [docs/KEYSYM_UNICODE.md](../docs/KEYSYM_UNICODE.md) records table scope, testing, provenance, limitations, and source notices.

Actions [Build and test #695](https://github.com/GraderGamer2/NekoEdit/actions/runs/42560170496) passed all eight workflow steps, including the complete Wayland mock, ELF inspection, and artifact upload. Artifact [13648893107](https://github.com/GraderGamer2/NekoEdit/actions/runs/42560170496/artifacts/13648893107) is 104,167 bytes; ZIP SHA-256 `5762e219685c3734e77e8b2bd7e9fad0bdb39d3ca4c742d969fe330a8d407c4c`.

The user reports the last build works perfectly and sees no visible behavior difference. This is consistent with backend-only alias coverage; live manual validation of additional script layouts is not claimed. `Ctrl+Shift+Left` was previously confirmed manually. The requested three-command right-click context menu remains a separate unimplemented roadmap item.
