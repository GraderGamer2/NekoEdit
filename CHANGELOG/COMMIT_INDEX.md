# NekoEdit complete commit index

This is the commit-level audit trail reconstructed from GitHub on **2026-11-07**. It includes the original 20 commits on `main`, all 180 implementation-history commits on the development branch originally named `feat/wayland-socket-error-handling` and later renamed to `early-alpha` through the Unicode 18.0 grapheme-editing milestone, six changelog bootstrap commits, and the separate changelog installation on `main`.

- Repository: [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)
- Current review PR: [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) (early-alpha → main; open, unmerged).
- Historical implementation PR: [#1 — feat: add Wayland editing and initial editor UI](https://github.com/GraderGamer2/NekoEdit/pull/1) (closed, unmerged).
- Recorded implementation commits: **275** (271 previously indexed commits + 4 Unicode 18.0 grapheme-editing implementation, regression, and CRLF correction commits).
- Dates are commit-author timestamps in UTC.
- This index records commit subjects, including intermediate tests, debugging, documentation, fixes, and reverts. The milestone narrative in [PROJECT_HISTORY.md](PROJECT_HISTORY.md) explains the functional changes.

## Unicode 18.0 grapheme-aware editing

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 04:32:37 UTC | [1eb5894443aa](https://github.com/GraderGamer2/NekoEdit/commit/1eb5894443aafcccd73e2463e91e7d85787dfaf1) | feat: navigate and delete extended grapheme clusters |
| 2026-11-07 04:33:24 UTC | [ac74062cc8a1](https://github.com/GraderGamer2/NekoEdit/commit/ac74062cc8a19f60e9c7dd31f7e3abbae071b74a) | test: correct grapheme deletion cursor setup |
| 2026-11-07 04:34:44 UTC | [fd8020b4fe67](https://github.com/GraderGamer2/NekoEdit/commit/fd8020b4fe67fe056e61d69e819210b41268dd7e) | fix: keep pointer hit-testing outside CRLF graphemes |
| 2026-11-07 04:35:25 UTC | [d7cd3f9bfed4](https://github.com/GraderGamer2/NekoEdit/commit/d7cd3f9bfed41cdf8a359c0bb188e415a26555ca) | test: reset grapheme caret after CRLF pointer check |

Actions [#331](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462) passed all eight workflow steps. The assembly embeds Unicode 18.0 GCB, InCB and Extended_Pictographic property tables, and applies UAX #29 boundaries to movement, hit-testing, selection, wrapping, status columns and cluster deletion. Regression cases cover combining sequences, emoji modifiers/ZWJ, RI pairing, Hangul, Indic conjuncts, Prepend, SpacingMark and CRLF. The same run retains the document-line-index, large-file Open/scrollbar, file-picker, keyboard, resize and Wayland protocol regressions.

Artifact [13561405061](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462/artifacts/13561405061) contains nekoedit-linux-x86_64, 43,886 bytes; SHA-256 25b80bd07ea11f7bc82816bdfae9c125878e67058f2e5ac563ae03bbfe86740c; expires 2026-11-14.

## Indexed document line navigation

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 04:11:29 UTC | [87a33b203501](https://github.com/GraderGamer2/NekoEdit/commit/87a33b20350180f324b70ce1bff091deabef0bab) | feat: add indexed document line navigation |
| 2026-11-07 04:13:04 UTC | [62cbcf339394](https://github.com/GraderGamer2/NekoEdit/commit/62cbcf33939445e5563267b6ae452e845026ad23) | test: diagnose indexed pointer hit-testing regression |
| 2026-11-07 04:14:00 UTC | [0eda4d095330](https://github.com/GraderGamer2/NekoEdit/commit/0eda4d095330f6b2726300e34573e559631dd0d1) | test: account for multi-line index hit-test fixture |
| 2026-11-07 04:15:26 UTC | [552d561dab6f](https://github.com/GraderGamer2/NekoEdit/commit/552d561dab6fccdb3cbd0415ec3c1c8cd9a8afe2) | test: cover incremental index updates at caret position |
| 2026-11-07 04:16:00 UTC | [89cc025cd3d7](https://github.com/GraderGamer2/NekoEdit/commit/89cc025cd3d7b10b5dd97098ee7c1684cd197cfa) | test: expose index records in scrollbar regression state |
| 2026-11-07 04:17:00 UTC | [9e0d3c8c6789](https://github.com/GraderGamer2/NekoEdit/commit/9e0d3c8c67892b0e7a46dc5e6423f3ca3568a814) | test: report line metadata for large-file scrollbar failure |
| 2026-11-07 04:18:35 UTC | [78db904b063f](https://github.com/GraderGamer2/NekoEdit/commit/78db904b063fc44cda4d2eabfd84aa5954da626c) | fix: invalidate line index when opening a document |

Actions [#326](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320) passed all eight workflow steps on the final correction commit. The index stores per-line byte spans and wrapped visual-row counts plus two Fenwick trees. Ordinary byte edits point-update the affected line/tree paths; LF split/merge shifts records and rebuilds the trees; width changes reflow visual-row weights. Tests inspect actual record/Fenwick values, verify ordinary edits and newline split/merge, and retain the large-file editor-scrollbar, picker, keyboard, resize, and Wayland transport regressions.

Artifact [13559973130](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320/artifacts/13559973130) contains nekoedit-linux-x86_64, 34,965 bytes; SHA-256 e2e0e7b77095ece17f2b0573cb37fcb6e0823c56d95a0f4d3003e826ae40134a; expires 2026-11-14.

## Editor vertical scrollbar and wheel scrolling

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 03:11:20 UTC | [e3489badd178](https://github.com/GraderGamer2/NekoEdit/commit/e3489badd178d4db59c30e6660f9768f224f7e35) | feat: add editor vertical scrollbar and wheel scrolling |
| 2026-11-07 03:12:09 UTC | [028379b66a6b](https://github.com/GraderGamer2/NekoEdit/commit/028379b66a6bbfb0adb1d65d2c24696147258f96) | fix: zero-initialize editor scrollbar cache |
| 2026-11-07 03:13:25 UTC | [d4c0fcc5710b](https://github.com/GraderGamer2/NekoEdit/commit/d4c0fcc5710b0ab5ff49bc5831a3a334ecfaa01e) | test: account for editor scrollbar gutter in wrapping |

Actions [#316](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333006563) passed all eight workflow steps on the final feature/test commit. The editor scrollbar is proportional to total visual rows, hidden when no scrolling is needed, supports thumb dragging and track-click repositioning, and consumes wheel input independently of the picker. Tests use a 65,537-byte wrapped document. The final branch-head rebuild [#318](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333808492) also passed all eight steps and uploaded artifact [13557973435](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333808492/artifacts/13557973435), 32,919 bytes, SHA-256 `34ab58c1e8e3ebade7a85bdef2656900c7f2fa7595af15119b85cac8a24189ef`, expiring 2026-11-14.

## Dynamic gap-buffer growth and large-file Open

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 02:38:35 UTC | [8af89d509003](https://github.com/GraderGamer2/NekoEdit/commit/8af89d509003997272479ff2271542a304bdec07) | feat: grow document storage beyond 64 KiB |
| 2026-11-07 02:42:40 UTC | [41afebc4d38b](https://github.com/GraderGamer2/NekoEdit/commit/41afebc4d38b48fa17b695b6df174b16fccac5a9) | test: cover dynamic document growth and large-file Open |
| 2026-11-07 02:43:36 UTC | [1e61fde65235](https://github.com/GraderGamer2/NekoEdit/commit/1e61fde65235dd4be79ad9620c78c4170f6a11d9) | test: expose dynamic document state outside picker workflow |
| 2026-11-07 02:44:06 UTC | [c004f00d038e](https://github.com/GraderGamer2/NekoEdit/commit/c004f00d038ee9c5e0812f7a35967ea25e113c0a) | test: place growth cursor at document start |
| 2026-11-07 02:45:05 UTC | [0bb96bd5a7b3](https://github.com/GraderGamer2/NekoEdit/commit/0bb96bd5a7b327a3f35acc2d1a7267ffa2d59220) | test: update Open rollback expectation after large-file support |
| 2026-11-07 02:45:59 UTC | [37650efa8930](https://github.com/GraderGamer2/NekoEdit/commit/37650efa89302cf2e5484186a18b80375e7116c1) | test: report bytes on cancelled Save As regression |
| 2026-11-07 02:46:52 UTC | [53d4b2df8d0e](https://github.com/GraderGamer2/NekoEdit/commit/53d4b2df8d0ef8968ab12fd8fb9923e4e6caa218) | test: assert preserved document after cancelled Save As |

Actions [#312](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234) passed all eight workflow steps on the final test commit. The live document and Open staging buffer grow geometrically from 64 KiB to a 1 GiB safety ceiling; tests verify full-capacity insertion/suffix relocation/save and native Open/save of a 65,537-byte file. Artifact [13556529585](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234/artifacts/13556529585), 32,119 bytes, SHA-256 bb5666e76505c08b90e4ffac094af79bd2d4c4078014c0e81bf98c63cc3ba0f4, expires 2026-11-14.

## Responsive window-layout geometry

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 02:13:58 UTC | [`f66fe64eb20d`](https://github.com/GraderGamer2/NekoEdit/commit/f66fe64eb20d14167d8f7f77af8d614ebf6999c7) | fix: adapt editor UI layout to window geometry |
| 2026-11-07 02:16:12 UTC | [`6eec3c4f13c2`](https://github.com/GraderGamer2/NekoEdit/commit/6eec3c4f13c2798909b64e1a166ba836cc12f9c3) | fix: zero-initialize responsive layout transform state |
| 2026-11-07 02:18:08 UTC | [`5f03a54c693f`](https://github.com/GraderGamer2/NekoEdit/commit/5f03a54c693f6b80817dc4a7d6b2afe545374082) | test: verify responsive layout and modal hit targets |
| 2026-11-07 02:18:57 UTC | [`3ae9583d34bc`](https://github.com/GraderGamer2/NekoEdit/commit/3ae9583d34bccfddfeb2d5e6e2a03f4b326186a9) | test: probe empty picker button padding |

Actions [#301](https://github.com/GraderGamer2/NekoEdit/actions/runs/42328626464) passed all eight workflow steps on the final test commit and uploaded artifact [`13556316772`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42328626464/artifacts/13556316772), 31,328 bytes, SHA-256 `9be62cda309b4c460e90df2200a9963ab9e541f011c471d9510e9d1dbcbd4de4`. The UI now positions the status/footer metadata against the active width, while the picker and path prompt are centered and scaled to smaller surfaces with matching mouse hit testing.

## Cursor-shape get_pointer argument marshalling

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 02:07:45 UTC | [`a440fd2683a8`](https://github.com/GraderGamer2/NekoEdit/commit/a440fd2683a821bf1535924b932be55b05ab58f7) | fix: marshal cursor-shape get_pointer arguments |

Actions [#298](https://github.com/GraderGamer2/NekoEdit/actions/runs/42327663095) passed all eight workflow steps. The source now sends the required new cursor-device ID and existing `wl_pointer` ID in the eight-byte request payload; the mock test asserts both arguments. Artifact [`13555438576`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42327663095/artifacts/13555438576) is 30,625 bytes with SHA-256 `91538137f998925ed72cd9d47604380be85906a17eb8af1d7dd1aaa885f49300`, expiring 2026-11-14.

## Original `main` prototype history

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 01:08:52 UTC | [`30d0205f7618`](https://github.com/GraderGamer2/NekoEdit/commit/30d0205f761877dfb950127d4aa3561d0acf2471) | docs: add NekoEdit project overview |
| 2026-11-06 01:09:18 UTC | [`b40660979c1f`](https://github.com/GraderGamer2/NekoEdit/commit/b40660979c1f21d7242669354ad381afa70a4413) | chore: add build artifacts to gitignore |
| 2026-11-06 01:09:20 UTC | [`9f69c15f1bc6`](https://github.com/GraderGamer2/NekoEdit/commit/9f69c15f1bc6271b08e9d9fbe7c391cc06e276b0) | build: add freestanding assembly Makefile |
| 2026-11-06 01:09:22 UTC | [`7e8b95c4e667`](https://github.com/GraderGamer2/NekoEdit/commit/7e8b95c4e667b082a689862a66bb81f9dfa700d1) | feat: add freestanding x86-64 assembly entry point |
| 2026-11-06 01:09:25 UTC | [`2623240b78b2`](https://github.com/GraderGamer2/NekoEdit/commit/2623240b78b222fd5517fa165eaa9d6bb8b4f68a) | feat: add direct Linux syscall helpers |
| 2026-11-06 01:09:27 UTC | [`df64e0089ece`](https://github.com/GraderGamer2/NekoEdit/commit/df64e0089ece547540f5ee4980229cd8d255781e) | test: add bootstrap smoke tests |
| 2026-11-06 01:09:30 UTC | [`77f84236eb4f`](https://github.com/GraderGamer2/NekoEdit/commit/77f84236eb4fd381c3c67500d2fc395230e6d440) | docs: document core and platform architecture |
| 2026-11-06 01:09:32 UTC | [`bea2604a070f`](https://github.com/GraderGamer2/NekoEdit/commit/bea2604a070f5b9f7a639c2084999a57bc9c5aa2) | docs: specify clipboard snapshot ownership and interoperability |
| 2026-11-06 01:09:34 UTC | [`716e69b7d101`](https://github.com/GraderGamer2/NekoEdit/commit/716e69b7d10126b4e798d59bf73f1e0e4b61d205) | docs: design simple built-in directory browser |
| 2026-11-06 01:09:37 UTC | [`acf34f7e2a97`](https://github.com/GraderGamer2/NekoEdit/commit/acf34f7e2a9700f600ed815993df84c030964189) | docs: outline software renderer and system font support |
| 2026-11-06 01:21:47 UTC | [`33d098dc3f46`](https://github.com/GraderGamer2/NekoEdit/commit/33d098dc3f46d2d0d75ad55b7c12ba7c0b6747f4) | feat: add freestanding Wayland window prototype and CI |
| 2026-11-06 01:22:10 UTC | [`c624b4dddd09`](https://github.com/GraderGamer2/NekoEdit/commit/c624b4dddd09bceb2031925441b06d074c98248e) | fix: correct workflow concurrency expression |
| 2026-11-06 01:24:20 UTC | [`42cfdb4dba35`](https://github.com/GraderGamer2/NekoEdit/commit/42cfdb4dba352727924eadad88fecc5ebfe8a854) | fix: correct smoke test binary argument |
| 2026-11-06 01:35:15 UTC | [`a02a988a8eb2`](https://github.com/GraderGamer2/NekoEdit/commit/a02a988a8eb26628953f0429a226697b4a860c2c) | debug: report Wayland protocol errors and setup stage |
| 2026-11-06 01:35:57 UTC | [`d57b38d86d9d`](https://github.com/GraderGamer2/NekoEdit/commit/d57b38d86d9dad2bd031e7e0ba4f66f6b86d995e) | fix: align Wayland ancillary data structures |
| 2026-11-06 01:39:54 UTC | [`9c5394495f29`](https://github.com/GraderGamer2/NekoEdit/commit/9c5394495f2955a022a1404e5924603a6e4df1bb) | fix: allocate Wayland client object IDs densely |
| 2026-11-06 01:40:03 UTC | [`e727647f2c0f`](https://github.com/GraderGamer2/NekoEdit/commit/e727647f2c0fd3100bd8fb5761b49452495ad863) | fix: finish dense Wayland object ID sequence |
| 2026-11-06 01:40:10 UTC | [`9bc01a11c625`](https://github.com/GraderGamer2/NekoEdit/commit/9bc01a11c625a7cb8cdbfdb1b150c0a1255e5b90) | test: enforce dense Wayland object ID allocation |
| 2026-11-06 01:40:22 UTC | [`90d97457b68f`](https://github.com/GraderGamer2/NekoEdit/commit/90d97457b68f9d8f9acf9c13bd52ccb6c8e51561) | docs: document dense Wayland object ID allocation |
| 2026-11-06 01:40:41 UTC | [`06d0bf60c2c2`](https://github.com/GraderGamer2/NekoEdit/commit/06d0bf60c2c2770bb6d9121c4d88a0fa35f23836) | test: expect dense Wayland shared-memory pool ID |

## Development PR #1 history

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 02:24:36 UTC | [`b0e399149ef9`](https://github.com/GraderGamer2/NekoEdit/commit/b0e399149ef9cab5fc8b8562b9531f5e8f4298c5) | feat: support inherited Wayland sockets and protocol errors |
| 2026-11-06 02:24:39 UTC | [`3d19a0b52432`](https://github.com/GraderGamer2/NekoEdit/commit/3d19a0b52432546da6c037764a91615ed5b22227) | test: cover inherited Wayland sockets and compositor errors |
| 2026-11-06 02:24:41 UTC | [`8be27cae5dfb`](https://github.com/GraderGamer2/NekoEdit/commit/8be27cae5dfb037bd4514a086d5eb0154349f9f1) | docs: describe inherited Wayland socket support |
| 2026-11-06 02:25:09 UTC | [`940a6e9f8806`](https://github.com/GraderGamer2/NekoEdit/commit/940a6e9f8806ef4e614771901de256d9a159cae5) | test: correct protocol error string encoding |
| 2026-11-06 02:25:31 UTC | [`834a0560c102`](https://github.com/GraderGamer2/NekoEdit/commit/834a0560c1025bd5fdbd182f549d80c8c2a57d1e) | docs: document Wayland socket and error handling |
| 2026-11-06 02:26:55 UTC | [`dda6c0a56e9e`](https://github.com/GraderGamer2/NekoEdit/commit/dda6c0a56e9e49bcc52dd9ff0efff7546a7caa33) | fix: bound compositor error message output |
| 2026-11-06 02:32:55 UTC | [`87280bea8e11`](https://github.com/GraderGamer2/NekoEdit/commit/87280bea8e11add503186f5bce05ff6541ba9bd0) | feat: add Wayland pointer input and interactive palette |
| 2026-11-06 02:33:23 UTC | [`3bfd056b7f4e`](https://github.com/GraderGamer2/NekoEdit/commit/3bfd056b7f4e0a2f5cc25268efe14a92968560df) | test: exercise Wayland pointer clicks and buffer release |
| 2026-11-06 02:33:44 UTC | [`27549fc68914`](https://github.com/GraderGamer2/NekoEdit/commit/27549fc6891401d1429e50f3518069781ddb446d) | test: encode Wayland strings with proper NUL terminators |
| 2026-11-06 02:34:03 UTC | [`165a460c3ba7`](https://github.com/GraderGamer2/NekoEdit/commit/165a460c3ba7d8df5d0313612bcf46733e516e7e) | docs: describe initial Wayland pointer interaction |
| 2026-11-06 02:34:06 UTC | [`af24fe281d09`](https://github.com/GraderGamer2/NekoEdit/commit/af24fe281d0982866b31367fba0328c01ae38af2) | docs: document Wayland pointer handling and safe redraw |
| 2026-11-06 02:34:48 UTC | [`f453b9a591ce`](https://github.com/GraderGamer2/NekoEdit/commit/f453b9a591ce5b8d1843737ff39b8860f4209038) | test: fix Wayland protocol NUL string encoding |
| 2026-11-06 02:36:20 UTC | [`4e8271ed83b9`](https://github.com/GraderGamer2/NekoEdit/commit/4e8271ed83b9b5bb0b3a98ec755b534c9323543e) | feat: receive Wayland keyboard focus and key events |
| 2026-11-06 02:36:37 UTC | [`a42b390340b8`](https://github.com/GraderGamer2/NekoEdit/commit/a42b390340b83acb3a4f51141665cf6b961257c5) | test: cover Wayland keyboard focus and key events |
| 2026-11-06 02:36:46 UTC | [`a505abe3a1f9`](https://github.com/GraderGamer2/NekoEdit/commit/a505abe3a1f9711bdf70a72b02c78cd25c17f04d) | test: terminate mock keymap data correctly |
| 2026-11-06 02:37:05 UTC | [`690ce9ba8e72`](https://github.com/GraderGamer2/NekoEdit/commit/690ce9ba8e722068da21dfd6b9dfa04baa366900) | docs: describe raw Wayland keyboard events |
| 2026-11-06 02:37:08 UTC | [`a043e5f97e9e`](https://github.com/GraderGamer2/NekoEdit/commit/a043e5f97e9e5d2378183c1882df0576adf0b218) | docs: document Wayland keyboard event handling |
| 2026-11-06 02:37:21 UTC | [`80e507c381ec`](https://github.com/GraderGamer2/NekoEdit/commit/80e507c381ec86aae7fe276b38cbb375252549a4) | fix: zero-initialize Wayland input object counter |
| 2026-11-06 02:44:34 UTC | [`907be1b2f5f1`](https://github.com/GraderGamer2/NekoEdit/commit/907be1b2f5f197a5b1cb1d46f240fdbf51bebf98) | feat: add editable text buffer and basic document rendering |
| 2026-11-06 02:45:01 UTC | [`21076c78df07`](https://github.com/GraderGamer2/NekoEdit/commit/21076c78df07d777a867f83878446254d609e7c9) | test: verify text insertion navigation and rendering |
| 2026-11-06 02:45:28 UTC | [`475047d223d3`](https://github.com/GraderGamer2/NekoEdit/commit/475047d223d3077d23db034f643511c7b4b60ddf) | fix: escape keymap NUL in Python test source |
| 2026-11-06 02:45:52 UTC | [`1386f8b1b1e0`](https://github.com/GraderGamer2/NekoEdit/commit/1386f8b1b1e0a779250404f3105f918dfca58b6e) | fix: align stack during nested software redraw calls |
| 2026-11-06 02:46:38 UTC | [`00b6558351be`](https://github.com/GraderGamer2/NekoEdit/commit/00b6558351be77c2b89154fb5459e3d245277e3f) | test: report rendered text pixels for diagnostics |
| 2026-11-06 02:48:00 UTC | [`bad2d82d86ae`](https://github.com/GraderGamer2/NekoEdit/commit/bad2d82d86ae5359dac010bb19b2424ff987c87b) | test: position cursor before newline insertion |
| 2026-11-06 02:48:26 UTC | [`3865ab5cff04`](https://github.com/GraderGamer2/NekoEdit/commit/3865ab5cff04a70f65644f99bea7124b2ed75dfc) | test: verify initial editor text rendering |
| 2026-11-06 03:07:23 UTC | [`a132547ec4e8`](https://github.com/GraderGamer2/NekoEdit/commit/a132547ec4e8c08d1e2458071cf8ca697c60f633) | test: sample visible prompt pixel beside caret |
| 2026-11-06 03:09:27 UTC | [`eb346a077334`](https://github.com/GraderGamer2/NekoEdit/commit/eb346a0773348cd3b0a87a5338d2041fe1147d1a) | test: synchronize each editor key redraw with buffer release |
| 2026-11-06 03:11:14 UTC | [`6ac1ea8e4489`](https://github.com/GraderGamer2/NekoEdit/commit/6ac1ea8e44893e3e1c8073b1a4fa2d8639adfc9e) | feat: synchronize Wayland keyboard modifier state |
| 2026-11-06 03:11:25 UTC | [`bb9a61b1f346`](https://github.com/GraderGamer2/NekoEdit/commit/bb9a61b1f34605c00aa3bdc49882fe91d595a29f) | test: verify Wayland modifier state and shifted text |
| 2026-11-06 03:12:00 UTC | [`93c48e7e3f98`](https://github.com/GraderGamer2/NekoEdit/commit/93c48e7e3f989757dcf40e7815143179bc53ab14) | docs: describe current ASCII editor prototype |
| 2026-11-06 03:12:03 UTC | [`814068c6d6a8`](https://github.com/GraderGamer2/NekoEdit/commit/814068c6d6a8284a26dd40afe24af261dbbd74e8) | docs: document keyboard editing and XKB limitations |
| 2026-11-06 03:12:23 UTC | [`1ce489b767a9`](https://github.com/GraderGamer2/NekoEdit/commit/1ce489b767a9d54f96e09cc4ddae3d8f2b96481f) | test: sample centered exclamation glyph pixel |
| 2026-11-06 03:13:23 UTC | [`9b5af6542df0`](https://github.com/GraderGamer2/NekoEdit/commit/9b5af6542df0cbf741826b582c14e5b54d446cb6) | docs: update development roadmap after editor milestone |
| 2026-11-06 03:13:26 UTC | [`a118b3513a32`](https://github.com/GraderGamer2/NekoEdit/commit/a118b3513a324fef772ad25ddd6b58119c952254) | docs: rename Wayland backend milestone |
| 2026-11-06 03:18:53 UTC | [`c191cd21d923`](https://github.com/GraderGamer2/NekoEdit/commit/c191cd21d9238748a297c016bd16c27a0851d540) | feat: place document cursor with pointer clicks |
| 2026-11-06 03:19:31 UTC | [`40ad45c23cda`](https://github.com/GraderGamer2/NekoEdit/commit/40ad45c23cdaf6cfd5f1725cd38765c966d92189) | test: verify pointer-based document caret placement |
| 2026-11-06 03:20:02 UTC | [`303c6792bda1`](https://github.com/GraderGamer2/NekoEdit/commit/303c6792bda17baccff2f0e2063cdae3bc68989f) | fix: map mouse clicks to containing text row |
| 2026-11-06 03:20:44 UTC | [`90eadbdd453a`](https://github.com/GraderGamer2/NekoEdit/commit/90eadbdd453a795da9764b0f837913768729c91c) | test: expose caret pixel row for pointer diagnostics |
| 2026-11-06 03:21:45 UTC | [`b49c7f4ff224`](https://github.com/GraderGamer2/NekoEdit/commit/b49c7f4ff224efddff9b2c8d004767e9b69689e8) | test: inspect caret candidate columns after mouse line click |
| 2026-11-06 03:24:04 UTC | [`2d23362296a4`](https://github.com/GraderGamer2/NekoEdit/commit/2d23362296a40dca2bef85eb0f94d39baccbb1c9) | test: isolate pointer click position from motion dispatch |
| 2026-11-06 03:25:14 UTC | [`c49a23565b8a`](https://github.com/GraderGamer2/NekoEdit/commit/c49a23565b8af79cd8649a3dc9b0e58212958f87) | fix: simplify pointer-to-document cursor scan |
| 2026-11-06 03:26:00 UTC | [`d842690acf76`](https://github.com/GraderGamer2/NekoEdit/commit/d842690acf76d5a2b90860617ef8de57b451f58b) | debug: expose pointer hit-test coordinates to mock surface |
| 2026-11-06 03:26:13 UTC | [`7566ba04abc0`](https://github.com/GraderGamer2/NekoEdit/commit/7566ba04abc0efdc903b1675be37f8cc4ff0b0f4) | fix: preserve callee-saved registers in pointer diagnostics |
| 2026-11-06 03:26:23 UTC | [`0aa560a0e504`](https://github.com/GraderGamer2/NekoEdit/commit/0aa560a0e504ef4b2788fe31de784db04064bd49) | test: capture pointer coordinate and line-scan diagnostics |
| 2026-11-06 03:27:17 UTC | [`0b70aa98dbd2`](https://github.com/GraderGamer2/NekoEdit/commit/0b70aa98dbd29ae110a5e2af70de0a0acd321cd1) | fix: use valid mapped-buffer base for pointer diagnostics |
| 2026-11-06 03:28:17 UTC | [`4d322d85bd47`](https://github.com/GraderGamer2/NekoEdit/commit/4d322d85bd479e4fcea441ac19214ab0e0dad663) | fix: compute mouse text column from left-relative coordinates |
| 2026-11-06 03:29:07 UTC | [`334954ade218`](https://github.com/GraderGamer2/NekoEdit/commit/334954ade218c2ecc2b77a15f547cb8cd4edd822) | debug: inspect mouse column conversion intermediates |
| 2026-11-06 03:29:15 UTC | [`a0602dbd003a`](https://github.com/GraderGamer2/NekoEdit/commit/a0602dbd003a657a74590123e3454259074a759e) | test: capture intermediate mouse column calculations |
| 2026-11-06 03:30:10 UTC | [`ab9345969b26`](https://github.com/GraderGamer2/NekoEdit/commit/ab9345969b262fe6a8503c7eec154ea9a101c7bc) | fix: map mouse click coordinates to text insertion columns |
| 2026-11-06 03:30:23 UTC | [`b518c89fa637`](https://github.com/GraderGamer2/NekoEdit/commit/b518c89fa63716cf86b6fa493e963d04d62188b8) | test: verify mouse caret placement by real pointer motion |
| 2026-11-06 03:30:50 UTC | [`75a8b78fb051`](https://github.com/GraderGamer2/NekoEdit/commit/75a8b78fb05171872e553409febe0509ba82cf87) | docs: describe mouse-based caret placement |
| 2026-11-06 03:30:53 UTC | [`253eb3dd1c0d`](https://github.com/GraderGamer2/NekoEdit/commit/253eb3dd1c0df9eb150b429bf5ddf25733a9aedf) | docs: document pointer text hit-testing |
| 2026-11-06 03:38:45 UTC | [`2e155362ee6f`](https://github.com/GraderGamer2/NekoEdit/commit/2e155362ee6fcfb21d06d91a4027907f9ed7cb29) | feat: add mouse drag text selection |
| 2026-11-06 03:39:15 UTC | [`cfc379435be6`](https://github.com/GraderGamer2/NekoEdit/commit/cfc379435be6909e773a890ff7fe180434a63590) | test: cover mouse drag selection and replacement |
| 2026-11-06 03:40:18 UTC | [`1a861a9787b0`](https://github.com/GraderGamer2/NekoEdit/commit/1a861a9787b0197b374028179eb0bb68da15c0cb) | docs: describe mouse drag selection |
| 2026-11-06 03:40:23 UTC | [`55b197e1a51d`](https://github.com/GraderGamer2/NekoEdit/commit/55b197e1a51da8e20d9915bd2c68da52cdd7b460) | docs: describe drag selection behavior |
| 2026-11-06 03:41:11 UTC | [`e165d414973f`](https://github.com/GraderGamer2/NekoEdit/commit/e165d414973f35d38b0c34dc6d0cc133109d6fe1) | test: inspect selection highlight beyond caret and glyph pixels |
| 2026-11-06 03:42:21 UTC | [`02131abc8206`](https://github.com/GraderGamer2/NekoEdit/commit/02131abc82069f6c31a5e365124c6d2428a7507b) | test: cover multi-line mouse selection |
| 2026-11-06 03:49:19 UTC | [`7cb2ad8b77a5`](https://github.com/GraderGamer2/NekoEdit/commit/7cb2ad8b77a564b8e7c533efcf01a9099a50cc4b) | feat: add Shift-based keyboard text selection |
| 2026-11-06 03:49:53 UTC | [`d0f4b1fdc0c5`](https://github.com/GraderGamer2/NekoEdit/commit/d0f4b1fdc0c5670ee85c4bff46b341b1bac20045) | test: cover Shift-based keyboard selection |
| 2026-11-06 03:50:17 UTC | [`0065593e2df7`](https://github.com/GraderGamer2/NekoEdit/commit/0065593e2df748cf363b0fa73b869e203a72c8aa) | docs: describe Shift-based keyboard selection |
| 2026-11-06 03:50:20 UTC | [`6bfdc2811e85`](https://github.com/GraderGamer2/NekoEdit/commit/6bfdc2811e85bbc56f07530841ccbf98e00826cd) | docs: describe keyboard selection behavior |
| 2026-11-06 03:51:05 UTC | [`feb0a01484c2`](https://github.com/GraderGamer2/NekoEdit/commit/feb0a01484c2f7a89dd175f05f6526567e76324e) | docs: mark keyboard selection as implemented |
| 2026-11-06 03:51:08 UTC | [`3ba2a94d044b`](https://github.com/GraderGamer2/NekoEdit/commit/3ba2a94d044b0a82dfec22e635aa581d9f711533) | docs: note approximate selection highlight geometry |
| 2026-11-06 03:58:33 UTC | [`b275ffbd1912`](https://github.com/GraderGamer2/NekoEdit/commit/b275ffbd19121ecb182133c74fa6f698fd6085f2) | feat: add delayed keyboard key repeat |
| 2026-11-06 03:59:17 UTC | [`da7c6d77beef`](https://github.com/GraderGamer2/NekoEdit/commit/da7c6d77beef1c0582fe3d4802c2984c03319a58) | test: verify delayed keyboard auto-repeat |
| 2026-11-06 04:00:04 UTC | [`fa7e0c3cb4da`](https://github.com/GraderGamer2/NekoEdit/commit/fa7e0c3cb4dafed4d7e56cf8502fd8dd0c11c925) | test: cover held Delete key repeat |
| 2026-11-06 04:00:16 UTC | [`1e94e2cf0d77`](https://github.com/GraderGamer2/NekoEdit/commit/1e94e2cf0d7793329fd6d94be99f4ae0afc19e4e) | docs: record planned Ctrl keyboard shortcuts |
| 2026-11-06 04:00:19 UTC | [`63a7f60a949d`](https://github.com/GraderGamer2/NekoEdit/commit/63a7f60a949dfdf48fc38425e056afb5aa98dcd0) | docs: document timed key repeat and shortcut roadmap |
| 2026-11-06 04:00:42 UTC | [`1eb95b4d8aec`](https://github.com/GraderGamer2/NekoEdit/commit/1eb95b4d8aec755b8f0530de431c88ecfb5ed86e) | test: inspect visible C glyph after forward Delete |
| 2026-11-06 04:01:30 UTC | [`b2d67b775720`](https://github.com/GraderGamer2/NekoEdit/commit/b2d67b77572034fed8f3e7dda944f72f0716a924) | test: check forward Delete repeat with an unoccluded glyph pixel |
| 2026-11-06 04:10:30 UTC | [`e87d44199e9a`](https://github.com/GraderGamer2/NekoEdit/commit/e87d44199e9a5e5806adc7df2e0f9743e2cf9043) | fix: wrap overflowing document text and scroll caret into view |
| 2026-11-06 04:11:23 UTC | [`8c721150b579`](https://github.com/GraderGamer2/NekoEdit/commit/8c721150b5799654cc4019cbcb4f8372c5553b31) | test: cover soft wrapping and vertical document scrolling |
| 2026-11-06 04:12:26 UTC | [`75b6d9957f0f`](https://github.com/GraderGamer2/NekoEdit/commit/75b6d9957f0fe0c32dc4e5ebffdf990dbd0b44e5) | docs: describe wrapping and vertical caret scrolling |
| 2026-11-06 04:12:29 UTC | [`03d5f160c673`](https://github.com/GraderGamer2/NekoEdit/commit/03d5f160c673a1ac4236b74c06f7ff2c9687d710) | docs: describe soft wrapping and automatic viewport scrolling |
| 2026-11-06 04:18:51 UTC | [`94b025e926d4`](https://github.com/GraderGamer2/NekoEdit/commit/94b025e926d4c1ab12b6d263842667b0f10903c1) | feat: add Ctrl+A select-all editing shortcut |
| 2026-11-06 04:18:53 UTC | [`ac12cffff2ee`](https://github.com/GraderGamer2/NekoEdit/commit/ac12cffff2ee990a0664d4e83a5e32f4375efeb6) | test: cover Ctrl+A document selection |
| 2026-11-06 04:18:56 UTC | [`69f274e6dd78`](https://github.com/GraderGamer2/NekoEdit/commit/69f274e6dd781e3b6d650b7b2d62d3ccf5f57e1c) | docs: document Ctrl+A select-all support |
| 2026-11-06 04:19:00 UTC | [`ae6532551c27`](https://github.com/GraderGamer2/NekoEdit/commit/ae6532551c274bc8857d8588a9ef8a788b55ec33) | docs: describe Ctrl+A keyboard selection |
| 2026-11-06 04:29:43 UTC | [`cf6ac519d189`](https://github.com/GraderGamer2/NekoEdit/commit/cf6ac519d189736e105e4ebce26b90462d2542f4) | feat: honor Wayland repeat settings for all ordinary keys |
| 2026-11-06 04:29:48 UTC | [`8f9e31965e22`](https://github.com/GraderGamer2/NekoEdit/commit/8f9e31965e2241ec0729fe0abbe4fd2d13a83a8a) | test: cover compositor-configured key repeat |
| 2026-11-06 04:29:53 UTC | [`4a4e2ceb19c7`](https://github.com/GraderGamer2/NekoEdit/commit/4a4e2ceb19c7e72d2a94903eb2922488bfc052ca) | docs: describe compositor-configured keyboard repeat |
| 2026-11-06 04:29:58 UTC | [`2d7d66633473`](https://github.com/GraderGamer2/NekoEdit/commit/2d7d66633473017d0ffa10503fa5eaa404f47baa) | docs: describe generic Wayland keyboard repeat |
| 2026-11-06 04:30:22 UTC | [`bb14274b5f50`](https://github.com/GraderGamer2/NekoEdit/commit/bb14274b5f501a05f6a79952258bc0cbc242480b) | fix: calculate Wayland seat version payload address safely |
| 2026-11-06 04:30:50 UTC | [`f3a9a1b60b62`](https://github.com/GraderGamer2/NekoEdit/commit/f3a9a1b60b620e56fbb89efae82c4aa3ba92a115) | docs: correct keyboard repeat and keymap status |
| 2026-11-06 04:31:26 UTC | [`7deb359cf6c2`](https://github.com/GraderGamer2/NekoEdit/commit/7deb359cf6c2801b658a63094891ea51d1b38370) | test: account for Ctrl+A replacement before key repeat |
| 2026-11-06 04:41:04 UTC | [`0cb2ef704ae0`](https://github.com/GraderGamer2/NekoEdit/commit/0cb2ef704ae0b7eb5dccb3d943bbb7e916818d91) | feat: add document tab and live editor status bar |
| 2026-11-06 04:41:07 UTC | [`597999983508`](https://github.com/GraderGamer2/NekoEdit/commit/597999983508fd307ce471f919fbc098a384b853) | test: verify editor chrome and status bar rendering |
| 2026-11-06 04:41:10 UTC | [`c5a198206c36`](https://github.com/GraderGamer2/NekoEdit/commit/c5a198206c36e1cd705cd31edb71bf862e8e5ed3) | docs: describe document tab and live editor status |
| 2026-11-06 04:41:13 UTC | [`6cd1225bd6ca`](https://github.com/GraderGamer2/NekoEdit/commit/6cd1225bd6ca8afe7fae4c0328d608bb9229fb4c) | docs: describe editor chrome and live status bar |
| 2026-11-06 04:42:20 UTC | [`b8f7bc2de41a`](https://github.com/GraderGamer2/NekoEdit/commit/b8f7bc2de41a4f931a4b7284ce694219b61b6e9d) | fix: preserve keyboard dispatch while removing palette controls |
| 2026-11-06 04:43:01 UTC | [`6a976eb23704`](https://github.com/GraderGamer2/NekoEdit/commit/6a976eb2370474f11933c127767aa6a6f6b3069c) | fix: keep the status bar outside the document viewport |
| 2026-11-06 04:43:05 UTC | [`757aabdc98d3`](https://github.com/GraderGamer2/NekoEdit/commit/757aabdc98d3c8de93db15271a63eeb369f55ce8) | test: verify logical line and column status |
| 2026-11-06 04:43:08 UTC | [`48bec939c5d6`](https://github.com/GraderGamer2/NekoEdit/commit/48bec939c5d66190c396bfe5305e1bae6acf1eac) | docs: update editor chrome and viewport status |
| 2026-11-06 04:43:11 UTC | [`1a0a985e53e8`](https://github.com/GraderGamer2/NekoEdit/commit/1a0a985e53e82affe5f60b1a93c3920a93226697) | docs: clarify document viewport and footer |
| 2026-11-06 04:43:44 UTC | [`7a617f9d9ce3`](https://github.com/GraderGamer2/NekoEdit/commit/7a617f9d9ce39ecabe6569beabe28e8377cd3fba) | test: distinguish footer accent from status background |
| 2026-11-06 04:44:27 UTC | [`41437c171887`](https://github.com/GraderGamer2/NekoEdit/commit/41437c171887a5083deb3c8058e03ce66183d30d) | test: update mouse hit targets for compact editor header |
| 2026-11-06 04:45:12 UTC | [`83a4a10e3e72`](https://github.com/GraderGamer2/NekoEdit/commit/83a4a10e3e72edc74b1eb18a402f790ff2d14750) | test: align multiline selection drag with new document origin |
| 2026-11-06 04:46:34 UTC | [`c64be1694f3d`](https://github.com/GraderGamer2/NekoEdit/commit/c64be1694f3da488074cf6cf47825b757f59b0a7) | test: report actual caret position on viewport failures |
| 2026-11-06 04:47:27 UTC | [`58933b545d9e`](https://github.com/GraderGamer2/NekoEdit/commit/58933b545d9ef8a063219b6ba9b45b195d545500) | fix: render scrolled document rows with signed viewport clipping |
| 2026-11-06 04:48:17 UTC | [`e907843752e8`](https://github.com/GraderGamer2/NekoEdit/commit/e907843752e87d94686afce8eca062833977e61c) | test: update repeat caret expectations for new editor origin |
| 2026-11-06 04:49:55 UTC | [`ca1a92e49d4d`](https://github.com/GraderGamer2/NekoEdit/commit/ca1a92e49d4d3ca2a63e32a9907f1fa5f1ebfc7a) | docs: remove palette references and describe 30-row viewport |
| 2026-11-06 05:00:12 UTC | [`d011362fc75a`](https://github.com/GraderGamer2/NekoEdit/commit/d011362fc75a0cb891747f3cd058f60a1d9958d1) | feat: add launch-time file loading and Ctrl+S saving |
| 2026-11-06 05:01:42 UTC | [`a5b9463366ab`](https://github.com/GraderGamer2/NekoEdit/commit/a5b9463366abfa62ad9bc87ced73f799609ec6be) | test: account for loaded text when checking clicked caret |
| 2026-11-06 05:03:07 UTC | [`6415e6324869`](https://github.com/GraderGamer2/NekoEdit/commit/6415e632486957280d0de9d1175e2b27e6f2d8c2) | test: isolate file load and save round trip |
| 2026-11-06 05:07:01 UTC | [`cdc77878756a`](https://github.com/GraderGamer2/NekoEdit/commit/cdc77878756a563d7c08fb597824a9282a45fcab) | feat: receive and map Wayland XKB keymap descriptors |
| 2026-11-06 05:07:39 UTC | [`4ddded6542ba`](https://github.com/GraderGamer2/NekoEdit/commit/4ddded6542bae728d442ddd2bb2595e63ffce13b) | fix: handle Wayland event EOF and keymap FD cleanup |
| 2026-11-06 05:08:09 UTC | [`ae4766a7c707`](https://github.com/GraderGamer2/NekoEdit/commit/ae4766a7c707a395a3dfdd9d2ac553c0b6f74c7c) | fix: initialize keymap FD sentinel at event receive |
| 2026-11-06 05:09:54 UTC | [`ca42e495f3a4`](https://github.com/GraderGamer2/NekoEdit/commit/ca42e495f3a4cfbc1d110d68515a92ccfca94151) | test: make malformed XKB map rejection deterministic |
| 2026-11-06 05:12:11 UTC | [`034cbacd1653`](https://github.com/GraderGamer2/NekoEdit/commit/034cbacd1653e2ca2066cd73003c5dc3852e1928) | fix: dispatch XKB keymap events during protocol reads |
| 2026-11-06 05:13:28 UTC | [`b255886d1e22`](https://github.com/GraderGamer2/NekoEdit/commit/b255886d1e226bbac2dc949ba6cd3a32a83ed0d2) | fix: validate XKB map payloads before event dispatch |
| 2026-11-06 05:17:00 UTC | [`2b6729ec8d82`](https://github.com/GraderGamer2/NekoEdit/commit/2b6729ec8d82ef958fcbf8e46b2106b1a461b7d2) | fix: preserve Wayland event errors while closing FDs |
| 2026-11-06 05:18:07 UTC | [`4e065562dc47`](https://github.com/GraderGamer2/NekoEdit/commit/4e065562dc47e92939e17857923841e7768c6f49) | debug: trace Wayland keyboard keymap event dispatch |
| 2026-11-06 05:19:00 UTC | [`10976f4930ac`](https://github.com/GraderGamer2/NekoEdit/commit/10976f4930acb905a4df81ef58155bfe2face889) | debug: trace keyboard opcode zero event headers |
| 2026-11-06 05:19:21 UTC | [`a9ee528e5a33`](https://github.com/GraderGamer2/NekoEdit/commit/a9ee528e5a33a94997ca611e1dbeeaf32b0b85a3) | fix: preserve event payload length after keymap trace |
| 2026-11-06 05:20:32 UTC | [`451a0fd2c51b`](https://github.com/GraderGamer2/NekoEdit/commit/451a0fd2c51bdc960c93b92fb1cacb27ae5523e1) | test: retain valid XKB descriptor coverage without flaky negative case |
| 2026-11-06 05:21:52 UTC | [`a5b5162908e8`](https://github.com/GraderGamer2/NekoEdit/commit/a5b5162908e80a487469421219fcaac9894d2546) | revert: restore stable Wayland event handling |
| 2026-11-06 06:07:51 UTC | [`dbace125d1e2`](https://github.com/GraderGamer2/NekoEdit/commit/dbace125d1e21c6f683e26ee941e3c2e26b08215) | feat: add in-window File menu and path-based file operations |
| 2026-11-06 06:09:02 UTC | [`ade6912116f1`](https://github.com/GraderGamer2/NekoEdit/commit/ade6912116f1c924d6168285b6122d2bbbafc5f7) | test: resolve editor path for relative-path fixtures |
| 2026-11-06 06:15:20 UTC | [`ed702b25d184`](https://github.com/GraderGamer2/NekoEdit/commit/ed702b25d184f108bd919c19fbc45596a28d69ee) | fix: preserve signed file-operation errors and test rollback |
| 2026-11-06 06:16:48 UTC | [`41543dbd0fe5`](https://github.com/GraderGamer2/NekoEdit/commit/41543dbd0fe57961c017e3b15f1b597e58b33af7) | test: sample path prompt below its title bar |
| 2026-11-06 06:18:06 UTC | [`9d3967e6a15d`](https://github.com/GraderGamer2/NekoEdit/commit/9d3967e6a15d281896bf4f95c5b696684b6df8ac) | test: distinguish edits across failed-open rollback checks |
| 2026-11-06 06:30:44 UTC | [`14912ae02e03`](https://github.com/GraderGamer2/NekoEdit/commit/14912ae02e03e78811fb2506c294ed5a9bafa8b1) | feat: receive and map Wayland XKB keymap descriptors |
| 2026-11-06 06:31:31 UTC | [`25f1e758bc95`](https://github.com/GraderGamer2/NekoEdit/commit/25f1e758bc952ebd2a2de960b0cd9a0d807b41f0) | fix: keep Wayland descriptor sentinel in BSS-safe storage |
| 2026-11-06 06:32:57 UTC | [`6c594243d1b9`](https://github.com/GraderGamer2/NekoEdit/commit/6c594243d1b917a4206fc8da8e02714121c548bb) | test: keep absolute path fixture within simulated keymap |
| 2026-11-06 06:33:57 UTC | [`7e4bb7ac02b9`](https://github.com/GraderGamer2/NekoEdit/commit/7e4bb7ac02b97f098304fbec63722fde27292998) | docs: distinguish XKB keymap transport from symbol parsing |
| 2026-11-06 06:45:29 UTC | [`f597587867dc`](https://github.com/GraderGamer2/NekoEdit/commit/f597587867dcca88603dc5574575377c2d6f3f0c) | feat: add bounded XKB text keymap parser |
| 2026-11-06 06:46:36 UTC | [`8f7ee6af08cc`](https://github.com/GraderGamer2/NekoEdit/commit/8f7ee6af08ccbc33aef80c2fa5ea30b587a6bdd0) | fix: classify compound XKB types and preserve inferred key indexes |
| 2026-11-06 06:47:29 UTC | [`096a64b0030f`](https://github.com/GraderGamer2/NekoEdit/commit/096a64b0030f7363c6e68ae1da53cdc42b94925f) | feat: translate input using parsed XKB symbols |
| 2026-11-06 06:48:58 UTC | [`3120c0b9297f`](https://github.com/GraderGamer2/NekoEdit/commit/3120c0b9297f93747dce41ad6e27ebfa5fc11be7) | test: verify XKB groups and modifier-level symbol translation |
| 2026-11-06 06:49:23 UTC | [`2eb6c3952cf4`](https://github.com/GraderGamer2/NekoEdit/commit/2eb6c3952cf45e4c6ae30cfb123004ad7376274c) | fix: use encodable XKB group fallback address |
| 2026-11-06 06:51:40 UTC | [`b5076b809140`](https://github.com/GraderGamer2/NekoEdit/commit/b5076b809140dda8de7a6b6aa7e4fd76b32b550f) | fix: preserve backend link order and correct ASCII keysym names |
| 2026-11-06 06:53:12 UTC | [`322d96c4726e`](https://github.com/GraderGamer2/NekoEdit/commit/322d96c4726ef529f6794b5c3d9d112863db1b67) | test: seed keymap integration document with visible content |
| 2026-11-06 06:55:09 UTC | [`7adbf6051a49`](https://github.com/GraderGamer2/NekoEdit/commit/7adbf6051a49a10f09b6bcb809d62c5b576de7a5) | test: exercise XKB LevelThree on an already-mapped key |
| 2026-11-06 06:56:24 UTC | [`e3da028925df`](https://github.com/GraderGamer2/NekoEdit/commit/e3da028925dff7f6a3ec386b8f6ed90bf617a2d9) | test: inspect parsed XKB symbol and modifier tables |
| 2026-11-06 06:56:50 UTC | [`5baa7b9315b5`](https://github.com/GraderGamer2/NekoEdit/commit/5baa7b9315b5060f3c5c0380435819789836edcd) | test: correct XKB parser table assertions |
| 2026-11-06 06:58:00 UTC | [`68ef47719d2c`](https://github.com/GraderGamer2/NekoEdit/commit/68ef47719d2cb03471d118a676646b9d690be805) | test: surface mock compositor failures without hanging client |
| 2026-11-06 06:59:05 UTC | [`691931d8cdbf`](https://github.com/GraderGamer2/NekoEdit/commit/691931d8cdbfc7c65a73fb74a046549c29bc56a2) | fix: preserve XKB keysym lengths during named symbol lookup |
| 2026-11-06 06:59:49 UTC | [`d1bb417f73c8`](https://github.com/GraderGamer2/NekoEdit/commit/d1bb417f73c86127fcaa16626daa88b51a5be47c) | fix: correct XKB bracket and backslash keysym lengths |
| 2026-11-06 07:00:56 UTC | [`478a0437cbf7`](https://github.com/GraderGamer2/NekoEdit/commit/478a0437cbf7623cdf44a5b49a86171aadd7aea3) | docs: describe parsed XKB ASCII layout support |
| 2026-11-06 07:09:13 UTC | [`23edad5b916c`](https://github.com/GraderGamer2/NekoEdit/commit/23edad5b916cbb843feea7800a0ceeffc95cbba7) | fix: parse shorthand XKB symbol arrays and reject sparse maps |
| 2026-11-06 07:09:50 UTC | [`fd0b3c5db4bd`](https://github.com/GraderGamer2/NekoEdit/commit/fd0b3c5db4bde1d52cfac6ddf974f610cdc37f3f) | test: cover xkbcomp shorthand and shifted number-row symbols |
| 2026-11-06 07:11:15 UTC | [`35320e8a168d`](https://github.com/GraderGamer2/NekoEdit/commit/35320e8a168dda08b55660212fa8107027f6aa37) | test: inspect XKB shorthand number-row tables |
| 2026-11-06 07:39:47 UTC | [`26f7a862c190`](https://github.com/GraderGamer2/NekoEdit/commit/26f7a862c190b62b6db935cef7aa23fbb6fb22dd) | fix: preserve XKB keysym table stride after partial matches |
| 2026-11-06 07:42:33 UTC | [`5114b6ae8f8b`](https://github.com/GraderGamer2/NekoEdit/commit/5114b6ae8f8b771e43c52a5c1ed72635e7a056a1) | test: require complete XKB alphabet coverage |
| 2026-11-06 07:44:15 UTC | [`7be6f4f5136e`](https://github.com/GraderGamer2/NekoEdit/commit/7be6f4f5136e88819493c027aed4f68d57afec99) | test: verify fallback for incomplete XKB keymaps |
| 2026-11-06 07:47:14 UTC | [`3e22a463d65c`](https://github.com/GraderGamer2/NekoEdit/commit/3e22a463d65c1c20d658f66811073ef3c9333a51) | test: exercise typing after sparse XKB map rejection |
| 2026-11-06 07:49:15 UTC | [`5e6e2cf8796f`](https://github.com/GraderGamer2/NekoEdit/commit/5e6e2cf8796f3f4779314cf68119e65bf834069b) | docs: document XKB layout parsing and sparse-map fallback |
| 2026-11-06 07:51:04 UTC | [`cc0165585e5f`](https://github.com/GraderGamer2/NekoEdit/commit/cc0165585e5ff7ba28ad645a33936d74721d17d7) | test: synchronize mock with XKB keymap processing completion |
| 2026-11-06 08:53:04 UTC | [`56855bd985ed`](https://github.com/GraderGamer2/NekoEdit/commit/56855bd985edd41c12939b434d6557f2e7b75782) | fix: render complete printable ASCII punctuation set |
| 2026-11-06 08:54:15 UTC | [`c2ffefad821c`](https://github.com/GraderGamer2/NekoEdit/commit/c2ffefad821c857afe6c402ab2efa5c3a76bf1ca) | test: place punctuation fixture after visible origin glyph |
| 2026-11-06 08:55:34 UTC | [`978d556657dc`](https://github.com/GraderGamer2/NekoEdit/commit/978d556657dce0abb5f930eb42f7b6960139694b) | test: calculate initial caret position from fixture size |
| 2026-11-06 08:57:24 UTC | [`2feadff8365b`](https://github.com/GraderGamer2/NekoEdit/commit/2feadff8365bc5c5e8cdfc95a1842de8f6cfb0b2) | test: tolerate pointer hit-test rounding in long fixtures |
| 2026-11-06 08:59:47 UTC | [`79574507baa7`](https://github.com/GraderGamer2/NekoEdit/commit/79574507baa79d8fbf4b9082ba1b0ef93b671c2d) | test: allow slower XKB mock integration runs |
| 2026-11-06 09:00:51 UTC | [`1c08affe8c58`](https://github.com/GraderGamer2/NekoEdit/commit/1c08affe8c58477a92faaffdc7a0d80e486b863d) | test: isolate XKB and glyph cases from pointer assertion |
| 2026-11-06 11:36:00 UTC | [`70a333fc5392`](https://github.com/GraderGamer2/NekoEdit/commit/70a333fc5392fe0db5ba29d117358ef4767e407b) | feat: navigate and edit UTF-8 code points safely |
| 2026-11-06 11:36:38 UTC | [`056b381ab571`](https://github.com/GraderGamer2/NekoEdit/commit/056b381ab57191c9c28f6305914c3edc814c22df) | test: cover UTF-8 cursor movement and deletion |
| 2026-11-06 11:37:18 UTC | [`711613327410`](https://github.com/GraderGamer2/NekoEdit/commit/711613327410dbe6a7fdc0df816dd0c217483182) | test: verify UTF-8 scalars stay intact during selection |
| 2026-11-06 11:40:56 UTC | [`29ea6773e2db`](https://github.com/GraderGamer2/NekoEdit/commit/29ea6773e2db6f9bb6008a9016d78d24786df6f1) | test: run UTF-8 edits before generic save scenario |
| 2026-11-06 11:42:39 UTC | [`f9bc6f5df0c0`](https://github.com/GraderGamer2/NekoEdit/commit/f9bc6f5df0c0339cca88da022ca225045823200b) | test: report editor exit status on compositor failure |
| 2026-11-06 11:45:18 UTC | [`ec5d5ef33a44`](https://github.com/GraderGamer2/NekoEdit/commit/ec5d5ef33a44c85f72d9e43cddfd4dac76450d2e) | test: position UTF-8 fixtures on the first document row |
| 2026-11-06 11:45:50 UTC | [`fd14288098c5`](https://github.com/GraderGamer2/NekoEdit/commit/fd14288098c5383121c6db3a7077bc65f6dec535) | test: delete every byte in malformed UTF-8 fixture |
| 2026-11-06 11:46:49 UTC | [`6e401497373c`](https://github.com/GraderGamer2/NekoEdit/commit/6e401497373c1c78ce6de5dc06c0be3887b83878) | docs: clarify current UTF-8 editing support |
| 2026-11-06 11:47:03 UTC | [`749d1cc085d2`](https://github.com/GraderGamer2/NekoEdit/commit/749d1cc085d25e8cccc89e62455dfca9d43607d8) | docs: define UTF-8 editing boundary policy |
| 2026-11-06 11:47:22 UTC | [`998577b6e09a`](https://github.com/GraderGamer2/NekoEdit/commit/998577b6e09adf61f93666b12b9d1c3de8e92c21) | docs: document UTF-8 Wayland editor behavior |
| 2026-11-06 11:47:58 UTC | [`b71fa066fd3a`](https://github.com/GraderGamer2/NekoEdit/commit/b71fa066fd3afc65f42b0d6b5f245a5d2e945c6f) | test: verify pointer mapping across UTF-8 code points |
| 2026-11-06 11:48:18 UTC | [`5c8b0aea3ed9`](https://github.com/GraderGamer2/NekoEdit/commit/5c8b0aea3ed9a39ed30f7cae03366f5c062ad471) | test: fix expected UTF-8 pointer fixture bytes |
| 2026-11-06 11:49:03 UTC | [`6cd9e08fada0`](https://github.com/GraderGamer2/NekoEdit/commit/6cd9e08fada059ae3e24c9cdab7cf86762b24414) | test: route UTF-8 pointer case through its own edit scenario |
| 2026-11-06 12:15:57 UTC | [`776a72c07579`](https://github.com/GraderGamer2/NekoEdit/commit/776a72c07579ced1e54929946de65cea6271267e) | feat: add fixed-capacity gap buffer for document editing |

## Changelog bootstrap commits

These six commits created the changelog system after the 188-commit source-history snapshot above. They are included here so the repository's new history mechanism starts with its own setup work accounted for.

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 11:57:39 UTC | [`eb9497a49e8b`](https://github.com/GraderGamer2/NekoEdit/commit/eb9497a49e8bda601bba91ce8b5f6111133d1e74) | \\|d\\|o\\|c\\|s\\|:\\| \\|a\\|d\\|d\\| \\|c\\|o\\|m\\|p\\|l\\|e\\|t\\|e\\| \\|N\\|e\\|k\\|o\\|E\\|d\\|i\\|t\\| \\|c\\|o\\|m\\|m\\|i\\|t\\| \\|i\\|n\\|d\\|e\\|x\\| |
| 2026-11-06 11:58:06 UTC | [`29191c9011a8`](https://github.com/GraderGamer2/NekoEdit/commit/29191c9011a83d8ef2ad14afe498126ea78865fd) | \\|d\\|o\\|c\\|s\\|:\\| \\|d\\|e\\|f\\|i\\|n\\|e\\| \\|m\\|a\\|n\\|d\\|a\\|t\\|o\\|r\\|y\\| \\|c\\|h\\|a\\|n\\|g\\|e\\|l\\|o\\|g\\| \\|w\\|o\\|r\\|k\\|f\\|l\\|o\\|w\\| |
| 2026-11-06 11:58:35 UTC | [`35cc73903529`](https://github.com/GraderGamer2/NekoEdit/commit/35cc7390352970ccc25ba4b5b9b3de12da4869d2) | \\|d\\|o\\|c\\|s\\|:\\| \\|r\\|e\\|c\\|o\\|r\\|d\\| \\|N\\|e\\|k\\|o\\|E\\|d\\|i\\|t\\| \\|d\\|e\\|v\\|e\\|l\\|o\\|p\\|m\\|e\\|n\\|t\\| \\|h\\|i\\|s\\|t\\|o\\|r\\|y\\| |
| 2026-11-06 11:58:51 UTC | [`8401ae5f3997`](https://github.com/GraderGamer2/NekoEdit/commit/8401ae5f399797f3ac818a3ddcf4eddbaa0940e2) | \\|d\\|o\\|c\\|s\\|:\\| \\|a\\|d\\|d\\| \\|i\\|n\\|i\\|t\\|i\\|a\\|l\\| \\|d\\|e\\|v\\|e\\|l\\|o\\|p\\|m\\|e\\|n\\|t\\| \\|l\\|o\\|g\\| \\|e\\|n\\|t\\|r\\|y\\| |
| 2026-11-06 11:59:21 UTC | [`7815e253ae38`](https://github.com/GraderGamer2/NekoEdit/commit/7815e253ae38fe544a69d15fe54b1e2a4c58fc2d) | \\|d\\|o\\|c\\|s\\|:\\| \\|a\\|d\\|d\\| \\|c\\|u\\|r\\|r\\|e\\|n\\|t\\| \\|N\\|e\\|k\\|o\\|E\\|d\\|i\\|t\\| \\|i\\|m\\|p\\|l\\|e\\|m\\|e\\|n\\|t\\|a\\|t\\|i\\|o\\|n\\| \\|s\\|t\\|a\\|t\\|u\\|s\\| |
| 2026-11-06 11:59:30 UTC | [`1754d426a945`](https://github.com/GraderGamer2/NekoEdit/commit/1754d426a945580d3c9ae5372d1bb876d89b90be) | \\|d\\|o\\|c\\|s\\|:\\| \\|l\\|i\\|n\\|k\\| \\|p\\|r\\|o\\|j\\|e\\|c\\|t\\| \\|c\\|h\\|a\\|n\\|g\\|e\\|l\\|o\\|g\\| \\|f\\|r\\|o\\|m\\| \\|R\\|E\\|A\\|D\\|M\\|E\\| |


## Main-branch changelog installation

This docs-only commit copied the changelog directory and its root README link to `main`. It did not merge or copy the editor implementation from PR #1; `main` remains the original Wayland prototype.

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 12:09:42 UTC | [`9377c5c9c4bf`](https://github.com/GraderGamer2/NekoEdit/commit/9377c5c9c4bfee8a6a6ea4b8f27be451e85bf6e8) | docs: add project changelog and continuity notes to main |

## Post-bootstrap documentation and branch synchronization

These commits keep the feature milestone, main-branch changelog mirror, and PR branch ancestry aligned after the original six-commit changelog bootstrap.

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 12:19:24 UTC | [d35d54bb8726](https://github.com/GraderGamer2/NekoEdit/commit/d35d54bb8726f1c10cc3c9213ba49916939f06cf) | docs: record gap-buffer milestone and verification |
| 2026-11-06 12:20:05 UTC | [f31dc4177c78](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d) | docs: sync gap-buffer milestone changelog to main |
| 2026-11-06 12:22:24 UTC | [379a34981fc6](https://github.com/GraderGamer2/NekoEdit/commit/379a34981fc697be322063458b44ff4dd9a1e72d) | merge: sync main changelog into feature branch |
| 2026-11-06 12:23:48 UTC | [dd5176adf27d](https://github.com/GraderGamer2/NekoEdit/commit/dd5176adf27dec5b282b3ec565c51f5c34dcf83c) | docs: record main changelog sync and clean PR ancestry |
| 2026-11-06 12:25:00 UTC | [48861e43aac8](https://github.com/GraderGamer2/NekoEdit/commit/48861e43aac8cc20a70465b35e504d1a996c45d9) | docs: clarify feature branch synchronization status |

## 2026-11-06 branch rename and current PR state

The development branch was renamed from `feat/wayland-socket-error-handling` to `early-alpha`. GitHub reports the renamed branch at the preserved implementation tip [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0); the former branch ref is no longer listed. The rename itself is a GitHub ref rename, not a source commit, so it has no commit row.

At the same verification, PR [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) was closed and unmerged. Its API metadata still returned the former branch name as its head ref. This is recorded as observed repository state, not as an inferred cause or a merge.

Actions run [#174](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217617434) passed on the preserved implementation tip before the rename; all eight workflow steps succeeded. No application code or tests changed as part of this administrative event.

## Branch-rename documentation commits

| 2026-11-06 12:42:53 UTC | [`e50e87f2fe62`](https://github.com/GraderGamer2/NekoEdit/commit/e50e87f2fe62f0212b7fb0f77e6ebf5d1b4a55e5) | docs: index branch rename documentation commits |
| 2026-11-06 12:42:55 UTC | [`2c2dfbe16a9f`](https://github.com/GraderGamer2/NekoEdit/commit/2c2dfbe16a9feed38ea279281e6321b283219c54) | docs: sync branch rename commit index to main |
| 2026-11-06 12:44:35 UTC | [`b452c39c82a0`](https://github.com/GraderGamer2/NekoEdit/commit/b452c39c82a069236443b8ce14266a3fd2fae8aa) | docs: clarify main implementation base in status snapshot |
| 2026-11-06 12:44:42 UTC | [`99084a344cf3`](https://github.com/GraderGamer2/NekoEdit/commit/99084a344cf39f9ba2c5beec7a7db1528c7cf507) | docs: clarify main implementation base in status snapshot |

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 12:41:33 UTC | [`4d3786b206db`](https://github.com/GraderGamer2/NekoEdit/commit/4d3786b206dbdb6dc86ca4a2d140e57fe78ed459) | docs: record early-alpha branch rename and PR status |
| 2026-11-06 12:41:35 UTC | [`6f50ea994362`](https://github.com/GraderGamer2/NekoEdit/commit/6f50ea994362178dc7a34320263d00b3d7244158) | docs: sync early-alpha branch rename status to main |

## Replacement review PR #2

[PR #2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) was opened on 2026-11-06 from early-alpha into main. It re-proposes the existing development-branch implementation for review after PR #1 was closed without merging. At creation it contained 185 commits ahead / 4 behind, and changed 12 files (6,804 additions, 235 deletions). GitHub Actions [#179](https://github.com/GraderGamer2/NekoEdit/actions/runs/42220633279) passed all eight steps on head `108d7df1e024e74c653c5bb4cdbe52fb1d1289bf`; the PR was subsequently reported mergeable with a clean state. It remains open and unmerged.

The latest user-reported symbol-keyboard issue is documented in CURRENT_STATUS.md and DEVELOPMENT_LOG.md; passing automated tests do not imply that manual regression is resolved.
## Replacement PR #2 documentation commits

| 2026-11-06 12:52:48 UTC | [`fa4725159a20`](https://github.com/GraderGamer2/NekoEdit/commit/fa4725159a202130c5fdd8d2123d1e10be35cadc) | docs: record replacement pull request #2 |
| 2026-11-06 12:52:50 UTC | [`92fa00fca547`](https://github.com/GraderGamer2/NekoEdit/commit/92fa00fca547f4b5d947a645bce345f59046e9f6) | docs: sync pull request #2 status to main |

## Replacement PR #2 documentation commits

| 2026-11-06 12:52:48 UTC | [`fa4725159a20`](https://github.com/GraderGamer2/NekoEdit/commit/fa4725159a202130c5fdd8d2123d1e10be35cadc) | docs: record replacement pull request #2 |
| 2026-11-06 12:52:50 UTC | [`92fa00fca547`](https://github.com/GraderGamer2/NekoEdit/commit/92fa00fca547f4b5d947a645bce345f59046e9f6) | docs: sync pull request #2 status to main |

| 2026-11-06 12:54:16 UTC | [`4795856b1713`](https://github.com/GraderGamer2/NekoEdit/commit/4795856b1713c39103f56f3ba944f0723e3b4218) | docs: mirror pull request #2 status index to main |
| 2026-11-06 12:54:14 UTC | [`156e0ab2e53f`](https://github.com/GraderGamer2/NekoEdit/commit/156e0ab2e53fcdbcb4c8403154f577e1e41351c5) | docs: index pull request #2 status commits |
## XKB ONE_LEVEL parser fix and shifted-punctuation regression coverage

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 12:57:26 UTC | [`1cb1f15b7577`](https://github.com/GraderGamer2/NekoEdit/commit/1cb1f15b757713496fd5a259000b507867202ca7) | docs: complete PR #2 commit index |
| 2026-11-06 12:57:29 UTC | [`a6707045222e`](https://github.com/GraderGamer2/NekoEdit/commit/a6707045222e31f8e753808f00a0af53f29c9ec1) | docs: mirror completed PR #2 commit index to main |
| 2026-11-06 13:08:30 UTC | [`267ef0557b8e`](https://github.com/GraderGamer2/NekoEdit/commit/267ef0557b8e00bd01eae004ed346dde16977e3f) | fix: honor one-level XKB key types |
| 2026-11-06 13:11:10 UTC | [`b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b) | test: correct XKB punctuation fixture keycodes |

Actions run [#185](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223115089) failed because the new fixture declared evdev values instead of XKB keycodes for the shifted punctuation keys. After correction, Actions run [#186](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121) passed all eight steps on `b260457007589469abdb492358b7581558c0cc5b`, including the XKB +8/group/modifier assertions, shifted punctuation rows, ONE_LEVEL Shift behavior, and the pre-existing Wayland integration scenarios.
## XKB ONE_LEVEL validation documentation and ancestry synchronization

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 13:15:36 UTC | [`8fa6e2282703`](https://github.com/GraderGamer2/NekoEdit/commit/8fa6e2282703d164dcab2ecb096b9416523957ac) | docs: record XKB ONE_LEVEL fix and CI verification |
| 2026-11-06 13:16:24 UTC | [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c) | merge: synchronize main changelog history into early-alpha |

Actions run [#187](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584) passed all eight workflow steps on the ancestry synchronization merge commit. The tree was preserved from the prior `early-alpha` head; the merge adds the `main` history as a parent without bringing the editor implementation into `main`.

## Native directory-browser file picker and regression fixes

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 13:39:22 UTC | [`2164a327b310`](https://github.com/GraderGamer2/NekoEdit/commit/2164a327b3101478635cb0f0131fdf5b812d1c61) | feat: navigate directories and open selected files |
| 2026-11-06 13:43:33 UTC | [`c1442c0f13a5`](https://github.com/GraderGamer2/NekoEdit/commit/c1442c0f13a5c810d5c2d3c42ab1621d2982cce5) | feat: add picker keyboard and pointer interaction |
| 2026-11-06 13:45:17 UTC | [`94b916d90a8b`](https://github.com/GraderGamer2/NekoEdit/commit/94b916d90a8b26d237cd114d5ce6075048a4f5bd) | feat: render native directory picker interface |
| 2026-11-06 13:46:34 UTC | [`1921dd498b8e`](https://github.com/GraderGamer2/NekoEdit/commit/1921dd498b8eb2cc5c2bd26670182b79b976f5c6) | fix: initialize picker sentinels outside bss |
| 2026-11-06 13:50:34 UTC | [`00850e851bbd`](https://github.com/GraderGamer2/NekoEdit/commit/00850e851bbddd32769b92c670247c132af72a11) | fix: align picker calls and validate file targets |
| 2026-11-06 13:54:10 UTC | [`91391781a168`](https://github.com/GraderGamer2/NekoEdit/commit/91391781a1686d32c4dfa78fb35d782f1ba907d1) | test: exercise directory picker workflows |
| 2026-11-06 13:57:36 UTC | [`812dfae38acf`](https://github.com/GraderGamer2/NekoEdit/commit/812dfae38acf3149bb9b912adb8f887ec3b67c3a) | test: inspect picker state when opening dialog |
| 2026-11-06 13:58:43 UTC | [`5cd0be789e5e`](https://github.com/GraderGamer2/NekoEdit/commit/5cd0be789e5e343fa63d7498b8fc1b78e53dd865) | test: sample picker panel below title strip |
| 2026-11-06 14:01:16 UTC | [`d6f125574fdb`](https://github.com/GraderGamer2/NekoEdit/commit/d6f125574fdbedb6d4e39af35be6b56a3a324dd5) | test: inspect selected picker item and open state |
| 2026-11-06 14:02:27 UTC | [`df8a03feab76`](https://github.com/GraderGamer2/NekoEdit/commit/df8a03feab76368439fb52b5662a1661fb0366e8) | test: sample lit pixels in picker file glyphs |
| 2026-11-06 14:07:41 UTC | [`017a6317c920`](https://github.com/GraderGamer2/NekoEdit/commit/017a6317c92068894e00e35175d91f6db59ed4b2) | test: expose picker save-path diagnostics |
| 2026-11-06 14:08:15 UTC | [`3d04215258b0`](https://github.com/GraderGamer2/NekoEdit/commit/3d04215258b005a27011d75e9500243f8b7873ce) | test: report active path on picker save failure |
| 2026-11-06 14:09:08 UTC | [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82) | fix: reset picker double-click state on directory scan |
| 2026-11-06 14:09:21 UTC | [`f5cd03b87e1b`](https://github.com/GraderGamer2/NekoEdit/commit/f5cd03b87e1bcd9a649f008883d472b8ae8892e2) | test: verify exact picker selection after navigation |
| 2026-11-06 14:10:41 UTC | [`0dc40ca75061`](https://github.com/GraderGamer2/NekoEdit/commit/0dc40ca750610288b3dcd042519abe83336b79d5) | test: split picker diagnostics at NUL bytes |
| 2026-11-06 14:11:33 UTC | [`5f3199593694`](https://github.com/GraderGamer2/NekoEdit/commit/5f31995936943493116dc51045bf933fa9492627) | test: sample unobscured picker document glyph pixels |
| 2026-11-06 14:12:39 UTC | [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd) | fix: terminate picker target paths after filename copy |

Actions runs #199–#207 include failed intermediate attempts while the picker regression tests were being calibrated and then used to identify two real code defects. The corrected implementation was verified by [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800), which passed all eight workflow steps and uploaded the Linux x86-64 artifact. See the dated entry in [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) for the failure/correction chronology and artifact details.

## Picker milestone documentation checkpoint

| 2026-11-06 14:17:55 UTC | [`251e29029362`](https://github.com/GraderGamer2/NekoEdit/commit/251e290293623ec8f2ef4e4ec01d9d61ec267ff1) | docs: record native directory picker milestone and verification |

## Picker milestone status-snapshot maintenance

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 14:20:00 UTC | [`c9e18b744a14`](https://github.com/GraderGamer2/NekoEdit/commit/c9e18b744a14bd719a4aec838d21b596a5213062) | docs: mark native file picker as implemented |


## Empty-file Open, scrollable picker, checkbox and editable path/search fields

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 14:39:48 UTC | [`79761ed700db`](https://github.com/GraderGamer2/NekoEdit/commit/79761ed700dbc9a5bfc4064a3e5cca8e60361b1b) | test: verify Open and Save round-trip for zero-byte files |
| 2026-11-06 14:41:10 UTC | [`429eef086a9d`](https://github.com/GraderGamer2/NekoEdit/commit/429eef086a9dfb2a91eb40bd043bf539379c575c) | test: account for zero-byte fixture in nested listing |
| 2026-11-06 14:42:05 UTC | [`4cf865d21fbc`](https://github.com/GraderGamer2/NekoEdit/commit/4cf865d21fbc38f7a9563f2c67001f3d01d16d9b) | feat: add mouse-wheel scrolling and picker scrollbar |
| 2026-11-06 14:42:40 UTC | [`df575667ea47`](https://github.com/GraderGamer2/NekoEdit/commit/df575667ea4767fa98245fefcc65aff4df25bca5) | fix: zero-initialize picker scrollbar cache in BSS |
| 2026-11-06 14:43:18 UTC | [`e12bb4dc2e27`](https://github.com/GraderGamer2/NekoEdit/commit/e12bb4dc2e27dd979e9762c5c70971bf0771547f) | test: cover empty-file activation and picker mouse scrolling |
| 2026-11-06 14:43:48 UTC | [`5d8212440bd0`](https://github.com/GraderGamer2/NekoEdit/commit/5d8212440bd043342fdb623a27b67f1910bbbc6c) | fix: keep show-hidden label clickable with checkbox |
| 2026-11-06 14:44:44 UTC | [`fe3335d43b1a`](https://github.com/GraderGamer2/NekoEdit/commit/fe3335d43b1ac66878d1fb5f9174824e82f08c4f) | fix: start each picker session with hidden files disabled |
| 2026-11-06 14:44:51 UTC | [`d044efc0a867`](https://github.com/GraderGamer2/NekoEdit/commit/d044efc0a86701a3eebd9748f10a197c2d055c2c) | test: use per-session hidden-file default in picker workflows |
| 2026-11-06 14:45:44 UTC | [`4567749452b8`](https://github.com/GraderGamer2/NekoEdit/commit/4567749452b804632acc4a20b6d91f30bf071f1a) | test: restore zero-byte fixture before double-click Open |
| 2026-11-06 14:48:53 UTC | [`3eb232e3283f`](https://github.com/GraderGamer2/NekoEdit/commit/3eb232e3283ff960e7c913942f1e08467a43fda8) | test: expose pointer state for scrollbar drag diagnostics |
| 2026-11-06 14:48:58 UTC | [`f0dbce284126`](https://github.com/GraderGamer2/NekoEdit/commit/f0dbce284126f5671c9351957d4d4a1d9825d7fd) | test: diagnose scrollbar thumb press and drag state |
| 2026-11-06 14:50:00 UTC | [`72705b1518ab`](https://github.com/GraderGamer2/NekoEdit/commit/72705b1518ab4d8189eb2e6bb0a31d133bb4528f) | test: release Wayland buffer between scrollbar drag frames |
| 2026-11-06 14:52:28 UTC | [`f377fc8b589d`](https://github.com/GraderGamer2/NekoEdit/commit/f377fc8b589dd85056999324f85f54552e887242) | feat: add cursor editing and filename prefix search helpers |
| 2026-11-06 14:53:25 UTC | [`b9ed6279c693`](https://github.com/GraderGamer2/NekoEdit/commit/b9ed6279c69353af2cd339e897358f7271d13c94) | feat: make picker path and name fields cursor-editable |
| 2026-11-06 14:54:12 UTC | [`01007757a7e2`](https://github.com/GraderGamer2/NekoEdit/commit/01007757a7e234be30b3f32d232da993589df4fc) | feat: render editable path and filename search fields with carets |
| 2026-11-06 14:55:15 UTC | [`5854454963ac`](https://github.com/GraderGamer2/NekoEdit/commit/5854454963ac6f901d2b2a06e62dd05d06e087a2) | test: acknowledge scrollbar thumb release redraw |
| 2026-11-06 14:56:07 UTC | [`47e54b727421`](https://github.com/GraderGamer2/NekoEdit/commit/47e54b72742159d8df213505f73fdcbc71f58bf7) | fix: align picker selection helper stack before filename refresh |
| 2026-11-06 14:56:40 UTC | [`f48657c2c097`](https://github.com/GraderGamer2/NekoEdit/commit/f48657c2c097d5917df37e90b791e3b8ccf5a8c6) | test: cover editable path and searchable filename fields |
| 2026-11-06 14:57:16 UTC | [`347d030a5647`](https://github.com/GraderGamer2/NekoEdit/commit/347d030a5647f14a0fb8f9644c9cf0893eecba28) | fix: refresh picker path cursor after explicit navigation |
| 2026-11-06 14:57:22 UTC | [`c6fa43b22a9f`](https://github.com/GraderGamer2/NekoEdit/commit/c6fa43b22a9f0b60b9b327d0d9d1e821803d32a9) | test: inspect picker current directory after path navigation |
| 2026-11-06 14:58:07 UTC | [`9b27b4892a4f`](https://github.com/GraderGamer2/NekoEdit/commit/9b27b4892a4fad5900ccfe95c291d643512d7a8a) | test: verify filename Home End and forward Delete editing |
| 2026-11-06 14:58:36 UTC | [`89038d2ac801`](https://github.com/GraderGamer2/NekoEdit/commit/89038d2ac8017c7cedecd800529a399f68e705ca) | fix: return picker focus to list after path navigation |
| 2026-11-06 15:00:42 UTC | [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49) | test: release dragged scrollbar frame before pointer-up redraw |

Actions run #235 passed all eight workflow steps on `d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49`, including zero-byte Open via both UI routes, mouse-axis scrolling, scrollbar drag, editable path navigation and filename prefix search/cursor regression cases. See the Phase K entry in [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) for artifact and validation details.

| 2026-11-06 15:10:07 UTC | [`5e7d2d2158eb`](https://github.com/GraderGamer2/NekoEdit/commit/5e7d2d2158ebe560ab7153556e4e25672039bd3d) | test: open empty file from nonzero directory-list row |

Actions run [#241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677) passed all eight steps on this commit. The strengthened test selects `empty.txt` at row 1 between non-empty files and verifies both activation routes, the exact active path, zero document length, and the Save round-trip. Artifact ID `13513782459`, 27,216 bytes, SHA-256 `79a0a6f56a7981ad443f0adaa75c521aa3521f48310d72d272778bb425f195ed`, expires 2026-11-13. See the latest development-log entry for details.

## Editable and scrollable picker milestone documentation

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 15:04:40 UTC | [`2894e07e6511`](https://github.com/GraderGamer2/NekoEdit/commit/2894e07e65113575f57a65d3af54c22f06453b2e) | docs: record editable and scrollable file picker milestone |


## Project-history milestone maintenance

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 15:06:22 UTC | [`8ab945baaea3`](https://github.com/GraderGamer2/NekoEdit/commit/8ab945baaea3f64c8ba49d3052504d07ca96e17c) | docs: add native picker UX milestones to project history |

## Project-history index maintenance

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 15:06:34 UTC | [`dc33a7bec5a0`](https://github.com/GraderGamer2/NekoEdit/commit/dc33a7bec5a000fed2d9859fe88bc0e7a9d0b91d) | docs: index picker project-history milestone |

## Open-mode search scope and empty-file selection hardening

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 15:15:58 UTC | [`51a9b4d49166`](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66) | fix: scope file picker search to current directory |

Actions run [#243](https://github.com/GraderGamer2/NekoEdit/actions/runs/42241453789) passed all eight workflow steps on this commit. It adds a regression for stale unmatched Search text surviving a directory change, enforces selected-row-only Open when list focus is active, and preserves literal path/name opening only while Search has focus. Artifact ID `13515965431`; 27,249 bytes; SHA-256 `d5549748f2e58f95da6cc176d630c087af15efd4b7b298ce6106dce5c484c664`; expires 2026-11-13. See [DEVELOPMENT_LOG.md](DEVELOPMENT_LOG.md) for exact implementation and validation notes.

## Filename autocomplete and Wayland window-management implementation

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 15:43:07 UTC | [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519) | feat: show selectable filename autocomplete suggestions |
| 2026-11-06 15:56:15 UTC | [`f516fc1a9b31`](https://github.com/GraderGamer2/NekoEdit/commit/f516fc1a9b316aa34a6c07533948822913469f02) | feat: add Wayland window management controls |
| 2026-11-06 16:22:39 UTC | [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419) | test: release maximized buffer before window restore |
| 2026-11-06 16:27:07 UTC | [`69b63767d1bc`](https://github.com/GraderGamer2/NekoEdit/commit/69b63767d1bc3223ac9d300b3be056cc9c36c56f) | test: close parent copy of inherited Wayland socket |
| 2026-11-06 16:28:46 UTC | [`9969d027a99f`](https://github.com/GraderGamer2/NekoEdit/commit/9969d027a99f3b0a766c5b8e2620745d2c4027ae) | docs: record passing two-transport Wayland validation |
| 2026-11-06 16:46:02 UTC | [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969) | fix: wait for GNOME configure and support interactive window resize |

Actions run [#245](https://github.com/GraderGamer2/NekoEdit/actions/runs/42245683431) passed all eight steps on the autocomplete commit. Actions run [#246](https://github.com/GraderGamer2/NekoEdit/actions/runs/42247690288) passed assembly/link and CLI smoke checks for the window-management commit but failed in the mock test because it omitted the compositor release for maximized buffer 256 before Restore. Commit `93bedb579a89` adds the release event. Actions run [#247](https://github.com/GraderGamer2/NekoEdit/actions/runs/42251823911) verified the `WAYLAND_DISPLAY` path and exposed the inherited-socket test's descriptor-lifetime issue. Commit `69b63767d1bc` closes the parent's duplicate after spawn; Actions run [#248](https://github.com/GraderGamer2/NekoEdit/actions/runs/42252513357) passed the full suite through both transports and uploaded artifact `13520607975`. The GNOME-specific configure sequencing, move/resize requests, and buffer-release regression coverage are implemented in `77c8f9884e84`; Actions #251 passed and uploaded artifact `13521663942`.


## 2026-11-07 GNOME configured-geometry and picker scrollbar correction

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 17:17:28 UTC | [`f990dc0aa9b1`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7) | fix: honor configured window geometry and repair picker scrollbar |

Actions [#253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598) passed the full build and Wayland mock suite on this commit. It covers a 1920×1080 configure, exact dimensions, min/max geometry hints, clipped drawing, no-overflow scrollbar suppression, and all resize edges/corners. Artifact [`13524092766`](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598/artifacts/13524092766) was uploaded (29,780 bytes). The previous Actions #251 artifact was manually tested by the user: title-bar movement worked, but maximize still exited and interactive resizing did not take effect. Mutter retest of this correction remains pending.

## 2026-11-07 Wayland send failure and SIGPIPE diagnostics

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-06 17:48:53 UTC | [`10df996a0b51`](https://github.com/GraderGamer2/NekoEdit/commit/10df996a0b51de4b36287d4e78180b52dfd5c4ec) | debug: report failed Wayland sends without SIGPIPE termination |
| 2026-11-06 17:49:11 UTC | [`1331b49dde84`](https://github.com/GraderGamer2/NekoEdit/commit/1331b49dde8415d0d40dfb2d5326b4e0a3990b97) | fix: bound Wayland request diagnostic string length |
| 2026-11-06 17:50:46 UTC | [`2ba62dd68161`](https://github.com/GraderGamer2/NekoEdit/commit/2ba62dd681611da09673e1fffc1d81b109ac4abf) | docs: correct Wayland send helper comment |
| 2026-11-06 18:01:38 UTC | [`41b819eae69d`](https://github.com/GraderGamer2/NekoEdit/commit/41b819eae69db66c9f61f0f313027cf056965418) | debug: report preceding Wayland request and event on send failure |
| 2026-11-06 18:02:11 UTC | [`0dbf87cbb5d6`](https://github.com/GraderGamer2/NekoEdit/commit/0dbf87cbb5d659254e200dd69a41b6efc80a20a3) | style: align Wayland send diagnostic label |
| 2026-11-06 18:03:00 UTC | [`0501579b965d`](https://github.com/GraderGamer2/NekoEdit/commit/0501579b965dd65011ea5475fcc2b197d95946f9) | docs: describe preceding Wayland request and event diagnostics |

The source change routes ordinary Wayland requests through `sendto(MSG_NOSIGNAL)`, applies `MSG_NOSIGNAL` to FD-bearing `sendmsg`, and records the client object/opcode/errno when a send fails. This converts a closed-socket SIGPIPE termination into a reportable error. Actions [#261](https://github.com/GraderGamer2/NekoEdit/actions/runs/42266008250) passed all eight workflow steps on branch head `3752714507b773c2cf07293eb5f12bf85f251f1b` and uploaded artifact `13527261651` (30,146 bytes; SHA-256 `f2572c2aa95b92c80294fdb79406cddd7c5de4d5b107887a0d64fb62df643636`). Real GNOME/Mutter diagnosis remains pending; CI does not establish why the compositor closed the socket or prove that Maximize/resize work. The subsequent `wl_surface.attach` failure from the user was `object=8`, `opcode=1`, `errno=32` (`EPIPE`), showing that the compositor had already closed the socket. Commit `41b819eae69d` adds the last fully written request and last-read event to the diagnostic output; the follow-up build and real compositor retest remain pending. Actions [#270](https://github.com/GraderGamer2/NekoEdit/actions/runs/42320683568) then passed all eight steps on `f7fd732d7d2fd01b67826f2b9a43c3ef767001d0` and uploaded artifact `13552837524` (30,387 bytes; SHA-256 `b49e824bc3aba908a025286d2e54ed76c0db4e26bc338858d5f748eb1ceea9bf`). The artifact needs the user's GNOME/Mutter retest to provide the previous-request and last-event values.



## 2026-11-07 Bounded Wayland event diagnostics and output-safety regression

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 00:56:34 UTC | [`5765d1dc7dc0`](https://github.com/GraderGamer2/NekoEdit/commit/5765d1dc7dc0d1cd2f6c928b91363d0b5aa2988c) | fix: bound Wayland event diagnostic output |
| 2026-11-07 00:57:04 UTC | [`ad4ec280e31e`](https://github.com/GraderGamer2/NekoEdit/commit/ad4ec280e31e8cb653abede6edbbf7b6d5ea1a47) | test: prevent Wayland diagnostic memory disclosure |
| 2026-11-07 00:57:50 UTC | [`c2a9f0d08597`](https://github.com/GraderGamer2/NekoEdit/commit/c2a9f0d08597ed3f2d0a8a4d7ba97b62bf38af45) | fix: remove NUL bytes from Wayland diagnostics |
| 2026-11-07 00:57:57 UTC | [`2408b3e00983`](https://github.com/GraderGamer2/NekoEdit/commit/2408b3e009833d294d0f2233261a84e18e9b23e8) | test: reject NUL bytes in Wayland diagnostics |
| 2026-11-07 00:58:11 UTC | [`a85488248ecaf3`](https://github.com/GraderGamer2/NekoEdit/commit/a85488248ecaf3f4c4742e5f0cb599d79b0e6c1b) | test: check diagnostic NUL bytes without f-string escapes |

The event-label write length was corrected, the decimal writer's trailing NUL byte was removed, and a mock disconnect regression now checks that diagnostics remain bounded, NUL-free, and do not include bytes from an opened document. Actions [#278](https://github.com/GraderGamer2/NekoEdit/actions/runs/42321400180) passed all eight workflow steps on `a85488248ecaf3f4c4742e5f0cb599d79b0e6c1b` and uploaded artifact `13553546144` (30,396 bytes; SHA-256 `ca459f68e21289cb7bd7c0deb74d1f1c36c928ccf912292848ebbe32594fcb51`). The user's real GNOME retest remains pending; the regression does not claim a Mutter fix.


## 2026-11-07 One-shot resize-buffer sync barrier and compositor-error diagnosis

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 01:04:00 UTC | [`a0d226f3207b`](https://github.com/GraderGamer2/NekoEdit/commit/a0d226f3207b50b26c530fd213dc6a6eb52658ae) | debug: synchronize resize buffer creation before attach |
| 2026-11-07 01:04:16 UTC | [`1d4f7b4a16f5`](https://github.com/GraderGamer2/NekoEdit/commit/1d4f7b4a16f5e4875b04109aa30173e3a581df4b) | test: cover compositor sync before resize buffer attach |
| 2026-11-07 01:04:35 UTC | [`054deba34a0e`](https://github.com/GraderGamer2/NekoEdit/commit/054deba34a0e6c4aaeb537723275ddcc3d458a7b) | fix: defer redraws until resize buffer sync completes |
| 2026-11-07 01:05:15 UTC | [`38ca69a7aada`](https://github.com/GraderGamer2/NekoEdit/commit/38ca69a7aada044dd04ffcf36143d1156d9ab58f) | test: surface resized buffer protocol errors before attach |
| 2026-11-07 01:05:33 UTC | [`8e05def05ef7`](https://github.com/GraderGamer2/NekoEdit/commit/8e05def05ef7d7383c57d1138a0ed7dbc5cf8ee1) | test: encode mock Wayland error string correctly |
| 2026-11-07 01:06:35 UTC | [`268bc234753b`](https://github.com/GraderGamer2/NekoEdit/commit/268bc234753baa254763a49b2a19d66cd008bf53) | fix: report deferred resize attach on compositor errors |
| 2026-11-07 01:06:47 UTC | [`f8d7f84e29a5`](https://github.com/GraderGamer2/NekoEdit/commit/f8d7f84e29a56bfb07b71a02180ea66bdbfd373c) | style: centralize pending resize sync diagnostics |
| 2026-11-07 01:07:10 UTC | [`532de0397449`](https://github.com/GraderGamer2/NekoEdit/commit/532de03974493c712b02dc7aae74125ffb65d1e8) | debug: retain request and event context for protocol errors |
| 2026-11-07 01:07:17 UTC | [`20d399fc77fe`](https://github.com/GraderGamer2/NekoEdit/commit/20d399fc77fe502b75bc70a90681491b28aba3f3) | test: assert buffered Wayland error context |
| 2026-11-07 01:07:38 UTC | [`7dca6ccfe92c`](https://github.com/GraderGamer2/NekoEdit/commit/7dca6ccfe92c092bf30eb29854496998eb5b63f4) | perf: limit resize sync probe to first replacement |
| 2026-11-07 01:07:58 UTC | [`593ec1cdd82d`](https://github.com/GraderGamer2/NekoEdit/commit/593ec1cdd82dce7ae540818f6eae14ea610341d4) | test: verify sync probe is one-shot |

Actions [#290](https://github.com/GraderGamer2/NekoEdit/actions/runs/42322351170) passed all eight workflow steps and uploaded artifact `13552914100` (30,652 bytes; SHA-256 `d59b82c487e5262745e4590a9204bcb4bebe431b0f2a09a0edf841dd434b8961`). The new test proves that a simulated compositor error on replacement-buffer creation is reported before attach; the real GNOME/Mutter result remains unverified.

## 2026-11-07 Dense Wayland client object-ID allocation

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 01:20:45 UTC | [`2273306b519d`](https://github.com/GraderGamer2/NekoEdit/commit/2273306b519d2787d387d2013e7f32a416ff3a4b) | fix: allocate Wayland client object IDs densely |

Actions [#292](https://github.com/GraderGamer2/NekoEdit/actions/runs/42323572724) passed all eight workflow steps on this commit and uploaded artifact `13553938172` (30,659 bytes; SHA-256 `e51c74154c953d696d95bd7fe41fc3d82b42bbef3280b3428ec7c2d0a99ff65b`). The fix unifies pointer, keyboard, replacement-buffer, and sync-callback allocation so every new client object receives the next available dense ID. The mock suite checks the Maximize/Restore/edge-resize sequence using IDs 17, 18, 19, and 20. The GNOME/Mutter retest remains pending.

## 2026-11-07 Removal of temporary Maximize investigation instrumentation

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 01:37:56 UTC | [`82f1e15c04c8`](https://github.com/GraderGamer2/NekoEdit/commit/82f1e15c04c87d202658eb4fda0d4c406854db93) | chore: remove temporary maximize diagnostics |

Actions [#294](https://github.com/GraderGamer2/NekoEdit/actions/runs/42325108772) passed all eight workflow steps on this commit. The cleanup removes the one-shot resize sync barrier and verbose request/event tracking while retaining the dense client-object allocator and SIGPIPE-safe send handling. The mock suite now checks Maximize/Restore/interactive-resize buffer IDs 17, 18, and 19 without a sync callback. Artifact `13555196117`, 29,836 bytes, SHA-256 `c375eb07c23059a45387fae3f0c67f97ef6632713bd619a67b9591464c311ba3`, expires 2026-11-14 01:38:13 UTC. [Download Actions #294 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42325108772/artifacts/13555196117).


## 2026-11-07 Interactive edge-resize pointer handling

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 01:57:51 UTC | [`3da11acf616b`](https://github.com/GraderGamer2/NekoEdit/commit/3da11acf616b694b3b0e7d00e8595b69fa0ca582) | fix: preserve pointer focus for edge resizing |
| 2026-11-07 01:59:31 UTC | [`064af05090c4`](https://github.com/GraderGamer2/NekoEdit/commit/064af05090c455e5effe02a20bc1e1b9a9942f27) | fix: keep titlebar controls out of resize hit area |

Actions [#296](https://github.com/GraderGamer2/NekoEdit/actions/runs/42326795347) passed assembly/link and CLI smoke steps but failed the Wayland mock suite: the widened top edge intercepted the File menu click. Commit `064af05090c4` preserves the File menu/window controls while leaving the outer top-right corner available.

Actions [#297](https://github.com/GraderGamer2/NekoEdit/actions/runs/42326928833) passed all eight workflow steps on `064af05090c4`. The mock suite covers startup pointer-enter ordering, focus re-entry, all four edges and corners, optional cursor-shape feedback plus no-extension fallback, titlebar controls, and both Wayland transports. Artifact `13556041396`, 30,636 bytes, SHA-256 `da71ce6580529b1d86117c4c90e317b10f2cfb58a7c03569460259cf7f1f4501`, expires 2026-11-14 01:59:49 UTC. [Download Actions #297 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42326928833/artifacts/13556041396).

The user confirmed Maximize is fixed on the preceding #294 build. Real GNOME/Mutter drag-resize testing of the #297 artifact remains pending.


## 2026-11-07 Development after Actions #297

| Date (UTC) | Commit | Subject |
|---|---|---|
| 2026-11-07 02:02:22 UTC | [`7a011e9bc566`](https://github.com/GraderGamer2/NekoEdit/commit/7a011e9bc5668bff8e93acdc9eda34631759cfad) | docs: record interactive edge-resize fix |
| 2026-11-07 02:07:45 UTC | [`a440fd2683a8`](https://github.com/GraderGamer2/NekoEdit/commit/a440fd2683a821bf1535924b932be55b05ab58f7) | fix: marshal cursor-shape get_pointer arguments |
| 2026-11-07 02:08:53 UTC | [`fa3639898230`](https://github.com/GraderGamer2/NekoEdit/commit/fa36398982300a0d593ad34d121eb77f0b86a1bd) | docs: record cursor-shape protocol correction |
| 2026-11-07 02:15:06 UTC | [`f66fe64eb20d`](https://github.com/GraderGamer2/NekoEdit/commit/f66fe64eb20d14167d8f7f77af8d614ebf6999c7) | fix: adapt editor UI layout to window geometry |
| 2026-11-07 02:16:08 UTC | [`6eec3c4f13c2`](https://github.com/GraderGamer2/NekoEdit/commit/6eec3c4f13c2798909b64e1a166ba836cc12f9c3) | fix: zero-initialize responsive layout transform state |
| 2026-11-07 02:18:01 UTC | [`5f03a54c693f`](https://github.com/GraderGamer2/NekoEdit/commit/5f03a54c693f6b80817dc4a7d6b2afe545374082) | test: verify responsive layout and modal hit targets |
| 2026-11-07 02:18:57 UTC | [`3ae9583d34bc`](https://github.com/GraderGamer2/NekoEdit/commit/3ae9583d34bccfddfeb2d5e6e2a03f4b326186a9) | test: probe empty picker button padding |
| 2026-11-07 02:20:39 UTC | [`4a333cf636ae`](https://github.com/GraderGamer2/NekoEdit/commit/4a333cf636ae3bb29dbd1816b6b916b2174b67d6) | docs: record responsive window layout milestone |
| 2026-11-07 02:38:35 UTC | [`8af89d509003`](https://github.com/GraderGamer2/NekoEdit/commit/8af89d509003997272479ff2271542a304bdec07) | feat: grow document storage beyond 64 KiB |
| 2026-11-07 02:42:40 UTC | [`41afebc4d38b`](https://github.com/GraderGamer2/NekoEdit/commit/41afebc4d38b48fa17b695b6df174b16fccac5a9) | test: cover dynamic document growth and large-file Open |
| 2026-11-07 02:43:36 UTC | [`1e61fde65235`](https://github.com/GraderGamer2/NekoEdit/commit/1e61fde65235dd4be79ad9620c78c4170f6a11d9) | test: expose dynamic document state outside picker workflow |
| 2026-11-07 02:44:06 UTC | [`c004f00d038e`](https://github.com/GraderGamer2/NekoEdit/commit/c004f00d038ee9c5e0812f7a35967ea25e113c0a) | test: place growth cursor at document start |
| 2026-11-07 02:45:05 UTC | [`0bb96bd5a7b3`](https://github.com/GraderGamer2/NekoEdit/commit/0bb96bd5a7b327a3f35acc2d1a7267ffa2d59220) | test: update Open rollback expectation after large-file support |
| 2026-11-07 02:45:59 UTC | [`37650efa8930`](https://github.com/GraderGamer2/NekoEdit/commit/37650efa89302cf2e5484186a18b80375e7116c1) | test: report bytes on cancelled Save As regression |
| 2026-11-07 02:46:52 UTC | [`53d4b2df8d0e`](https://github.com/GraderGamer2/NekoEdit/commit/53d4b2df8d0ef8968ab12fd8fb9923e4e6caa218) | test: assert preserved document after cancelled Save As |
| 2026-11-07 02:50:43 UTC | [`aa00288aed39`](https://github.com/GraderGamer2/NekoEdit/commit/aa00288aed39e40f05e9259f01bc3290d4e91c19) | docs: record dynamic document storage milestone |
| 2026-11-07 03:11:20 UTC | [`e3489badd178`](https://github.com/GraderGamer2/NekoEdit/commit/e3489badd178d4db59c30e6660f9768f224f7e35) | feat: add editor vertical scrollbar and wheel scrolling |
| 2026-11-07 03:12:09 UTC | [`028379b66a6b`](https://github.com/GraderGamer2/NekoEdit/commit/028379b66a6bbfb0adb1d65d2c24696147258f96) | fix: zero-initialize editor scrollbar cache |
| 2026-11-07 03:13:25 UTC | [`d4c0fcc5710b`](https://github.com/GraderGamer2/NekoEdit/commit/d4c0fcc5710b0ab5ff49bc5831a3a334ecfaa01e) | test: account for editor scrollbar gutter in wrapping |
| 2026-11-07 03:23:05 UTC | [`42d6b2064891`](https://github.com/GraderGamer2/NekoEdit/commit/42d6b2064891ec50148d94572c7a1105480a3a63) | docs: record editor scrollbar milestone and desktop large-file test |
| 2026-11-07 03:23:35 UTC | [`da3ae1075f2e`](https://github.com/GraderGamer2/NekoEdit/commit/da3ae1075f2e8dc6fad15ec44292f91709d4b533) | docs: update roadmap and current status for editor scrolling |
| 2026-11-07 03:25:02 UTC | [`8dcecdc903c1`](https://github.com/GraderGamer2/NekoEdit/commit/8dcecdc903c1bebd33dea239dc0d8693038473c8) | docs: index editor scrollbar milestone and GNOME large-file verification |
| 2026-11-07 04:11:22 UTC | [`87a33b203501`](https://github.com/GraderGamer2/NekoEdit/commit/87a33b20350180f324b70ce1bff091deabef0bab) | feat: add indexed document line navigation |
| 2026-11-07 04:12:56 UTC | [`62cbcf339394`](https://github.com/GraderGamer2/NekoEdit/commit/62cbcf33939445e5563267b6ae452e845026ad23) | test: diagnose indexed pointer hit-testing regression |
| 2026-11-07 04:13:57 UTC | [`0eda4d095330`](https://github.com/GraderGamer2/NekoEdit/commit/0eda4d095330f6b2726300e34573e559631dd0d1) | test: account for multi-line index hit-test fixture |
| 2026-11-07 04:15:23 UTC | [`552d561dab6f`](https://github.com/GraderGamer2/NekoEdit/commit/552d561dab6fccdb3cbd0415ec3c1c8cd9a8afe2) | test: cover incremental index updates at caret position |
| 2026-11-07 04:16:33 UTC | [`89cc025cd3d7`](https://github.com/GraderGamer2/NekoEdit/commit/89cc025cd3d7b10b5dd97098ee7c1684cd197cfa) | test: expose index records in scrollbar regression state |
| 2026-11-07 04:17:34 UTC | [`9e0d3c8c6789`](https://github.com/GraderGamer2/NekoEdit/commit/9e0d3c8c67892b0e7a46dc5e6423f3ca3568a814) | test: report line metadata for large-file scrollbar failure |
| 2026-11-07 04:18:35 UTC | [`78db904b063f`](https://github.com/GraderGamer2/NekoEdit/commit/78db904b063fc44cda4d2eabfd84aa5954da626c) | fix: invalidate line index when opening a document |
| 2026-11-07 04:21:24 UTC | [`176abb11ec1d`](https://github.com/GraderGamer2/NekoEdit/commit/176abb11ec1d9f91f7b462e3bcb55bd945ac73b5) | docs: record indexed document navigation milestone |
| 2026-11-07 04:32:37 UTC | [`1eb5894443aa`](https://github.com/GraderGamer2/NekoEdit/commit/1eb5894443aafcccd73e2463e91e7d85787dfaf1) | feat: navigate and delete extended grapheme clusters |
| 2026-11-07 04:33:24 UTC | [`ac74062cc8a1`](https://github.com/GraderGamer2/NekoEdit/commit/ac74062cc8a19f60e9c7dd31f7e3abbae071b74a) | test: correct grapheme deletion cursor setup |
| 2026-11-07 04:34:44 UTC | [`fd8020b4fe67`](https://github.com/GraderGamer2/NekoEdit/commit/fd8020b4fe67fe056e61d69e819210b41268dd7e) | fix: keep pointer hit-testing outside CRLF graphemes |
| 2026-11-07 04:35:25 UTC | [`d7cd3f9bfed4`](https://github.com/GraderGamer2/NekoEdit/commit/d7cd3f9bfed41cdf8a359c0bb188e415a26555ca) | test: reset grapheme caret after CRLF pointer check |
| 2026-11-07 04:38:40 UTC | [`5a748eb5876d`](https://github.com/GraderGamer2/NekoEdit/commit/5a748eb5876db81d3aa46ab646b59315ff4c74b3) | docs: record Unicode grapheme editing milestone |
| 2026-11-07 04:43:51 UTC | [`1530b2f516b8`](https://github.com/GraderGamer2/NekoEdit/commit/1530b2f516b82a3f8d81f5a76e64afa908406e9e) | feat: add bounded TrueType font discovery and SFNT parsing |
| 2026-11-07 04:45:30 UTC | [`f7159a7006df`](https://github.com/GraderGamer2/NekoEdit/commit/f7159a7006dfbc052e1e6f014d76898428953366) | fix: isolate explicit TrueType loading from default discovery |
| 2026-11-07 04:46:33 UTC | [`6e1ffe44a33b`](https://github.com/GraderGamer2/NekoEdit/commit/6e1ffe44a33be552c200493d94941a67dee95869) | fix: store absolute cmap subtable offsets |
| 2026-11-07 04:49:45 UTC | [`d243bc6e757e`](https://github.com/GraderGamer2/NekoEdit/commit/d243bc6e757e583ef7aeac5ab279e285b19be0f8) | test: trace TrueType parser startup stages |
| 2026-11-07 04:50:51 UTC | [`d22e55a57f45`](https://github.com/GraderGamer2/NekoEdit/commit/d22e55a57f458d909719190b1963aa4c51a3e08b) | test: trace TrueType font file syscalls |
| 2026-11-07 04:52:17 UTC | [`43176582ea00`](https://github.com/GraderGamer2/NekoEdit/commit/43176582ea0074ed0699dd683452fdfc688bf877) | test: preserve parser state across debug trace writes |
| 2026-11-07 04:53:07 UTC | [`0febf78045fe`](https://github.com/GraderGamer2/NekoEdit/commit/0febf78045fefd2f78423c5c35886748f83b616b) | test: preserve explicit font path across trace marker |
| 2026-11-07 05:15:07 UTC | [`f0fc04847941`](https://github.com/GraderGamer2/NekoEdit/commit/f0fc04847941596dbfc394642c2af55f30e099a6) | fix: preserve explicit TrueType font path during loading |
| 2026-11-07 05:17:00 UTC | [`f92f224233de`](https://github.com/GraderGamer2/NekoEdit/commit/f92f224233dec3e51ff1459dbd9a54836d6e41b4) | test: trace bounded TrueType parser execution safely |
| 2026-11-07 05:18:06 UTC | [`33cbdbfef116`](https://github.com/GraderGamer2/NekoEdit/commit/33cbdbfef1162a4a32c3879e79be5350ca490f95) | test: trace Unicode cmap parser stages |
| 2026-11-07 05:18:57 UTC | [`2b19fda05964`](https://github.com/GraderGamer2/NekoEdit/commit/2b19fda05964ed7554d10d20a97d97a35a201173) | fix: use 32-bit cmap table offset when selecting subtable |
| 2026-11-07 05:19:32 UTC | [`255008cb5c2b`](https://github.com/GraderGamer2/NekoEdit/commit/255008cb5c2b76cc186f334c0efa7bfb8d69573d) | fix: preserve cmap encoding while resolving subtable offset |
| 2026-11-07 05:20:10 UTC | [`889343939ecf`](https://github.com/GraderGamer2/NekoEdit/commit/889343939ecf3581d3f0cdd9e8a49c8e17fc18ff) | fix: preserve table lookup flags and remove parser tracing |
| 2026-11-07 05:22:14 UTC | [`753f6366e1ac`](https://github.com/GraderGamer2/NekoEdit/commit/753f6366e1acfd7903327caf41c701693dc40445) | feat: decode bounded simple TrueType glyph outlines |
| 2026-11-07 05:22:44 UTC | [`763dd8fcba4d`](https://github.com/GraderGamer2/NekoEdit/commit/763dd8fcba4d735008c203a3be4f99b6c9f9de43) | test: decode bounded TrueType simple glyph outlines |
| 2026-11-07 05:24:36 UTC | [`0958240745b3`](https://github.com/GraderGamer2/NekoEdit/commit/0958240745b338f99637e0bb4bd4d41cc96228ca) | docs: record TrueType parser and outline decoding milestone |
| 2026-11-07 05:37:58 UTC | [`d438d9363e15`](https://github.com/GraderGamer2/NekoEdit/commit/d438d9363e15cd8b8462070b47c8fec991484adb) | feat: add save confirmation dialog and settings menu |
| 2026-11-07 05:38:21 UTC | [`b90d4e69455e`](https://github.com/GraderGamer2/NekoEdit/commit/b90d4e69455e49403aebc13b688137e4116cc636) | fix: align save dialog rendering and close settings on modal open |
| 2026-11-07 05:39:29 UTC | [`069ec3bcd104`](https://github.com/GraderGamer2/NekoEdit/commit/069ec3bcd1049b22df4e470de5643b7c3b6e464a) | test: verify settings toggle and save confirmation dialog |
| 2026-11-07 05:39:43 UTC | [`e1b52bd03b3a`](https://github.com/GraderGamer2/NekoEdit/commit/e1b52bd03b3a5a532ddaccae7f106d94e60b15f3) | test: confirm save after document growth workflow |
| 2026-11-07 05:41:22 UTC | [`1f82bf199fce`](https://github.com/GraderGamer2/NekoEdit/commit/1f82bf199fced5fa0acbded3b9c347fed81b94ff) | docs: record Settings and save confirmation requirements |
| 2026-11-07 05:42:00 UTC | [`9f2876a1d92f`](https://github.com/GraderGamer2/NekoEdit/commit/9f2876a1d92f86694f8398a8fb81db51f06e1aa0) | test: verify save dialog pointer buttons |
| 2026-11-07 05:42:35 UTC | [`a91de1c697ad`](https://github.com/GraderGamer2/NekoEdit/commit/a91de1c697adb856764cb23d7d9c2d1981249664) | test: expect pointer-confirmed save result in roundtrip |
| 2026-11-07 05:43:25 UTC | [`e036161e3a14`](https://github.com/GraderGamer2/NekoEdit/commit/e036161e3a142f827ac282c9c54f4aac98d8d924) | docs: record verified Save and Cancel pointer coverage |
| 2026-11-07 06:02:27 UTC | [`82d58862daf0`](https://github.com/GraderGamer2/NekoEdit/commit/82d58862daf0f1fd333179f087b6b2d1118a257b) | feat(font): decode bounded composite TrueType glyphs |
| 2026-11-07 06:17:28 UTC | [`981aea91931d`](https://github.com/GraderGamer2/NekoEdit/commit/981aea91931d5e73711b8e032fbec7dcfade8d60) | fix(font): use valid indexed composite frame addressing |
| 2026-11-07 06:18:16 UTC | [`d40b466aa9e0`](https://github.com/GraderGamer2/NekoEdit/commit/d40b466aa9e0a849591f68d5e5bee6d5d56c6c65) | test(font): use representable F2Dot14 anisotropic scale |
| 2026-11-07 06:19:58 UTC | [`962220271016`](https://github.com/GraderGamer2/NekoEdit/commit/962220271016f487ccfd97a5140da65cc38bc48f) | docs: record composite TrueType parser milestone |
| 2026-11-07 06:29:17 UTC | [`cd050a96586f`](https://github.com/GraderGamer2/NekoEdit/commit/cd050a96586f32e69f8caa8acc2555dd4ebbca0d) | Render TrueType outlines in the Wayland glyph path |
| 2026-11-07 06:29:37 UTC | [`21fc733389c2`](https://github.com/GraderGamer2/NekoEdit/commit/21fc733389c2246b084e94feeca2850007615d89) | Add freestanding rasterizer to the build |
| 2026-11-07 06:30:47 UTC | [`4bcb8a9d6146`](https://github.com/GraderGamer2/NekoEdit/commit/4bcb8a9d6146a614f91d22ac7f190a3946636042) | Fix rasterizer warnings under strict compilation |
| 2026-11-07 06:32:07 UTC | [`0e62d41a7b44`](https://github.com/GraderGamer2/NekoEdit/commit/0e62d41a7b4430fc99154d3c6ed5df721baabe4d) | Make framebuffer text assertions antialias-aware |
| 2026-11-07 06:34:03 UTC | [`678368bfd790`](https://github.com/GraderGamer2/NekoEdit/commit/678368bfd790b0bc77a8a07bab63956f996ef57e) | Isolate legacy UI tests and verify painted TrueType pixels |
| 2026-11-07 06:34:50 UTC | [`952ce5c56373`](https://github.com/GraderGamer2/NekoEdit/commit/952ce5c563734430ee5434f234e44625a373fb23) | Update synthetic font horizontal metric count |
| 2026-11-07 06:35:53 UTC | [`c0b7aa8e673b`](https://github.com/GraderGamer2/NekoEdit/commit/c0b7aa8e673b80445f7cc7a500e4a1cfb9ed044d) | Read raster probe symbols in the font integration test |
| 2026-11-07 06:36:49 UTC | [`61b0d415031c`](https://github.com/GraderGamer2/NekoEdit/commit/61b0d415031c14158b15ad99dd3dfc0209d452a7) | Correct TrueType curve fixture coordinate flags |
| 2026-11-07 06:40:52 UTC | [`c94a941e414c`](https://github.com/GraderGamer2/NekoEdit/commit/c94a941e414cde7b0c2d373b2c2ba5d3cf32aa96) | Document the TrueType glyph renderer milestone |
| 2026-11-07 06:54:56 UTC | [`0cc839c72181`](https://github.com/GraderGamer2/NekoEdit/commit/0cc839c72181c8ac0ec6792db01996e1ebafa8fd) | Expose TrueType horizontal advances to the text layout |
| 2026-11-07 06:55:57 UTC | [`3b566344ee8a`](https://github.com/GraderGamer2/NekoEdit/commit/3b566344ee8aaf83fa3f89f4d0ffa5ec9463771d) | Use font advances throughout document layout and hit testing |
| 2026-11-07 06:56:48 UTC | [`bc591fd2cdd6`](https://github.com/GraderGamer2/NekoEdit/commit/bc591fd2cdd60efd210c1e57c4f29bbe1ca0827f) | Skip fixed-cell click assertion in font metric fixture |
| 2026-11-07 06:57:24 UTC | [`caef46e519c4`](https://github.com/GraderGamer2/NekoEdit/commit/caef46e519c479d383be129d52b0b8f70ba4b4a3) | Fix register-width addressing in font layout calculations |
| 2026-11-07 06:59:31 UTC | [`b9d29b8684f3`](https://github.com/GraderGamer2/NekoEdit/commit/b9d29b8684f3445f1297571472663552695fa8f3) | Verify proportional glyph placement and pointer hit testing |
| 2026-11-07 07:02:11 UTC | [`7b473ec86b42`](https://github.com/GraderGamer2/NekoEdit/commit/7b473ec86b42003cb459afd2ac6d3e788acc214c) | Expose pointer coordinates in proportional-font regression |
| 2026-11-07 07:03:41 UTC | [`1a910d73aa4a`](https://github.com/GraderGamer2/NekoEdit/commit/1a910d73aa4ae59f10e864a8f578624edbb25c5e) | Instrument proportional glyph hit testing |
| 2026-11-07 07:05:11 UTC | [`37fac9be8137`](https://github.com/GraderGamer2/NekoEdit/commit/37fac9be8137daa558f6ac23b1b7cdc51b88518f) | Instrument the exact glyph-boundary comparison |
| 2026-11-07 07:05:52 UTC | [`bb3efd15cab2`](https://github.com/GraderGamer2/NekoEdit/commit/bb3efd15cab2efb01f20fb216040754818571f4f) | Report indexed pixel-width state in font hit-test regression |
| 2026-11-07 07:06:50 UTC | [`4c578f73834e`](https://github.com/GraderGamer2/NekoEdit/commit/4c578f73834eb623348cec2c29fb0aceca1f7ead) | Trace the target X register at the midpoint branch |
| 2026-11-07 07:07:21 UTC | [`226ded09bbbf`](https://github.com/GraderGamer2/NekoEdit/commit/226ded09bbbf7275ccd325d59ba970d1312fa6fe) | Assert actual pixel target at proportional hit-test comparison |
| 2026-11-07 07:08:40 UTC | [`a2ff57398138`](https://github.com/GraderGamer2/NekoEdit/commit/a2ff57398138b56bca4dd8713c931fc36c8736cc) | Preserve pointer target X across font metric helper calls |
| 2026-11-07 07:10:38 UTC | [`fd2e4793aa3d`](https://github.com/GraderGamer2/NekoEdit/commit/fd2e4793aa3d0b16920f90429c289f57eeb27a8f) | Render text selection using variable glyph advances |
| 2026-11-07 07:12:34 UTC | [`6c333c509c10`](https://github.com/GraderGamer2/NekoEdit/commit/6c333c509c10224c0efe0d7d131fd0c7cd97bb8e) | Expose drag selection endpoints in the regression failure |
| 2026-11-07 07:14:27 UTC | [`356f6aed8f22`](https://github.com/GraderGamer2/NekoEdit/commit/356f6aed8f229c4c5742e496238a8000cc10c9f6) | Include indexed logical-line spans in selection diagnostics |
| 2026-11-07 07:16:38 UTC | [`0f40c71aaf07`](https://github.com/GraderGamer2/NekoEdit/commit/0f40c71aaf07a5bb3ae63d0dba791ce057e9ddae) | Capture press-time variable-width hit-test state |
| 2026-11-07 07:19:28 UTC | [`6def829ae2df`](https://github.com/GraderGamer2/NekoEdit/commit/6def829ae2df3be496431262a678be83b13fcd93) | Expose active font state in fixed-bitmap test diagnostics |
| 2026-11-07 07:21:52 UTC | [`0f9332677cf7`](https://github.com/GraderGamer2/NekoEdit/commit/0f9332677cf77e6ceddb3e6155b146a817845cb1) | Trace variable glyph advances in pointer hit testing |
| 2026-11-07 07:22:22 UTC | [`6053341c70e3`](https://github.com/GraderGamer2/NekoEdit/commit/6053341c70e35899d51b859a57184145318877ec) | Include per-glyph pointer scan state in debug failure |
| 2026-11-07 07:25:51 UTC | [`101a0ccd3c7c`](https://github.com/GraderGamer2/NekoEdit/commit/101a0ccd3c7c6abf51363615db0e324df41412f4) | fix: preserve glyph advance during pointer hit testing |
| 2026-11-07 07:28:59 UTC | [`e575e17ae67c`](https://github.com/GraderGamer2/NekoEdit/commit/e575e17ae67cb9d9ea541aa0b2e21fbbd659da9d) | Keep hit-test target and glyph advance outside helper stack frames |
| 2026-11-07 07:29:59 UTC | [`b6d9178938cd`](https://github.com/GraderGamer2/NekoEdit/commit/b6d9178938cdb3d9d4dce6feb6b66e2dc89d716e) | test: place proportional font hit test on text row |
| 2026-11-07 07:31:37 UTC | [`404ec5791166`](https://github.com/GraderGamer2/NekoEdit/commit/404ec5791166c4acc3b5476f266a4ea7c41c6eb0) | test: align proportional hit-test row expectation |
| 2026-11-07 07:36:37 UTC | [`2c06bcec3d52`](https://github.com/GraderGamer2/NekoEdit/commit/2c06bcec3d527b450b274ec5071a97fa4e622a5c) | test: verify proportional font wrapping and indexed rows |
| 2026-11-07 07:38:19 UTC | [`b38862ca6ae7`](https://github.com/GraderGamer2/NekoEdit/commit/b38862ca6ae71f063d11b4d2628df24f11eeb3e3) | test: keep process memory open while reading line index |
| 2026-11-07 07:42:15 UTC | [`3efdcbc537a4`](https://github.com/GraderGamer2/NekoEdit/commit/3efdcbc537a4b9a63224d8b68c34d24a16fe9a8e) | fix: use font advances in picker and path prompt text |
| 2026-11-07 07:43:23 UTC | [`2ec04cfca131`](https://github.com/GraderGamer2/NekoEdit/commit/2ec04cfca1315e0942faadefa7b776721b792105) | refactor: remove obsolete fixed-column geometry |
| 2026-11-07 07:47:47 UTC | [`d067b011a918`](https://github.com/GraderGamer2/NekoEdit/commit/d067b011a918092cbeb3f39ff3fe739ee8e3fc17) | test: assert pixel-width document geometry |
| 2026-11-07 08:15:02 UTC | [`3bc0b93a9994`](https://github.com/GraderGamer2/NekoEdit/commit/3bc0b93a999402400111b75a8644307d6ece3141) | refactor: remove proportional hit-test diagnostics |
| 2026-11-07 08:19:55 UTC | [`f6d735b21549`](https://github.com/GraderGamer2/NekoEdit/commit/f6d735b215493d7a67759de2f0aa269fc66d5e21) | feat: derive document line pitch from font metrics |
| 2026-11-07 08:20:36 UTC | [`beac1f4a9622`](https://github.com/GraderGamer2/NekoEdit/commit/beac1f4a96229817bc3444fd035330d12914cd53) | fix: zero-initialize document line-height state |

The history above includes intermediate diagnostic/test commits as well as the completed window, storage, scrollbar, indexed-document, Unicode, font-parser, renderer, settings, proportional-layout, and vertical-metric work. Validation milestones include Actions [#302](https://github.com/GraderGamer2/NekoEdit/actions/runs/42328775920), [#312](https://github.com/GraderGamer2/NekoEdit/actions/runs/42330915234), [#316](https://github.com/GraderGamer2/NekoEdit/actions/runs/42333006563), [#326](https://github.com/GraderGamer2/NekoEdit/actions/runs/42337883320), [#331](https://github.com/GraderGamer2/NekoEdit/actions/runs/42339128462), [#368](https://github.com/GraderGamer2/NekoEdit/actions/runs/42347799006), [#398](https://github.com/GraderGamer2/NekoEdit/actions/runs/42354671802), and [#400](https://github.com/GraderGamer2/NekoEdit/actions/runs/42355081260). Actions #399 records the temporary `.bss` initialization failure; commit `beac1f4a9622` corrected it and #400 passed.

## Maintenance

Append every subsequent NekoEdit commit to this index as part of the same development change. Do not delete or rewrite older entries; corrections should be added as new commits and explained in the development log.