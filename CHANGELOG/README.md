# NekoEdit changelog and continuity notes

This directory is the project's durable development history and handoff source. It exists so work can continue in a new ChatGPT conversation without relying on the context length or availability of an older chat.

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

The Compose locale architecture is implemented through the bounded NLP1 loader, reproducible pt_BR.UTF-8, fi_FI.UTF-8, and sr_RS.UTF-8 datasets, automatic character-locale discovery, and the Settings Add/Remove manager. Settings now exposes a dynamic installed-locale dropdown, populated from `~/.nekoedit/locales/` with built-in en_US first; it refreshes when Settings opens and after Add/Remove, and installed packs can be selected by mouse or keyboard without a file picker. Build and test #711 verifies locale precedence/aliases and #736 verifies the Add/Remove installer. The dynamic dropdown and its new Wayland mock assertions are recorded in CURRENT_STATUS.md and DEVELOPMENT_LOG.md; CI for that newest milestone is still pending. The Add picker displays `TARGET: ~/.nekoedit/locales/`; packs remain data-only. The Release workflow attaches packs and notices when a project Release is published. System/user Compose imports and locale-specific dead-key rules remain future work. Keep packs inert; do not add executable plugins or automatic downloads.
