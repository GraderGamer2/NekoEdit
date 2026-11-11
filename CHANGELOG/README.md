## Latest handoff (2026-11-11)

Continue from `early-alpha`. Run #825 passed build, CLI, full Wayland mock, and ELF checks but failed the native parser's final `xkb_symbols` guard. It parsed 84 symbol values (above the 16-value minimum) but counted zero alphabetic pairs. The rejection is isolated to the alpha guard's use of the auxiliary `xkb_ascii_levels` byte table.

The latest source correction counts Group1 lowercase/uppercase pairs from canonical `xkb_unicode_levels`, which is the table used by live symbol lookup. It keeps the 12-pair safeguard intact. The native probe now preserves and prints a small Unicode-vs-ASCII sample for AD01/AC01/AB01 if the parser still rejects the map. Build and test #826 must verify the real keymap and its Multi_key/dead-key positions before any claim of completion.

## Latest handoff (2026-11-11)

Continue from `early-alpha`. Run #824 passed build, CLI, full Wayland mock and ELF checks; the real `us(intl)` parser probe failed at stage 4 (end of `xkb_symbols`, byte 66,422, token `}`). The parser has final safety checks for at least 16 symbols and 12 alphabetic keys.

The current change reports `.Lxkb_symbol_count` and `.Lxkb_alpha_key_count` before reset. Build and test #825 will show which acceptance threshold rejects the valid 66 KB keymap. Do not loosen either threshold until the count data shows why.

## Latest handoff (2026-11-11)

Continue from branch `early-alpha` and inspect `CHANGELOG/CURRENT_STATUS.md`. Run #823 confirmed the host XKB probe compiles, but NekoEdit rejects the valid 66,429-byte libxkbcommon `us(intl)` / `compose:ralt` keymap.

The current commit adds bounded diagnostics to `xkb_parse_keymap`: top-level parser stage, byte offset, and last token. Run #824 will report the exact pass/construct that causes rejection. Do not relax the parser or modify the Mutter key dispatch until the actual failure is identified.

## Latest handoff (2026-11-11)

Continue from `early-alpha`. Build and test #822 failed at compilation of the new host-side XKB probe, not in NekoEdit's parser. The compiler requires `struct xkb_context *` and `struct xkb_keymap *`; both were corrected.

The probe now compares NekoEdit's application-facing `xkb_unicode_levels` table, not the modifier-only `xkb_keysym_levels`: Multi_key should be `0x110007`, dead_grave `0x110001`, dead_circumflex `0x110003`, and period/A their Unicode scalars. Build and test #823 will determine whether the assembly parser accepts the real `us(intl)` keymap. Keep the live Mutter failure unclassified until this probe passes.

## Latest handoff (2026-11-11)

Continue on `early-alpha`. Run #821 passed build, CLI, Wayland mock, ELF, pinned importer, locale-pack, native Mutter keymap startup, app focus, document pointer focus, and basic save; it failed only the final Compose comparison because the output remained literal grave/circumflex.

The newest change adds `tests/xkb_native_keymap_test.c` and `make test-xkb-native`. It compiles an actual `us(intl)` / `compose:ralt` keymap using libxkbcommon, feeds the serialized keymap text into NekoEdit's assembly XKB parser, and verifies that Multi_key, dead_grave, dead_circumflex, period, and A survive at matching keycode/group/level positions. CI uses `libxkbcommon-dev` only for this test; the application remains freestanding. Build and test #822 must run this parser check before the Mutter step. Do not claim live Compose success until both pass.
## Latest handoff (2026-11-11)

Continue from `early-alpha`. Run #820 passed all pre-Mutter checks and the basic live input/save canary, but its Compose phase still inserted literal grave/circumflex characters. The extension successfully called Mutter's backend `set_keymap` API, but it did so after NekoEdit had received its initial plain-US Wayland keymap.

The latest change moves that backend call before launching NekoEdit. Mutter Shell starts, the keyboard device is primed, the `us(intl)`/`compose:ralt` keymap is applied, and only then is NekoEdit started. Build and test #821 will verify that the initial keymap resolves Multi_key and dead-key composition. Do not claim full Mutter Compose validation until #821 passes.

## Latest handoff (2026-11-11)

Continue from `early-alpha`. The latest test, #819, passed build, CLI, Wayland mock, ELF, pinned importer, locale packs, native pointer focus, and basic input/save. It failed only Compose: GSettings stored `us+intl` and `compose:ralt`, but Mutter still emitted literal grave/circumflex characters.

The newest correction exposes `ApplyKeymap` in the temporary GNOME Shell extension. Immediately before Compose, it calls the same `global.backend.set_keymap('us','intl','compose:ralt','pc105')` and `lock_layout_group(0)` API used by GNOME Shell's `KeyboardManager`. Build and test #820 must verify that the keysyms map and the exact `…Ầ` bytes are saved. Do not claim full Mutter Compose validation until this run passes.

## Latest handoff (2026-11-11)

Continue on `early-alpha` from the newest branch head. Read `CHANGELOG/CURRENT_STATUS.md` and `CHANGELOG/DEVELOPMENT_LOG.md` for run-by-run validation. Commit [b39eb3c1](https://github.com/GraderGamer2/NekoEdit/commit/b39eb3c186086454eec7ec504cf5319a1d68c4cd) added a native pointer click before the Mutter keyboard canary; run #818 confirmed that this fixed basic pointer/keyboard focus and the default save-confirmation sequence.

Run #818 still failed only the Compose phase because Mutter reported no keycode for Multi_key and the two dead keys. The test had only exported `XKB_DEFAULT_*`, but Mutter's native seat defaults to plain `us`; GNOME Shell applies input layout via `org.gnome.desktop.input-sources`. The latest change configures and verifies the isolated settings to `us+intl`, `compose:ralt`, `pc105` before Shell starts. Run #819 must verify these keysyms and the final `…Ầ` bytes. Do not claim Compose support is live-validated until #819 passes.

## Latest handoff (2026-11-11)

Continue from branch `early-alpha`. Read `CHANGELOG/CURRENT_STATUS.md`, `CHANGELOG/DEVELOPMENT_LOG.md`, and `CHANGELOG/COMMIT_INDEX.md` for exact validation. Commit [11e3f2ed](https://github.com/GraderGamer2/NekoEdit/commit/11e3f2ed9ca4cdf3ae3256945b50c912235e6c75) primed Mutter's native virtual keyboard before NekoEdit startup, but run #817 still failed the basic canary.

The current test correction adds a native RemoteDesktop pointer move/click into the document body after NekoEdit's MetaWindow is activated. This is intended to exercise NekoEdit's own document-area click/caret focus path before typing. Build and test #818 must validate this change; do not claim native input or Compose success until it completes.

## Latest handoff (2026-11-11)

Continue from `early-alpha` and read `CHANGELOG/CURRENT_STATUS.md`, `CHANGELOG/DEVELOPMENT_LOG.md`, and `CHANGELOG/COMMIT_INDEX.md` for the detailed state. Source/test commit [638d225e](https://github.com/GraderGamer2/NekoEdit/commit/638d225eea36ff08f5b3660048e1f371c5d27f79) corrected the Mutter smoke test to press Enter after Ctrl+S because confirm-before-save is enabled by default. Run #816 still failed the native basic canary, so Enter was not the remaining input issue.

The current correction primes Mutter's lazy RemoteDesktop keyboard before NekoEdit starts. Mutter 46.2 creates the virtual device on the first key press; the native keyboard device then updates `wl_seat` capabilities. The harness now starts the RemoteDesktop session, sends/releases Ctrl_L with no app window open, then launches/focuses NekoEdit and sends the basic and Compose test sequences. Build and test #817 must verify this ordering. Do not claim that live Mutter input or Compose passes until that run is green.

# NekoEdit changelog and continuity notes

This directory is the project's durable development history and handoff source. It exists so work can continue in a new ChatGPT conversation without relying on the context length or availability of an older chat.

## Latest handoff (2026-11-10)

The #806 shell syntax error is corrected in [e57e0233e128](https://github.com/GraderGamer2/NekoEdit/commit/e57e0233e1287b7d3636e2fd4ddecc4193b5735a). The test script is restored and the explicit X11 focus + normal-key canary is applied using a literal-safe replacement. Build and test #807 is running; GitHub's latest state is still package installation. Core tests passed in #806, but the Mutter step did not run because its script could not parse. See CURRENT_STATUS.md before claiming any new validation.

Build and test #806 passed all core, host, Wayland mock, ELF, pinned X.Org, and locale-pack checks but stopped at shell parsing in the Mutter test before input delivery. A literal-dollar expansion corrupted the fallback window-search line during editing. The test script has been rebuilt from the clean source and the explicit-focus + plain-key canary block reapplied safely. This correction still needs CI validation.

Build and test #805 passed the freestanding build, host tests, Wayland mock, ELF inspection, pinned X.Org verification, and separate locale packs. It failed only in the nested Mutter input test: the compositor started, but the document remained unchanged. The harness relied on a click without explicitly focusing GNOME Shell's outer X11 window in bare Xvfb. The next correction now focuses/verifies that window and adds a simple printable-key + Ctrl+S canary before Compose. The fix awaits CI; no Mutter input success is claimed yet.

Harness invocation correction [14e7a902699e](https://github.com/GraderGamer2/NekoEdit/commit/14e7a902699e8411bd95a4d6d332105bff665d73) is pushed to early-alpha. It now starts NekoEdit with a document path only; the nested Wayland socket selects the backend. Build and test #805 is running, but GitHub's latest available status remains at package installation. #804 passed the freestanding build, host tests, Wayland mock, ELF inspection, pinned locale data verification and separate locale-pack build; it failed before input delivery because of the old harness argument. The Mutter key-input scenario is still unverified.

Build and test #804 passed the freestanding build, all host tests, corrected Wayland mock, ELF checks, pinned X.Org data comparisons, and separate locale-pack builds. The new GNOME Shell 46/Mutter 46.2 compositor started, but NekoEdit exited because the test combined the backend-only `--backend=wayland` option with a document filename; the current CLI accepts a document path alone and chooses Wayland from WAYLAND_DISPLAY. The harness launch line is corrected; the Mutter input test has not yet passed. See CURRENT_STATUS.md for the exact boundary.

Build and test #803 failed before reaching the new Mutter test: the freestanding build, host tests, and locale tests passed, but the existing held-Tab repeat assertion in the Wayland mock sampled a redraw without proving a timer-driven edit had occurred. The mock is being corrected to wait for document-cursor increments on repeated Enter/Tab and cancel after the first verified repeat. The nested GNOME Shell/Mutter harness commit is 71d0040; its test has not yet run in CI. #802 remains the latest fully green build.

The newest development change adds a nested GNOME Shell/Mutter Wayland smoke test under Xvfb and D-Bus. It exercises the editor against an actual compositor with synthetic XTest keyboard input, checking Right-Alt Multi_key and a two-mark pt_BR dead-key chain through Ctrl+S. The harness and its dependencies are test-only; optional locale packs remain separate data files. The branch-push CI result is pending, and this is not yet evidence from the user's physical keyboard or running GNOME session. See CURRENT_STATUS.md and docs/MUTTER_INTEGRATION_TEST.md for scope and validation boundaries.

Build and test #802 passed the `early-alpha` Wayland multi-dead-key milestone on exact head `91a92c38210362def100026afd60e7b08132d08f`. NekoEdit now buffers one to three dead-key marks followed by a base scalar, performs typed NLP1 lookup, and preserves unmatched chains literally. The 52-byte NLP1 record and four-input cap are unchanged; the native Settings importer, offline user converter, and pinned X.Org importer share the bounded chain grammar. The four separate locale tables were regenerated from pinned sources (pt_BR 4,484; fi_FI 4,488; sr_RS 4,495; el_GR 5,730 records). The build workflow is read-only again (`contents: read`). The Wayland mock, host/importer tests, pinned byte comparisons, locale-pack build, and both uploads passed. The editor and separate locale artifacts are 13761918009 and 13762312971 (one-day retention; expires 2026-11-11 at 18:48 Jakarta). No X11 backend change was made. This is CI/mock validation, not live Mutter/physical-keyboard verification. The implementation and updated datasets remain on `early-alpha`; PR #2 is open and unmerged. See CURRENT_STATUS.md for the full commit sequence, locale statistics, artifact hashes and remaining work.

## Read this first in every new development chat

Before changing NekoEdit, inspect these files in this order:

1. `CHANGELOG/CURRENT_STATUS.md` — verified current implementation, build/test state, known limitations, and latest source commit.
2. `CHANGELOG/DEVELOPMENT_LOG.md` — recent development entries and the latest work performed.
3. `CHANGELOG/PROJECT_HISTORY.md` — the complete milestone narrative from the original prototype to the current implementation.
4. `CHANGELOG/COMMIT_INDEX.md` — the commit-by-commit audit trail, including intermediate fixes, tests, documentation, debugging, and reverts.
5. Then inspect the actual source, tests, build files, and the active GitHub branch/PR. The changelog is a navigation and continuity aid; source code and current CI results remain authoritative.

Repository: [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)

## Files in this directory

- **PROJECT_HISTORY.md** — retroactive chronological explanation of the project's development from its original freestanding Wayland prototype.
- **COMMIT_INDEX.md** — exact commit subjects, dates, and links for the original `main` history and the complete development PR history captured on 2026-11-06.
- **DEVELOPMENT_LOG.md** — append-only work log. Add a dated entry for every future development session/change.
- **CURRENT_STATUS.md** — concise source-of-truth snapshot. Update it whenever implementation, test status, branch, or known limitations change.
- The current implementation includes optional Wayland text-input-v3 integration in `src/backend/wayland.S` (including compositor-visible `set_text_change_cause` synchronization; see `docs/TEXT_INPUT_V3.md`), `src/backend/clipboard.c` for Wayland clipboard transfers and the bundled `nekoedit-clip` process-exit owner, plus `src/editor/history.c` for compact version-2 per-document delta journals with version-1 compatibility. `docs/CLIPBOARD.md` records helper teardown/lifecycle and session limits; `docs/UNDO.md` describes compact record formats, recovery validation, permissions, and History-tab management. `make install-user` installs a per-user executable and desktop-menu launcher; `make test` includes an install/uninstall smoke test.

## Wayland window management and resize behavior

The pointer lifecycle, 16-unit edge hit areas, `xdg_toplevel.resize` request, optional cursor-shape feedback, and mock-compositor coverage are documented in [docs/WAYLAND_WINDOW_RESIZE.md](../docs/WAYLAND_WINDOW_RESIZE.md).

## Wayland Maximize crash investigation

The removed temporary diagnostics and sync barrier are documented in [docs/WAYLAND_MAXIMIZE_DEBUGGING.md](../docs/WAYLAND_MAXIMIZE_DEBUGGING.md). It records the confirmed dense-object-ID root cause, the historical commits containing the probes, and safe guidance for reintroducing them if the issue returns.

## Mandatory rule for future NekoEdit development

**Every time NekoEdit is developed, the changelog must be updated as part of that same work. Do not treat changelog updates as optional or postpone them to a later session.**

For each feature, bug fix, refactor, or meaningful test change:

1. Read this directory and inspect the current repository state before coding.
2. Implement the change and add/update regression tests where practical.
3. Run the relevant local checks or GitHub Actions. Record exactly what passed, failed, or was not run. Never report an unverified test as passing.
4. Append an entry to `DEVELOPMENT_LOG.md` describing:
   - the date and purpose of the work;
   - files/modules changed and the behavior added or corrected;
   - implementation decisions and important constraints;
   - tests added/changed and their exact results;
   - manual test results reported by the user, clearly distinguished from automated tests;
   - remaining defects, limitations, or follow-up work;
   - resulting commit SHA(s), PR, CI run, and build artifact when available.
5. Update `CURRENT_STATUS.md` if the current implementation, verified build, branch/commit, or limitations changed.
6. Update `PROJECT_HISTORY.md` when a new development milestone is completed. Do not rewrite history to conceal failed approaches or regressions; record noteworthy reversions and corrections in the development log.
7. Add each new commit to `COMMIT_INDEX.md`. Keep the index chronological and preserve all prior entries.

A small typo or truly documentation-only correction still receives a commit entry in `COMMIT_INDEX.md`; group minor edits into a concise development-log note where appropriate. A multi-commit feature must be recorded as one coherent work entry plus the individual commit-index rows.

## GitHub Actions trigger policy

The Build and test workflow must run for pushes to `main` and the active development branch `early-alpha`. Pull-request runs are reserved for opening, reopening, or marking a PR ready; normal commits on the development branch are tested by the branch-push event so a merge-conflicted PR cannot block validation. Changelog-only commits are ignored by the workflow's path filters, but source, test, and workflow changes still run the build.

Do not put a skip annotation such as `[skip ci]` in the HEAD commit of an open PR when validation is required. GitHub suppresses `push` and `pull_request` workflows for a matching commit message, and GitHub also suppresses `pull_request` workflows while the PR has merge conflicts. Check the actual PR mergeability state and the commit message before diagnosing a missing Actions run; do not assume it is an Actions-tab filter problem.

---

## Accuracy and continuity rules

- Do not rely on a previous ChatGPT conversation when the repository contains newer information.
- Do not assume a previous build is still the latest build. Query the current branch, PR, and Actions run before claiming status.
- Keep user-confirmed behavior separate from mock-compositor/integration-test results.
- Explicitly state what is implemented, partially implemented, planned, and unsupported.
- Do not call code "full Unicode support" merely because UTF-8 byte sequences are preserved or code-point boundaries are respected. Record grapheme handling, Unicode rendering, text input, and IME separately.
- Preserve the project's design constraints: Linux x86-64, GNU assembly, direct syscalls, no third-party runtime/shared-library dependency, and native Wayland/X11 protocols. Do not introduce dependencies or change the established launch interface without an explicit reason and a documented decision.
- Keep the executable's supported launch command working. Direct build launch: `./build/nekoedit [FILE]` (explicit backend selection remains available as `./build/nekoedit --backend=wayland`). The per-user desktop/terminal install is `make install-user`, which adds `~/.local/bin/nekoedit [FILE]` and a NekoEdit application-menu launcher; `make uninstall-user` removes it.

## Historical coverage

The initial history was reconstructed from GitHub on 2026-11-06 and includes **188 commits**: 20 commits from the original `main` prototype history and 168 commits in development PR #1. See `COMMIT_INDEX.md` for the exact commit-by-commit record and `PROJECT_HISTORY.md` for the functional narrative.

The project state in these files must be refreshed with every future development change. The compact-journal encoder declaration correction and inactive-selection-anchor size correction are recorded in `CHANGELOG/DEVELOPMENT_LOG.md`. Actions #608 and #609 stopped before the Wayland tests; corrected Actions #610 then passed the full build, host, install, Wayland mock, and artifact workflow. Live GNOME/Mutter verification remains separate.


## Current keyboard-input milestone

The current branch has optional `zwp_text_input_manager_v3` discovery/binding, document-scoped enable/disable, surrounding-text state, preedit/commit/delete event staging, UTF-8 validation, and mock coverage. Its XKB text-v1 reader parses declared per-key/per-group type maps, exact modifier filters, up to eight levels, explicit per-name 32-bit virtual-modifier encodings, direct key-level `virtualModifiers`, direct and recognized indirect keysym `modifier_map` bindings, and a bounded `xkb_compat` interpretation subset (recognized modifier-keysyms, all five real-modifier predicates, `virtualModifier`, specificity ordering, equal-specificity declaration order, and `useModMapMods=level1|any`, with omitted scope defaulting to `any`). The keysym table now includes ISO group/level selectors such as `ISO_Group_Shift` and `ISO_Next_Group`. Actions #664 passed all nine workflow steps on implementation commit `a1791e03bdb0`, including the twelve-rule compatibility fixture and full Wayland/Unicode/IME mock suite. General stateful key actions remain compositor-owned. Per-key repeat policy and XKB type `preserve[]`/consumed-modifier handling for Control and Shift shortcut state are implemented and mock-tested; live GNOME/Mutter input-method and real-keymap verification remain outstanding. Read the newest section in `CURRENT_STATUS.md` and `DEVELOPMENT_LOG.md` before continuing.

The History path filter is user-reported nonfunctional, and deeper journal compaction remains deferred. Do not describe the filter as working or mix History fixes into the input/shaping roadmap unless the user changes that priority.


## 2026-11-09 context-menu and locale-pack status

The current early-alpha implementation includes the minimal right-click document menu (Copy, Paste, Cut), recorded in CURRENT_STATUS.md and DEVELOPMENT_LOG.md. The corresponding Wayland mock validates pointer-serial clipboard ownership, selection preservation, immutable clipboard snapshots, asynchronous external Paste, Undo/Redo, and dismissal without click-through.

The early-alpha locale architecture now includes reproducible pt_BR.UTF-8, fi_FI.UTF-8, sr_RS.UTF-8, and el_GR.UTF-8 NLP1 datasets, automatic locale selection, a Settings Add/Remove manager, and native UTF-8 .XCompose import with bounded sibling, %H, %S, and %L includes. The native %L resolver follows X.Org compose.dir; the optional host converter remains useful for non-UTF-8 source encodings, broader keysym resolution, and syntax outside the in-app subset. Locale packs remain separate data-only files under ~/.nekoedit/locales/; only en_US is embedded. Build and test #795 passed the latest early-alpha workflow. These changes remain on early-alpha and have not been merged into main.
