## 2026-11-13 — track compositor-preferred surface scale and transform (CI pending)

Bind `wl_compositor` at up to v6 instead of unconditionally at v1. This gives the created `wl_surface` the version-6 `preferred_buffer_scale` and `preferred_buffer_transform` events while preserving v1 behavior on older compositors. Track both preferences on the surface, defaulting to scale 1 and normal transform; validate positive scale values and the transform enum. The output integration mock exercises the compositor preference independently of per-output scale transactions.

This is selection metadata only: no buffer-scale request or pixel-dimension change is made. Logical/physical renderer separation and a correctly enlarged backing store must precede `wl_surface.set_buffer_scale`. CI is pending.

## 2026-11-13 — Wayland output discovery, atomic scale cache and hotplug (CI PASS #867)

Actions [Build and test #867](https://github.com/GraderGamer2/NekoEdit/actions/runs/43227267710) passed all 15 steps. The Wayland mock verified v3/v2 output discovery, per-output scale changes committed only on `wl_output.done`, multi-output surface membership, v3 release vs v2 local proxy discard, hot-add with a fresh contiguous client ID, surface leave, and scale-cache recomputation. The nested GNOME Shell 46 / Mutter 46 integration job also completed successfully. No high-DPI rendering claim is made: the output cache remains metadata-only and the buffer is still scale 1.

## 2026-11-12 — CI #866 stopped on a duplicated test assertion line (fixed; CI PASS #867)

Actions [Build and test #866](https://github.com/GraderGamer2/NekoEdit/actions/runs/43226811420) passed the freestanding assembly/C build, ELF inspection, and command-line test set. The Wayland suite did not start because a scripted block move duplicated the `memfd+SCM_RIGHTS buffer verified` observation on one Python source line, producing a SyntaxError. The duplicate line was removed in commit [8365b7d](https://github.com/GraderGamer2/NekoEdit/commit/8365b7d9abc6e654efb38c0a0fad741016feacc1). Actions [Build and test #867](https://github.com/GraderGamer2/NekoEdit/actions/runs/43227267710) then passed the corrected Wayland mock and the complete GNOME Shell/Mutter integration job.

## 2026-11-12 — enforce contiguous client IDs before Wayland output binding (CI PASS #867)

Reorder startup so output proxies are bound only after fixed objects 8–14 and any optional input-service objects have been allocated. Defer the first shared-buffer attach/damage/commit until after those output bindings; the no-seat path uses the next free ID after the initial window/shm objects. Registry announcements are still captured in both startup roundtrips, but object creation is deferred until the allocator can issue contiguous new IDs. This directly addresses Mutter's `wl_registry.bind` rejection from #865.

The output cache now stages each positive v2+ `wl_output.scale` value and publishes it only when that output's `wl_output.done` arrives. The mock checks independent pending/committed values for a v3 and v2 output, then repeats the transaction for a hot-added output. It still verifies version-gated release, surface membership, and scale-summary recomputation. Output scale remains metadata only; the active framebuffer is still scale 1. This startup reorder and the complete output suite passed in Actions #867.

## 2026-11-12 — CI #865 output mock passed; Mutter exposed non-contiguous new_id startup ordering

Actions [Build and test #865](https://github.com/GraderGamer2/NekoEdit/actions/runs/43224109434) passed build, command-line checks, the full Wayland protocol mock, ELF/XKB verification, Compose importer and locale-pack checks. The new output mock verified two output versions/scales, per-surface enter/leave membership, v2/v3 removal semantics, and hot-added output binding. The final nested GNOME Shell/Mutter test then rejected `wl_registry.bind(new_id=15)`: the client had not yet created its hard-coded surface/toplevel/shared-memory objects 8–12 and seat/sync objects 13–14. The previous mock accepted this invalid object-ID gap, so it missed the real libwayland object-map constraint.

The correction reserves output client IDs only after the fixed surface/toplevel/shm and seat bootstrap IDs, pointer/keyboard objects, and optional cursor/clipboard/text-input objects have been allocated. The initial buffer attach/map is delayed until these output bindings complete. This preserves the monotonic allocator and keeps surface.enter events associated with already-bound output objects.

## 2026-11-12 — route startup and steady-state Wayland output events (CI PASS #867)

Actions [Build and test #864](https://github.com/GraderGamer2/NekoEdit/actions/runs/43223717648) passed the freestanding build and all existing Wayland scenarios, then the new output mock reported that `wl_output.scale` remained at its default value. The output handlers were present, but three pre-existing conditional branches still jumped past them: the initial display event path, the initial seat roundtrip, and the steady-state seat-event path. Update those branch targets so registry events and output/surface events actually reach their handlers. The failure was in event routing, not output parsing or object binding. The corrected dispatch routes the initial registry events, initial seat roundtrip and steady-state output/surface events; the complete regression passed in #867.

---

## 2026-11-12 — Wayland output discovery and integer-scale metadata (CI PASS #867)

Add a bounded cache for up to eight `wl_output` globals. The client binds outputs at no more than protocol version 3, records each output's negotiated version and integer scale (default 1), tracks which outputs the Wayland surface enters/leaves, and handles registry global removal. It sends `wl_output.release` only for v3 resources; v1/v2 outputs are dropped locally. New output announcements reuse free cache slots but receive fresh IDs from the monotonic client-object allocator. The cache reports the entered-output count and maximum scale as metadata.

The client still renders into the existing scale-1 shared buffer. It does not yet apply `wl_surface.set_buffer_scale`, use preferred/fractional scale or viewporter protocols, or translate logical dimensions to physical buffer dimensions. Those require separating logical layout/hit-testing from pixel geometry and keeping buffer replacement release-safe. The mock adds two outputs at different scales, surface enter/leave, v2/v3 removal semantics, atomic `scale`/`done` updates, and a hot-added output. Actions #867 passed the mock plus nested GNOME Shell 46 / Mutter 46 integration.

---

## 2026-11-12 — correct combined cursor-shape/text-input test object IDs (verified in CI #863)

Build and test [#862](https://github.com/GraderGamer2/NekoEdit/actions/runs/43216141990) passed the freestanding build and CLI tests, then reached the new active-IME hotplug scenario. The mock expected the text-input manager to use object 17, which is valid when cursor-shape support is absent, but the combined scenario advertises cursor-shape support and therefore allocates manager/device IDs 17/18 first. Text-input setup correctly uses 19/20. The mock now derives the text-input IDs from the advertised optional globals, and the preedit-clear pixel assertion now checks that the IME highlight color is absent after keyboard removal rather than merely checking for background-colored pixels. No backend runtime code changed.

## 2026-11-12 — test keyboard removal while text-input-v3 preedit is active (CI PASS #863)

Add a dedicated opt-in mock scenario in which the compositor focuses the editor, enables text-input-v3, sends a visible preedit string, and then removes the keyboard capability. The mock requires the text-input disable request and its state commit, verifies the transient preedit/cursor state clears without inserting those bytes into the document, and checks the immediate redraw when the shared buffer and frame callback are idle. Existing tests continue to verify that text-input-v3 remains default-off and that ordinary XKB typing works when the manager is advertised but not opted in. Actions [Build and test #863](https://github.com/GraderGamer2/NekoEdit/actions/runs/43216928301) passed all 15 steps. Its Wayland mock explicitly verified that keyboard removal sends text-input disable+commit, clears the visible preedit without modifying document bytes, and submits the immediate repaint.

## 2026-11-12 — assert seat redraw through the mock callback interceptor (CI PASS #861)

Build and test [#860](https://github.com/GraderGamer2/NekoEdit/actions/runs/43211045584) passed the complete set of existing Wayland cases and reached the new seat-hotplug case. Its failure was in the new test expectation: the mock's `recv_wayland_message()` intentionally consumes `wl_surface.frame` requests, tracks callback IDs/counters, and acknowledges them after the matching surface commit. Therefore `expect_message()` cannot observe opcode 3; it sees the following buffer attach instead.

Correct the hotplug assertion to verify the attach/damage/commit sequence and independently assert that the callback interceptor recorded exactly one new callback ID (19), then delivered its completion. Actions [Build and test #861](https://github.com/GraderGamer2/NekoEdit/actions/runs/43213761614) passed all 15 workflow steps, including both seat-v2 and seat-v4 removal/re-addition scenarios, the complete Wayland mock, nested GNOME Shell/Mutter integration, and both artifact uploads.

---

## 2026-11-12 — widen bounded Wayland mock process timeout (verified in CI #861)

Build and test [#859](https://github.com/GraderGamer2/NekoEdit/actions/runs/43210190052) passed the freestanding build, ELF check, and command-line tests but timed out in the very first general Wayland mock scenario, before the hotplug-specific cases ran. It emitted no application error or fake-compositor assertion. The same initial smoke scenario took 19.1 seconds in the prior passing run #858, while the harness allowed only 20 seconds for ordinary child processes.

Raise the ordinary per-child `communicate()` deadline to 30 seconds, retaining 90 seconds for the longer picker/settings workflows. The mock compositor still uses its shorter socket read deadlines, so a protocol mismatch does not inherit the larger process timeout. No application runtime behavior changes in this test-harness correction. The 30-second ordinary child deadline completed the full test set successfully in #861.

---

## 2026-11-12 — flush idle-buffer redraws after seat hotplug (CI PASS #861)

Follow-up to [hotplug implementation](https://github.com/GraderGamer2/NekoEdit/commit/bbb9ce3627b48773659711e4a1af8cf3f128ddb3): the seat-event path now submits a pending redraw immediately when the single shared buffer is released and no frame callback is outstanding. When either gate remains busy, the existing buffer-release/frame-done sequencing still performs the deferred presentation. This prevents an IME-preedit clear or other keyboard-removal state reset from remaining visually stale until an unrelated later event.

The hotplug mock now drains the initial buffer, confirms the frame gate is idle, removes the keyboard, and asserts the immediate `wl_surface.frame` / attach / damage / commit sequence plus the resulting busy/callback/redraw state. Because that presentation consumes the next client object ID, the subsequent keyboard, pointer, and cursor-shape re-add assertions are updated. This behavior passed both hotplug cases in #861.

---

## 2026-11-12 — Wayland seat capability hotplug lifecycle (CI PASS #861)

The Wayland backend now treats each `wl_seat.capabilities` event as a complete state transition instead of only creating input objects once. Removing pointer capability clears focus/serial and active pointer/scroll drag state, stops selection auto-scroll, destroys the cursor-shape device tied to that pointer, and abandons the old pointer proxy. Removing keyboard capability cancels key repeat, clears held modifier/lock state and pending dead-key/Compose prefixes, abandons the old keyboard proxy, and disables optional text-input-v3 so stale preedit cannot survive unplug.

For `wl_seat` versions 3–4, the backend sends `wl_pointer.release` / `wl_keyboard.release` before forgetting the proxies. Versions 1–2 do not define those requests; the client drops the local proxies without sending unsupported opcodes and uses new monotonically allocated object IDs if the capability returns. The cursor-shape manager remains bound while its device is destroyed and recreated against each replacement pointer.

The Wayland mock adds dedicated hotplug scenarios for both version families. It verifies remove/re-add of keyboard and pointer, expected release/no-release behavior, fresh object IDs, cursor-shape device recreation, use of the replacement pointer's enter serial, and clearing of keyboard focus/modifier masks. The source and test changes are committed to `early-alpha`; CI is pending and no passing run is claimed yet.

---

## 2026-11-12 — live IBus preedit, cancellation, commit, and save verified (CI PASS)

Actions [Build and test #856](https://github.com/GraderGamer2/NekoEdit/actions/runs/43182358544) completed successfully. All 15 workflow steps passed: freestanding x86-64 build and ELF verification, CLI smoke tests, the complete Wayland protocol mock, executable inspection, real `us(intl)` keymap validation, X.Org importer verification, locale-pack build, nested GNOME Shell/Mutter integration, and both artifact uploads.

The native Mutter virtual keyboard canary also passed: Right Alt `Multi_key`, the two-mark dead-key chain, and confirmed Ctrl+S save preserved exactly U+2026 U+1EA6 (`…Ầ`). The live IBus Simple phase passed end to end through GNOME Shell, Mutter 46.2, and NekoEdit's optional text-input-v3 client: the physical apostrophe generated a visible `dead_acute` preedit; Backspace cancelled it without changing document bytes; a fresh apostrophe followed by `e` committed U+00E9 (`é`); and the normal Ctrl+S / Enter confirmation saved the exact UTF-8 bytes `C3 A9`.

This validates the narrowly gated Mutter 46.0–46.2 compatibility cases: a multibyte preedit's legacy character-index anchor is converted only when it resolves to the same validated cursor byte offset, and the nullable empty-preedit `(0, 1)` anchor is normalized to `(0, 0)`. The mock tests both cases while keeping unrelated malformed UTF-8 boundaries rejected. No IBus, D-Bus, GNOME, or other runtime dependency was added to NekoEdit.

Artifacts from #856: [Linux x86-64 executable](https://github.com/GraderGamer2/NekoEdit/actions/runs/43182358544/artifacts/13927605875) and [Compose locale packs](https://github.com/GraderGamer2/NekoEdit/actions/runs/43182358544/artifacts/13927775229). Both are configured with one-day retention.

---










## 2026-11-12 — inject physical evdev keycodes for the live IBus preedit probe (CI pending)

Actions [Build and test #844](https://github.com/GraderGamer2/NekoEdit/actions/runs/43151433375) passed the freestanding build/ELF check, CLI tests, complete Wayland mock (including both frame-callback/release orders), ELF inspection, native `us(intl)` parser, X.Org importer, and locale-pack build. The headless IBus daemon and D-Bus-activated portal also started successfully; Mutter's original physical-XKB Compose/dead-key sequence and the text-input-v3 manager/focus/enable/state-commit handshake passed. The live IBus Simple preedit assertion still failed: the apostrophe keysym produced no provider preedit, even though the earlier `dead_acute` keysym had been rejected by Mutter's reverse mapping.

The keysym route is still not a reliable way to test a physical-layout engine: Mutter's `NotifyKeyboardKeysym` resolves a keysym back to a hardware keycode using the compositor's current group. The revised test bridge exposes Mutter's separate `NotifyKeyboardKeycode` method, documented as taking an evdev keycode, and the IBus probe now sends actual Linux keycodes: `KEY_APOSTROPHE=40`, `KEY_BACKSPACE=14`, and `KEY_E=18`. This bypasses the reverse keysym lookup and makes the test sequence correspond to physical key events delivered to the selected `xkb:us:intl:eng` engine. The original keysym route remains for Ctrl+S and Enter, which already work in the first Mutter canary.

Feature/test commit: [be5dfef](https://github.com/GraderGamer2/NekoEdit/commit/be5dfefe684a6778d41b34f927abc7352aee325f). This changes only the Mutter integration extension, Python test probe, and test documentation; the editor's ELF, backend, and runtime dependencies are unchanged. A new Actions run is required. No live IBus preedit/commit pass is claimed yet.

---

## 2026-11-12 — send a mapped apostrophe key into the IBus dead-key engine (CI pending)

Actions [Build and test #843](https://github.com/GraderGamer2/NekoEdit/actions/runs/43150721562) passed the freestanding build/ELF check, command-line tests, the full Wayland mock (including frame callback ordering), executable inspection, native `us(intl)` parsing, X.Org importer verification, and locale-pack build. The daemon/portal startup also succeeded in Mutter, and the original physical-XKB `Multi_key` + pt_BR dead-key save canary passed. The text-input-v3 handshake passed.

The IBus dead-key probe then reported no preedit. Mutter's log supplied the decisive clue: `No keycode found for keyval fe51 in current group` (twice). The native RemoteDesktop virtual-keyboard API resolves an injected keysym against the active Mutter keymap; `dead_acute` is not a directly mappable keyval in that map, so Mutter discarded it before IBus saw it. The updated probe sends the ordinary apostrophe keysym instead. This key exists in the active map, and the selected `xkb:us:intl:eng` IBus Simple engine translates it to its internal `dead_acute` sequence. The revised scenario still requires provider-owned preedit, Backspace cancellation without document mutation, apostrophe + `e` committing U+00E9 (`C3 A9`), and an exact confirmed save.

This keeps physical-XKB Compose and IBus dead-key coverage distinct. The D-Bus/IBus portal setup from [f2ee759](https://github.com/GraderGamer2/NekoEdit/commit/f2ee7595da3c32c3d690d7af998080d323451737) remains in place; application code and runtime dependencies are unchanged. The revised live test is pending CI; no IBus provider pass is claimed yet.

---

## 2026-11-12 — use the IBus Simple dead-key path for live text-input-v3 validation (CI pending)

Actions [Build and test #842](https://github.com/GraderGamer2/NekoEdit/actions/runs/43149228354) passed the freestanding build, command-line tests, full Wayland protocol mock, ELF inspection, native `us(intl)` parser, X.Org importer verification, and locale-pack build. The Mutter test also verified that the isolated IBus daemon owns its bus name and that the separately activated `org.freedesktop.portal.IBus` service starts successfully before GNOME Shell. Physical-XKB Right Alt Compose, the pt_BR dead-key chain, save, and the text-input-v3 manager/focus/enable/state-commit handshake all pass. The remaining failure is provider preedit for an IBus Simple `Multi_key` sequence.

The IBus 1.5.29 Wayland input-method path does not reliably inherit the compositor's XKB Compose-key option; upstream tracks this as [ibus/ibus#2579](https://github.com/ibus/ibus/issues/2579). The IBus phase was incorrectly using `Multi_key` as though it inherited the physical `compose:ralt` setup. The revised probe tests the XKB-backed IBus Simple dead-key path instead: `dead_acute`, Backspace cancellation, then `dead_acute` + `e` to commit U+00E9 (`C3 A9`). It requires provider preedit with no document change, cancellation without commit, exact UTF-8 commit, and the normal save-confirmation path. The earlier native Mutter phase still exercises physical `Multi_key` Compose and the two-mark locale-specific dead-key sequence independently. This is a test-only distinction; NekoEdit's backend and runtime dependencies are unchanged.

The updated probe and documentation are committed next; a new Actions run is pending. No live IBus dead-key pass is claimed yet.

---

## 2026-11-12 — propagate the IBus socket address to D-Bus-activated portal services (CI pending)

Actions [Build and test #841](https://github.com/GraderGamer2/NekoEdit/actions/runs/43138760681) passed the freestanding build, command-line tests, full Wayland protocol mock, ELF inspection, real `us(intl)` parser validation, X.Org importer verification, and locale-pack build. Mutter again passed native Right Alt Compose, the pt_BR dead-key sequence and save, plus text-input-v3 manager/focus/enable/state-commit. The only failure remained live IBus Simple preedit.

The #841 trace narrows the problem: `ibus-daemon` successfully owns `org.freedesktop.IBus` and `ibus engine` reports `xkb:us:intl:eng`, but the separately D-Bus-activated `org.freedesktop.portal.IBus` process exits with “Not connected to the ibus bus”. The portal is launched by `dbus-daemon`, which uses its own activation environment. The harness was changing `HOME` and XDG variables only in its own process after `dbus-run-session` had already created the bus.

The next test correction uses `dbus-update-activation-environment` to publish the isolated HOME/XDG/Wayland variables to D-Bus, obtains the real IBus socket address through `ibus address`, publishes it as `IBUS_ADDRESS`, then explicitly starts `org.freedesktop.portal.IBus` and verifies its name owner before launching GNOME Shell. This validates the portal's IBus connection, not merely the daemon's session-bus name. The IBus address lookup follows IBus's documented preference for the `IBUS_ADDRESS` environment variable before the per-user socket file; D-Bus activation services inherit the activation environment maintained by the bus daemon. This remains a test-harness-only change; the editor keeps no IBus or D-Bus runtime dependency.

The strict real IBus Compose preedit/backspace-correction/commit/save assertion is unchanged. CI is pending; no live IBus pass is claimed.

---

## 2026-11-12 — make IBus available before headless GNOME Shell startup (CI pending)

Actions [Build and test #840](https://github.com/GraderGamer2/NekoEdit/actions/runs/43136666325) passed the freestanding build, command-line tests, complete Wayland protocol mock, ELF inspection, native `us(intl)` XKB parser verification, X.Org source importer verification, and optional locale-pack build. Its Mutter phase passed the physical-XKB Right Alt Compose and pt_BR dead-key sequence, confirmed save, and text-input-v3 manager/focus/enable/state-commit handshake. IBus Simple still failed to deliver preedit. The log showed the portal's “Not connected to the ibus bus” failure occurring during GNOME Shell startup, before the harness switched the second phase to IBus Simple.

The harness starts GNOME Shell directly under `dbus-run-session`, without the full `gnome-session`/systemd user manager. IBus's GNOME unit is normally ordered after `gnome-session-initialized.target` and wanted by `gnome-session.target`; those targets are absent in this stripped test. The latest correction starts the same GNOME-mode `ibus-daemon --panel disable` command after the temporary HOME/XDG/Wayland environment is set but **before GNOME Shell launches**, verifies the `org.freedesktop.IBus` session-bus owner and required IBus Simple engine, and clears any inherited `IBUS_ADDRESS`/daemon-PID overrides so both Shell and the portal discover the isolated test daemon. The daemon remains a supervised child and is terminated during cleanup. The second phase now only changes the input-source settings and confirms the active engine.

This is still a test-harness-only change; NekoEdit gains no IBus runtime dependency or daemon-startup behavior. The real provider preedit/backspace-correction/commit/save assertion is unchanged. CI is pending; no live IBus success is claimed.

---

## 2026-11-12 — sample maximized-buffer ID at the actual resize allocation (CI pending)

Actions [Build and test #839](https://github.com/GraderGamer2/NekoEdit/actions/runs/43136062548) passed the freestanding build/ELF check and command-line tests. The full Wayland mock then passed the clipboard scenarios that failed in #838: keyboard Copy/Cut/Paste, context-menu Copy/Cut/Paste, asynchronous transfers, Undo/Redo, and the post-exit Clipboard Service. The standard smoke run also completed 217 frame callbacks, and the focused callback/release ordering regression was included.

The resize suite then exposed one more stale sample: the test captured the first maximized-buffer ID at the start of the file-workflow block, before hundreds of redraw callbacks from earlier interactions consumed IDs. The compositor's next buffer was therefore ID 384, not the stale expected ID 18. The test now samples `next_client_object_id` immediately before the maximize configure/release sequence, matching the point where `window_apply_pending_resize` allocates the replacement. Restore, edge-resize, and minimum-size buffer IDs are also sampled immediately before their respective allocation events.

Test correction commit: [0f89da3](https://github.com/GraderGamer2/NekoEdit/commit/0f89da36c2ebc6b647d1a1ae2bbcb9c72b34a379). This is a mock-only correction; the backend's dense object-ID allocator remains unchanged. A new Actions run is pending. No complete Wayland mock or full workflow pass is claimed yet. The live IBus Simple provider preedit/commit issue remains separate.

---

## 2026-11-12 — correct Wayland mock object-ID assumptions after frame callbacks (CI pending)

Actions [Build and test #838](https://github.com/GraderGamer2/NekoEdit/actions/runs/43134380215) passed the freestanding build/ELF check and command-line/host tests. The standard Wayland mock run completed 217 frame callbacks, and the dedicated release-before-callback regression passed: the buffer was released first, a second edit stayed queued, and exactly one follow-up frame was submitted after callback.done.

The full mock then failed in the clipboard scenario because its first Ctrl+C fixture expected object ID 19 while the client correctly allocated 21. Frame callbacks share Wayland's dense client object-ID namespace with clipboard data sources and newly created buffers. The backend allocator must remain dense; the correction is entirely in the mock. The clipboard, context-menu, and clipboard-persistence fixtures now read `next_client_object_id` before creating data sources, and the resize fixture captures each replacement buffer ID before the released buffer is destroyed. The mock no longer assumes callback-free consecutive IDs across resizes.

Commits: [8b966b2](https://github.com/GraderGamer2/NekoEdit/commit/8b966b20753dd33fa26cbaf1986ef874493c115b) derives clipboard/context-menu source IDs from the live allocator; [00c6847](https://github.com/GraderGamer2/NekoEdit/commit/00c684780a763a6a789e27fb74ff90589afd9ff8) completes dynamic resize-buffer ID expectations. The corrected mock awaits Actions; no full Wayland or workflow pass is claimed yet. Live IBus Simple preedit/commit remains a separate unresolved integration test.

---

## 2026-11-12 — correct Wayland mock object-ID assumptions after frame callbacks (CI pending)

Actions [Build and test #838](https://github.com/GraderGamer2/NekoEdit/actions/runs/43134380215) passed the freestanding build/ELF check and command-line/host tests. The standard Wayland mock run reported 217 frame callbacks completed, and the dedicated release-before-callback scenario passed: the buffer was released first, the second edit stayed queued, and exactly one follow-up frame was submitted after callback.done.

The complete Wayland mock then failed later in the clipboard scenario. The first Ctrl+C expected data-source ID 19 but received 21. The backend correctly allocated the intervening frame callbacks from the same dense client object-ID counter; several older test fixtures still assumed no additional client-created objects. The implementation must retain Wayland's dense ID allocation rather than moving callbacks into a sparse/high-numbered range. The test fixtures now read `next_client_object_id` before clipboard source creation and derive resize buffer IDs from the live counter. The corrected mock is awaiting a new run; no full Wayland or workflow pass is claimed.

Source/test feature commit: [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d). The branch currently also contains the frame-pacing documentation commit [c391b99](https://github.com/GraderGamer2/NekoEdit/commit/c391b9975f0577a9698acfd8b928f5aa8e0fe949).

---

## 2026-11-12 — single-buffer Wayland frame pacing (CI pending)

Commit [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d) adds one outstanding `wl_surface.frame` callback to normal redraw commits. Visual changes are coalesced in `redraw_pending`; another commit is permitted only when both `wl_buffer.release` and `wl_callback.done` have arrived, regardless of event order. The original single-buffer memory ownership rule and release-gated resize replacement are retained.

The mock now accounts for every callback request/completion and deliberately tests release-before-callback ordering: it withholds `done`, releases the SHM buffer first, injects another edit, verifies that no early surface request is emitted, then releases the callback and checks for one coalesced follow-up frame. The normal path also covers callback-before-release ordering.

This remains a single-buffer pacing improvement, not a multi-buffer ring. A new Actions run is pending; no build or test pass is claimed yet.

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
## 2026-11-12 — explicit opt-in fallback regression — Build and test #834 passed

The live Mutter text-input-v3 handshake is now verified by Build and test [#833](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452). On GNOME Shell 46 / Mutter 46.2, the compositor advertised the protocol and NekoEdit bound the manager, received `enter`, enabled the focused document, and committed state. The same workflow passed all 14 steps, including the unchanged physical Compose canaries; it uploaded a 137,017-byte editor artifact and the separate 120,536-byte locale-pack artifact.

This follow-up adds a complementary Wayland-mock case for the other capability branch: the test compositor deliberately omits `zwp_text_input_manager_v3`, while the child process still starts with `NEKOEDIT_ENABLE_TEXT_INPUT=1`. It requires every text-input object/state symbol to remain zero and then runs the full real-keymap keyboard editing/save scenario. Thus it checks that opting in cannot disable physical XKB typing when the compositor does not advertise the manager.

The fallback regression was fast-forwarded to `early-alpha` at [cadf39a](https://github.com/GraderGamer2/NekoEdit/commit/cadf39a3a4b03ce890c1bf57a43c6bdb999368c5). Build and test [#834](https://github.com/GraderGamer2/NekoEdit/actions/runs/43105116760) passed all 14 workflow steps. The job log confirms the seven text-input fields remained inactive and the complete real-keymap XKB editing/save scenario passed with the opt-in variable set.

---
## 2026-11-12 — capability-aware live text-input-v3 probe — Build and test #833 passed

Continue from `early-alpha` at [38d44ff](https://github.com/GraderGamer2/NekoEdit/commit/38d44ff7b3729b449ee784c7d32713dd3efb7034). The change extends the existing successful Mutter Compose smoke test with a second editor process launched using `NEKOEDIT_ENABLE_TEXT_INPUT=1`. The first `…Ầ` test is left intact.

New test file: `tests/mutter_text_input_probe.py`. After the original editor exits, the helper starts a second NekoEdit child, activates its Mutter window, clicks the document area, and reads the child's existing non-PIE ELF state symbols through `nm` + read-only `/proc/<pid>/mem`. No application-side diagnostics or runtime dependency were added.

Expected branches:
- Protocol global present: the probe requires a manager object, text-input object, compositor `enter`, document `enable`, and at least one outbound state commit.
- Protocol global absent: the probe requires no partial text-input setup and then sends Ctrl+A, `z`, Ctrl+S, Enter through Mutter to verify that explicit opt-in does not suppress the ordinary XKB path.

The probe intentionally does not claim that an actual IBus/Fcitx engine has sent `preedit_string`, `commit_string`, or `delete_surrounding_text`. Those incoming-event paths remain covered by `tests/wayland_mock.py`; live provider integration remains outstanding and text-input-v3 must remain disabled by default.

The original Compose test leaves the RemoteDesktop input session active until after the second process. The new helper is the direct parent of its NekoEdit child for normal Linux parent-to-child `/proc` access. If CI fails, inspect the helper's captured `text-input-nekoedit.log` before changing editor code. Do not weaken assertions based only on a missing protocol global: take the fallback branch only after checking that all downstream client object/state fields remain zero.

Also corrected `docs/ARCHITECTURE.md` and README to describe the actual hybrid Assembly/freestanding-C implementation. C is permitted; the invariant is no libc/C runtime or third-party runtime shared libraries, direct syscalls, and one freestanding ELF. Host-only tests may link test libraries separately.

Files changed: `tests/mutter_text_input_probe.py`, `tests/mutter_gnome_smoke.sh`, `docs/MUTTER_INTEGRATION_TEST.md`, `docs/TEXT_INPUT_V3.md`, `docs/ARCHITECTURE.md`, `README.md`, `CHANGELOG/README.md`, and this status file.

The eight-file change was fast-forwarded to `early-alpha` at [38d44ff](https://github.com/GraderGamer2/NekoEdit/commit/38d44ff7b3729b449ee784c7d32713dd3efb7034). Build and test [#833](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452) passed all 14 steps, including the live Mutter manager/enter/enable/state-commit handshake. The test did not exercise an external IBus/Fcitx provider, so that remains a separate validation task.

---

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

## 2026-11-11 — Build and test #826: count alphabetic keys from canonical XKB Unicode levels

**Run #825:** [failed at the final `xkb_symbols` validation](https://github.com/GraderGamer2/NekoEdit/actions/runs/42996770082). The parser successfully recorded 84 symbol values, so the minimum 16-symbol safeguard was satisfied. The alphabetic-key counter remained zero and rejected the map. The failure is isolated to the counter's use of the auxiliary byte-oriented `xkb_ascii_levels` table; no parser-stage or syntax failure occurred.
**Correction:** the alphabetic-pair check now reads the canonical `xkb_unicode_levels` table, which is also the authoritative scalar/action table consumed by live symbol lookup. It still requires at least 12 distinct Group1 lowercase/uppercase pairs, so the anti-sparse-map validation remains in place. The native parser probe also captures bounded AD01/AC01/AB01 samples from both Unicode and ASCII tables on failure, to diagnose any remaining index mismatch without another instrumentation-only run.
**Build and test #826** will validate the real libxkbcommon `us(intl)` keymap and then continue to the pinned X.Org and Mutter integration checks if the native parser and symbol-position assertions pass. No safety threshold was relaxed.
## 2026-11-11 — Build and test #825: inspect symbols-section acceptance thresholds

**Run #824:** [failed at the symbols-section pass](https://github.com/GraderGamer2/NekoEdit/actions/runs/42995879521). The 66,429-byte libxkbcommon keymap reaches stage 4 at byte offset 66,422, with the final token `}`. This locates the failure at the end of `xkb_symbols`, rather than the virtual-modifier, keycode, or types passes. The symbols parser has two final safeguards: at least 16 parsed symbols and 12 alphabetic keys.
**Correction:** extended the bounded failure record to capture the actual parsed symbol count and alphabetic-key count before keymap reset. The native test now prints both alongside stage, offset, and token. This will establish which safety threshold is rejecting the valid map and whether the problem is symbol parsing or alphabetic-key classification.
**Build and test #825** will run the additional count diagnostics. No safety threshold has been relaxed and no keymap acceptance behavior has changed.
## 2026-11-11 — Build and test #824: locate the real-keymap parser rejection

**Run #823:** [failed at the real-keymap parser probe](https://github.com/GraderGamer2/NekoEdit/actions/runs/42994629933). The probe now compiles and executes; it feeds a valid 66,429-byte `us(intl)` / `compose:ralt` text-v1 keymap generated by libxkbcommon into NekoEdit's actual assembly parser. The parser returns `-1` and resets `xkb_keymap_ready` to zero. The failure is therefore inside real-keymap parsing, not a C build or keymap-generation problem.
**Correction:** instrumented the parser's top-level passes with a small diagnostic record: stage (virtual-modifier scan, keycodes, types, symbols, compat, virtual-modifier resolution, or types reparse), byte offset, and last token. The native test prints these fields when parsing fails. This instrumentation does not change parser acceptance or fallback behavior.
**Build and test #824** will identify the exact failing parser pass and construct. No relaxing of validation or change to live key processing has been made yet.
## 2026-11-11 — Build and test #823: correct the native XKB probe's types and expected storage

**Run #822:** [failed before the parser test could execute](https://github.com/GraderGamer2/NekoEdit/actions/runs/42992625113). The freestanding build, command-line smoke tests, full Wayland protocol mock, and ELF inspection passed. The new host-side C probe then failed compilation because it used `xkb_context` and `xkb_keymap` as typedefs; libxkbcommon exposes these as `struct xkb_context` and `struct xkb_keymap`.
**Test-model correction:** the probe also needs to compare against the application-facing `xkb_unicode_levels` table. NekoEdit intentionally stores ordinary Unicode scalars plus reserved action markers (`Multi_key` = `0x110007`, `dead_grave` = `0x110001`, `dead_circumflex` = `0x110003`) there. `xkb_keysym_levels` is a separate raw table for modifier keysyms only and is not the correct assertion target for these symbols.
**Correction:** fixed the libxkbcommon struct pointer types and changed the probe to assert the Unicode/action value at each matching keycode/group/level cell. The next run will establish whether the assembly parser accepts the real compiled `us(intl)` text before any further live-input source changes.
**Build and test #823** will validate the corrected test; no parser-acceptance or Mutter Compose pass is claimed until CI completes.
## 2026-11-11 — Build and test #822: real us(intl) keymap parser regression test

**Run #821:** [failed in the native Mutter Compose comparison](https://github.com/GraderGamer2/NekoEdit/actions/runs/42989531248). The pre-Mutter build, CLI tests, full Wayland mock, ELF inspection, pinned X.Org regeneration, and four separate locale packs passed. Mutter reported the startup `us(intl)` keymap application, the native NekoEdit window focus, the document-body pointer click, and the ordinary edit/save canary all succeeded. The final saved bytes still contained literal grave/circumflex characters.
**Diagnosis boundary:** the run establishes that the compositor keymap setup and app focus steps completed, but not whether NekoEdit's assembly parser accepted the full keymap text it received. It would be premature to change the editor's live key processing without isolating parser acceptance and key-level mapping.
**Correction:** added `tests/xkb_native_keymap_test.c` and `make test-xkb-native`. The test asks libxkbcommon to compile the same `evdev` / `pc105` / `us` / `intl` / `compose:ralt` keymap, serializes the real XKB v1 text, calls NekoEdit's assembly `xkb_parse_keymap`, and compares stored keysyms for `Multi_key`, `dead_grave`, `dead_circumflex`, `period`, and `A` at matching keycode/group/level cells. CI uses `libxkbcommon-dev` solely for this host test; it is not linked into the freestanding application.
**Build and test #822** will provide the first deterministic accept/reject result for a real generated `us(intl)` map. The Mutter Compose case remains unverified until that test and the live integration gate pass.
## 2026-11-11 — Build and test #821: apply the native keymap before NekoEdit binds wl_keyboard

**Run #820:** [failed only in the final Compose comparison](https://github.com/GraderGamer2/NekoEdit/actions/runs/42988594141). The direct `global.backend.set_keymap('us','intl','compose:ralt','pc105')` operation returned successfully, but it ran after NekoEdit had already bound its initial plain-US `wl_keyboard.keymap`. The output remained literal `..` + grave + circumflex + `A`, indicating that a runtime keymap transition was not reflected in the key translation used by this session.
**Correction:** retain session GSettings and Mutter direct backend setup, but move the `ApplyKeymap` operation to after the compositor/keyboard startup and preflight-device creation and before launching NekoEdit. The editor will receive the configured `us(intl)` keymap in its initial keymap event, avoiding runtime keymap-replacement timing in this live smoke test.
**Build and test #821** will validate the basic canary and Compose output from an initial configured keymap. No full Mutter Compose pass is claimed until CI completes.
## 2026-11-11 — Build and test #820: apply us(intl) directly to Mutter before Compose

**Run #819:** [failed only at the Compose output comparison](https://github.com/GraderGamer2/NekoEdit/actions/runs/42987693384). All build, CLI, Wayland mock, ELF, pinned importer, and four locale-pack checks passed. The native pointer focus and ordinary input/save canary also passed. GSettings read back `sources=[('xkb','us+intl')]`, `xkb-options=['compose:ralt']`, and `xkb-model='pc105'`, but the actual Compose output contained literal grave/circumflex characters rather than dead-key composition. Thus settings persistence did not guarantee that GNOME Shell had activated the source on Mutter's native backend before input.
**Source inspection:** GNOME Shell 46.2 `KeyboardManager` applies layouts through `global.backend.set_keymap(layouts, variants, options, model)` and then locks the group. This is the exact backend API used by the normal shell input-source path.
**Correction:** the temporary extension now exposes a narrow `ApplyKeymap` operation, calling `global.backend.set_keymap('us','intl','compose:ralt','pc105')` followed by `global.backend.lock_layout_group(0)`. The harness invokes it immediately before the Compose sequence, after Shell startup, editor focus, pointer click, and successful basic canary. The existing isolated GSettings values remain as the configured session state.
**Build and test #820** will validate that Mutter now maps Right Alt to Multi_key and the US International dead keys to the expected symbols, then checks exact saved UTF-8 bytes for `…Ầ`. No Compose pass is claimed before the run completes.
## 2026-11-11 — Build and test #819: configure Mutter's actual XKB keymap for Compose

**Run #818:** [failed only at the Compose output comparison](https://github.com/GraderGamer2/NekoEdit/actions/runs/42986520195). The document-area pointer click succeeded, and the basic Ctrl+A / x / Ctrl+S / Enter canary saved `x` correctly. The Compose phase wrote literal `..A`; Mutter logged `No keycode found` for `Multi_key` (`0xff20`), `dead_grave` (`0xfe50`), and `dead_circumflex` (`0xfe52`).
**Root cause:** the harness set `XKB_DEFAULT_*` variables, but Mutter 46.2's native backend initializes its seat with a default plain `us` keymap. GNOME Shell's `KeyboardManager` applies the actual layout and options through `org.gnome.desktop.input-sources`; the previous test never configured those settings.
**Correction:** configure the temporary keyfile with source `us+intl`, MRU source `us+intl`, option `compose:ralt`, and model `pc105` before starting Shell. Read back and assert all four values. Remove the ineffective `XKB_DEFAULT_*` exports. The Compose test now describes the physical sequence mapped by that keymap: Right Alt Multi_key, period-period, grave dead key, Shift+6 circumflex, Shift+A.
**Build and test #819** will determine whether Mutter's keyval-to-keycode lookup now resolves all Compose/dead-key symbols and the separate `pt_BR.UTF-8` pack produces U+2026 U+1EA6. No Compose pass is claimed until CI finishes.
## 2026-11-11 — Build and test #818: add native pointer focus before Mutter keyboard input

**Run #817:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42982720723) in the basic canary. The native headless compositor started, created its virtual monitor, found/focused NekoEdit, and created the RemoteDesktop virtual keyboard before app startup. The test sent Ctrl+A, x, Ctrl+S, and Enter; the file still remained `seed`. Pre-creating the virtual keyboard did not resolve the issue.
**Source review:** Mutter 46.2 RemoteDesktop virtual keyboard devices are created with `CLUTTER_INPUT_MODE_PHYSICAL`, and `meta_wayland_seat_update()` accepts physical-mode keyboard devices with the keyboard capability. Thus the native key path is not excluded by the seat's synthetic-device filter. The Wayland seat's input focus is also updated from MetaDisplay's `focus-window` signal when a Wayland MetaWindow is activated.
**Correction:** the test now uses the same RemoteDesktop session to move a native virtual pointer into the center of NekoEdit's document body and click the left button after activation, before it sends any keyboard events. This exercises the editor's real pointer-driven document focus/caret path, which the live harness had omitted. Pointer motion is relative to `global.get_pointer()` and uses the target MetaWindow frame rectangle; the harness waits for explicit motion/press/release completion before typing.
**Build and test #818** will validate this additional focus path. No live input or Compose pass is claimed until the new run completes.
## 2026-11-11 — Build and test #817: create Mutter virtual keyboard before editor launch

**Run #816:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42981744154) at the native Mutter basic canary. The native headless compositor focused NekoEdit and accepted the RemoteDesktop D-Bus key-notification calls. The corrected canary also sent Enter after Ctrl+S, so the default confirmation modal was handled; the on-disk file still stayed unchanged. Thus save confirmation was a separate test bug, but not the remaining input-delivery explanation.
**Source inspection:** Mutter 46.2 creates the RemoteDesktop virtual keyboard lazily inside `ensure_virtual_device()` on the first key press. Its Clutter `device-added` signal updates the Wayland seat capabilities, and enabling the Wayland keyboard initializes focus from the seat's current input-focus surface. The harness previously launched and focused NekoEdit before that first virtual-device creation.
**Correction:** create/start the RemoteDesktop session and send/release an isolated Ctrl_L before launching NekoEdit. This primes the native keyboard device and gives the editor the keyboard capability during its initial `wl_seat` handshake. The real edit/Compose sequence remains after NekoEdit is launched and focused. This ordering change is a diagnosis-driven test correction, not yet a proven input fix.
**Build and test #817** will validate the revised lifecycle. Build/host tests, Wayland mock, ELF, pinned X.Org regeneration, and separate locale packs passed in #816; the Mutter stage still failed. No live keyboard or Compose pass is claimed before #817 completes.
## 2026-11-11 — Build and test #816: correct save-confirmation handling in Mutter canary

**Previous run #815:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42965658728) at the basic edit/save file comparison. It successfully started Mutter's native headless backend, found and activated NekoEdit's MetaWindow, started the RemoteDesktop session, and completed all D-Bus key-notification calls. However, the harness sent Ctrl+S without Enter. NekoEdit's default confirm-before-save setting intentionally opens a modal and leaves the target file unchanged until Enter accepts it. The unchanged seed file therefore did not prove that key delivery had failed; the earlier interpretation was too strong.
**Correction:** the basic canary and the final Compose save now both send Enter after Ctrl+S and before the exact on-disk byte comparison. This follows the existing Wayland mock assertion that Enter accepts the default save confirmation. Failure messages now describe the incomplete save canary rather than claiming that key delivery was absent.
**Source/test commit:** this entry is linked to the exact commit in the development log. **Build and test #816** will validate the corrected harness from a fresh build; no Mutter input or Compose pass is claimed yet.
**Scope:** only the integration test and its documentation/changelog were changed. NekoEdit editor source, runtime dependencies, and CI package list are unchanged.
## 2026-11-11 — Build and test #814: XI2 raw-key event diagnostics in progress

**Source commit:** [1e34ec6fe546](https://github.com/GraderGamer2/NekoEdit/commit/1e34ec6fe54661e447713e73c90d2020a0744fb4). The test now runs `xinput test-xi2 --root` alongside the ordinary-key canary and captures raw/device key events from the Xvfb server. This separates the XTest injection layer from Mutter's forwarding to the nested Wayland surface. `xinput` is a CI-only test package; the editor binary is unchanged.
**Run #813:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42961793193) in the Mutter canary. GNOME Shell reported NekoEdit's Wayland MetaWindow focused, with frame rectangle `0,32,800,568`; the harness clicked its center at `400,316`, while the X11 host still reported focus. The Clutter-stage captured-event counter remained empty and the document stayed `seed`. The stage callback alone is not a conclusive input-path probe for a nested Wayland client.
**Run #814:** [Build and test #814](https://github.com/GraderGamer2/NekoEdit/actions/runs/42963271284) is running on the exact source commit above. Build and command-line smoke tests have passed; the Wayland mock suite is running. The XI2 monitor will independently confirm whether host XTest key events exist before the Mutter forwarding path.
**Scope:** test-only instrumentation, CI test packages, and integration-test documentation; no editor runtime source or dependency changes.

## 2026-11-11 — Build and test #811: direct XTest host input, validation in progress

**Source commit:** [3477b605c01b](https://github.com/GraderGamer2/NekoEdit/commit/3477b605c01bba5fb686dc462766a47026f93d9a). The nested Mutter smoke test now sends actual XTest key events from the Xvfb host after explicitly setting and verifying the us(intl) / compose:ralt keymap. NekoEdit's inner Wayland MetaWindow is still activated and verified through the temporary, narrow GNOME Shell extension. The extension no longer creates a Clutter virtual device or exports key-injection methods.
**Run #810:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42959565212) only at the Mutter basic edit/save canary. The outer X11 and inner Wayland focus checks both reported the expected windows, but the Clutter virtual-device input did not modify the document. Build, host/CLI tests, Wayland mocks, ELF inspection, pinned X.Org regeneration checks, and optional locale packs all passed.
**Run #811:** [Build and test #811](https://github.com/GraderGamer2/NekoEdit/actions/runs/42960747590) is running on the exact source commit above. Build, command-line tests, Wayland mock, ELF inspection, pinned source checks, and four separate locale-pack builds have passed. The nested GNOME Shell/Mutter test is currently running; no basic-input, Compose, or final artifact success is claimed until it completes.
**Scope:** test harness, test-only package list, and integration documentation only. The freestanding editor and its runtime dependency boundary are unchanged.

## 2026-11-11 — Build and test #810: verify both nested Mutter focus layers

**Source commit:** [78adad34caaa](https://github.com/GraderGamer2/NekoEdit/commit/78adad34caaabfe1fe5699bb0042144fbdab356b). The Mutter harness now focuses GNOME Shell's outer X11 host window and NekoEdit's inner Wayland `MetaWindow`, then verifies both before sending keys. It restores `xdotool` as a test-only dependency; the editor binary and runtime dependencies are unchanged.
**Root cause from #809:** the extension loaded and Mutter reported NekoEdit as the focused inner `MetaWindow`, but the basic edit/save canary remained unchanged. Inspection of GNOME Mutter 46.2 showed that the nested X11 backend creates `MetaVirtualInputDeviceX11`, whose `notify_keyval` path calls `XTestFakeKeyEvent` on the outer X display. Focusing the inner Wayland window alone did not ensure that the outer GNOME Shell X11 window received those XTest events.
**CI:** [Build and test #810](https://github.com/GraderGamer2/NekoEdit/actions/runs/42959565212) is running against the exact source commit above. No Mutter input success is claimed yet. The build, host tests, Wayland mock, ELF verification, pinned X.Org comparisons, and separate locale-pack builds passed in #809; #810 must re-run all checks and complete the Mutter step.
**Changelog-only follow-up:** this entry is recorded without changing application/test sources, and the workflow ignores `CHANGELOG/**`.

## 2026-11-11 — Build and test #809: keyfile settings and explicit user session

**Source commit:** [88f3e9e248b2](https://github.com/GraderGamer2/NekoEdit/commit/88f3e9e248b26a12430dec6862e262c3bee228c2). Replaced the private dconf profile with GLib's isolated keyfile GSettings backend, verified the temporary extension UUID was persisted, and declared the GNOME Shell extension compatible with the `user` session mode.
**CI:** [Build and test #809](https://github.com/GraderGamer2/NekoEdit/actions/runs/42946768420) passed the build, command-line tests, Wayland protocol mock, ELF inspection, pinned source checks, and separate locale-pack builds. The Mutter test loaded the extension and verified NekoEdit's inner MetaWindow focus, but the ordinary key/save canary remained unchanged. No live key delivery or Compose success is claimed.
**Diagnosis:** the next correction must set both the nested compositor's outer X11 host-window focus and its inner Wayland client focus.

## 2026-11-10 — Build and test #807 running against literal-safe Mutter focus harness

**Source commit:** [e57e0233e128](https://github.com/GraderGamer2/NekoEdit/commit/e57e0233e1287b7d3636e2fd4ddecc4193b5735a). The test script was restored from the clean pre-focus version and the explicit outer-window focus + ordinary-key canary was reapplied using a literal-safe replacement; the fallback window-title match no longer contains an anchored dollar sign.
**CI:** [Build and test #807](https://github.com/GraderGamer2/NekoEdit/actions/runs/42837714490) was triggered by the source/test push. Latest check: **Install system Compose test corpus — in progress**. No #807 build or test result is claimed yet.
**Previous run #806:** core build, host tests, Wayland mock, ELF verification, pinned X.Org comparisons, and separate locale-pack builds passed; the Mutter script failed at parsing before input delivery. The current run must reach the new test before its explicit focus and plain-key canary can be evaluated.

## 2026-11-10 — correct test-script replacement syntax after #806

**CI #806:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42837121285) at shell parsing in `tests/mutter_gnome_smoke.sh` before input testing. The freestanding build, host tests, Wayland protocol mock, ELF inspection, pinned X.Org comparisons, and separate locale-pack builds all passed. The reported error was `line 239: syntax error near unexpected token '('`; inspection showed the fallback window-search line had been corrupted by the text-replacement operation around a literal dollar sign.
**Correction:** rebuilt the test script from the clean pre-focus version and applied the X11-focus/canary block using a callback replacement, avoiding replacement-token expansion. The fallback window search now uses the unanchored literal window title `GNOME Shell`; the previous explicit PID search and direct focus checks remain.
**Validation:** the corrected script is pushed below. The focus/canary behavior still requires a successful CI run; #806 never reached input injection.

## 2026-11-10 — improve Mutter input focus and add a keyboard-delivery canary after #805

**CI #805:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42833913969) only in `make test-mutter`. The freestanding build, host tests, Wayland mock, ELF inspection, pinned X.Org input-data verification, and all four optional locale-pack builds passed. GNOME Shell 46 / Mutter 46.2 started, and NekoEdit stayed alive, but the temporary document remained `seed` after the test's XTest input.
**Harness diagnosis:** the prior Xvfb flow clicked a hard-coded root coordinate but never explicitly set or verified X input focus on GNOME Shell's outer X11 window. Since this test runs without a separate X11 window manager, it could not rely on the usual click-to-focus policy. GNOME's nested-shell development notes also warn that keyboard shortcuts may not normally reach a nested compositor.
**Correction:** the harness now locates the visible GNOME Shell X11 window by PID, raises it, explicitly calls `xdotool windowfocus --sync`, verifies the focused XID, and clicks the center using window-relative coordinates. Before Compose input it replaces the temporary document with a one-character `x` canary and confirms Ctrl+S saved it. Failure now distinguishes missing basic keyboard delivery from a Compose translation/output mismatch.
**Scope:** test/docs only. The application and its runtime dependencies are unchanged; optional NLP1 packs remain external files under the temporary HOME's `~/.nekoedit/locales/`.
**Validation:** the fix is committed before the next branch-push run. No successful Mutter result is claimed yet.

## 2026-11-10 — nested Mutter smoke-test launch correction pushed; Build and test #805 pending

**Harness fix commit:** [14e7a902699e](https://github.com/GraderGamer2/NekoEdit/commit/14e7a902699e8411bd95a4d6d332105bff665d73). The harness now uses the supported `nekoedit <document>` invocation and selects Wayland through its private `WAYLAND_DISPLAY`.
**CI:** [Build and test #805](https://github.com/GraderGamer2/NekoEdit/actions/runs/42833913969) is running on this exact source commit. The latest available job status is still **Install system Compose test corpus — in progress**; build, mocks, and Mutter have not yet reported results for #805.
**Last completed run:** #804 passed the ELF build, host/command-line tests, Wayland mock, ELF inspection, pinned X.Org data comparisons, and all four optional locale-pack builds. It failed only because of the now-corrected combined CLI arguments in the new harness. Do not treat the Mutter keyboard scenario as validated until #805 completes successfully.

## 2026-11-10 — correct nested Mutter harness invocation after Build and test #804

**Branch:** early-alpha; harness commit [71d0040473d4](https://github.com/GraderGamer2/NekoEdit/commit/71d0040473d4b8b93f6f65f59741b8479c4d6588); repeat-mock correction [baaef829f1bb](https://github.com/GraderGamer2/NekoEdit/commit/baaef829f1bbc1452bbad7b89957704b3085c54f).
**CI #804:** [failed in the new integration harness](https://github.com/GraderGamer2/NekoEdit/actions/runs/42833190272). The freestanding build, all host/command-line tests, corrected Wayland mock, ELF inspection, pinned X.Org source comparisons, and all four separate locale-pack builds passed. The nested GNOME Shell 46 / Mutter 46.2 compositor started and published its Wayland socket. NekoEdit then exited immediately with `unknown argument` because the harness passed both `--backend=wayland` and a document path; the current CLI accepts the explicit backend flag only by itself, while the normal invocation with a file selects Wayland from `WAYLAND_DISPLAY`.
**Correction:** the harness now launches `nekoedit <temporary-document>` under its private nested `WAYLAND_DISPLAY`, which is the supported file-opening path and selects Wayland automatically. No editor CLI or backend code was changed.
**Validation:** this specific correction is committed below. CI has not rerun yet. The Compose event delivery/output check remains unverified; the compositor starting alone is not counted as a passing input test.

## 2026-11-10 — synchronize held-key repeat assertions after Build and test #803

**Branch:** early-alpha; nested Mutter integration harness source commit: [71d0040473d4](https://github.com/GraderGamer2/NekoEdit/commit/71d0040473d4b8b93f6f65f59741b8479c4d6588).
**CI #803:** [failed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42832654453) in the pre-existing Wayland protocol mock. The freestanding build, command-line/host tests, and locale tests passed. The mock reported held Tab with unchanged caret coordinates (after_press=(48,128), after_repeat=(48,128)); it failed before pinned-data verification, locale-pack build, and the new Mutter step.
**Diagnosis and test correction:** the Enter/Tab repeat assertions accepted a redraw without first proving that the repeat timer had inserted another newline/four spaces. The mock now waits for the corresponding shared document-cursor increment, sends key-up immediately after the first verified repeat, waits for repeat_keycode to clear, and only then checks the frame. This narrows the assertion to the actual first timer-driven edit and prevents later periodic ticks from moving the caret again. No editor runtime source was changed for this test-only synchronization fix.
**Mutter validation:** the new nested GNOME Shell/Mutter test was skipped in #803 because the earlier mock step failed. It remains unverified until the next branch-push run passes the complete workflow.
**Accuracy boundary:** #802 remains the last fully green build. Do not report the Mutter smoke test or this repeat-test correction as passing until the next run completes.

## 2026-11-10 — nested GNOME Shell/Mutter input integration harness — CI pending

**Branch:** early-alpha, based on a16365ebc80151759b26be39f14a6316896dc99b. This is the next validation layer after the #802 multi-dead-key implementation.
**Added:** tests/mutter_gnome_smoke.sh, docs/MUTTER_INTEGRATION_TEST.md, and the Makefile test-mutter target. The GitHub Actions workflow now installs GNOME Shell/Xvfb/XTest dependencies and runs this target after building the separate locale packs.
**Scenario:** a private D-Bus session and Xvfb host a nested GNOME Shell Wayland compositor. NekoEdit connects through its ordinary --backend=wayland path with a temporary HOME and separately installed pt_BR pack. XTest injects a Multi_key period-period sequence and dead_grave + dead_circumflex + A; Ctrl+S must save exactly U+2026 U+1EA6.
**Architecture boundary:** GNOME/Xvfb/xdotool are test-only packages. No GNOME library, compositor dependency, locale bundle, or input automation component was added to the editor binary. The four optional locale packs remain separate files below ~/.nekoedit/locales.
**Validation:** the script and workflow change are committed together so the branch-push workflow tests the exact tree. At commit time, CI has not yet run. This connector session has no GNOME/Mutter display available for local execution. Do not treat this as a passing compositor test until the branch-push Actions run succeeds.
**Limitations:** XTest input is synthetic, not a physical keyboard. The harness validates GNOME Shell/Mutter's nested Wayland event path and the tested us(intl) sequences, not the user's actual desktop, hardware, IME preedit behavior, or complex shaping.

## 2026-11-10 — Wayland dead-key chains support one to three combining marks — Build and test #802 passed

**Branch:** `early-alpha`; exact validated source/test head `91a92c38210362def100026afd60e7b08132d08f`. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Wayland implementation:** [e2521c401744](https://github.com/GraderGamer2/NekoEdit/commit/e2521c401744f2695b51b505f3ee6b7f53bd0d66). Generated locale data: [c61453d2d180](https://github.com/GraderGamer2/NekoEdit/commit/c61453d2d180075e8d2eec323ad7bdde5dbdd30f). Workflow/data notice cleanup: [81e6272e95e5](https://github.com/GraderGamer2/NekoEdit/commit/81e6272e95e587327458a94c96957748291507b2). Final fixture update: [91a92c382103](https://github.com/GraderGamer2/NekoEdit/commit/91a92c38210362def100026afd60e7b08132d08f).
**CI:** [Build and test #802](https://github.com/GraderGamer2/NekoEdit/actions/runs/42810208303) passed all 14 steps on the exact final source/test head.

### Wayland input behavior

The Wayland keyboard path now buffers a chain of one to three dead-key actions (stored as their combining-mark scalars) and the following ordinary base scalar. It queries the active optional NLP1 locale pack with the complete two-to-four-scalar kind-1 record. The existing built-in single-mark precomposition fallback remains intact. When a multi-mark chain has no locale rule, the editor preserves the base character followed by each combining mark in input order rather than dropping input.

The chain is bounded by the unchanged four-input NLP1 ceiling. A fourth consecutive dead action flushes the first three marks literally and starts a new chain. Starting `Multi_key` flushes a pending dead-key chain before beginning that separate compose state; Escape and Backspace cancel the entire pending chain and clear all prefix slots. The fixed 52-byte record, header, format version, loader, and output ceiling are unchanged, so older NLP1 packs remain readable.

The native Settings XCompose importer, offline user-file converter, and pinned X.Org locale importer now accept the same grammar: one to three leading recognized `dead_*` actions followed by one ordinary Unicode keysym. Intermediate events must be recognized dead actions; the final event must be a character, not another dead action. Longer chains and malformed intermediate/final events are rejected within the existing limits.

### Regenerated separate locale data

Extending the pinned importer admitted additional multi-dead-key source records, so the four committed JSON tables were regenerated from the same pinned libX11/xorgproto inputs and verified byte-for-byte in CI. The common en_US baseline now contains 1,576 accepted dead-key records, up from 1,228; the locale packs remain separate files and are not embedded into the editor.

| Locale | Final records | 2-input | 3-input | 4-input | Locale Multi_key | Locale dead-key | Total overrides |
|---|---:|---:|---:|---:|---:|---:|---:|
| `pt_BR.UTF-8` | 4,484 | 3,448 | 894 | 142 | 9 | 2 | 5 |
| `fi_FI.UTF-8` | 4,488 | 3,445 | 901 | 142 | 6 | 346 | 343 |
| `sr_RS.UTF-8` | 4,495 | 3,461 | 892 | 142 | 40 | 50 | 74 |
| `el_GR.UTF-8` | 5,730 | 3,589 | 1,387 | 754 | 922 | 970 | 628 |

The locale-specific dead-key override counts are 2 (pt_BR), 338 (fi_FI), 38 (sr_RS), and 234 (el_GR). The remaining locale-specific dead-key records add previously absent input sequences. `data/locales/README.md` now records the regenerated counts and override breakdowns.

### Regression coverage and CI recovery

The host tests now verify one-, two-, and three-mark import/lookup paths and reject malformed dead-key chains. The locale-data test checks the new totals and real source-derived mappings, including Portuguese `dead_grave + dead_circumflex + A → U+1EA6` and the Greek three-mark sequence `U+0300 + U+0313 + U+0345 + U+0391 → U+1F8A`. The Wayland mock sends keyboard events through the runtime and checks two-/three-mark locale lookup, literal fallback, the fourth-mark boundary, Escape, and Backspace.

The first two CI attempts (#798 and #799) stopped at the expected pinned-data comparison because the importer had begun accepting records that were absent from the previous JSON tables. A short-lived CI artifact step recovered the exact regenerated outputs; a one-time CI refresh committed those outputs in `c61453d`. The first read-only validation then caught stale golden counts in `tests/compose_locale_data_test.py`; [#802](https://github.com/GraderGamer2/NekoEdit/actions/runs/42810208303) passed after updating those assertions.

The temporary artifact-upload and write-enabled refresh logic was removed. The final `.github/workflows/build.yml` has `contents: read`, contains no data-push code, and the pinned-source compare passed without special workflow permissions.

#802 artifacts (one-day retention):
- Editor ZIP [13761918009](https://github.com/GraderGamer2/NekoEdit/actions/runs/42810208303/artifacts/13761918009), 135,673 bytes, SHA-256 `ab71efb788fcf25dc14c232c369a60a5edfa61dbecb339d08ee28fa238cd49e8`.
- Separate locale ZIP [13762312971](https://github.com/GraderGamer2/NekoEdit/actions/runs/42810208303/artifacts/13762312971), 114,239 bytes, SHA-256 `5605356b9d3b38fe5fa1b08334645ba62e8224904119b702ec3f5709c8fd8a52`.
- Both expire **2026-11-11 11:48 UTC / 18:48 Jakarta**. The locale ZIP contains separate pt_BR, fi_FI, sr_RS, and el_GR `.nlp` packs and their notices.

This is automated build, host-test, and Wayland protocol-mock validation. It is not a live GNOME/Mutter session or physical-keyboard test; the user has confirmed the previous build launches, but the newly added chained sequences still need to be exercised on the desktop. Example imported rules for manual testing are `<dead_grave> <dead_circumflex> <A> : "Ầ"` and `<dead_grave> <dead_psili> <dead_iota> <Greek_Alpha> : "ᾊ"`. No X11 backend was added or changed in this milestone.

Next Wayland work remains live GNOME/Mutter validation, modifier-qualified Compose semantics and startup discovery/merging, then additional optional locale datasets. Chains longer than three dead actions remain outside the current bounded record model.

## 2026-11-10 — native Settings XCompose importer shares XKB Unicode keysym resolver — Build and test #797 passed

**Branch:** `early-alpha`; exact validated head `b23b2ae61dd3422806d6155eec8ac3c9c16f327d`. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation:** [4079e8cfee89](https://github.com/GraderGamer2/NekoEdit/commit/4079e8cfee89611f45eecfbc938a54fda960b748). Test-link correction: [b23b2ae61dd3](https://github.com/GraderGamer2/NekoEdit/commit/b23b2ae61dd3422806d6155eec8ac3c9c16f327d).
**CI:** [Build and test #797](https://github.com/GraderGamer2/NekoEdit/actions/runs/42792816159) passed all 14 workflow steps on the exact final head.

The native **Settings → Locale → Import** parser now resolves named character keysyms through the same read-only X.Org Unicode-annotated table and bounded resolver used by physical XKB keymap parsing. The accepted name set therefore covers the embedded table's Latin, Greek, Cyrillic, Arabic, Hebrew, Thai, Hangul, Armenian, Georgian, Kana, Sinhala, Braille, and xorgproto 2026.1 aliases, rather than the previous short hand-maintained list of common Latin-1 names.

A length-bounded assembly entry point saves and restores the XKB parser's shared 64-byte tokenizer buffer and token length. The importer continues to preserve its explicit `Uxxxx` scalar path. The shared ASCII resolver now also retains the importer's former `quoteleft` and `quoteright` aliases. Named `dead_*` function keysyms are rejected as ordinary Multi_key character inputs; dead-key action names remain accepted through the separate typed dead-key lead path. This matches the X.Org protocol distinction that dead keys are Function KeySyms, not Unicode KeySyms.

The NLP1 schema, its input/output limits, typed record kinds, import path checks, include ceilings, modifier-qualified-rule skip behavior, and data-only locale packaging are unchanged. No external library, locale bundle, Python runtime, or duplicated Unicode name table was added.

Native importer fixtures now validate pack import and lookup with Greek/Cyrillic, Arabic/Hebrew, Thai/Hangul, accented Latin, xorgproto 2026.1 angle-quotation names, the legacy quote aliases, and the dead-key/function-keysym distinction. The locale-manager host test also links the shared XKB object, so both host test binaries resolve the new symbol. CI logs explicitly report **Compose locale manager tests passed** and **Native in-app XCompose import tests passed**.

Build and test #796 exposed one test-only link omission: the locale-manager test target also links `compose_locale.c`, so it needed the same XKB object as the new importer test target. The application ELF build had passed; the manager test link failed with an undefined reference. Commit `b23b2ae` corrected that Makefile dependency, and #797 then passed the full suite, Wayland mock, ELF inspection, pinned X.Org regeneration, optional locale-pack build, and both uploads.

#797 artifacts (one-day retention):
- Editor ZIP [13753236119](https://github.com/GraderGamer2/NekoEdit/actions/runs/42792816159/artifacts/13753236119), 135,337 bytes, SHA-256 `6d77a6357686fbe065c456c7b99e931cebf0087857ce61a3dafde35dafbf04ac`.
- Separate locale ZIP [13753071329](https://github.com/GraderGamer2/NekoEdit/actions/runs/42792816159/artifacts/13753071329), 101,677 bytes, SHA-256 `4d99b142af8f6ceb2c959289e1b222bed4375b65e0dc730d8578400a5b8624e3`.
- Both expire **2026-11-11 09:43 UTC / 16:43 Jakarta**.

This is automated CI/mock validation, not a real GNOME/Mutter or physical-keyboard test. The user should manually import a file containing the new named-key cases in Settings and exercise the corresponding sequences on the actual desktop. Remaining XCompose work includes modifier-qualified rule representation, broader syntax semantics, and automatic system/user startup discovery/merging; longer dead-key chains remain priority 2.

## 2026-11-10 — native XCompose rooted includes and compose.dir locale mapping — Build and test #795 passed

**Branch:** `early-alpha` only. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; this implementation is not on `main`.
**Implementation series:** [391b0c66d89c](https://github.com/GraderGamer2/NekoEdit/commit/391b0c66d89c9ee734c5f652de8bf733a30ab6af), [575db597c7b0](https://github.com/GraderGamer2/NekoEdit/commit/575db597c7b0b8e0c3874d9fd7c1ffdb0c6bcddd), [6bf83dce7b34](https://github.com/GraderGamer2/NekoEdit/commit/6bf83dce7b3437aadda06574f6cccd4175cd83e8), [ae6323501b66](https://github.com/GraderGamer2/NekoEdit/commit/ae6323501b66e1d8bf5d36d044454c0ad7f00570), [a4bdccc12147](https://github.com/GraderGamer2/NekoEdit/commit/a4bdccc12147c38e81008dee37c545c75e628e48).
**CI:** [Build and test #795](https://github.com/GraderGamer2/NekoEdit/actions/runs/42743763387) passed all 14 workflow steps on `a4bdccc12147`.

The freestanding Settings importer now supports bounded quoted sibling, `%H`, `%S`, and `%L` includes. `%H/path` resolves beneath HOME; `%S/path` resolves beneath `/usr/share/X11/locale` (overridable through `NEKOEDIT_XCOMPOSE_SYSTEM_ROOT`). Nested sibling includes remain relative to the file containing each directive, including when that file was reached through a macro root.

`%L` selects the first non-empty `LC_ALL`, `LC_CTYPE`, or `LANG` value (otherwise `C`); `POSIX` aliases `C`. The normalized locale is matched through X.Org's system `compose.dir`, so aliases such as `el_CY.UTF-8` map to `el_GR.UTF-8/Compose`, and `C` and `C.UTF-8` use their respective entries. The map is bounded, opened without following symlinks, and charged to the aggregate import-byte budget. The mapped path is validated component by component and opened beneath the same system root.

Limits remain 512 KiB aggregate bytes including compose.dir, 512 KiB per Compose file, 32 unique Compose files, 64 expansions, 16 active include levels, 64 KiB per line, and 32,768 output records. The importer remains a bounded UTF-8/Multi_key/dead-key subset; non-UTF-8 source encodings, full XKB modifier semantics, broader keysym coverage, and automatic startup discovery/merging remain unsupported.

Regression coverage includes %L/%H/%S, nested system includes, compose.dir aliases, the C mapping, missing system roots, traversal, final/intermediate symlinks, and existing sibling ordering/cycle/expansion/depth protections. CI #791 exposed the initial helper buffer declaration mismatch; #792 caught strict fixture-path truncation warnings; #793 passed the first macro-include version; #794 caught an alias fixture that exceeded NLP1's eight-scalar output limit. The fixes are recorded in the commit series above; #795 passed the complete workflow.

#795 artifacts: editor ZIP [13729764162](https://github.com/GraderGamer2/NekoEdit/actions/runs/42743763387/artifacts/13729764162), 135,652 bytes; separate locale ZIP [13730980366](https://github.com/GraderGamer2/NekoEdit/actions/runs/42743763387/artifacts/13730980366), 101,677 bytes. Both expire **2026-11-11 02:36 UTC / 09:36 Jakarta**.

The user has confirmed that Settings Import installs a separate .nlp under `~/.nekoedit/locales/`; live GNOME/Mutter and physical-keyboard Compose validation remains outstanding.

## 2026-11-10 — early-alpha Greek Compose locale pack and CI verification handoff

**Branch boundary:** this milestone is on `early-alpha` only; the application/data changes are not present on `main`. PR #2 remains open and unmerged.
**Implementation:** [953ae55d414c](https://github.com/GraderGamer2/NekoEdit/commit/953ae55d414c9a0866271b5a6f73be0d87895931); Greek test correction [f6a16b948983](https://github.com/GraderGamer2/NekoEdit/commit/f6a16b9489830db7f3ae199146b169b19ad6c83d); Wayland test timeout [0a03493b4eac](https://github.com/GraderGamer2/NekoEdit/commit/0a03493b4eacb5c54f193cfdb5eed4021d218241).
**CI:** [Build and test #790](https://github.com/GraderGamer2/NekoEdit/actions/runs/42738784199) passed on the exact `early-alpha` head after the upstream source regeneration, tests, full Wayland mock, and separate artifact uploads.

- Added optional `el_GR.UTF-8` from pinned libX11 source blob `4a644258ce32cd34ddcc0c47605938db5f697b7d` at commit `ff8706a5eae25b8bafce300527079f68a201d27f`. Its standalone Compose source is explicitly merged over the pinned en_US baseline using `--locale-standalone`.
- The generated data file has 4,690 records (922 accepted Greek Multi_key, 138 locale dead-key rules, 488 overrides, 13 dropped prefixes). The editor still embeds only en_US; Greek is a separate optional NLP1 pack built and uploaded separately.
- Golden tests cover Greek tonos, uppercase iota diaeresis, and two breathing-mark results. These are automated data checks only; no live GNOME/Mutter or physical keyboard validation is claimed.
- CI #788 corrected an inaccurate expected value (U+03AA, not U+03CA). CI #789 hit the existing 50-second cap in the extended Settings-locale Wayland mock; the test cap was raised to 90 seconds, with the ordinary keyboard/XKB bound unchanged.
- Build and test [#790](https://github.com/GraderGamer2/NekoEdit/actions/runs/42738784199) passed. Separate artifacts: editor ZIP 13727403952 (133,624 bytes) and locale ZIP 13727443844 (101,677 bytes), expiring 2026-11-11 around 01:53 UTC.
- The user has confirmed that Settings Import successfully installs a separate .nlp under `~/.nekoedit/locales/`; symbol-by-symbol manual desktop testing remains outstanding.

## 2026-11-10 — bounded sibling includes in native Settings XCompose import — Build and test #787 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation:** [d56bffc9ebe7](https://github.com/GraderGamer2/NekoEdit/commit/d56bffc9ebe79c16d37e9d95ed776f1beb331233); fixture correction [752c24664911](https://github.com/GraderGamer2/NekoEdit/commit/752c24664911f672c7c672cfd2a01fc33ad6cdd9).
**CI:** [Build and test #787](https://github.com/GraderGamer2/NekoEdit/actions/runs/42736381984) passed all 14 workflow steps, including the native import tests, full Wayland mock, ELF inspection, pinned X.Org source verification, locale-pack build, and separate artifact uploads.

- The native **Settings → Locale → Import** parser now supports quoted relative `include "sibling.XCompose"` directives. Included files are expanded depth-first at the exact directive position. Later parent rules override earlier included records; re-including a file after its previous expansion has returned is allowed and is applied again in textual order.
- The security boundary is intentionally same-directory only. The selected root file's containing directory is opened once and retained as a directory descriptor. Included paths must be a single basename; absolute paths, `/`, `\\`, `.`, `..`, `%H/%S/%L`, environment substitutions, and symlinks are rejected. Every opened input must be a regular file and uses `O_NOFOLLOW`.
- Active cycles are detected by device/inode identity. The parser fails the entire import before any pack is built or published if a cycle, unsupported include, read error, malformed include, or resource ceiling is hit. It never installs a partial locale.
- Fixed native limits: 512 KiB aggregate expanded input and 512 KiB per file; 32 unique files; 64 include expansions; 16 active include levels; 64 KiB per line; 32,768 records. Work buffers remain temporary mappings; no permanent locale table or third-party runtime dependency was added.
- Added regression coverage for nested and repeated sibling includes, depth-first/last-rule precedence, parent-directory traversal rejection, symlinked include rejection, active-cycle rejection, the 64-expansion ceiling, and the 16-level recursion ceiling. Pack loading/lookup, source preservation, private file permissions, and no-overwrite behavior remain covered.
- The optional host-side importer remains the route for `%H`, `%S`, and `%L`, cross-directory/system include resolution, non-UTF-8 encodings, and broader X.Org keysym definitions. The in-app parser does not shell out or launch Python.
- Build and test #786 stopped at a test-path assertion because new fixtures accidentally appended `/locales/` twice to a path already pointing at that directory. The implementation returned a successful import; the fixture was corrected in [752c24664911](https://github.com/GraderGamer2/NekoEdit/commit/752c24664911f672c7c672cfd2a01fc33ad6cdd9). Build and test #787 passed.
- #787 editor artifact: ZIP [13727451420](https://github.com/GraderGamer2/NekoEdit/actions/runs/42736381984/artifacts/13727451420), 133,624 bytes; locale pack ZIP [13727765638](https://github.com/GraderGamer2/NekoEdit/actions/runs/42736381984/artifacts/13727765638), 74,021 bytes. They expire **2026-11-11 01:32:59 UTC / 08:32:59 Jakarta** and **2026-11-11 01:32:58 UTC / 08:32:58 Jakarta**, respectively.
- The locale architecture remains modular: only the built-in en_US baseline is linked into the editor; imported locales remain separate NLP1 data files.

**Next:** add another reproducible non-en_US locale dataset from a pinned X.Org source, with tests for its actual locale-specific Multi_key/dead-key records. Preserve en_US as the built-in default and keep the new locale pack separate from the executable.

## 2026-11-10 — native Settings import for raw user XCompose files — Build and test #785 passed

**Branch:** `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
**Implementation:** [a5e75d0d6cee](https://github.com/GraderGamer2/NekoEdit/commit/a5e75d0d6cee29167c33bddb11e00fc75b0a1978); compile fixes [81fb2ca891cd](https://github.com/GraderGamer2/NekoEdit/commit/81fb2ca891cdf897c6c7509124fe719264c5a2f7) and [86ea3d00ee2b](https://github.com/GraderGamer2/NekoEdit/commit/86ea3d00ee2b59cf10fb6b0426b4d0abe75dbab3); Settings integration mock [4572affe38eb](https://github.com/GraderGamer2/NekoEdit/commit/4572affe38ebf9b771913fff85b8ca7a0f25fb5d).
**CI:** [Build and test #785](https://github.com/GraderGamer2/NekoEdit/actions/runs/42731684293) passed all 14 workflow steps, including the new end-to-end Settings Import scenario in the full Wayland mock.

- Added **Settings → Locale → Import** for selecting a raw user `.XCompose` file. NekoEdit performs the conversion inside its freestanding editor; it does not invoke Python or launch a helper process.
- The in-app importer creates a separate `.nlp` pack under `~/.nekoedit/locales/`, derives the locale tag from the selected filename (for example, `nekoedit-test.XCompose` → `nekoedit-test.UTF-8`), validates it through the runtime NLP1 validator, and atomically publishes it without replacing an existing pack. The source file is left untouched. The new locale is activated and persisted in `~/.nekoedit/preferences`.
- The native importer is deliberately bounded: UTF-8 self-contained files only; unqualified `Multi_key` rules with two to four following keysyms; one recognized dead-key action plus one following keysym; quoted UTF-8 output and supported simple/octal/hex/Unicode escapes; a printable-ASCII and curated common keysym subset. Later duplicates override earlier entries and shorter same-kind prefixes are dropped. Include directives are rejected fail-closed. Use the optional host-side converter for `%H`, `%S`, or `%L` includes, non-UTF-8 encodings, or broader X.Org keysym resolution.
- Native regression coverage verifies generated-pack loading and lookup, two-/three-/four-key sequences, named printable ASCII, escapes, multi-scalar output, dead-key namespace separation, duplicate override/prefix handling, 0700/0600 storage permissions, source preservation, symlink rejection, include rejection, and no-overwrite behavior.
- The extended Wayland mock now drives **Settings → Locale → Import**, selects a raw `.XCompose` fixture, and verifies the generated separate pack, activation, persisted locale preference, 0600 file mode, and unchanged source contents.
- **Modular locale boundary preserved:** only the built-in en_US baseline remains in the editor executable. The imported locale is a separate `.nlp` file. The release datasets remain independent of the editor and are uploaded separately.
- Build and test #784 [passed](https://github.com/GraderGamer2/NekoEdit/actions/runs/42731335861) the native importer host test and full existing Wayland mock. #785 then passed all 14 workflow steps after adding the Settings UI integration assertion.
- Build and test #785 artifacts: editor ZIP [13725565793](https://github.com/GraderGamer2/NekoEdit/actions/runs/42731684293/artifacts/13725565793), 132,507 bytes; separate locale ZIP [13725635467](https://github.com/GraderGamer2/NekoEdit/actions/runs/42731684293/artifacts/13725635467), 74,021 bytes. Both expire **2026-11-11 00:54 UTC** (2026-11-11 07:54 Jakarta) under the one-day policy.
- No non-en_US locale tables were added to the binary. No runtime libraries, Python interpreter, network dependency, or automatic import behavior were added.

**Next:** add coverage for safe relative includes in the in-app importer, or route include-rich imports through an explicitly selected host converter; do not silently weaken the path/size limits. Preserve the no-overwrite and separate-pack guarantees.

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

