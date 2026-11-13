## 2026-11-13 — separate logical surface geometry from backing-buffer pixels (CI pending)

Keep `window_width` / `window_height` as surface-local logical dimensions and add explicit `window_buffer_width` / `window_buffer_height` fields for pixel extents; retain `window_stride` as the physical byte pitch. Initial and resize-created `wl_buffer` requests now consume the backing-buffer fields. Rectangle/glyph bounds and the TrueType renderer's target dimensions also use those pixel extents. The current geometry updater intentionally keeps the dimensions 1:1 and rendering at scale 1; it does not apply the effective scale or preferred transform.

Extend the Wayland mock's ELF-symbol state reader and assert logical/backing dimensions for the initial 800×480 window, 1920×1080 maximize, 800×480 restore, and 720×480 edge resize. This is an architectural boundary-setting step, not a HiDPI implementation. The next change must scale raster positions and glyphs, handle transformed buffer-axis dimensions, and preserve surface-local pointer/layout semantics before sending `wl_surface.set_buffer_scale`. CI pending.

---

## 2026-11-13 — fix effective Wayland scale initialization (CI PASS #871)

The first attempt, Actions [#870](https://github.com/GraderGamer2/NekoEdit/actions/runs/43344591753), failed during assembly because GNU as rejected a non-zero `.long 1` in `.bss`. Storage was changed to zero-filled `.zero 4`; Wayland startup initializes the effective scale to 1 before processing events. No runtime behavior or expected values changed.

Actions [Build and test #871](https://github.com/GraderGamer2/NekoEdit/actions/runs/43345347954) passed all 15 steps, including freestanding build/ELF verification, CLI smoke tests, the complete Wayland protocol mock, native `us(intl)` XKB parsing, X.Org importer checks, Compose locale-pack build, GNOME Shell 46 / Mutter integration, and both artifact uploads. The `nekoedit-linux-x86_64` artifact is [available here](https://github.com/GraderGamer2/NekoEdit/actions/runs/43345347954/artifacts/14001132220) until 2026-11-14 01:33:26 UTC (08:33:26 WIB).

---

## 2026-11-13 — track compositor-preferred surface scale and transform (CI PASS #868)

Bind `wl_compositor` at up to v6 instead of unconditionally at v1. This gives the created `wl_surface` the version-6 `preferred_buffer_scale` and `preferred_buffer_transform` events while preserving v1 behavior on older compositors. Track both preferences on the surface, defaulting to scale 1 and normal transform; validate positive scale values and the transform enum. The output integration mock exercises the compositor preference independently of per-output scale transactions.

Actions [Build and test #868](https://github.com/GraderGamer2/NekoEdit/actions/runs/43342773468) passed all 15 workflow steps: freestanding build/ELF verification, CLI and complete Wayland mock, native `us(intl)` parser, X.Org importer, Compose locale pack, nested GNOME Shell 46 / Mutter integration, and both artifact uploads. The mock verified compositor-v6 preferred scale/transform transitions alongside per-output v2/v3 scale transactions and hotplug. Mutter also verified live IBus Simple preedit, Backspace cancellation, U+00E9 commit, and exact UTF-8 save.

This remains selection metadata only: no buffer-scale request or pixel-dimension change is made. Logical/physical renderer separation and a correctly enlarged backing store must precede `wl_surface.set_buffer_scale`.

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

The native Mutter virtual keyboard canary also passed: Right Alt `Multi_key`, the two-mark dead-key chain, and confirmed Ctrl+S save preserved exactly U+2026 U+1EA6 (`…Ầ`). The live IBus Simple phase passed end to end through GNOME Shell, Mutter 46.2, and NekoEdit's optional text-input-v3 client: the physical apostrophe generated a visible `dead_acute` preedit; Backspace cancelled it without changing document bytes; a fresh apostrophe followed by `e` committed U+00E9 (`é`); and the normal Ctrl+S / Enter confirmation saved the exact UTF-8 bytes `C3 A9`. Actions [Build and test #868](https://github.com/GraderGamer2/NekoEdit/actions/runs/43342773468) independently re-ran this canary successfully in the complete 15-step workflow.

This validates the narrowly gated Mutter 46.0–46.2 compatibility cases: a multibyte preedit's legacy character-index anchor is converted only when it resolves to the same validated cursor byte offset, and the nullable empty-preedit `(0, 1)` anchor is normalized to `(0, 0)`. The mock tests both cases while keeping unrelated malformed UTF-8 boundaries rejected. No IBus, D-Bus, GNOME, or other runtime dependency was added to NekoEdit.

Artifacts from #856: [Linux x86-64 executable](https://github.com/GraderGamer2/NekoEdit/actions/runs/43182358544/artifacts/13927605875) and [Compose locale packs](https://github.com/GraderGamer2/NekoEdit/actions/runs/43182358544/artifacts/13927775229). Both are configured with one-day retention.

---










## 2026-11-12 — inspect GNOME Shell's IBus InputMethod during live preedit validation (CI pending)

Actions [Build and test #846](https://github.com/GraderGamer2/NekoEdit/actions/runs/43161435296) passed the freestanding build/ELF checks, CLI tests, complete Wayland mock, executable inspection, native `us(intl)` XKB parser, X.Org importer, and locale-pack build. The isolated IBus daemon and D-Bus-activated portal acquired their bus names. The native Mutter physical-XKB Compose/dead-key/save canary and the independent text-input-v3 manager/focus/enable/state-commit handshake also passed.

The remaining failure is the live IBus Simple preedit assertion. The previous test-only observer watched `global.stage`, but that is not a reliable observation point for keys handled by GNOME Shell's input method on behalf of a separate Wayland client. Its absence of apostrophe events did not prove that Mutter failed to receive the key.

The new test-only D-Bus method queries the actual `Clutter.InputMethod` instance installed on GNOME Shell's backend and exposes its input source, IBus context availability, focus state, and preedit visibility/string. The Python probe first requires the expected `ibus:xkb:us:intl:eng` source, a ready context, and input-method focus. It then requires Shell-side preedit and independently checks the preedit received by NekoEdit through `zwp_text_input_v3`. Backspace must clear both states; a second apostrophe followed by `e` must commit U+00E9; Ctrl+S and Enter must persist the exact UTF-8 bytes.

This correction changes only the temporary GNOME Shell test extension, Python probe, integration documentation, and changelog. The invalid stage observer and counter assertion are removed. The NekoEdit backend, ELF, and runtime dependency set remain unchanged. CI is pending; no live IBus preedit/commit pass is claimed.

---

## 2026-11-12 — attempted Mutter stage-level key observation (superseded)

Actions [Build and test #845](https://github.com/GraderGamer2/NekoEdit/actions/runs/43152106813) passed the freestanding build/ELF check, CLI tests, complete Wayland mock, executable inspection, native `us(intl)` parser, X.Org importer, and locale-pack build. The isolated IBus daemon and separately D-Bus-activated portal both acquired their bus names. Mutter's native physical-XKB Compose/dead-key/save canary passed, and the second process completed the text-input-v3 manager bind/focus/enable/state-commit handshake. The only failing assertion remains live IBus Simple preedit: sending evdev `KEY_APOSTROPHE=40` leaves NekoEdit's preedit empty.

The latest change adds a **test-only, non-consuming Clutter capture observer** to the temporary GNOME Shell extension. It records the last key press and release seen at `global.stage` capture phase, with the translated keysym, XKB keycode, Unicode value, and modifier state. The probe waits until both apostrophe press and release have been observed, then includes those values in the failure report. The observer always returns `Clutter.EVENT_PROPAGATE` and is disconnected when the extension is disabled; it does not replace, suppress, or synthesize the application's key events. This will establish whether Mutter maps evdev 40 to XKB keycode 48 / `dead_acute` (keysym `0xfe51`) before the IBus provider is expected to send preedit. A follow-up review corrected the Python event-counter regex before the patch was published.

No application source or runtime dependency is changed. This test/diagnostic update awaits Actions; no live IBus preedit/commit pass is claimed.


This diagnostic attempt was superseded after Actions #846 showed that the observer saw only the earlier Ctrl events and not the apostrophe sent to the focused NekoEdit Wayland client. A global-stage capture callback is not authoritative for events consumed by GNOME Shell's Clutter input method. The observer was removed; the live probe now inspects the actual backend `Clutter.InputMethod` state and independently checks the client's text-input-v3 events.

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

## 2026-11-12 — pace Wayland redraws with frame callbacks (CI pending)

The native Wayland backend now requests one `wl_surface.frame` callback before each normal redraw commit and tracks its client object ID separately from `buffer_busy`. A further repaint is admitted only after the frame callback and the current shared-memory buffer have both completed their independent lifecycles. If callback.done arrives first, the still-busy buffer remains protected; if wl_buffer.release arrives first, the callback remains outstanding. When both have arrived, the latest visual state is rendered once. Intermediate edits stay represented by `redraw_pending`.

The mock compositor intercepts `wl_surface.frame`, tracks callback IDs, and emits the one-shot `wl_callback.done` after the carrying commit. Its reverse-order regression withholds the callback, sends buffer release, types another character, asserts no surface request was sent early, then releases the callback and verifies one coalesced follow-up frame. A separate normal run asserts that all requested callbacks complete.

The existing one-active-buffer design remains unchanged. The patch does not add a buffer ring, output/fractional scaling, a callback timeout, or X11. Code and test are in [0917374](https://github.com/GraderGamer2/NekoEdit/commit/09173744284281ce8363555f1aef1bea5161650d). A new Actions run is pending; this entry makes no local-build or CI-success claim. The outstanding live GNOME Shell/Mutter + IBus Simple preedit test remains a separate issue.

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

## 2026-11-11 — derive the XKB alphabetic-key guard from canonical Unicode levels

- Build and test [#825](https://github.com/GraderGamer2/NekoEdit/actions/runs/42996770082) passed the executable build, command-line tests, complete Wayland mock suite, and ELF inspection. The new native libxkbcommon probe then failed at the final `xkb_symbols` guard: it reported 84 parsed values but zero alphabetic key pairs.
- The 84 count exceeds the minimum 16-symbol threshold. The rejected condition is the 12-letter-pair guard, which was reading `xkb_ascii_levels`, an auxiliary byte table, rather than the canonical `xkb_unicode_levels` cells that contain the actual symbols used by the editor.
- Updated `.Lxkb_key_block_done` to count a lowercase Group1 symbol followed by its corresponding uppercase symbol from the Unicode scalar table. The minimum remains 12; this is a data-source correction, not a validation relaxation.
- Added bounded error samples for AD01, AC01, and AB01 to preserve the first two Unicode levels and ASCII mirrors before `xkb_reset_keymap()` clears the failed map. The C probe prints these only if parsing still fails, and its counter line now emits a normal newline.
- Build and test #826 will validate the real `us(intl)` map and exact Compose/dead-key positions. No Mutter pass is claimed until that and the later compositor stage complete.
## 2026-11-11 — report symbol and alphabetic-key totals when the real map fails stage 4

- Build and test [#824](https://github.com/GraderGamer2/NekoEdit/actions/runs/42995879521) passed the freestanding build, CLI tests, complete Wayland mock suite, and ELF inspection. The native parser probe then reported stage 4 (`xkb_symbols`), byte offset 66,422, and final token `}`.
- Inspected `.Lxkb_parse_symbols`: after reaching the symbols-section closing brace, it rejects maps with fewer than 16 parsed symbols or fewer than 12 alphabetic keys. The failure is therefore at section completion; the previous token/offset alone could not distinguish which threshold fired.
- Exported two bounded diagnostic values copied before the parser resets its keymap state: `.Lxkb_symbol_count` and `.Lxkb_alpha_key_count`. The native C probe now prints both counters alongside the stage/token diagnostics.
- Build and test #825 will distinguish whether the parser is not collecting enough symbols at all or whether its alphabetic-key detection is too strict for this valid XKB map. No minimum threshold or parser acceptance rule has been changed.
## 2026-11-11 — instrument the XKB parser's top-level failure stage and token

- Build and test [#823](https://github.com/GraderGamer2/NekoEdit/actions/runs/42994629933) passed executable build, CLI tests, Wayland mocks, ELF inspection, and compilation of the native probe. The probe generated a valid 66,429-byte libxkbcommon `us(intl)` / `compose:ralt` text-v1 keymap, then NekoEdit's `xkb_parse_keymap()` returned `-1` and reset `xkb_keymap_ready` to zero.
- Added bounded parser diagnostics: the top-level pass, current text byte offset, token length, and last token. The parser records these immediately on failure before it resets its regular map data. Stage values are: 1 virtual-modifier scan, 2 keycodes, 3 first types pass, 4 symbols, 5 compat, 6 virtual-modifier resolution, 7 second types pass.
- Extended `tests/xkb_native_keymap_test.c` to print the diagnostic fields when the real keymap is rejected. The instrumentation does not relax validation or alter the fallback path.
- Build and test #824 will identify the exact parser stage and token so the next fix can target the unsupported XKB construct rather than broadly accepting unknown syntax.
## 2026-11-11 — fix native XKB keymap probe compilation and inspect the correct table

- Build and test [#822](https://github.com/GraderGamer2/NekoEdit/actions/runs/42992625113) passed the freestanding executable build, CLI tests, Wayland mock suite, and ELF inspection. It failed at the new host-side `test-xkb-native` step during C compilation.
- The compiler error was an invalid assumption that libxkbcommon exposes `xkb_context` and `xkb_keymap` typedefs. Its public API uses `struct xkb_context *` and `struct xkb_keymap *`; corrected every declaration and function parameter accordingly.
- Corrected the probe's assertion model as well. NekoEdit's `xkb_unicode_levels` stores the values consumed by keyboard dispatch: Unicode scalars and reserved internal action markers (`Multi_key` 0x110007, dead_grave 0x110001, dead_circumflex 0x110003). `xkb_keysym_levels` is intentionally only the raw modifier-keysym table, so comparing general symbols against it would be incorrect even after compilation.
- The test now compares `xkb_unicode_levels[keycode*32 + group*8 + level]` against the corresponding action marker or Unicode scalar for each keymap symbol location returned by libxkbcommon.
- Build and test #823 will run the corrected probe before pinned importer, locale pack, and Mutter integration stages. No editor source was changed in this correction.
## 2026-11-11 — test the assembly XKB parser against a real us(intl) keymap

- Build and test [#821](https://github.com/GraderGamer2/NekoEdit/actions/runs/42989531248) passed the freestanding build, CLI, full Wayland protocol mock, ELF, pinned X.Org importer, and four separate locale-pack stages. The Mutter test also confirmed the startup `us(intl)` keymap call, editor MetaWindow activation, native document-body click, and ordinary edit/save. Compose still left grave/circumflex as literal characters.
- The remaining uncertainty is whether the editor's assembly parser accepts the exact keymap text generated for `us(intl)`, and whether its parsed keycode/group/level symbols match libxkbcommon. Mutter setup changes alone cannot establish that.
- Added `tests/xkb_native_keymap_test.c`. It uses libxkbcommon to compile `evdev` / `pc105` / `us` / `intl` / `compose:ralt`, serializes the actual XKB v1 text, passes it to the existing `xkb_parse_keymap()` function, and checks that NekoEdit retains the keysyms `Multi_key`, `dead_grave`, `dead_circumflex`, `period`, and `A` at the same positions as libxkbcommon.
- Added a separate `make test-xkb-native` target and CI step. CI installs `libxkbcommon-dev` only to build/run this host diagnostic; neither the application build nor its runtime dependency set links to libxkbcommon. The ordinary `make test` target is unchanged.
- Build and test #822 will report whether a real `us(intl)` map is rejected or misparsed before the next live Mutter debugging change.
## 2026-11-11 — send the configured Mutter keymap before NekoEdit's first wl_keyboard bind

- Build and test [#820](https://github.com/GraderGamer2/NekoEdit/actions/runs/42988594141) passed all pre-Mutter checks, the native pointer click, and the ordinary edit/save canary. The extension's `ApplyKeymap` call also returned the expected `us` / `intl` / `compose:ralt` / `pc105` tuple, but the final file still contained literal grave/circumflex characters.
- In #820, `ApplyKeymap` ran after NekoEdit had launched and bound `wl_keyboard` with the default plain-US keymap. NekoEdit's dynamic keymap listener exists, but the integration result did not establish that the new map had been consumed before the synthetic key sequence. The harness no longer uses that ambiguous order.
- Moved the same direct Mutter backend call to after Shell startup and keyboard-device priming but before launching NekoEdit. The editor's initial `wl_keyboard.keymap` FD should therefore already describe `us(intl)` with `compose:ralt`; the Compose test no longer depends on a runtime keymap change. Session GSettings remains configured and verified.
- Build and test #821 will validate the initial-map path and exact UTF-8 output. No application source or runtime dependencies were modified.
## 2026-11-11 — call Mutter's backend keymap API directly before the Compose integration sequence

- Build and test [#819](https://github.com/GraderGamer2/NekoEdit/actions/runs/42987693384) passed the build, CLI tests, Wayland protocol mock, ELF inspection, pinned X.Org regeneration, and all four separate locale-pack builds. The headless Mutter integration also passed native pointer focus and the basic typing/save canary.
- The Compose phase still failed. The temporary GNOME keyfile read back `us+intl`, `compose:ralt`, and `pc105`, but Mutter emitted ordinary grave/circumflex symbols, so the Settings values had not been applied to the active native backend keymap before input.
- Inspected GNOME Shell 46.2 `js/misc/keyboardManager.js`: its `KeyboardManager._applyLayoutGroup()` calls `global.backend.set_keymap(layouts, variants, options, model)` and locks the selected group through the same backend object.
- Added a constrained `ApplyKeymap` method to the temporary extension. After the basic canary, the harness calls it to set `us`, `intl`, `compose:ralt`, `pc105`, then locks group 0 before injecting the Compose/dead-key sequence. This avoids a startup ordering dependency while using the same API as GNOME Shell's normal input-source manager.
- Build and test #820 will verify keyval-to-keycode mapping and exact `…Ầ` output. No application source or runtime dependencies changed; the extension and GNOME settings remain test-scoped.
## 2026-11-11 — configure GNOME Shell's actual XKB map before Mutter Compose testing

- Build and test [#818](https://github.com/GraderGamer2/NekoEdit/actions/runs/42986520195) passed the full freestanding build, command-line tests, Wayland protocol mock, ELF inspection, pinned-source importer comparison, and all four locale-pack builds. The native Mutter test now successfully focused the document with a RemoteDesktop pointer click; its basic Ctrl+A / x / Ctrl+S / Enter canary saved exactly `x`.
- The Compose phase failed with file bytes `..A`. Mutter logged `No keycode found` for `Multi_key` (0xff20), `dead_grave` (0xfe50), and `dead_circumflex` (0xfe52), while ordinary ASCII keysyms resolved. This directly showed that the native backend keymap did not contain the requested Compose/dead-key symbols.
- Inspected Mutter 46.2: `meta_seat_native_new()` initializes the native seat with a plain `us` layout and empty options; the `XKB_DEFAULT_*` variables in the smoke test do not configure this backend. GNOME Shell `KeyboardManager` reads `org.gnome.desktop.input-sources` and applies its layout/options to the native backend.
- Updated the isolated temporary GLib keyfile settings before Shell startup: `sources=[('xkb','us+intl')]`, `mru-sources=[('xkb','us+intl')]`, `xkb-options=['compose:ralt']`, and `xkb-model='pc105'`. The test reads the values back and aborts if any differ. Removed misleading ineffective XKB environment exports.
- Documented the actual physical key sequence expected under `us(intl)`: Right Alt for Multi_key, grave for dead_grave, Shift+6 for dead_circumflex, and Shift+A for A. Build and test #819 will verify lookup and the final UTF-8 output. No editor source or runtime dependency changed.
## 2026-11-11 — focus the document body with a native Mutter pointer click before key injection

- Build and test [#817](https://github.com/GraderGamer2/NekoEdit/actions/runs/42982720723) passed the build, CLI tests, full Wayland mock, ELF inspection, pinned X.Org import comparisons, and four separate locale-pack builds. Mutter's native headless backend and virtual monitor started; NekoEdit's MetaWindow was focused; the RemoteDesktop keyboard device was created before the editor launched. The basic edit/save canary still left the file unchanged after Ctrl+S and Enter.
- Confirmed from Mutter 46.2 source that RemoteDesktop virtual keyboard devices are physical-mode Clutter devices and pass the Wayland seat's supported-hardware filter. `MetaWindow.activate()` is connected through Mutter's `focus-window` signal to the Wayland seat input-focus surface. This makes the prior device-classification/focus explanations insufficient.
- Added a bounded pointer-click operation to the temporary GNOME Shell extension. It reads the current stage pointer position, gets NekoEdit's frame rectangle, computes a target 65% down the frame (inside the document body), and uses `NotifyPointerMotionRelative` plus left-button press/release in the same RemoteDesktop session.
- The harness waits for explicit pointer motion and button completion, then sends the basic keyboard/save canary. This exercises the editor's own document-area click path rather than assuming window activation alone established internal focus. No editor runtime code or dependencies changed.
- Build and test #818 will validate the change. No success is claimed yet.
## 2026-11-11 — prime the Mutter native virtual keyboard before NekoEdit binds wl_seat

- Build and test #816 passed the freestanding build, command-line tests, full Wayland protocol mock, ELF inspection, pinned X.Org byte-for-byte regeneration, and four optional locale-pack builds. The native headless Mutter session focused NekoEdit, started the RemoteDesktop session, and completed the D-Bus key-notification calls. The basic edit/save canary still left the file unchanged even after Enter was sent to accept the default save-confirmation modal.
- Inspected Mutter 46.2 source: `ensure_virtual_device()` creates the remote-desktop virtual keyboard lazily on the first pressed key. The resulting Clutter `device-added` signal recomputes `wl_seat` capabilities. When keyboard capability becomes enabled, `meta_wayland_keyboard_enable()` initializes the keyboard focus from the seat's current input-focus surface.
- The previous harness started and focused NekoEdit before creating this virtual keyboard device. Changed test order to create/start the RemoteDesktop session and send/release Ctrl_L before launching NekoEdit. The first press instantiates the device; the editor should then see keyboard capability during its initial seat bind. The key is released while no editor window exists, so it cannot modify the document.
- NekoEdit is then launched, its MetaWindow activated, and the two byte-checked keyboard scenarios run as before. No application source, runtime dependency, workflow package, or binary architecture changed.
- Build and test #817 is triggered by this exact test-harness change. It must validate the native event path; no success is assumed beforehand.
## 2026-11-11 — accept NekoEdit's default save confirmation in the native Mutter smoke test

- Build and test [#815](https://github.com/GraderGamer2/NekoEdit/actions/runs/42965658728) passed all build, CLI, Wayland mock, ELF, pinned locale-data, and optional locale-pack stages. The native headless Mutter backend started, found and activated NekoEdit's MetaWindow, created the RemoteDesktop input session, and reported all queued key-notification D-Bus calls complete. The saved document nevertheless remained unchanged.
- Rechecked the actual save-confirmation behavior in tests/wayland_mock.py: confirm-before-save defaults to enabled; Ctrl+S opens a modal without writing; Escape cancels it; Enter accepts and commits the save. The Mutter canary had sent Ctrl+S but omitted Enter. Its unchanged-file assertion therefore could not distinguish absent keyboard input from the expected pending confirmation dialog.
- Updated both basic and Compose save paths in tests/mutter_gnome_smoke.sh to send Return (keysym 65293) after Ctrl+S. The file comparison happens only after the confirmation key and after the input queue drains. Failure text no longer mislabels a failed file comparison as proof that keys were not delivered.
- Updated docs/MUTTER_INTEGRATION_TEST.md to document the confirmation requirement and exact canary.
- Build and test #816 is triggered by this source/test commit. It must validate both the basic edit/save canary and the Multi_key / two-dead-key output; no success is assumed before the run completes.
## 2026-11-11 — monitor Xvfb raw key events independently in the nested Mutter test

- Build and test [#813](https://github.com/GraderGamer2/NekoEdit/actions/runs/42961793193) passed every pre-Mutter stage but failed the ordinary key/save canary. Mutter found NekoEdit's focused MetaWindow and reported frame rectangle `0,32,800,568`; the test clicked its frame center at `400,316`. The X11 host focus check remained valid, yet the document stayed `seed`.
- The extension's Clutter stage `captured-event` callback observed no key events. This callback is not a sufficient diagnostic for events forwarded to an independently focused nested Wayland client, so it is not used as the sole indicator of host keyboard delivery.
- Added an independent `xinput test-xi2 --root` event monitor around the plain Ctrl+A / x / Ctrl+S canary. The harness now captures raw/device key events from the Xvfb root and requires that at least one key press was emitted before evaluating the saved document. This separates XTest/Xvfb generation from nested-Mutter-to-Wayland forwarding.
- Added `xinput` to the CI-only test tool installation and documented the monitor. No change to NekoEdit's freestanding binary or runtime dependency set.
- Build and test [#814](https://github.com/GraderGamer2/NekoEdit/actions/runs/42963271284) is running on [1e34ec6fe546](https://github.com/GraderGamer2/NekoEdit/commit/1e34ec6fe54661e447713e73c90d2020a0744fb4). The build and command-line checks passed; the Wayland mock suite is in progress.

## 2026-11-11 — replace Clutter keyval injection with XTest events from the focused Xvfb host

- Build and test #810 passed all stages before the nested Mutter test. The test found NekoEdit, confirmed its inner Wayland MetaWindow was focused, and also verified the outer GNOME Shell X11 window had X input focus. Nevertheless, the Clutter virtual-keyboard sequence did not update the document.
- Re-examined the test's input path rather than touching editor keyboard processing. Replaced the Clutter SendKey / SendShortcut D-Bus methods with direct XTest events generated by xdotool on the outer Xvfb display. The test still focuses the actual Wayland target by PID and confirms the X11 host owns X input focus before sending input.
- The host XKB map is explicitly set to us(intl) with compose:ralt via setxkbmap, and the resulting layout, variant, and option are checked before GNOME Shell starts. The workflow installs x11-xkb-utils as a test-only package. The extension now has only readiness and PID-based activation methods.
- Updated docs/MUTTER_INTEGRATION_TEST.md to describe the XTest-to-nested-Wayland route and removed claims that the extension injects keys. No editor source or runtime dependencies changed.
- Build and test [#811](https://github.com/GraderGamer2/NekoEdit/actions/runs/42960747590) is running on [3477b605c01b](https://github.com/GraderGamer2/NekoEdit/commit/3477b605c01bba5fb686dc462766a47026f93d9a). Its build, CLI, Wayland mock, ELF, pinned data, and four locale-pack steps passed; the Mutter integration step is still in progress.

## 2026-11-11 — verify the outer X11 host and inner Wayland focus before Mutter virtual input

- Build and test [#809](https://github.com/GraderGamer2/NekoEdit/actions/runs/42946768420) passed its build, CLI/host suite, Wayland mock, ELF inspection, pinned X.Org importer comparison, and all optional locale-pack builds. The nested GNOME Shell extension loaded correctly and reported NekoEdit's PID as the focused Mutter `MetaWindow`; nevertheless the basic Ctrl+A / `x` / Ctrl+S canary left the document unchanged.
- Inspected the GNOME Mutter 46.2 source rather than changing NekoEdit input code speculatively. `MetaSeatX11.create_virtual_device()` constructs `MetaVirtualInputDeviceX11`; its `notify_keyval` implementation emits `XTestFakeKeyEvent` on the outer X display. In a nested compositor, this requires both the outer GNOME Shell X11 window and the inner NekoEdit Wayland `MetaWindow` to be focused.
- Updated `tests/mutter_gnome_smoke.sh` to find, raise, and focus GNOME Shell's outer X11 window, verify its X focus, click the nested display center, activate NekoEdit's inner Mutter `MetaWindow` by PID, then verify the outer X focus was retained. The Clutter keyval injection remains the same.
- Added `xdotool` back to the workflow's test-only packages and updated the integration-test documentation with the two-focus-layer requirement. No editor runtime source, ELF properties, or runtime dependencies changed.
- Build and test [#810](https://github.com/GraderGamer2/NekoEdit/actions/runs/42959565212) is running on source commit [78adad34caaa](https://github.com/GraderGamer2/NekoEdit/commit/78adad34caaabfe1fe5699bb0042144fbdab356b). The complete Mutter input path remains unverified until that run passes the integration step.

## 2026-11-11 — isolate the Mutter test extension's GSettings backend

- Build and test [#808](https://github.com/GraderGamer2/NekoEdit/actions/runs/42946147559) passed the freestanding build and command-line/Wayland mock stages but the test extension did not register its D-Bus bridge.
- The test wrote settings through a D-Bus-activated dconf service whose environment was not reliably tied to the temporary profile. Replaced that setup with the GLib keyfile backend under the isolated `XDG_CONFIG_HOME`, asserted that the extension UUID was persisted, and declared its GNOME Shell 46 `user` session mode explicitly.
- Build and test [#809](https://github.com/GraderGamer2/NekoEdit/actions/runs/42946768420) confirmed the extension now loads and the actual NekoEdit MetaWindow can be located and activated. Its basic key/save canary still failed; the nested X11 host focus needed a separate correction, documented above.

## 2026-11-10 — trigger Build and test #807 for the restored Mutter focus harness

- Source/test commit [e57e0233e128](https://github.com/GraderGamer2/NekoEdit/commit/e57e0233e1287b7d3636e2fd4ddecc4193b5735a) restores the clean shell script and reapplies explicit GNOME Shell X11 window focus plus a basic printable-key/Save canary with a literal-safe replacement.
- The fallback title search now uses `GNOME Shell` without an anchored dollar sign. The source file was re-read from the pushed branch and the malformed insertion pattern from #806 is absent.
- Build and test #807 is running on the exact source commit. At the latest check, GitHub still reports the package-install step in progress. Do not treat the focus path or Compose input as validated until the workflow reaches and passes the Mutter step.
- This commit-index/status update is documentation-only and excluded from the Build and test workflow's path trigger.

## 2026-11-10 — restore Mutter smoke-test script after #806 shell syntax error

- Build and test #806 passed the core build, host/command-line tests, Wayland mock, ELF inspection, pinned X.Org data verification, and four separate locale-pack builds.
- The new Mutter step then failed before input testing with `tests/mutter_gnome_smoke.sh: line 239: syntax error near unexpected token '('`.
- The syntax issue came from the test-source text replacement expanding a literal dollar-sign sequence in a shell window-title regular expression. Rebuilt the script from the clean commit and applied the replacement using an ordinary callback; simplified the fallback window-title search to the literal text `GNOME Shell`.
- The direct X window focus checks, geometry-relative center click, and plain-key + Ctrl+S canary remain in the corrected script. They have not yet been executed by CI because #806 stopped at parsing.
- No production code or runtime dependencies changed. A new branch-push run is required.

## 2026-11-10 — make the nested Mutter test explicitly focus its X11 host window

- Build and test #805 passed the freestanding build, command-line/host tests, Wayland protocol mock, ELF inspection, pinned X.Org source verification, and all four separate locale-pack builds. It failed only at the nested Mutter keyboard test: GNOME Shell/Mutter started, NekoEdit stayed alive, but the source document remained unchanged after XTest events.
- The previous harness clicked a fixed root coordinate but never explicitly called XSetInputFocus on the outer GNOME Shell X11 window. CI uses bare Xvfb without a separate window manager, so the harness cannot assume normal click-to-focus management.
- Updated the harness to locate the visible Shell window using its PID, raise and explicitly focus it, verify the focused XID, query its geometry, and click the display center with window-relative coordinates.
- Added a plain printable-character + Ctrl+S canary before Compose. The expected one-byte file must be saved before the test proceeds to Right-Alt Multi_key and the two-mark dead-key chain. This distinguishes generic XTest routing from XKB Compose/locale behavior.
- Updated the test documentation with the nested keyboard-routing limitation documented by GNOME's development guide. No runtime code or dependencies changed; the locale data remains separate.
- Validation for the new focus/canary correction is pending its branch-push CI run.

## 2026-11-10 — document the nested Mutter CLI correction commit and #805 run

- Source/harness correction committed as [14e7a902699e](https://github.com/GraderGamer2/NekoEdit/commit/14e7a902699e8411bd95a4d6d332105bff665d73); the command uses the supported one-file CLI form and relies on the private WAYLAND_DISPLAY for backend selection.
- Build and test #805 was triggered by this source commit. At the time of this handoff, GitHub reported the package-install step in progress; no #805 test result is claimed.
- The #804 run had already passed the freestanding build, host suite, Wayland mock, ELF inspection, pinned-source comparison, and locale-pack build before the harness invocation failed. The compositor had started, but editor input was not exercised.
- This entry is followed by a changelog-only commit to keep the exact source correction in COMMIT_INDEX.md without triggering another build.

## 2026-11-10 — correct the nested Mutter harness command line after #804

- Build and test #804 passed the freestanding ELF build, command-line/host suite, full Wayland protocol mock, ELF inspection, pinned X.Org importer byte comparisons, and all four optional locale-pack builds.
- The nested GNOME Shell 46 / Mutter 46.2 compositor started and created the requested Wayland socket. NekoEdit exited before connecting because the harness supplied both `--backend=wayland` and a document path; the current argument parser supports either the backend-only switch or one document path, not both.
- Corrected tests/mutter_gnome_smoke.sh to launch the executable with only the temporary document path. The private WAYLAND_DISPLAY selects the native Wayland connection automatically. No production code or supported CLI syntax was changed.
- The original #804 run failed at the new integration test, so the Compose key and dead-key sequence have still not been validated through Mutter. The next branch-push run must complete before this milestone can be called green.

## 2026-11-10 — make held-key repeat mock assertions wait for actual document edits

- Recorded Build and test #803 failure: build, command-line/host tests and locale tests passed; tests/wayland_mock.py failed at the legacy seat-v3 held-Tab assertion with unchanged caret coordinates (48,128). The new nested Mutter step was not reached.
- The mock's repeat sequence checked the next redraw but did not assert that a timer-driven edit had occurred before sampling the frame. Updated the held Enter and Tab cases to wait for doc_cursor to advance by one newline byte or four inserted spaces, respectively.
- The mock now sends key-up after the first observed repeat, waits for repeat_keycode to clear, and then reads the repeat frame. This avoids accepting a queued initial redraw and avoids extra periodic timer ticks affecting the expected caret position.
- No production assembly/C code or executable behavior was changed. The runtime's existing 300 ms / 30 Hz compatibility fallback is unchanged.
- CI result for the correction is pending. Do not treat the new Mutter harness as validated; run #803 stopped before its step.

## 2026-11-10 — add nested GNOME Shell/Mutter Compose integration test (CI pending)

- Added tests/mutter_gnome_smoke.sh, a test-only Xvfb + D-Bus harness that starts GNOME Shell as a nested Wayland compositor and connects the normal freestanding editor to its Wayland socket.
- The harness configures us(intl) with compose:ralt, selects a separately copied pt_BR.UTF-8 NLP1 pack beneath a temporary HOME, and sends XTest events for Right-Alt Multi_key + period + period, followed by dead_grave + dead_circumflex + A. It then checks that Ctrl+S saved exactly U+2026 U+1EA6.
- Added make test-mutter after the separate locale-pack build; the regular host and protocol-mock targets remain independent of GNOME/Xvfb packages.
- Updated the branch-push workflow to install gnome-shell, xvfb, xauth, xdotool, x11-xkb-utils, and dbus-daemon, then run the new target. Increased the job timeout to accommodate the additional compositor packages and startup.
- Added docs/MUTTER_INTEGRATION_TEST.md and linked it from README. The documentation explicitly distinguishes real Mutter protocol delivery from physical keyboard validation.
- Local execution was unavailable in this connector session; CI is pending on the push of this source/workflow commit. No successful run is claimed here. Follow up by recording the exact run and job results after Actions reports.
- Test input uses a temporary HOME and data-only locale file. No locale packs or test dependencies were added to the runtime binary.

## 2026-11-10 — Wayland multi-dead-key chains and locale data refresh — #802 passed

- Added a Wayland keyboard dead-key state that buffers up to three combining marks, then queries a kind-1 locale record with the final base scalar. Preserved the existing one-mark precomposition path and added base-plus-marks literal fallback when no multi-mark locale rule exists.
- Implemented a bounded flush path for a fourth dead action and when entering Multi_key; Escape and Backspace clear all pending dead-key state. NLP1's 52-byte record and four-input maximum remain unchanged.
- Extended the native Settings importer, offline user XCompose converter, and pinned X.Org Compose importer to accept one to three leading `dead_*` actions plus one final ordinary character. Invalid intermediate or final dead-key actions and deeper chains are excluded.
- Regenerated the four pinned optional locale tables. The shared baseline now has 1,576 dead-key records. Final counts are pt_BR 4,484; fi_FI 4,488; sr_RS 4,495; el_GR 5,730. Detailed distributions and override counts are in `data/locales/README.md`.
- Added importer, pack, locale-manager, locale-data, and Wayland mock tests. Coverage includes two-/three-mark lookup, literal fallback, the four-mark cap, cancellation, and real generated Portuguese and Greek chain records.
- CI #798 and #799 exposed only the expected old-JSON/pinned-importer mismatch after newly accepted source rules. A one-time refresh in #800 committed exact outputs as `c61453d`; this used temporary write permissions that were removed by `81e6272`. The intermediate read-only run #801 then caught stale expected statistics; updated the golden test in `91a92c3`.
- Final [Build and test #802](https://github.com/GraderGamer2/NekoEdit/actions/runs/42810208303) passed all 14 steps on `91a92c38210362def100026afd60e7b08132d08f`, including the freestanding ELF check, all host tests, Wayland protocol mock, executable inspection, pinned source regeneration/comparison, optional pack generation, and separate uploads.
- Final artifacts: editor ZIP 13761918009 (135,673 bytes, SHA-256 `ab71efb788fcf25dc14c232c369a60a5edfa61dbecb339d08ee28fa238cd49e8`); locale ZIP 13762312971 (114,239 bytes, SHA-256 `5605356b9d3b38fe5fa1b08334645ba62e8224904119b702ec3f5709c8fd8a52`). Both expire 2026-11-11 11:48 UTC / 18:48 Jakarta.
- The temporary workflow changes are gone: `.github/workflows/build.yml` is read-only (`contents: read`) with no artifact-debug or data-push block. No runtime dependency, embedded optional locale, or binary pack-format change was introduced.
- Automated Wayland mock success is not live Mutter validation. The latest user-confirmed build launches, but new chained-key behavior still needs physical GNOME/Mutter testing. X11 backend work remains deferred.

### Commit and CI sequence

| Commit / run | Result |
|---|---|
| `e2521c4` | Implemented the Wayland and importer multi-dead-key chain support. |
| #798 | Built and passed the command/Wayland/ELF checks; stopped at stale pinned locale JSON comparison. |
| `39688a7` | Temporary artifact-only workflow instrumentation to retain exact generated JSON. |
| #799 | Captured generated outputs; stopped at the same expected old-data comparison. |
| `9419447` | Temporary one-time CI data refresh permission/step. |
| #800 | Passed all steps and produced the refreshed data commit below. |
| `c61453d` | CI-generated exact locale-table refresh. |
| `81e6272` | Removed temporary write step, restored read-only permissions, updated locale-data counts. |
| #801 | Correctly caught stale golden data assertions against the refreshed JSON. |
| `91a92c3` / #802 | Updated locale count/depth and real chain assertions; all 14 steps passed. |


## 2026-11-10 — native XCompose import uses the shared XKB Unicode keysym table — #797 passed

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

## 2026-11-10 — native XCompose macro includes and compose.dir locale mapping; Build and test #795 passed

- Extended the freestanding Settings importer to expand `%H`, `%S`, and `%L` in addition to depth-first sibling includes. Home/system roots are cached; nested siblings resolve from the directory of the file containing each directive.
- Implemented bounded X.Org `compose.dir` lookup for `%L`. Locale precedence is `LC_ALL`, `LC_CTYPE`, `LANG`, then `C`; `POSIX` aliases `C`. Normalized locale names are matched exactly, including the `el_CY.UTF-8` → `el_GR.UTF-8/Compose` alias and separate `C`/`C.UTF-8` mappings.
- The mapping file is a regular no-follow input, with bounded file/line sizes and bytes charged to the aggregate budget. Its mapped relative path is validated component-by-component and the target uses the same safe include opener.
- Added tests for all three macros, nested system includes, locale aliasing, the C mapping, missing roots, traversal, file/directory symlinks, and existing cycle/depth/expansion and no-partial-publish checks.
- CI #791 caught the helper buffer declaration mismatch; #792 caught `-Werror=format-truncation` in test path arrays; #793 passed the first rooted-include implementation. The compose.dir version compiled and passed smoke tests in #794, where the alias fixture exceeded NLP1's eight-scalar output cap; it was shortened without changing the runtime ceiling. Build and test [#795](https://github.com/GraderGamer2/NekoEdit/actions/runs/42743763387) passed all 14 steps, including the Wayland mock, ELF checks, pinned X.Org verification, locale build, and separate artifact uploads.
- #795 artifacts: editor ZIP 13729764162 (135,652 bytes); locale ZIP 13730980366 (101,677 bytes), both expiring 2026-11-11 02:36 UTC / 09:36 Jakarta.
- Commits: [391b0c66d89c](https://github.com/GraderGamer2/NekoEdit/commit/391b0c66d89c9ee734c5f652de8bf733a30ab6af), [575db597c7b0](https://github.com/GraderGamer2/NekoEdit/commit/575db597c7b0b8e0c3874d9fd7c1ffdb0c6bcddd), [6bf83dce7b34](https://github.com/GraderGamer2/NekoEdit/commit/6bf83dce7b3437aadda06574f6cccd4175cd83e8), [ae6323501b66](https://github.com/GraderGamer2/NekoEdit/commit/ae6323501b66e1d8bf5d36d044454c0ad7f00570), [a4bdccc12147](https://github.com/GraderGamer2/NekoEdit/commit/a4bdccc12147c38e81008dee37c545c75e628e48).
- Limits remain 512 KiB aggregate input including compose.dir, 512 KiB per Compose file, 32 unique files, 64 expansions, 16 active levels, 64 KiB per line, and 32,768 records. Native input remains UTF-8-only and bounded; no startup discovery, non-UTF-8 parsing, external helper/runtime dependency, or optional locale table was added to the executable. No live GNOME/Mutter or physical-keyboard verification is claimed.

## 2026-11-10 — early-alpha-only Greek Compose locale pack

- The early-alpha branch added an optional `el_GR.UTF-8` pack derived from pinned standalone libX11 Compose source blob `4a644258ce32cd34ddcc0c47605938db5f697b7d`. Its generator explicitly merges the source over the same pinned en_US baseline.
- The data contains 4,690 final records (922 accepted locale Multi_key rules and 138 dead-key rules). Golden data tests cover Greek accent and breathing-mark sequences. These are not live keyboard test results.
- Build and test [#790](https://github.com/GraderGamer2/NekoEdit/actions/runs/42738784199) passed the full build, host tests, Wayland mock, pinned source re-import/byte-for-byte comparison, locale pack build, and separate artifact uploads.
- This is a branch-only data/workflow milestone; `main` still embeds only its en_US prototype and does not contain the Greek pack or its release workflow changes. PR #2 remains open and unmerged.

## 2026-11-10 — safely expand sibling includes in native Settings XCompose import

- Extended the freestanding native importer to expand quoted same-directory sibling includes in depth-first textual order. Repeated non-active includes are allowed; active cycles are rejected using device/inode identity.
- Root and include files are opened relative to a retained root-directory descriptor. A target must be one basename in the same directory; path separators, absolute paths, traversal components, percent/environment substitutions, and symlinks are rejected. Inputs must be regular files opened with O_NOFOLLOW.
- Added strict bounds: 512 KiB aggregate expanded input, 512 KiB per file, 32 unique files, 64 total include expansions, 16 active include levels, 64 KiB per line, and 32,768 records. Failure occurs before pack construction/publication, so no partial pack can be installed.
- Regression tests verify nested/repeated include behavior and precedence, parent traversal, symlinks, cycles, include-expansion exhaustion, and recursion depth, in addition to existing import/pack/permissions tests.
- Updated README and docs/COMPOSE_USER_IMPORT.md to distinguish the native sibling-include subset from the host-side converter's %H/%S/%L and cross-directory policy.
- Build and test #786 failed only because the include test's expected output path had a duplicated /locales segment. Corrected in [752c24664911](https://github.com/GraderGamer2/NekoEdit/commit/752c24664911f672c7c672cfd2a01fc33ad6cdd9). Build and test [#787](https://github.com/GraderGamer2/NekoEdit/actions/runs/42736381984) passed all 14 steps.
- Artifacts: editor ZIP 13727451420 (133,624 bytes) and locale ZIP 13727765638 (74,021 bytes), expiring 2026-11-11 01:32:59 UTC and 01:32:58 UTC respectively.
- Implementation commit: [d56bffc9ebe7](https://github.com/GraderGamer2/NekoEdit/commit/d56bffc9ebe79c16d37e9d95ed776f1beb331233).

## 2026-11-10 — native raw XCompose import from Settings; Build and test #785 passed

- Added a native, bounded UTF-8 XCompose parser to `src/backend/compose_locale.c` and a new **Settings → Locale → Import** action/picker flow in `src/backend/wayland.S`. This is an in-app feature: the editor does not launch Python, shell commands, or an import helper.
- The importer creates a separate NLP1 data pack under `~/.nekoedit/locales/`. The tag is derived from the selected filename, e.g. `nekoedit-test.XCompose` becomes `nekoedit-test.UTF-8`. It validates with the same NLP1 runtime validator, writes privately and atomically, refuses to overwrite an existing pack, preserves the selected source, activates the imported locale, and persists the choice.
- Bounded in-app support: UTF-8 self-contained rule files; Multi_key with two to four following Unicode keysyms; a recognized dead-key action plus one following keysym; quoted UTF-8 results and simple/octal/hex/Unicode escapes; printable ASCII keysym names and a curated common set. Later identical rules override earlier rules and shorter same-kind prefixes are removed. Includes and unsupported syntax fail closed or are skipped; the optional host converter remains the route for include-rich or broader X.Org input.
- Work buffers are mapped only during import and released afterward. They do not reserve multi-megabyte static locale tables in the editor. No locale datasets are linked into the executable.
- Added `tests/compose_locale_import_test.c` to verify pack generation and actual runtime lookup, permissions, no-overwrite, source preservation, symlink rejection, include rejection, dead-key and multi-input behavior, and Unicode escapes.
- Extended `tests/wayland_mock.py` to use the actual Settings Import button and picker with a raw `.XCompose` file. The test verifies the generated file, activation, preference persistence, source preservation, and private mode.
- Build and test [#784](https://github.com/GraderGamer2/NekoEdit/actions/runs/42731335861) passed the native importer host test and all previous checks. Build and test [#785](https://github.com/GraderGamer2/NekoEdit/actions/runs/42731684293) passed all 14 workflow steps with the new end-to-end Settings Import mock.
- The separate artifacts from #785 are editor ZIP 13725565793 (132,507 bytes) and locale ZIP 13725635467 (74,021 bytes), both expiring 2026-11-11 00:54 UTC.
- Implementation and UI-test commits: [a5e75d0d6cee](https://github.com/GraderGamer2/NekoEdit/commit/a5e75d0d6cee29167c33bddb11e00fc75b0a1978), [81fb2ca891cd](https://github.com/GraderGamer2/NekoEdit/commit/81fb2ca891cdf897c6c7509124fe719264c5a2f7), [86ea3d00ee2b](https://github.com/GraderGamer2/NekoEdit/commit/86ea3d00ee2b59cf10fb6b0426b4d0abe75dbab3), and [4572affe38eb](https://github.com/GraderGamer2/NekoEdit/commit/4572affe38ebf9b771913fff85b8ca7a0f25fb5d).

## 2026-11-10 — validate user XCompose import against the installed X.Org corpus

- Added `tests/system_xcompose_import_test.py` and wired it into `make test`. It uses the actual installed `/usr/share/X11/locale/en_US.UTF-8/Compose` file through a temporary user `.XCompose` with `include "%L"`, rather than checking only synthetic parser fixtures.
- The test asserts the known `Multi_key o c` system rule is overridden by a later user rule, `dead_acute + e` produces é, a user-only rule is imported, include order is counted, and the full corpus produces enough records to prove that it was traversed. The NLP1 encoder validates the generated pack in memory; no locale is installed.
- Build and test [#781](https://github.com/GraderGamer2/NekoEdit/actions/runs/42728278622) passed the new system-corpus test, all existing host tests, the full Wayland mock, pinned X.Org regeneration, locale-pack build, and separate artifact uploads.
- The test reported 5,127 scanned rules, 3,747 final records, two include-expanded files, two overrides, and 194,916 packed bytes.
- Added only test-environment packages `libx11-data` and `x11proto-dev` to CI. They do not enter the build or runtime dependency graph.
- Documented the modular packaging invariant: only en_US is built into the editor; non-en_US and user-created locale tables stay in separate `.nlp` files that can be offered as optional Release assets later. The app build remains independent of those pack files.
- CI artifacts remain distinct: editor ZIP 13723627010 (127,343 bytes) and locale ZIP 13723811429 (74,021 bytes), each expiring 2026-11-11 00:27 UTC under the one-day policy.
- Source/test/docs implementation: [a11a4b0ede67](https://github.com/GraderGamer2/NekoEdit/commit/a11a4b0ede6711f5abed47f8e8c2cf666fb5a841).

## 2026-11-10 — reduce early-alpha Actions artifact retention to one day

- Changed both artifact uploads in `.github/workflows/build.yml` (the executable and optional Compose locale pack) from `retention-days: 90` to `retention-days: 1` in commit [a0d707c5a30c](https://github.com/GraderGamer2/NekoEdit/commit/a0d707c5a30ca6ff27b4005939ffa80fc4678cc1).
- Changed the manual/release locale-pack upload in `.github/workflows/locale-packs.yml` to `retention-days: 1` in commit [9859912d75d3](https://github.com/GraderGamer2/NekoEdit/commit/9859912d75d3d8dc8941653e09316e141fc0ac3f).
- The Build and test path filter now ignores changelog-only updates and changes confined to the separate manual/release locale-pack workflow. This avoids redundant editor builds.
- The one-day setting affects newly uploaded artifacts only. The existing artifacts from Build and test #777 keep their previously assigned 90-day expiry; this change does not delete or shorten them.
- No editor source, binary, or runtime behavior changed. The available GitHub connector only exposes pull-request-triggered workflow-run lookup, so the push-triggered run ID and artifact `expires_at` could not be independently retrieved in this session. The workflow YAML itself is verified. Check [Build and test runs on early-alpha](https://github.com/GraderGamer2/NekoEdit/actions/workflows/build.yml?query=branch%3Aearly-alpha) for the push run.

## 2026-11-10 — set GitHub Actions artifact retention to 90 days — Build and test #777 passed

- Confirmed that NekoEdit is a public repository and that the active Build and test workflow explicitly shortened both uploaded artifacts to 7 days. The optional locale-pack workflow separately used 30 days.
- Changed both Build and test artifact uploads and the locale-pack workflow upload to `retention-days: 90`, the maximum documented for public repositories.
- This only affects future uploads. Existing #776 artifacts (editor ZIP 13697074317 and locale ZIP 13698660427) keep their original November 16, 2026 expiry; the workflow push will create fresh artifacts with the new retention period.
- GitHub Free includes 500 MB of Actions artifact storage shared with Packages. The latest two NekoEdit artifacts total 201,364 bytes; usage above the included storage can incur charges. Standard GitHub-hosted runners are free for public repositories.
- No editor source, binary, or runtime behavior changed. No new application dependencies were introduced.
- Commit [d9a2d9cca407](https://github.com/GraderGamer2/NekoEdit/commit/d9a2d9cca407f5dc60f7d5e2947600b9329bd0f5) pushed the workflow changes to `early-alpha`. Build and test [#777](https://github.com/GraderGamer2/NekoEdit/actions/runs/42725593861) passed all 13 steps, including the Wayland mock, pinned X.Org verification, and both artifact uploads.
- GitHub confirms the new editor artifact 13722915782 (127,343 bytes) and locale artifact 13721843648 (74,021 bytes) expire on 2027-02-08 00:05:31 UTC, exactly the 90-day retention period.
- The prior #776 artifacts retain their original 2026-11-16 expiry.

---

## 2026-11-10 — built-in printable ASCII X keysym names; Build and test #776 passed

- Added a built-in mapping for standard printable ASCII X keysym names, including punctuation names and quote aliases. Literal ASCII characters remain on the existing direct path.
- The resolver retains caller-supplied X.Org keysym definitions as first priority, then uses the built-in ASCII aliases. Named non-ASCII keysyms still require the optional Unicode-annotated keysymdef.h.
- Added no-header regression cases for both event inputs and keysym-only results. Updated docs/COMPOSE_USER_IMPORT.md to reflect the exact no-header boundary.
- Source change: [f05a54158632](https://github.com/GraderGamer2/NekoEdit/commit/f05a541586329b0c05097aa5078944e6db0d7187). Regression-fixture correction: [74a0a7780885](https://github.com/GraderGamer2/NekoEdit/commit/74a0a7780885f95ffcd1a709d3d2ae55c66d1898).
- Build and test #775 failed in the new fixture because its Python newline escapes were double-escaped. Build and test [#776](https://github.com/GraderGamer2/NekoEdit/actions/runs/42669196064) passed all 13 workflow steps on the corrected head: freestanding ELF build, command-line/host tests, complete Wayland mock, executable inspection, pinned X.Org regeneration/verification, locale-pack build, and both artifact uploads.
- Artifacts: editor ZIP 13697074317 (127,343 bytes); locale ZIP 13698660427 (74,021 bytes), both expiring 2026-11-16.
- The user separately confirmed the Settings locale dropdown works in the desktop build. No live GNOME/Mutter layout or IME test was performed during this session.

**Next:** exercise the manual importer with a wider set of actual user-authored Compose files. Preserve its bounded offline include policy and the freestanding runtime.

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

