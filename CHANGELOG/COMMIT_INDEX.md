# NekoEdit complete commit index

This is the commit-level audit trail reconstructed from GitHub on **2026-11-06**. It includes the original 20 commits on `main`, all 169 implementation-history commits on the development branch originally named `feat/wayland-socket-error-handling` and later renamed to `early-alpha` through the fixed-capacity gap-buffer milestone, six changelog bootstrap commits, and the separate changelog installation on `main`.

- Repository: [GraderGamer2/NekoEdit](https://github.com/GraderGamer2/NekoEdit)
- Current review PR: [#2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2) (early-alpha → main; open, unmerged).
- Historical implementation PR: [#1 — feat: add Wayland editing and initial editor UI](https://github.com/GraderGamer2/NekoEdit/pull/1) (closed, unmerged).
- Recorded commits: **217** (20 original main prototype + 169 PR #1 implementation-history commits + 6 changelog bootstrap commits + 1 initial main changelog installation + 5 post-bootstrap documentation/synchronization commits + 2 branch-rename documentation commits + 4 follow-up branch-rename index/status commits + 2 PR #2 status documentation commits + 2 PR #2 index/log commits + 2 previously unindexed PR #2 index commits + 2 XKB ONE_LEVEL implementation/test commits + 1 XKB status/log documentation commit + 1 ancestry synchronization merge commit).
- Dates are commit-author timestamps in UTC.
- This index records commit subjects, including intermediate tests, debugging, documentation, fixes, and reverts. The milestone narrative in [PROJECT_HISTORY.md](PROJECT_HISTORY.md) explains the functional changes.

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
## Maintenance

Append every subsequent NekoEdit commit to this index as part of the same development change. Do not delete or rewrite older entries; corrections should be added as new commits and explained in the development log.