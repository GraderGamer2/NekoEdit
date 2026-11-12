## Latest handoff (2026-11-12 — Mutter key-event observation pending CI)

Continue from branch `early-alpha`. Wayland single-buffer frame pacing is implemented and its full protocol mock is green. Actions #845 passed build, command-line tests, complete Wayland mock, ELF inspection, real `us(intl)` parser, X.Org importer, and locale-pack build. The isolated IBus daemon and its D-Bus-activated portal now start successfully. Mutter's native physical-XKB Compose/dead-key/save canary and the text-input-v3 manager/focus/enable/state-commit handshake pass.

The only failed check is live IBus Simple preedit. The latest probe sends evdev `KEY_APOSTROPHE=40`, waits for Mutter's virtual-input calls to drain, then sees an empty NekoEdit preedit. The engine `xkb:us:intl:eng` is active and the portal is connected. Commits [ddbc7aa](https://github.com/GraderGamer2/NekoEdit/commit/ddbc7aa719870ff28d3ca242598e101077f9d7c6) and [618b92a](https://github.com/GraderGamer2/NekoEdit/commit/618b92a1b99eb3a115e10becd2ebd443e7ec284e) add a test-only Clutter capture observer and fix its event-counter parser. It records the actual keysym, XKB keycode, Unicode value, and modifiers as Mutter delivers the press/release, returns `Clutter.EVENT_PROPAGATE`, and never changes the input event. The probe requires both key press and release to be observed. Expected for the physical apostrophe key under `us(intl)`: XKB keycode 48 and `dead_acute` keysym `0xfe51`. Do not change the IBus preedit expectation until this event evidence is available.

No NekoEdit app source, ELF, backend, or runtime dependency is changed. Inspect the next Actions run and use the captured key event to decide whether to fix the test keymap/delivery path or investigate IBus provider/context signaling. Do not claim live IBus compatibility until the real preedit/cancellation/commit/save sequence passes.

---

## Latest handoff (2026-11-12 — evdev-based IBus preedit probe, CI pending)

Continue from `early-alpha`. Wayland single-buffer frame pacing is implemented, and the complete protocol mock is green. Actions #844 passed build/CLI, full Wayland mock, ELF inspection, real `us(intl)` parsing, X.Org importer verification, locale-pack build, IBus daemon/portal startup, physical Mutter XKB Compose/dead-key input, and text-input-v3 manager/focus/enable/state-commit. The only failing check is real IBus provider preedit/commit.

The IBus dead-key probe has tried direct `dead_acute` keysym and then apostrophe keysym; neither produced preedit. The direct dead-acute route logged `No keycode found for keyval fe51`; the apostrophe keysym avoided that warning but still produced no preedit. Commit [be5dfef](https://github.com/GraderGamer2/NekoEdit/commit/be5dfefe684a6778d41b34f927abc7352aee325f) adds a second test-bridge operation using Mutter RemoteDesktop's `NotifyKeyboardKeycode` and drives the IBus probe using Linux evdev codes `KEY_APOSTROPHE=40`, `KEY_BACKSPACE=14`, and `KEY_E=18`. This bypasses Mutter's keysym-to-keycode lookup. Ctrl+S and Enter remain on the existing keysym API. The app itself is not modified. Await and inspect the next Actions run before claiming live IBus support is verified.

---

## Latest handoff (2026-11-12 — mapped apostrophe IBus dead-key probe, CI pending)

Continue from `early-alpha`. The frame-pacing feature and complete Wayland mock remain green. Actions #843 passed build/CLI, Wayland, ELF, XKB, X.Org importer, and locale-pack stages. The headless Mutter harness now starts IBus and its D-Bus-activated portal successfully. Physical-XKB `Multi_key`, the pt_BR two-dead-key sequence, save, and text-input-v3 manager/focus/enable/state-commit all pass.

The new IBus dead-key probe still did not produce preedit because the first attempt injected keysym `0xFE51` directly. Mutter's RemoteDesktop virtual-keyboard API resolves keysyms against the active XKB map and logged `No keycode found for keyval fe51`; IBus never received the dead_acute. The latest test correction sends the ordinary apostrophe keysym (`'`), which maps to a real keycode. IBus Simple's selected `xkb:us:intl:eng` engine should convert that key to its internal dead_acute variant. It then tests Backspace cancellation and apostrophe + `e` → `é` (`C3 A9`) through real provider preedit/commit and confirmed save. Check the next Actions run before claiming the IBus path is validated. No application/backend change in this iteration.

---

## Latest handoff (2026-11-12 — IBus dead-key probe revision, CI pending)

Continue from branch `early-alpha`. Wayland frame pacing is implemented and the full Wayland mock is green. Actions #842 passed build/CLI, full Wayland mock, ELF, native XKB, X.Org importer, and locale-pack stages. Mutter physical-XKB Right Alt Compose, two-mark dead-key save, and the text-input-v3 manager/focus/enable/state-commit handshake pass. The headless IBus startup issue is now resolved too: the daemon owns `org.freedesktop.IBus`, D-Bus activation receives the isolated XDG paths and actual `IBUS_ADDRESS`, and `org.freedesktop.portal.IBus` starts and owns its name.

The remaining #842 failure was specifically no IBus Simple preedit for the test's `Multi_key` Compose sequence. IBus 1.5.29 Wayland input-method mode does not reliably inherit the compositor's XKB Compose option (upstream [ibus/ibus#2579](https://github.com/ibus/ibus/issues/2579)). The next probe/documentation commit replaces only the IBus-specific sequence with `dead_acute`, Backspace cancellation, and `dead_acute` + `e` → `é` (`C3 A9`). It still requires real provider preedit, no document mutation before commit, Backspace cancellation, exact committed UTF-8 bytes, and confirmed save. The first physical-XKB test continues to exercise `Multi_key` and locale-specific dead-key composition independently. Check the next Actions run before claiming live provider success.

---

## Latest handoff (2026-11-12 — IBus D-Bus activation environment correction pending CI)

Continue from branch `early-alpha`. The frame-pacing implementation and complete Wayland mock remain green. Actions #841 passed build, command-line, Wayland, ELF, native `us(intl)` parsing, X.Org importer, and locale-pack stages. Mutter physical XKB Compose/dead-key save and the text-input-v3 handshake passed. The live IBus Simple preedit assertion still failed.

The latest failure is not that the daemon is absent: it owns `org.freedesktop.IBus`, and `ibus engine` returns `xkb:us:intl:eng`. The separately D-Bus-activated `org.freedesktop.portal.IBus` process prints “Not connected to the ibus bus”. The test updates HOME/XDG variables after `dbus-run-session` has already launched its bus, so the activated portal inherits the bus's old environment. IBus clients resolve their socket using `IBUS_ADDRESS` or a config-directory socket file; D-Bus-activated services use the bus daemon's activation environment.

The newest correction (pending Actions) updates D-Bus activation with isolated HOME/XDG/Wayland paths, obtains the actual IBus address using `ibus address`, exports and publishes `IBUS_ADDRESS` through `dbus-update-activation-environment`, explicitly starts `org.freedesktop.portal.IBus`, and requires that portal name to be owned before GNOME Shell starts. It does not relax the real provider preedit/commit/save canary or modify the editor's runtime dependencies. Check Actions #842 (or newer) before claiming IBus coverage is complete.

---

## Latest handoff (2026-11-12 — IBus startup ordering correction pending CI)

Continue from branch `early-alpha`. The frame-pacing feature is implemented and the full Wayland mock is green. Actions #840 passed build/CLI, Wayland mock, ELF checks, native XKB validation, X.Org importer, and locale-pack build. The first Mutter leg passed real native virtual keyboard input, Right Alt Compose, two-mark dead-key composition, and save. The text-input-v3 activation handshake passed. The only remaining failed assertion is real IBus Simple preedit/commit.

Diagnosis: the test launches GNOME Shell directly under `dbus-run-session`, not a full `gnome-session` plus systemd user manager. IBus's GNOME service is normally started after `gnome-session-initialized.target` and wanted by `gnome-session.target`; neither is created in this stripped headless test. The IBus portal logs “Not connected to the ibus bus” during Shell startup. The newest test correction starts `ibus-daemon --panel disable` before GNOME Shell, after setting the isolated HOME/XDG/Wayland environment, clears inherited `IBUS_ADDRESS`/daemon PID overrides, verifies the `org.freedesktop.IBus` bus owner and `xkb:us:intl:eng` engine, then proceeds with the same live provider sequence. The daemon stays test-only and is cleaned up; no IBus dependency is added to NekoEdit. Check CI before claiming the IBus provider path is fixed.

---

## Latest handoff (2026-11-12 — maximize resize ID test correction pending CI)

Continue from branch `early-alpha`. Frame pacing is implemented in [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d): normal redraws request `wl_surface.frame`, and another commit is gated on both callback completion and `wl_buffer.release`. The standard Wayland mock has repeatedly shown 217 callbacks completing, and the dedicated release-before-callback coalescing scenario passed.

Actions #839 passed the freestanding build and command-line tests. It also passed the clipboard shortcut, context-menu, clipboard-persistence, and other prior mock scenarios. It failed only when the resize fixture expected buffer ID 18 but the application correctly allocated ID 384: the test had captured the counter before earlier interactions generated callback IDs. Commit [0f89da3](https://github.com/GraderGamer2/NekoEdit/commit/0f89da36c2ebc6b647d1a1ae2bbcb9c72b34a379) now samples the maximized buffer ID immediately before the configure/release sequence. Restore/edge/minimum-size IDs are sampled at their individual allocation points.

A new run is required before marking the Wayland mock green. Do not change the backend allocator to sparse IDs; Wayland requires dense client object IDs. The live GNOME Shell/Mutter + IBus Simple provider preedit/commit issue is still separate and unresolved; physical XKB remains the default.

---

## Latest handoff (2026-11-12 — frame pacing mock correction pending CI)

Continue from branch `early-alpha`. Feature commit [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d) implements `wl_surface.frame` pacing on the existing single SHM buffer. Another redraw requires both callback completion and `wl_buffer.release`; redraws in between are coalesced. The mock passed the callback-before-release path (217 completed callbacks in the standard run) and the focused release-before-callback scenario in Actions #838.

Actions #838 failed later because older clipboard/resize fixtures assumed fixed client object IDs. Wayland client IDs are dense, and each new frame callback consumes one. The backend's allocator is unchanged. Commits [8b966b2](https://github.com/GraderGamer2/NekoEdit/commit/8b966b20753dd33fa26cbaf1986ef874493c115b) and [00c6847](https://github.com/GraderGamer2/NekoEdit/commit/00c684780a763a6a789e27fb74ff90589afd9ff8) update clipboard/context-menu/persistence and resize fixtures to read `next_client_object_id`. The complete corrected mock has not run yet. Check the newest Actions run before making further changes or claiming success.

The live GNOME Shell/Mutter + IBus Simple preedit/commit test also remains unresolved: manager binding/focus/enable passed, but provider-originated preedit/commit did not. Physical XKB remains the default.

---

## Latest handoff (2026-11-12 — frame pacing test fixture correction)

Continue from branch `early-alpha`. The new backend feature and changelog are committed in [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d) and [c391b99](https://github.com/GraderGamer2/NekoEdit/commit/c391b9975f0577a9698acfd8b928f5aa8e0fe949). Actions #838 built the ELF and passed all command-line tests. Its Wayland mock verified 217 normal frame callbacks and passed the reverse-order release-before-callback coalescing regression. It then failed in clipboard tests because the fixtures assumed fixed source IDs and did not account for callback objects consuming client IDs.

The pending test correction reads the current `next_client_object_id` for clipboard source IDs and resize buffer IDs. Backend allocation remains dense as required by Wayland. Recheck branch HEAD and Actions before further code changes. Do not claim the full mock or overall workflow green until a subsequent run passes.

---

## Latest handoff (2026-11-12 — Wayland frame pacing, CI pending)

Continue from branch `early-alpha`. The current source commit is [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d), adding `wl_surface.frame` callback pacing to the existing single-buffer Wayland renderer. Normal redraw commits request one callback; redraws arriving before both callback completion and `wl_buffer.release` are coalesced into one later frame. The mock now covers callback-before-release and release-before-callback ordering, including a second edit while the callback is outstanding.

The source/test commit is staged in the branch history but must be fast-forwarded to `early-alpha` together with the changelog commit before validation. Build and test has not yet been run for this change. Do not report a pass until the new Actions run completes. The previous live IBus Simple test remains separately unresolved: text-input-v3 activation passed, but an actual provider-originated preedit/commit has not.

Read `CURRENT_STATUS.md`, `DEVELOPMENT_LOG.md`, `PROJECT_HISTORY.md`, and `COMMIT_INDEX.md` first, then inspect the current code/Actions run rather than relying on this handoff alone.

---

## 2026-11-12 — live IBus Simple Compose preedit/commit validation (CI pending)

Build and test [#836](https://github.com/GraderGamer2/NekoEdit/actions/runs/43115461168) passed the build, all command-line/Wayland mock tests, ELF inspection, native XKB parser, X.Org source-data verification, and locale-pack build. The live Mutter phase reached IBus Simple and text-input-v3 activation, but Ctrl+Shift+U was passed through as a literal `u` even after the private IBus daemon's environment was verified. This test-specific Unicode-entry mode is being dropped.

The replacement uses IBus Simple's standard built-in Compose table: `Multi_key`, `o`, Backspace, `o`, `c` should deliver preedit U+00B7 MIDDLE DOT → `o` → U+00B7 → `o`, keep the document empty during composition, then commit U+00A9 COPYRIGHT SIGN and save the exact UTF-8 bytes `C2 A9`. It uses no environment overrides or manually managed IBus daemon; the normal GNOME Shell session service starts IBus. This keeps the test closer to ordinary desktop input and still exercises real preedit, cancellation/correction, commit, and save through the full IBus → GNOME Shell → Mutter → NekoEdit path.

Staging commits: [b9e0933](https://github.com/GraderGamer2/NekoEdit/commit/b9e0933f951f8e343a784dda83b297fe52c4ec68) changes the probe to the Compose sequence; [95aeff4](https://github.com/GraderGamer2/NekoEdit/commit/95aeff426224b8193dd0b9d74d39363c1e6987be) removes explicit daemon startup; [c771053](https://github.com/GraderGamer2/NekoEdit/commit/c7710533a6481d05dd64c34b098eedb9ec0540a5) removes the Unicode-entry environment override; [03a5a64](https://github.com/GraderGamer2/NekoEdit/commit/03a5a64589e9c13c9428ba2ef1b2ba8f10c164b4) and [5c569df](https://github.com/GraderGamer2/NekoEdit/commit/5c569df6bcfb59d36cc04d0519016d5ce62d175d) update the detailed validation documentation. Build and test for this Compose path is pending; no live IBus preedit/commit pass is claimed yet.

---
## 2026-11-12 — switch live IBus probe to native Compose preedit (CI pending)

Build and test [#836](https://github.com/GraderGamer2/NekoEdit/actions/runs/43115461168) again passed the full freestanding build, command-line tests, Wayland mock, ELF inspection, native XKB parse, and locale-data checks. The Mutter stage still completed text-input-v3 activation, selected the real IBus Simple engine, and verified the private IBus daemon inherited `IBUS_ENABLE_CTRL_SHIFT_U=1`; nevertheless the first Ctrl+Shift+U event was forwarded as an ordinary `u`, with no preedit. The optional hex-entry path is therefore not a reliable live canary in this headless session, and I am removing that environment manipulation rather than adding more test-specific startup complexity.

The live test now uses IBus Simple's standard built-in Compose table instead: `Multi_key`, `o`, Backspace, `o`, `c` should show preedit as U+00B7, `o`, U+00B7, `o`, then commit U+00A9 COPYRIGHT SIGN. This still covers real preedit, cancellation/correction, commit, and exact save through GNOME Shell/Mutter text-input-v3, without a special IBus setting or private-daemon bootstrap. The original physical-XKB Compose/dead-key canaries remain unchanged. CI for this revised Compose sequence is pending; no live IBus pass is claimed yet.

Staging commits: [b9e0933](https://github.com/GraderGamer2/NekoEdit/commit/b9e0933f951f8e343a784dda83b297fe52c4ec68) switches the live probe to the IBus Compose sequence; [95aeff4](https://github.com/GraderGamer2/NekoEdit/commit/95aeff426224b8193dd0b9d74d39363c1e6987be) removes explicit IBus daemon/bootstrap configuration; [c771053](https://github.com/GraderGamer2/NekoEdit/commit/c7710533a6481d05dd64c34b098eedb9ec0540a5) removes the Unicode-entry environment override; [03a5a64](https://github.com/GraderGamer2/NekoEdit/commit/03a5a64589e9c13c9428ba2ef1b2ba8f10c164b4) and [5c569df](https://github.com/GraderGamer2/NekoEdit/commit/5c569df6bcfb59d36cc04d0519016d5ce62d175d) update the validation documentation.

---
## 2026-11-12 — IBus Simple live-engine bootstrap correction (CI pending)

Build and test [#835](https://github.com/GraderGamer2/NekoEdit/actions/runs/43114137743) passed every stage through the full Wayland mock, ELF inspection, native XKB parser, X.Org import verification, and locale-pack build. The GNOME Shell/Mutter integration stage still passed the physical `us(intl)` Compose and pt_BR dead-key canaries, confirmed `xkb:us:intl:eng` as the active IBus engine, and completed the text-input-v3 manager/focus/enable handshake. It then observed `doc_length=1` and empty preedit after Ctrl+Shift+U, meaning the initial `u` was forwarded as ordinary text rather than starting IBus Simple's Unicode preedit. No production application code failed or was changed by this run.

The likely test-harness issue is the environment of the IBus engine process. The follow-up now exports `IBUS_ENABLE_CTRL_SHIFT_U=1`, updates the private D-Bus activation environment, starts `ibus-daemon --panel disable` directly from that environment before GNOME Shell, and verifies the daemon inherited the flag through `/proc/<pid>/environ`. It also records the daemon log on integration failure. This keeps the setting in the ephemeral test session and does not touch application runtime behavior.

Staging commits: [b3268af](https://github.com/GraderGamer2/NekoEdit/commit/b3268af32ce62eda43d4c3da6affb3bc35a1c228) starts the private IBus daemon and updates the activation environment; [f28ff31](https://github.com/GraderGamer2/NekoEdit/commit/f28ff314418e67e786a1e9463ddf498701d56662) asserts the daemon environment. The corrected follow-up requires one Build and test run; no pass is claimed yet.

---
## 2026-11-12 — live IBus Simple preedit/commit integration (CI pending)

The Mutter test's second phase now switches the isolated GNOME input source to IBus Simple's `xkb:us:intl:eng` engine while preserving the `us(intl)` keyboard layout. The harness enables IBus Simple's documented Ctrl+Shift+U path in its private test environment and verifies the actual active IBus engine before launching NekoEdit with text-input-v3 explicitly enabled.

The probe reads the application's existing preedit and document-length state through its direct parent `/proc/<pid>/mem` access. It expects the real IBus sequence `u`, `u1`, `u1F`, `u1F6`, `u1F60`, `u1F600`; Backspace must return the preedit to `u1F60` without changing document bytes. Return must commit U+1F600 through GNOME Shell/Mutter text-input-v3, clear preedit, and save exactly `F0 9F 98 80` after the existing save-confirmation prompt.

This is test-only integration coverage. It adds no editor runtime dependency and changes no default input behavior. Fcitx and provider-originated delete-surrounding remain outside this live test; delete-surrounding, UTF-8 boundaries, and malformed events remain covered by the Wayland mock. The default physical-XKB path stays unchanged.

Staging commits: [9fb3ce1](https://github.com/GraderGamer2/NekoEdit/commit/9fb3ce1023c70306978e4b662eba5705e1d45c3f) adds live IBus preedit/commit assertions; [f1fcc39](https://github.com/GraderGamer2/NekoEdit/commit/f1fcc39b536a49141af31e2bd08e6e1de3e9773c) adds the preedit buffer to the symbol map; [e24bbda](https://github.com/GraderGamer2/NekoEdit/commit/e24bbda13314dc218cc9a83dd47a001cdce5e1a6) switches the Mutter second phase to IBus Simple. These changes still need one fast-forward to `early-alpha` and one normal Build and test run. CI is not yet claimed.

---
## 2026-11-12 — test opt-in fallback when text-input-v3 is not advertised — Build and test #834 passed

Added a Wayland-mock scenario that launches NekoEdit with `NEKOEDIT_ENABLE_TEXT_INPUT=1` while deliberately omitting `zwp_text_input_manager_v3` from the compositor registry. The test requires manager/object/enter/enable/serial/state-ready fields to remain zero, then runs the complete real-keymap keyboard-layout editing and confirmed-save sequence. It checks that the opt-in cannot suppress the normal XKB path when the compositor does not provide text-input-v3.

Commits: [799f57a](https://github.com/GraderGamer2/NekoEdit/commit/799f57ac2a10e3b4824cedba07f97d06ba3594c3) adds the opt-in no-global scenario; [54a0dae](https://github.com/GraderGamer2/NekoEdit/commit/54a0daea94238e63e988bf2dea08c4a77746ebb5) corrects its exact expected UTF-8 output bytes. Build and test [#834](https://github.com/GraderGamer2/NekoEdit/actions/runs/43105116760) passed all 14 steps. The Wayland log explicitly records that all seven text-input state fields remained inactive while the real `us(intl)` keymap, XKB translation, editing, and save assertions completed.

Artifact: editor [13893597286](https://github.com/GraderGamer2/NekoEdit/actions/runs/43105116760/artifacts/13893597286), 137,017 bytes; separate Compose locale packs [13894166119](https://github.com/GraderGamer2/NekoEdit/actions/runs/43105116760/artifacts/13894166119), 120,536 bytes.

---
## 2026-11-12 — live Mutter text-input-v3 activation — Build and test #833 passed

Build and test [#833](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452) passed all 14 workflow steps on source commit [38d44ff](https://github.com/GraderGamer2/NekoEdit/commit/38d44ff7b3729b449ee784c7d32713dd3efb7034). The Mutter 46.2 headless session actually advertised `zwp_text_input_manager_v3`; the second NekoEdit process, started with `NEKOEDIT_ENABLE_TEXT_INPUT=1`, bound the manager, received text-input `enter`, enabled its focused document, and committed text-input state. The original real Mutter input test also passed ordinary edit/save, Right Alt `Multi_key` → U+2026, and the pt_BR two-dead-key chain → U+1EA6.

The Wayland mock independently verifies incoming preedit UTF-8/cursor-byte-offset, commit, delete-surrounding, and serial handling. This CI result validates the live compositor/client activation handshake, not an external IBus/Fcitx provider's actual preedit/commit exchange. The default remains physical XKB; `NEKOEDIT_ENABLE_TEXT_INPUT=1` remains explicit opt-in.

Artifacts: editor [13892773320](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452/artifacts/13892773320), 137,017 bytes; separate Compose locale packs [13892008409](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452/artifacts/13892008409), 120,536 bytes. Both were uploaded successfully.

---
## 2026-11-12 — capability-aware live text-input-v3 probe

Added a second, isolated NekoEdit process to the GNOME Shell/Mutter integration smoke test. The original `us(intl)`/`compose:ralt` editor run remains unchanged: it still verifies ordinary edit/save, Right Alt `Multi_key`, and the pt_BR two-dead-key result `…Ầ`. After that process exits, a second instance starts with `NEKOEDIT_ENABLE_TEXT_INPUT=1`, is activated and clicked through Mutter's native virtual input path, and is inspected by a test-only Python parent process.

The probe resolves the non-PIE ELF symbol addresses with `nm` and reads only the child process's text-input state through `/proc/<pid>/mem`. This avoids adding diagnostic hooks, logging code, or dependencies to the application. It branches on the actual `zwp_text_input_manager_v3` registry result:
- When the compositor advertises the manager, require manager binding, a text-input focus `enter`, document `enable`, and at least one committed state update.
- When the manager is absent, require all text-input objects to remain inactive and verify normal Wayland/XKB typing plus the confirmed save path still work with the opt-in variable set.

This is a compositor/client activation test, not a full IME-provider test. It does not synthesize IBus/Fcitx preedit, commit, or delete-surrounding events. The existing Wayland mock remains the deterministic test for those incoming protocol events and UTF-8/serial edge cases. Text-input-v3 remains opt-in; do not enable it by default on the basis of this handshake alone.

Also corrected `docs/ARCHITECTURE.md` and the README's implementation description: NekoEdit is intentionally hybrid Assembly/C. Its dependency boundary is freestanding compilation, direct Linux syscalls, a single static ELF, and no C runtime or third-party runtime shared libraries—not a ban on C itself. The production C modules are rasterization, clipboard, Compose locale handling, history, and preferences.

The eight-file source/test/documentation change was fast-forwarded to `early-alpha` at [38d44ff](https://github.com/GraderGamer2/NekoEdit/commit/38d44ff7b3729b449ee784c7d32713dd3efb7034). Build and test [#833](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452) passed all 14 workflow steps and verified the Mutter 46 live text-input-v3 activation handshake. An external IBus/Fcitx provider exchange remains outside this test.

## 2026-11-11 — extend optional Compose dead-key chains to seven marks — Build and test #832 passed

The optional locale-pack format is advancing to NLP1 version 2: records grow from 52 to 68 bytes and carry eight input scalars. The runtime retains version-1 compatibility, including typed v1 dead-key records. Multi_key remains capped at four input scalars; v2 dead-key rules accept seven combining marks followed by the final base scalar.

The limit is carried consistently through the standard pack generator, pinned X.Org importer, offline user .XCompose converter, native Settings importer, freestanding validation/lookup, and Wayland document-input state. The editor buffers seven marks, queries the complete eight-scalar locale rule, preserves unmatched input literally, and flushes the previous seven marks only when an eighth consecutive dead action arrives. Multi_key continues to use its separate four-input state.

Regression coverage includes v2 eight-scalar serialization and bounds, pinned/user/native importer fixtures, freestanding manager lookup, an explicitly constructed v1 pack with both Multi_key and typed dead-key records, and physical Wayland mock events for seven-mark success and eight-action overflow. The four generated JSON datasets retain exactly the same rule sequences and record counts; only importer diagnostics change for 132 malformed en_US dead-key lines, now categorized as unsupported intermediate events instead of over-limit sequences. The regenerated unsupported_input counts are 1,061 (pt_BR), 1,063 (fi_FI), 1,061 (sr_RS), and 1,072 (el_GR), with too_long now zero. en_US remains the only embedded Compose dataset and optional locales remain separate data-only packs.

Commits: [bfa833f](https://github.com/GraderGamer2/NekoEdit/commit/bfa833f41448d46343f68ad77a045b4e7d3dc949) implements the v2 seven-mark chain path; [1b5b7e6](https://github.com/GraderGamer2/NekoEdit/commit/1b5b7e69f5117875aab444b3a25131b646ebd31f) corrects the namespace-isolation regression assertion; [2d43183](https://github.com/GraderGamer2/NekoEdit/commit/2d43183d6736cfddf93f5d960780b5eb24f1f0f5) refreshes only the four locale JSON diagnostic counters. Build and test [#832](https://github.com/GraderGamer2/NekoEdit/actions/runs/43027835505) passed all workflow steps on the final early-alpha data head. The run validated the freestanding build, all command-line/host tests, the complete Wayland mock (including seven-mark resolution and eight-action overflow), ELF inspection, the real libxkbcommon us(intl)/compose:ralt keymap, byte-for-byte regeneration of all four locale JSON datasets, separate locale-pack builds, and the nested GNOME Shell/Mutter integration test. Both artifacts uploaded successfully: editor [13858886635](https://github.com/GraderGamer2/NekoEdit/actions/runs/43027835505/artifacts/13858886635), 137,017 bytes; locale packs [13859156429](https://github.com/GraderGamer2/NekoEdit/actions/runs/43027835505/artifacts/13859156429), 120,536-byte ZIP. Both expire 2026-11-12 13:19 UTC / 20:19 Jakarta.


## 2026-11-11 — preserve canonical XKB key names alongside aliases

Actions #827 and #828 passed the freestanding build, CLI tests, Wayland mock, and ELF inspection, but the native libxkbcommon `us(intl)` parser test failed at the end of `xkb_symbols`. The #828 diagnostics identified the root cause: XKB keycodes define canonical names first (for example `<AD01> = 24`) and later define aliases (for example `alias <LatQ> = <AD01>`). NekoEdit stored only one name per keycode and overwrote the canonical name with each alias. The symbols section still refers to the canonical name, so those key blocks were skipped; the same happened to `RALT` when `ALGR` was recorded.

The parser now keeps the original canonical name in `xkb_key_names` and stores aliases in a bounded 256-entry name-to-keycode table. Lookup checks canonical names first and then aliases. Repeated aliases to the same keycode are harmless; conflicting names or table overflow fail closed. No safety thresholds were changed.

Regression coverage adds LatQ/LatA/LatZ/ALGR aliases to the synthetic Wayland keymap, routes one symbol block through LatW, verifies the canonical names remain intact, and checks the alias count. The native `us(intl)` probe now asserts canonical AD01/AC01/AB01/RALT names and retained aliases before comparing real keysyms. Build and test #829 will validate the full map, Compose/dead-key positions, and then the later X.Org/Mutter workflow steps.


## 2026-11-11 — trace missing XKB key blocks after Actions #827

Actions #827 passed the freestanding build, CLI tests, full Wayland mock, and ELF inspection. The native libxkbcommon `us(intl)` test still rejected the keymap at the end of `xkb_symbols`: 84 canonical Unicode cells were populated, but zero alphabetic pairs were found. The first eight populated cells were number-row keycodes 10 and 11, confirming the table-wide counter was not the remaining fault.

This diagnostic-only change preserves five targeted records before parser reset: keycodes 10/AE01, 24/AD01, 38/AC01, 52/AB01, and 108/RALT. For each it captures the parsed four-byte key name, Group1 symbol count, and first two canonical Unicode cells. The next native run will separate a keycodes-name lookup problem from symbols-section key-block parsing. No parser thresholds or acceptance behavior are changed.

Right Alt dispatch is now keymap-aware in the source, and both focused Right Alt Wayland scenarios and the complete mock pass in #827. The real `compose:ralt` keymap remains unvalidated until the native parser accepts it.

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
