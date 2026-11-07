# NekoEdit development log

## 2026-11-07 — Bound Wayland diagnostics and prevent diagnostic memory disclosure

**User retest and observed sequence:** The Actions #270 binary reported a failed `wl_surface.attach` request (object 8, opcode 1, `EPIPE`/errno 32), with the preceding locally written request at object 11/opcode 0 and the last event at object 9/opcode 0. Those IDs identify `wl_shm_pool.create_buffer` and `xdg_surface.configure`, respectively; the event's payload size is 4 bytes. This is consistent with the configure-driven buffer replacement path, but a locally successful socket write does not prove Mutter processed or accepted that request, so the disconnect's actual cause remains unconfirmed.

### Diagnostic defects found and fixed

- The diagnostic formatter calculated the byte length for `", payload bytes="` by subtracting the label address from a preceding label. The resulting length was vastly larger than the string itself, so the stderr write continued through adjacent process memory. That explains the unrelated XKB text, editor contents, and binary-looking bytes in the user's terminal output. This was an application-side out-of-bounds diagnostic write, not Wayland event payload data.
- Added an explicit end label for the payload-size string and calculate its length from the start and end of that exact string in [`5765d1dc7dc0`](https://github.com/GraderGamer2/NekoEdit/commit/5765d1dc7dc0d1cd2f6c928b91363d0b5aa2988c).
- The decimal integer printer also included one byte beyond its final digit, adding a NUL byte after every numeric field. Corrected the exclusive end address in [`c2a9f0d08597`](https://github.com/GraderGamer2/NekoEdit/commit/c2a9f0d08597ed3f2d0a8a4d7ba97b62bf38af45).
- Added a mock-compositor regression in [`ad4ec280e31e`](https://github.com/GraderGamer2/NekoEdit/commit/ad4ec280e31e8cb653abede6edbbf7b6d5ea1a47), then tightened it in [`2408b3e00983`](https://github.com/GraderGamer2/NekoEdit/commit/2408b3e009833d294d0f2233261a84e18e9b23e8) and [`a85488248ecaf3`](https://github.com/GraderGamer2/NekoEdit/commit/a85488248ecaf3f4c4742e5f0cb599d79b0e6c1b). It writes a unique sentinel to a temporary document, closes the mock compositor immediately after `xdg_surface.configure` acknowledgement, checks the failed request/previous request/last event values, rejects NUL bytes, caps stderr at 512 bytes, and ensures the document sentinel is absent.

### Verification

- Actions #274 passed all eight steps on the bounded-label source fix. Actions #275 then failed the new regression because the integer formatter appended NUL bytes; that failure identified the second off-by-one and was corrected. Intermediate runs #276 and #277 were cancelled as the fixes landed.
- GitHub Actions [Build and test #278](https://github.com/GraderGamer2/NekoEdit/actions/runs/42321400180) passed all eight steps on [`a85488248ecaf3`](https://github.com/GraderGamer2/NekoEdit/commit/a85488248ecaf3f4c4742e5f0cb599d79b0e6c1b), including the new closed-socket output-safety regression, all existing Wayland mock scenarios, CLI smoke tests, ELF inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,396 bytes; SHA-256 `ca459f68e21289cb7bd7c0deb74d1f1c36c928ccf912292848ebbe32594fcb51`; artifact ID `13553546144`; expires 2026-11-14 00:58:35 UTC. [Download from Actions #278](https://github.com/GraderGamer2/NekoEdit/actions/runs/42321400180/artifacts/13553546144).
- This CI test establishes that the diagnostic output is bounded and does not contain the opened document's sentinel. It does not establish why GNOME/Mutter closed the real client socket or demonstrate that Maximize/edge resize now work. The real GNOME retest is still required; no journald or system-log changes are needed.

This is an append-only narrative log. New entries go at the top, with the newest work first. The complete historical narrative is in [PROJECT_HISTORY.md](PROJECT_HISTORY.md); the full SHA/subject ledger is in [COMMIT_INDEX.md](COMMIT_INDEX.md).

## 2026-11-07 — Identify the request and event surrounding the GNOME disconnect

**User retest:** The `MSG_NOSIGNAL` diagnostic artifact produced:

```text
NekoEdit: Wayland protocol or shared-memory setup failed.
Wayland stage: event loop
Wayland send failed: object=8, opcode=1, errno=32
```

- Client object 8 is the `wl_surface` created during window setup; request opcode 1 is `wl_surface.attach`. `errno=32` is `EPIPE`: the compositor-side socket was already closed when NekoEdit attempted to send the attach request.
- This identifies the first send that failed, **not necessarily the request that caused the compositor to disconnect**. The server may have closed the socket after an earlier request or during configure/buffer handling. No `wl_display.error` message was included in the output.
- The user does not want journald enabled and has disabled system logging. No system logs are required for this next step.

### Additional source diagnostics

- Preserve the object ID/opcode of the last complete request NekoEdit wrote to the Wayland socket.
- On a failed request, print that preceding request and the last successfully read Wayland event (object ID, event opcode, payload byte count), in addition to the failed request and errno.
- This distinguishes whether the close happened directly after a toplevel configure, a surface configure/acknowledgement, a buffer release, or the replacement-buffer sequence. The preceding request's successful local write does not prove Mutter processed it.
- Source commits: [`41b819eae69d`](https://github.com/GraderGamer2/NekoEdit/commit/41b819eae69db66c9f61f0f313027cf056965418) and [`0dbf87cbb5d6`](https://github.com/GraderGamer2/NekoEdit/commit/0dbf87cbb5d659254e200dd69a41b6efc80a20a3); documentation: [`0501579b965d`](https://github.com/GraderGamer2/NekoEdit/commit/0501579b965dd65011ea5475fcc2b197d95946f9).

### Verification status

- GitHub Actions [Build and test #270](https://github.com/GraderGamer2/NekoEdit/actions/runs/42320683568) passed all eight workflow steps on branch head [`f7fd732d7d2fd01b67826f2b9a43c3ef767001d0`](https://github.com/GraderGamer2/NekoEdit/commit/f7fd732d7d2fd01b67826f2b9a43c3ef767001d0): assembly/link and ELF checks, CLI smoke tests, the complete Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,387 bytes; SHA-256 `b49e824bc3aba908a025286d2e54ed76c0db4e26bc338858d5f748eb1ceea9bf`; artifact ID `13552837524`; expires 2026-11-14 00:50:55 UTC. [Download from Actions #270](https://github.com/GraderGamer2/NekoEdit/actions/runs/42320683568/artifacts/13552837524).
- The user's real GNOME/Mutter retest is still pending. CI verifies assembly and mock protocol behavior; it does not establish why Mutter closed the socket or prove Maximize/resize work.

## 2026-11-07 — Report failed Wayland sends instead of terminating on SIGPIPE

**Purpose:** Continue diagnosing the user's GNOME Wayland Maximize/resize failure without asking them to enable system logging. The user confirmed the picker scrollbar correction works, while Maximize still exits NekoEdit and edge resizing still has no effect. Their original terminal run returned status 141; temporarily ignoring SIGPIPE changed this to the program's generic event-loop error and status 1.

### Diagnosis

- Exit status 141 is consistent with termination by SIGPIPE (signal 13). NekoEdit's Wayland request path previously used `write()` on the compositor socket; writing after the peer has closed that socket can raise SIGPIPE before the program's own error handler reports useful detail.
- With SIGPIPE ignored by the shell, the write can instead return a negative `EPIPE` error, but the existing error handler only printed the broad `Wayland stage: event loop` label.
- These outputs establish a broken/closed socket write path, but they do **not** yet establish why Mutter closed the connection or which request was the first trigger.

### Source changes

- Added a Wayland-specific send loop using `sendto(..., MSG_NOSIGNAL)`, including partial-send and `EINTR` handling. The `sendmsg` path used for shared-memory FD transfer also passes `MSG_NOSIGNAL`.
- A failed request now preserves its client object ID, opcode, and negative Linux errno. The common error handler prints those values to stderr, so the next manual test can identify the request that could not be sent.
- No logfile, journal, extra package, dependency, launch flag, or persistent system setting is needed. The normal launch command remains `./nekoedit --backend=wayland`.

### Verification status

- Source commits: [`10df996a0b51`](https://github.com/GraderGamer2/NekoEdit/commit/10df996a0b51de4b36287d4e78180b52dfd5c4ec), [`1331b49dde84`](https://github.com/GraderGamer2/NekoEdit/commit/1331b49dde8415d0d40dfb2d5326b4e0a3990b97), and [`2ba62dd68161`](https://github.com/GraderGamer2/NekoEdit/commit/2ba62dd681611da09673e1fffc1d81b109ac4abf).
- GitHub Actions [Build and test #261](https://github.com/GraderGamer2/NekoEdit/actions/runs/42266008250) passed all eight workflow steps on branch head [`3752714507b773c2cf07293eb5f12bf85f251f1b`](https://github.com/GraderGamer2/NekoEdit/commit/3752714507b773c2cf07293eb5f12bf85f251f1b): freestanding assembly/link and ELF checks, CLI smoke tests, the complete Wayland mock suite, executable inspection, and artifact upload.
- Artifact: `nekoedit-linux-x86_64`, 30,146 bytes; SHA-256 `f2572c2aa95b92c80294fdb79406cddd7c5de4d5b107887a0d64fb62df643636`; artifact ID `13527261651`; expires 2026-11-13 17:55:26 UTC. [Download from Actions #261](https://github.com/GraderGamer2/NekoEdit/actions/runs/42266008250/artifacts/13527261651).
- The user's real GNOME/Mutter retest is still pending. CI verifies the existing mock scenarios and that the diagnostic build compiles; it does not establish why Mutter closes the socket or prove Maximize/resize now work.

## 2026-11-07 — Correct configured geometry, widen interactive resize, and hide the idle picker scrollbar

**Purpose:** Respond to the user's GNOME Wayland retest of Actions #251 and the separate picker observation. The user confirmed that title-bar movement now works, but Maximize still exits the app and edge resizing has no visible effect; the file-picker scrollbar also appeared displaced in directories that fit without scrolling.

### Source changes

- File picker: the scrollbar geometry previously set a full-height thumb but stored a top coordinate of zero when the visible list did not overflow. The picker now sets thumb height to zero, skips both track and thumb rendering, and does not treat the gutter as a scrollbar drag target when the entry count is at most 15.
- Window geometry: the client advertises its 480×360 minimum and 3840×2160 maximum surface geometry to xdg-shell. Positive compositor configure dimensions are accepted exactly within that backing-store range instead of silently clamping them to those limits. A compositor request beyond the declared pool limit is rejected rather than committing a buffer with geometry that does not match the configure.
- Renderer: rectangle and glyph writes are clipped against the active window dimensions, preventing fixed-position UI elements from writing outside a smaller configured surface.
- Interactive resize: the hit band is increased from 6 to 12 pixels. The client still sends compositor-managed `xdg_toplevel.resize` with the initiating pointer serial; no local resize simulation or launch-command change was introduced.

### Regression coverage

- The file-picker test opens a directory with fewer than 15 rows and verifies that no scrollbar thumb or track is rendered and the empty gutter cannot start a drag. The existing overflow fixture continues to exercise wheel scrolling and thumb dragging.
- The maximize test now applies a 1920×1080 configure and verifies matching buffer dimensions, stride, window controls, acknowledgement, and release-gated replacement.
- The resize test initiates a real protocol request 10 pixels from the edge (outside the old 6-pixel band), then checks right/top/bottom edges and all four corners with the correct xdg-shell edge flags.
- Both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` paths run the expanded suite.

### Verification

- GitHub Actions [Build and test #253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598) passed on [`f990dc0aa9b1d25617e0a385cafe23acbeef84f7`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7). The freestanding assembly/link and ELF checks, CLI smoke tests, complete Wayland mock suite, executable inspection, and artifact upload succeeded.
- Artifact: `nekoedit-linux-x86_64`, 29,780 bytes; artifact ID `13524092766`; expires 2026-11-13 17:17:47 UTC. [Download from Actions #253](https://github.com/GraderGamer2/NekoEdit/actions/runs/42260289598/artifacts/13524092766).
- The mock suite does **not** establish that Mutter's real maximize/resize behavior is fixed. The user still needs to test this artifact inside GNOME Wayland; the previous #251 artifact was confirmed to fail Maximize and interactive resize on that desktop.

**Implementation commit:** [`f990dc0aa9b1`](https://github.com/GraderGamer2/NekoEdit/commit/f990dc0aa9b1d25617e0a385cafe23acbeef84f7).  
**Branch/PR:** `early-alpha`, PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.

## 2026-11-06 — Correct GNOME Wayland window-state sequencing and add interactive move/resize

**Purpose:** Stop all unrelated feature work and address the user's report that the current build exits when Maximize is clicked under GNOME, cannot be edge-resized, and only sends the window behind when Minimize is clicked.

### Source review and protocol diagnosis

- The previous client sent `xdg_toplevel.set_maximized`, `unset_maximized`, and `set_minimized`, then jumped to the generic keyboard-change path. That path immediately attached/damaged/committed the current buffer, even though the compositor had not yet supplied the toplevel/surface configure sequence for the requested state.
- Maximize/Restore/Minimize now return to the event loop after their xdg_toplevel request. They do not submit a stale-size frame. The next frame is scheduled by `xdg_toplevel.configure`, `xdg_surface.configure`, its `ack_configure`, and the existing release-safe buffer path.
- The previous implementation had no `xdg_toplevel.move` or `xdg_toplevel.resize` request. The client now retains the serial from `wl_pointer.button`; dragging blank title-bar space sends `move(seat=13, serial)`, and pressing within a 6-pixel edge/corner hit region sends `resize(seat=13, serial, edges)` using the xdg-shell edge enum.
- Resize requests are interactive compositor operations; NekoEdit does not locally guess a new size. The compositor supplies the configure dimensions, which are applied after `wl_buffer.release` if the prior frame is still owned.
- The app still sends `xdg_toplevel.set_minimized`. Whether and how GNOME presents minimized windows is a compositor/desktop policy; this client does not emulate minimizing by hiding or destroying its own surface.

### Regression tests added/changed

- The window-control test helper now expects the xdg_toplevel request only. It no longer treats an immediate attach/damage/commit using the old geometry as correct behavior.
- The maximize test emits a burst of toplevel configure events (with maximized and activated states) before the surface configure; the client must use the final geometry/state.
- The restore test sends configure while the maximized buffer is still busy, verifies the configure acknowledgement, and only then releases the old buffer. Reallocation/presentation must wait for that release.
- Added assertions for a title-bar move request with the original button serial and a left-edge interactive resize request with `resize_edge_left`. The resize configure is also delivered while the previous buffer remains busy.
- The tests run through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.

### Verification

- Commit: [`77c8f9884e84`](https://github.com/GraderGamer2/NekoEdit/commit/77c8f9884e843d529ea89a317e3a915a245b2969).
- GitHub Actions [Build and test #251](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769) passed all workflow steps: freestanding x86-64 build/ELF checks, CLI smoke tests, complete Wayland mock integration, executable inspection, and artifact upload.
- The mock suite verified Maximize/Restore with deferred buffer replacement, title-bar move, edge resize request/serial/edge value, and the full existing file-picker/editor/protocol regressions through both transports.
- Artifact: `nekoedit-linux-x86_64`, 29,625 bytes, ZIP SHA-256 `3c3a5563fe033772d46bd9209cbfd9fd31a1ae950a69c5851e6813afba6de2c1`, artifact ID `13521663942`, expires 2026-11-13 16:46:27 UTC. [Actions #251 artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42255454769/artifacts/13521663942).

### Explicit limitation

- I could not run the executable inside the user's GNOME/Mutter session. Actions #251 proves the client-side build and mock protocol behavior, not the absence of a Mutter-specific crash on the user's machine. Manual GNOME testing of this exact artifact/commit is still required before the GNOME report can be marked resolved.
- No unrelated roadmap work, dependency changes, or launch-command changes were made. `./nekoedit --backend=wayland` remains the supported launch form.

---

## 2026-11-06 — Pass the complete two-transport Wayland and window-control suite

**Purpose:** Verify the inherited-WAYLAND_SOCKET descriptor-lifetime correction from [`69b63767d1bc`](https://github.com/GraderGamer2/NekoEdit/commit/69b63767d1bc3223ac9d300b3be056cc9c36c56f) and record the complete CI result.

### Actions #248 result

- [Build and test #248](https://github.com/GraderGamer2/NekoEdit/actions/runs/42252513357) completed with **success** on commit `69b63767d1bc3223ac9d300b3be056cc9c36c56f`.
- All workflow steps passed: toolchain inspection, freestanding x86-64 assembly/link and ELF checks, command-line smoke tests, Wayland protocol mock integration, executable inspection, artifact upload, and job cleanup.
- The full Wayland mock workflow passed through both connection mechanisms: `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- Both transport paths now complete the native picker file workflow and the app-drawn Minimize, Maximize, Restore, and Close interactions. The 1280×720 resize, release-gated buffer replacement, return to 800×480, and final Close/EOF checks all completed.
- The run also confirms the prior mock correction: the compositor releases maximized buffer 256 before the Restore click, so the test respects the client's buffer-ownership rule.

### Artifact

- Name: `nekoedit-linux-x86_64`
- Size: 29,427 bytes
- Artifact ID: `13520607975`
- Expiration: 2026-11-13 16:27:32 UTC
- [Open Actions #248 and download its artifact](https://github.com/GraderGamer2/NekoEdit/actions/runs/42252513357/artifacts/13520607975)

### Scope and remaining manual validation

- No application source code or runtime dependency changed in this test-harness correction; the WAYLAND_SOCKET parent descriptor is closed immediately after the child inherits it.
- This confirms the mock-compositor integration suite, not compatibility with every real compositor. A separate manual run inside GNOME Wayland remains useful.
- The supported launch command remains `./nekoedit --backend=wayland`.

---

## 2026-11-06 — Close the parent copy of the inherited WAYLAND_SOCKET test descriptor

**Purpose:** Continue from [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419), which corrected the mock compositor's buffer-release ordering before Restore. Actions #247 then verified that the resize/control flow passed through `WAYLAND_DISPLAY`, but exposed a separate lifetime issue in the inherited-`WAYLAND_SOCKET` test.

### Actions #247 result

- [Build and test #247](https://github.com/GraderGamer2/NekoEdit/actions/runs/42251823911) used commit [`93bedb579a89`](https://github.com/GraderGamer2/NekoEdit/commit/93bedb579a89160ee64fe70664fb9f062951a419).
- Toolchain setup, freestanding assembly/link/ELF checks, and CLI smoke tests passed.
- The complete file-workflow run over `WAYLAND_DISPLAY` passed, including app-drawn Minimize, Maximize, Restore, dynamic 1280×720 buffer replacement, restoration to 800×480, and the Close control.
- The following inherited-`WAYLAND_SOCKET` file-workflow run reached the explicit Close check but the mock compositor did not observe EOF before the test's thread-join deadline.

### Root cause and test correction

- The inherited transport is created with `socket.socketpair()`. The parent passes `client_endpoint.fileno()` to `subprocess.Popen(pass_fds=...)`, so the child inherits that descriptor.
- The parent previously kept its own `client_endpoint` copy open until the outer `finally`, which executes only after the compositor thread has been joined.
- The Close assertion in the fake compositor calls `client.recv(1)` and expects EOF after the child exits. An open duplicate of the same socket endpoint prevents EOF, even after NekoEdit closes its own descriptor. This is a test-harness descriptor-lifetime defect, not a failure in the application's Close request.
- The harness now closes the parent's copy immediately after successful `Popen` and sets `client_endpoint = None`. The child retains its inherited descriptor; when the child exits, the compositor can observe EOF as intended.
- The earlier buffer-256 release remains in place. No application source or launch behavior was changed.

### Verification and remaining validation

- Actions #247 remains a failed workflow overall because the inherited-socket EOF assertion did not complete, despite the successful `WAYLAND_DISPLAY` path and successful build/CLI checks.
- The descriptor-lifetime correction is included in the current branch update. A fresh Actions run is required to verify both transport paths.
- No real GNOME Wayland desktop test has been performed in this session; CI mock-compositor success will still need separate manual confirmation on the target desktop.
- `./nekoedit --backend=wayland` remains the supported launch form; no runtime dependency was added.

---

## 2026-11-06 — Add Wayland window controls and repair resize-test buffer release ordering

**Purpose:** Continue from the tested filename-autocomplete milestone on the live `early-alpha` branch. The repository's next implementation commit added app-drawn window controls and compositor-driven resize handling; the latest CI run exposed a missing buffer-release event in the mock workflow rather than a build failure.

### Repository state checked before the change

- Development branch: `early-alpha`; PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged into `main`.
- Autocomplete implementation [`019113014bd6`](https://github.com/GraderGamer2/NekoEdit/commit/019113014bd6eaf9ba1355c9f7e37b13ae0e0519) was validated by [Actions #245](https://github.com/GraderGamer2/NekoEdit/actions/runs/42245683431), which passed all eight workflow steps.
- The branch then advanced to [`f516fc1a9b31`](https://github.com/GraderGamer2/NekoEdit/commit/f516fc1a9b316aa34a6c07533948822913469f02), adding Wayland title-bar controls and resize/reconfigure handling. [Actions #246](https://github.com/GraderGamer2/NekoEdit/actions/runs/42247690288) compiled/linked successfully and passed CLI smoke tests, but the mock Wayland integration test failed in the Restore sequence.

### Window-management implementation now present

- The initial surface remains 800×480. The renderer derives stride and editor/status geometry from the active window dimensions.
- The memfd mapping is bounded for a maximum 3840×2160 XRGB8888 surface; compositor-provided dimensions are clamped to 480×360 minimum and 3840×2160 maximum.
- The client captures `xdg_toplevel.configure` width, height, and maximized state, acknowledges `xdg_surface.configure`, and replaces the old `wl_buffer` only after the compositor releases it. The `wl_shm_pool` remains alive so the client can allocate replacement buffers from the same bounded mapping.
- The app-drawn title bar now exposes Minimize, Maximize/Restore, and Close controls using the corresponding xdg_toplevel requests or clean client shutdown.
- The integration scenario exercises each control, a 1280×720 maximize configure, buffer recreation/stride, restored 800×480 geometry, and close behavior.

### CI failure diagnosis and correction

- Actions #246 did not fail during assembly, linking, ELF checks, or CLI smoke tests. It timed out in `workflow_window_click(..., "restore")` while waiting for a surface attach.
- The mock had sent a 1280×720 configure and verified the new frame in buffer 256, but it did not send `wl_buffer.release` for that frame before simulating the Restore click. The client correctly kept the shared buffer busy and deferred repaint; the test incorrectly expected an immediate attach.
- Added the missing compositor-side `wl_buffer.release` event for buffer 256 before Restore. This makes the test respect the same buffer-ownership rule already followed by the application and the earlier picker-scrollbar test.
- No application-source workaround was added: the production release gate is the correct behavior and was not bypassed.

### Verification and remaining validation

- Actions #245 remains the passing validation for filename autocomplete.
- Actions #246 remains recorded as failed because of the mock-test sequencing defect described above. The corrected workflow is submitted with this change; its result and artifact must be recorded after GitHub Actions completes.
- No real GNOME Wayland desktop test was performed in this session. Mock-compositor success, when confirmed, will still not replace a manual desktop test.
- No third-party runtime dependency or launch-command change is introduced. `./nekoedit --backend=wayland` remains supported.

---

## 2026-11-06 — Strengthen zero-byte Open coverage for a non-first list row

**Purpose:** Investigate the user-reported case where opening an empty text file appeared to select another file. The active branch already contained zero-byte Open/Save tests and the completed scrolling, checkbox, and editable search-field implementation. The existing empty-file fixture, however, placed `empty.txt` at the first regular-file row. This follow-up tests the same operation with ordinary files before and after the empty target.

### Regression fixture change

- Added non-empty `aaa.txt` and `zzz.txt` fixtures around `empty.txt`, while retaining `inside.txt` and the hidden-file fixture.
- With hidden files disabled, the sorted regular-file order now places `empty.txt` at row 1, after `aaa.txt`; the Open-button test selects that second file row rather than row 0.
- The double-click route uses the same nonzero row. Both activation paths still verify the exact active path and `doc_length == 0`; the single-click/Open route then inserts one byte, saves with Ctrl+S, and checks that only that byte appears in `empty.txt`.
- Updated the separate `inside.txt` navigation/save regression to select its new row position after adding the surrounding fixtures.
- This is deliberately a test-hardening change, not a claim that a new assembly loader defect was found. Inspection of `load_document_from_path` confirmed that a successful zero-byte read sets `doc_length` and the gap-buffer start to zero. The pointer-selection path is now exercised against a nonzero row with neighboring regular files.

### Verification

- GitHub Actions [Build and test #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677) passed **all eight workflow steps** on test commit [`5e7d2d2158eb`](https://github.com/GraderGamer2/NekoEdit/commit/5e7d2d2158ebe560ab7153556e4e25672039bd3d): freestanding build/ELF checks, CLI smoke tests, complete Wayland mock-compositor integration, executable inspection, and artifact upload.
- The file-workflow test passed for both single-click/Open and double-click of `empty.txt` from row 1, with the exact active path and zero document length. The same integration sequence passed nested-file Open/Save, mouse-wheel scrolling, scrollbar dragging, editable location/search fields, and prefix matching.
- The same workflow also exercised the established Wayland, XKB punctuation/ONE_LEVEL, gap-buffer, UTF-8, selection, key-repeat, and protocol tests through both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET`.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes, artifact ID `13513782459`, SHA-256 `79a0a6f56a7981ad443f0adaa75c521aa3521f48310d72d272778bb425f195ed`, expires 2026-11-13 15:10:30 UTC. [Download from Actions run #241](https://github.com/GraderGamer2/NekoEdit/actions/runs/42240518677/artifacts/13513782459).

### Scope and remaining validation

- No application source or runtime behavior changed in this follow-up; no runtime dependencies were added. The wheel/scrollbar, checkbox, and editable path/search implementation is already present in the active `early-alpha` source and is rerun by #241.
- The mock compositor now covers the reported selection shape more closely, but it cannot reproduce every GNOME mouse/compositor interaction. The user's original desktop symptom remains **awaiting manual confirmation** against the #241 artifact.
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; no change was made to `main`.

---

## 2026-11-06 — Correct empty-file Open, add picker scrolling, and finish editable path/search fields

**Purpose:** Respond to picker testing feedback by verifying zero-byte Open behavior, adding mouse-wheel and scrollbar navigation, converting the hidden-files indicator into a normal checkbox, and making the location and filename/search fields genuinely editable. The implementation remains in the freestanding GNU assembly Wayland backend, with no third-party runtime dependency.

### Empty-file Open and stale-selection correctness

- Added a zero-byte `nested-dir/empty.txt` fixture and exercised both activation paths: single-click followed by the Open button, and double-click directly on the file.
- Each route checks the exact active document pathname and verifies `doc_length == 0`. The single-click route then types one byte, presses Ctrl+S, and verifies that the exact empty file now contains only that byte.
- Strengthened the selection/search state so keyboard movement refreshes the filename field from the newly highlighted regular file. Open confirmation uses the current explicit prefix-match state; when a typed prefix has no match, an older row selection is not silently reused.
- A successful edited-path navigation returns focus to the directory list. That keeps subsequent typing in the filename/search field rather than unexpectedly extending the location field.

### Mouse scrolling and checkbox interaction

- Routed the core Wayland `wl_pointer.axis` vertical-axis event into the picker. Smooth 24.8 fixed-point deltas are accumulated and converted into list-row movement without discarding fractional remainder.
- Added a proportional scrollbar thumb, track click/drag behavior, and a drag-state visual. The directory list remains capped at 128 entries with 15 rows visible at a time.
- Added a regression fixture with more than two viewport pages. It checks wheel-down by three rows, drag-to-bottom, and wheel-up by one row.
- The first checkbox revision left only the small box clickable; the label is now clickable too. Each new dialog starts with hidden files disabled, and the checkbox has a bordered square with a visible check mark when enabled.
- The scrollbar test harness was corrected to honor Wayland buffer lifetime: it releases the shared-memory frame after the drag redraw before requesting the separate pointer-release redraw. Earlier timeout/SIGPIPE failures were test-side buffer-release ordering, not a failure of wheel movement or thumb dragging.

### Editable location and filename/search fields

- The location and filename fields now have explicit byte cursors. Clicking positions the cursor at the nearest visible character; the text viewport follows the cursor horizontally when the field is longer than the available width.
- Both fields support insertion at the cursor, Left/Right, Home/End, Backspace, forward Delete, and Ctrl+A replacement. The UI draws the caret and a field-selection highlight.
- In Open mode, the filename field is labeled **SEARCH** and performs case-insensitive prefix matching against regular files in the current in-memory directory listing. A match selects and scrolls the first matching file into view. No match clears the previous selection; the text remains available as a literal path/name input rather than reusing an unrelated old row.
- In Save mode, the field remains **FILE NAME** and retains relative/absolute Save As and overwrite confirmation behavior.
- The path field can be edited in the middle and committed with Enter to navigate to that directory. The path is still passed directly to filesystem syscalls; no shell command or external file manager is involved.

### Regression tests and verification

- The expanded Wayland workflow verifies both zero-byte activation routes and the exact active path/document length, then checks typing and Ctrl+S against that same file.
- The same test sequence verifies wheel scrolling, proportional thumb geometry, thumb dragging, location-field mouse-positioned insertion and Backspace, explicit path navigation, filename prefix selection, mid-string insertion and Backspace, Home/End/Left, forward Delete, Ctrl+A replacement, and Enter opening the exact matching empty file.
- GitHub Actions [Build and test #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258) passed **all eight workflow steps** on head commit [`d071d832dbbf`](https://github.com/GraderGamer2/NekoEdit/commit/d071d832dbbf4c9a8efcf02b495d0e32d6f9bb49): toolchain inspection, freestanding x86-64 build and ELF checks, CLI smoke tests, the full Wayland mock-compositor integration suite, executable inspection, and artifact upload.
- Run #235 exercised both `WAYLAND_DISPLAY` and inherited `WAYLAND_SOCKET` test transports. The file-workflow observation confirms zero-byte Open through single-click/Open and double-click, wheel scrolling, scrollbar dragging, editable path navigation, cursor-based filename edits, Ctrl+A replacement, and filename prefix search.
- Artifact: `nekoedit-linux-x86_64`, 27,216 bytes, artifact ID `13515385312`, SHA-256 `1afeefccb7c594100137e91538d30c0d8e661d026be964c956871c5a9eb64175`, expires 2026-11-13 15:00:57 UTC. [Download from Actions run #235](https://github.com/GraderGamer2/NekoEdit/actions/runs/42239055258/artifacts/13515385312).
- Intermediate runs #224–#234 include failed or cancelled attempts while the tests were being calibrated. They exposed the BSS zero-initialization requirement, stale hidden-file test state, field-navigation focus handling, and Wayland shared-memory buffer-release ordering. The passing #235 result is the validation for the consolidated state; the intermediate history remains in GitHub Actions.

### Remaining limits and manual validation

- Path and filename editing remains ASCII-only. Non-ASCII filesystem names remain usable as raw filename bytes in the listing and filesystem calls, but non-ASCII typed input and Unicode glyph display are not supported.
- Clipboard paste is not implemented; it requires the Wayland data-device protocol and belongs in a separate clipboard milestone. There is no Shift-based partial text selection in these picker fields; Ctrl+A selects the whole field.
- Filename search is a case-insensitive prefix search over the current directory's loaded regular-file entries. It is not recursive, fuzzy, or an on-disk search index. Listings remain capped at 128 entries (15 visible rows).
- The picker does not follow symbolic links, does not ask before discarding an edited document on Open, and does not yet provide file filters, bookmarks, or incremental large-directory enumeration.
- CI uses a mock Wayland compositor. No real GNOME Wayland desktop smoke test has been performed for this updated picker. The prior shifted-symbol keyboard report also remains awaiting manual confirmation against a current artifact.

### Scope and commits

- The supported launch form remains `./nekoedit --backend=wayland`; the Makefile build output remains `./build/nekoedit`.
- The code and tests added no third-party runtime or shared-library dependency. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged; no change was made to `main`.
- The picker/scroll/edit/test commits from 2026-11-06 14:39–15:00 UTC are individually recorded in [`COMMIT_INDEX.md`](COMMIT_INDEX.md).

---

## 2026-11-06 — Complete and stabilize the native directory-browser file picker

**Purpose:** Resume NekoEdit development from the repository's existing picker implementation, inspect the active source and regression tests, and bring the native Open/Save directory browser to a fully passing automated integration state without changing the established launch command or adding runtime dependencies.

### Implementation brought to a verified state

- The active `early-alpha` source already contained the native in-window picker work: a modal Open/Save browser rendered by the Wayland software renderer, with a path field, Up and Home navigation, a hidden-files toggle, directory-first/file-second listing, filename field, and Cancel/Open actions.
- The picker uses direct Linux filesystem syscalls and keeps the file workflow inside the freestanding assembly application. No GTK, Qt, portal, D-Bus, external file manager, C runtime, or third-party shared-library dependency was added.
- Open mode supports listing selection, double-click directory entry, double-click regular-file opening, and keyboard activation/navigation. Save mode uses the same browser, supports relative and absolute destinations, and asks before replacing an existing target.
- The existing mock-compositor workflow covers Untitled Save, named Save, Open, nested-directory navigation, hidden-file visibility, Save As, overwrite confirmation/cancellation, missing/oversized Open rollback, failed Save As rollback, and Escape cancellation.

### Defects found and corrected

- Early picker tests sampled an unlit column in the first row of the H/N glyphs. The final assertions sample an unobscured lit glyph column and, more importantly, also inspect the actual active path and loaded document byte. This avoids treating a pixel coincidence as proof that the correct file opened.
- Re-entering a directory could carry the previous directory's double-click row index and timestamp into the new listing. A first click on row zero could then be treated as a second click from the prior directory. `picker_scan_directory` now resets both click-history fields every time it rebuilds a listing. This is implemented in [`f3189b1bbe6e`](https://github.com/GraderGamer2/NekoEdit/commit/f3189b1bbe6e73060fa8a47ffd23a56984e70b82).
- The strengthened test exposed stale bytes in `picker_target_buffer`: the relative filename-copy loop stopped at the source NUL but failed to write a new NUL into the destination. Opening a shorter name after a longer one could therefore generate a target such as `inside.txtte`. The loop now explicitly terminates the new target path. This is implemented in [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd).
- Test-only process-memory diagnostics were added to report the current document path, target path, picker selection, and loaded bytes when an integration assertion fails. The fixture also correctly trims those values at actual NUL bytes. These diagnostics made the mis-navigation and stale-path failures distinguishable from rendering assertions.

### Regression history and verification

- Intermediate Actions runs **#199–#207** failed during test development. The failures exposed invalid glyph-pixel samples, stale double-click state across directory scans, and the missing target-path terminator; a diagnostic-fixture NUL-escaping mistake was also corrected. Those failed runs are retained in GitHub history rather than being represented as successful validation.
- GitHub Actions [Build and test #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800) passed **all eight workflow steps** on implementation commit [`07bc16d71ac5`](https://github.com/GraderGamer2/NekoEdit/commit/07bc16d71ac5940d206d31a792e46ec6f130c7fd): toolchain inspection, freestanding x86-64 build and ELF checks, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload.
- The file-workflow scenario specifically verified opening the hidden file, navigating Up and re-entering the nested directory, opening the exact `inside.txt` path, replacing its document contents, and saving the exact nested file with Ctrl+S. It also verified Save As overwrite confirmation/cancellation and rollback on failed or oversized operations.
- Artifact: `nekoedit-linux-x86_64`, 24,492 bytes, artifact ID `13511065251`, SHA-256 `f157014623b7beb16b954a67a7cdcdc70304371cdeefb36f4615e0df35a62782`, expires 2026-11-13 14:13:07 UTC. [Download from Actions run #208](https://github.com/GraderGamer2/NekoEdit/actions/runs/42231898800/artifacts/13511065251).

### Remaining limits and manual validation

- The picker currently stores at most 128 entries per directory listing and displays 15 rows at a time. It is a document Open/Save utility, not a general-purpose file manager.
- Path and filename input is currently ASCII-only and supports simple append/backspace/clear behavior; caret repositioning, in-field insertion, and clipboard paste are not implemented. Non-ASCII filename bytes remain available to filesystem operations but render through the safe replacement glyph path.
- Unsaved-document confirmation, richer path/name editing, symlink navigation, file filters, and clipboard integration remain unfinished.
- CI uses a mock Wayland compositor. No real GNOME Wayland desktop smoke test has been performed for this picker build. The previously reported shifted-symbol keyboard regression also remains awaiting confirmation against a current artifact in the user's desktop session.

### Scope and commits

- The supported launch form remains `./nekoedit --backend=wayland`; the Makefile build output remains `./build/nekoedit`.
- The picker and regression work added no runtime dependency and did not merge PR #2. PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, targeting `main`.
- The individual picker implementation, regression-test, diagnostic, and correction commits are indexed in [`COMMIT_INDEX.md`](COMMIT_INDEX.md), including the final click-state fix and target-path termination fix.

---

## 2026-11-06 — Correct XKB ONE_LEVEL handling and expand shifted-punctuation tests

**Purpose:** Address the reported case where ordinary keys worked but many shifted punctuation keys displayed `?`. Inspection found that the bounded XKB type classifier collapsed ONE_LEVEL into the generic non-alphabetic path, so a one-symbol key could select an empty Level 2 slot while Shift was held.

### Implementation

- Added an explicit ONE_LEVEL type flag in `src/backend/xkb.S`. The lookup now forces Level 1 for ONE_LEVEL keys regardless of Shift, Caps Lock, or LevelThree state, instead of attempting to read a nonexistent second level.
- Kept the existing ALPHABETIC and three-/four-level handling unchanged. This is a targeted correction within the project's bounded XKB text-v1 subset, not full libxkbcommon-equivalent XKB support.
- Updated `README.md`, `docs/WAYLAND_BACKEND.md`, and `CHANGELOG/CURRENT_STATUS.md` to describe the currently supported common ONE_LEVEL/ALPHABETIC/THREE_LEVEL/FOUR_LEVEL families.

### Regression coverage and CI

- Extended `tests/wayland_mock.py` with actual Wayland key events for shifted grave/tilde, bracket/brace, semicolon/colon, apostrophe/quote, comma/less-than, period/greater-than, and slash/question keys, plus a ONE_LEVEL keypad key while Shift is active.
- The first CI attempt, [Build and test #185](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223115089), failed in the new test at the bracket key. The build/ELF verification and CLI smoke tests had passed; the Wayland integration test exposed incorrect fixture metadata: the added entries used raw evdev numbers, while the XKB fixture must declare the XKB keycode (evdev + 8).
- Corrected the fixture in [commit `b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b), also removing an accidental duplicate AB09 entry. The physical key events still use evdev keycodes as required by Wayland.
- The corrected [Build and test #186](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121) passed all eight workflow steps on `b260457007589469abdb492358b7581558c0cc5b`: freestanding build/link, ELF dependency checks, CLI smoke tests, complete Wayland mock integration, executable inspection, and artifact upload.
- The XKB scenario verified the evdev-to-XKB +8 lookup, group switching, Shift/LevelThree, all twelve shifted number-row symbols, the added shifted punctuation rows, ONE_LEVEL Shift behavior, and the exact saved document bytes. The complete suite also passed the UTF-8, gap-buffer, file-workflow, protocol-error, and sparse-keymap fallback scenarios.
- Artifact from #186: `nekoedit-linux-x86_64`, 19,009 bytes, SHA-256 `a27b9571cf9752c947ff7700f012320316db4e720bba195773ec8647644a8d7b`, artifact ID `13504771747`, expires 2026-11-13. [Run #186 artifacts](https://github.com/GraderGamer2/NekoEdit/actions/runs/42223470121/artifacts/13504771747).
- The post-sync [Build and test #187](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584) also passed all eight steps on merge commit `3a1b2bb9bed50e15bbd37da634505fead4f7724c`. Artifact ID `13504384311`, 19,009 bytes, SHA-256 `f0b63d507d2057dc46c8524ffc3e4f15d01dc9b1f09005ffcb3bc700acde98e5`, expires 2026-11-13. [Run #187 artifacts](https://github.com/GraderGamer2/NekoEdit/actions/runs/42224183584/artifacts/13504384311).

### Manual verification still needed

- The latest user-reported desktop issue (most shifted punctuation showing `?`) has not yet been manually re-tested against this patched artifact in the user's GNOME Wayland session. The mock compositor validates a controlled synthetic keymap, not every installed layout or GNOME modifier map.
- After downloading the #186 artifact, run it with the unchanged command `./nekoedit --backend=wayland` and test the full shifted punctuation sequence on the actual active layout. Report which physical keys still fail, if any. Do not call the user's desktop regression fully resolved until this check succeeds.

### Scope

- No third-party runtime libraries or external dependencies were added. The launch interface and document model are unchanged.
- PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open, unmerged, and mergeable with a clean state at the time of this update.
- The changelog update was committed as [`8fa6e2282703`](https://github.com/GraderGamer2/NekoEdit/commit/8fa6e2282703d164dcab2ecb096b9416523957ac). Because `main` contained separate changelog-only commits, the PR briefly became dirty. Created synchronization merge [`3a1b2bb9bed5`](https://github.com/GraderGamer2/NekoEdit/commit/3a1b2bb9bed50e15bbd37da634505fead4f7724c), with `main` as first parent and the previous `early-alpha` head as second parent; it preserved the entire development tree and brought the PR back to 0 commits behind / clean mergeability.
- Commits: [`267ef0557b8e`](https://github.com/GraderGamer2/NekoEdit/commit/267ef0557b8e00bd01eae004ed346dde16977e3f) (parser + regression test + docs); [`b26045700758`](https://github.com/GraderGamer2/NekoEdit/commit/b260457007589469abdb492358b7581558c0cc5b) (fixture keycode correction).

---

## 2026-11-06 — Open replacement pull request #2 for early-alpha

**Purpose:** Attach the renamed development branch to an active review so GitHub's recent-push prompt has a pull-request destination. The user explicitly authorized opening a pull request if required to clear the repository notification.

### Pull request

- Opened [PR #2 — feat: build out the Wayland text editor prototype](https://github.com/GraderGamer2/NekoEdit/pull/2), from `early-alpha` into `main`. It replaces closed, unmerged PR #1 as the active review for this development branch.
- At creation, GitHub compared the branch as 185 commits ahead and 4 behind main; the PR contained 12 changed files, 6,804 additions, and 235 deletions.
- PR #2 is open and not draft. No merge was attempted.
- After creation and its CI run, GitHub reported `mergeable=true` and `mergeable_state=clean`.

### Validation

- PR-triggered GitHub Actions [Build and test #179](https://github.com/GraderGamer2/NekoEdit/actions/runs/42220633279) completed successfully on head commit `108d7df1e024e74c653c5bb4cdbe52fb1d1289bf`. All eight workflow steps passed, including the freestanding x86-64 build/ELF verification, CLI smoke tests, Wayland mock-compositor integration, executable inspection, and artifact upload.
- No application source or tests changed after implementation-code tip [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0); the tested head contains later changelog-only maintenance commits.
- The mock compositor does not replace a real GNOME Wayland smoke test.

### Outstanding user-reported keyboard regression

- In the latest user test of a newer Actions build, normal alphabetic keys worked again, but most shifted punctuation/symbol keys displayed `?`. The user reported only a subset (including `<>`, `:"`, and `()`) rendered correctly.
- The exact Actions run/artifact for that manual report was not identified. Do not claim the regression is fixed because automated mock-compositor tests pass.

### Scope

- This is PR creation and repository documentation only; no editor implementation, tests, or build files were changed for this task.
- PR #2 remains open and unmerged. Further feature development remains paused pending explicit user authorization.
- The PR-status documentation was committed on `early-alpha` as [`fa4725159a20`](https://github.com/GraderGamer2/NekoEdit/commit/fa4725159a202130c5fdd8d2123d1e10be35cadc) and mirrored to `main` as [`92fa00fca547`](https://github.com/GraderGamer2/NekoEdit/commit/92fa00fca547f4b5d947a645bce345f59046e9f6). Both commits touch only the four CHANGELOG files.
- The index/log follow-up commits are [`156e0ab2e53f`](https://github.com/GraderGamer2/NekoEdit/commit/156e0ab2e53fcdbcb4c8403154f577e1e41351c5) on `early-alpha` and [`4795856b1713`](https://github.com/GraderGamer2/NekoEdit/commit/4795856b1713c39103f56f3ba944f0723e3b4218) on `main`.

---

## 2026-11-06 — Rename the development branch to `early-alpha`

**Purpose:** Replace the overly specific branch name with a concise early-development label while preserving the existing implementation history and keeping the project handoff documentation accurate.

### Branch and PR verification

- The user renamed `feat/wayland-socket-error-handling` to `early-alpha` in GitHub.
- Verified that GitHub's branch endpoint returns `early-alpha` at commit [`6f9d17a3a09eaabf1393db214868fe57716ac7c0`](https://github.com/GraderGamer2/NekoEdit/commit/6f9d17a3a09eaabf1393db214868fe57716ac7c0). Searching for the former branch name returns no branch.
- The branch rename preserved the implementation tip; it did not modify source history or create a new implementation commit.
- PR [#1](https://github.com/GraderGamer2/NekoEdit/pull/1) is currently closed and unmerged. The GitHub API still returns the former name in the PR's `head.ref`, despite the old branch ref no longer being present. The reason for closure is not inferred here; no PR action was taken.
- GitHub Actions [Build and test #174](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217617434) passed on the exact implementation tip before the rename. All eight workflow steps succeeded. This is validation of the unchanged code commit, not a new run triggered by the branch rename.
- At verification, `main` remained at [`f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d`](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d); it still contains the original prototype rather than the editor implementation.

### Scope

- Refreshed the status, development log, project history, and commit index so the renamed branch and current PR state are clear in future handoffs.
- The four-file documentation update was committed on `early-alpha` as [`4d3786b206db`](https://github.com/GraderGamer2/NekoEdit/commit/4d3786b206dbdb6dc86ca4a2d140e57fe78ed459) (12:41:33 UTC), then mirrored to `main` as [`6f50ea994362`](https://github.com/GraderGamer2/NekoEdit/commit/6f50ea994362178dc7a34320263d00b3d7244158) (12:41:35 UTC).
- Follow-up commit-index maintenance was committed as [`e50e87f2fe62`](https://github.com/GraderGamer2/NekoEdit/commit/e50e87f2fe62f0212b7fb0f77e6ebf5d1b4a55e5) on `early-alpha` and [`2c2dfbe16a9f`](https://github.com/GraderGamer2/NekoEdit/commit/2c2dfbe16a9feed38ea279281e6321b283219c54) on `main`.
- The current-status wording was then clarified in [`b452c39c82a0`](https://github.com/GraderGamer2/NekoEdit/commit/b452c39c82a069236443b8ce14266a3fd2fae8aa) on `early-alpha` and [`99084a344cf3`](https://github.com/GraderGamer2/NekoEdit/commit/99084a344cf39f9ba2c5beec7a7db1528c7cf507) on `main`. All six commits in this documentation sequence touch only files under `CHANGELOG/`.
- Mirrored the documentation-only update to `main`; no application source, tests, Makefile, workflow, or binary changed.
- No feature development was performed. Further NekoEdit development remains paused until the user explicitly authorizes it.

---

## 2026-11-06 — Put the changelog on main and synchronize the development branch

**Purpose:** Make the project continuity record available from main as requested, while keeping PR #1 based on main without merging the editor implementation prematurely.

### Main-branch changelog

- Created the initial main-only documentation commit [9377c5c9c4bf](https://github.com/GraderGamer2/NekoEdit/commit/9377c5c9c4bfee8a6a6ea4b8f27be451e85bf6e8). It adds all five CHANGELOG files and a root README link, and does not copy application code from PR #1.
- The main push workflow [Build and test #168](https://github.com/GraderGamer2/NekoEdit/actions/runs/42215548988) passed.
- After the gap-buffer milestone was documented on the feature branch, copied the updated CURRENT_STATUS, DEVELOPMENT_LOG, PROJECT_HISTORY, and COMMIT_INDEX blobs to main in [f31dc4177c78](https://github.com/GraderGamer2/NekoEdit/commit/f31dc4177c784a75da7edfc5bcfcaa9f419cfa1d). The project README and CHANGELOG onboarding file remained in place.
- Main push workflow [Build and test #170](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216873766) passed. Main remains the original Wayland prototype; only the changelog and its README link were added/updated.

### Feature-branch synchronization

- The independent main documentation commits initially made PR #1 report a dirty merge state even though the feature branch already contained identical changelog file contents.
- Created the explicit two-parent merge commit [379a34981fc6](https://github.com/GraderGamer2/NekoEdit/commit/379a34981fc697be322063458b44ff4dd9a1e72d): first parent is main at f31dc4177c78; second parent is the development branch's gap-buffer changelog commit d35d54bb8726. Its tree preserves the complete feature branch implementation and has the same changelog contents as main.
- This is a branch synchronization commit, not a PR merge. PR #1 remains open and unmerged; GitHub subsequently reported mergeable=true and mergeable_state=clean.
- Feature-branch [Build and test #171](https://github.com/GraderGamer2/NekoEdit/actions/runs/42217176741) passed on the merge commit. All eight workflow steps passed, including the full Wayland mock-compositor suite and executable artifact upload.
- Artifact: nekoedit-linux-x86_64; 18,978 bytes; SHA-256 2fa05d8a3b0f2b4422a4d4f81c1ebd3f701ea6d74c97221f467bf1b3ea9dbebf; expires 2026-11-13.

No program-code changes were made in this synchronization entry. The standalone launch command and 64 KiB gap-buffer implementation from commit 776a72c remain unchanged.

---

## 2026-11-06 — Implement a fixed-capacity gap-buffer document engine

**Purpose:** Replace the contiguous editing byte array with the planned gap-buffer structure while preserving the current Wayland interface, 64 KiB file limit, UTF-8 code-point handling, and freestanding runtime constraints.

### Implementation

- Added the logical gap interval [doc_gap_start, doc_gap_end) inside the existing 64 KiB allocation. doc_length, doc_cursor, and selection positions remain logical byte offsets.
- Added doc_byte_at to translate logical offsets to physical storage. UTF-8 validation/navigation, visual-row and pointer mapping, status calculation, selection painting, and document rendering now read through this accessor.
- Added overlap-safe gap movement in both directions. Moving left copies the prefix tail backwards; moving right copies the suffix head forwards. The direction flag is cleared before returning.
- Insertion moves the gap to the logical cursor and consumes bytes from the gap. Backspace/Delete and selection deletion move the gap to the deletion boundary and enlarge it instead of compacting the entire remaining suffix.
- Startup file loading and successful in-window Open initialize the gap immediately after the loaded bytes. Staged Open still leaves the current document untouched on failure.
- Atomic Save now writes the prefix and suffix as separate segments, excluding the unused gap, while retaining the existing write loop, EINTR handling, fsync, close, and rename behavior.
- Updated the project README and architecture description to distinguish a working gap buffer from the still-fixed 64 KiB capacity.

### Regression coverage

- Added a dedicated gap_buffer_test integration scenario using AéBC. It places the gap after the two-byte UTF-8 character, inserts on both sides, moves the cursor across the split, exercises Backspace and Delete, removes a selection, and verifies the exact saved bytes (AéC).
- The full GitHub Actions [Build and test #169](https://github.com/GraderGamer2/NekoEdit/actions/runs/42216369360) completed successfully on code commit [776a72c07579](https://github.com/GraderGamer2/NekoEdit/commit/776a72c07579ced1e54929946de65cea6271267e).
- All eight CI steps passed, including assembly/link and ELF checks, CLI smoke tests, full Wayland mock-compositor integration, executable inspection, and artifact upload.
- Artifact: nekoedit-linux-x86_64; size 18,978 bytes; SHA-256 dae27df70c60ae73c4bd45e494b10c7c47c7d0962c86c8876f48ab00965b515a; expiration 2026-11-13.
- No new real-GNOME-desktop manual test was performed for this milestone. The user's earlier desktop feedback about symbols and UTF-8 formatting remains separate from these automated results.

### Scope and remaining limits

- The gap buffer remains fixed at 65,536 bytes; there is no dynamic growth or allocation expansion yet, and oversized files continue to be rejected.
- There is no line-start index; rendering, cursor-to-row mapping, and row-to-cursor mapping still scan the document.
- UTF-8 support remains code-point-boundary-aware, not grapheme-aware. Non-ASCII glyphs still render as ?, keyboard text input is still ASCII-only, and IME/compose support is not implemented.
- Clipboard, undo/redo, horizontal scrolling, resize/scale handling, a directory-browser picker, and X11 remain unfinished.

The existing launch interface is unchanged: ./nekoedit --backend=wayland or ./build/nekoedit --backend=wayland. Development remains on feat/wayland-socket-error-handling / PR #1; the separate changelog-only commit on main did not merge the editor code.

---

## 2026-11-06 — Create permanent changelog and recover full project history

**Purpose:** Establish a durable development record before any further feature work, so a new ChatGPT conversation can reconstruct project context from the repository instead of depending on a long previous chat.

### Repository reconstruction

- Inspected the active repository, the original `main` prototype history, development PR #1, source tree, build files, architecture/backend documentation, and test harness.
- Reconstructed the complete history available on 2026-11-06: 20 commits on the original `main` prototype history and 168 commits in PR #1.
- Added `CHANGELOG/COMMIT_INDEX.md` with all 188 commit subjects, dates, abbreviated/full linked commit identities, including tests, intermediate debugging, documentation changes, fixes, and reverts.
- Added `CHANGELOG/PROJECT_HISTORY.md` with a functional milestone narrative: original freestanding Wayland window; inherited socket/error reporting; pointer/keyboard input; ASCII editing and UI; selection, key repeat, wrapping and scrolling; file loading and atomic saving; XKB keymap transport/parser; complete printable ASCII punctuation; and UTF-8 code-point-safe editing.
- Added `CHANGELOG/README.md` with instructions for future development chats and a mandatory changelog-maintenance procedure.
- Added this file as the append-only narrative log.
- Added `CHANGELOG/CURRENT_STATUS.md` as the concise source-of-truth snapshot.
- Added a link to this directory from the root project README.

### Code milestone included in the reconstructed history

The latest implementation work before this retrospective changelog task added code-point-safe editing around existing UTF-8 document bytes:

- `doc_utf8_next` and `doc_utf8_prev` validate bounded UTF-8 scalar sequences.
- Left/Right, Shift+Left/Right, pointer hit-testing, selection rendering, Backspace, and Delete operate on whole valid code points instead of splitting valid 2-, 3-, and 4-byte sequences.
- Malformed bytes remain independently editable.
- The fixed 64 KiB byte array remains; this did not implement the planned gap buffer.
- Non-ASCII rendering remains a `?` placeholder, keyboard text entry remains ASCII-only, and grapheme/IME support is not implemented.

Related code/test/docs commits (all individual entries are in [COMMIT_INDEX.md](COMMIT_INDEX.md)):

- `70a333fc5392` — UTF-8 code-point-safe editing implementation.
- `056b381ab571`, `711613327410` — UTF-8 navigation/deletion and selection regression tests.
- `29ea6773e2`, `f9bc6f5df0`, `ec5d5ef33a`, `fd14288098` — correct test dispatch, better failure diagnostics, fixture positioning, and malformed-byte fixture coverage.
- `6e401497373c`, `749d1cc085d2`, `998577b6e09a` — update README, architecture, and Wayland backend documentation.
- `b71fa066fd3a`, `5c8b0aea3ed9`, `6cd9e08fada0` — pointer hit-testing coverage and test-fixture corrections.

### Verification

- GitHub Actions [run #160](https://github.com/GraderGamer2/NekoEdit/actions/runs/42213034086) passed for code commit `6cd9e08fada059ae3e24c9cdab7cf86762b24414`.
- Passed stages: freestanding x86-64 build and ELF checks; command-line smoke tests; complete Wayland mock-compositor integration; executable inspection; Linux x86-64 artifact upload.
- The integration suite includes the original Wayland, keyboard, pointer, file workflow, XKB, punctuation, repeat, valid UTF-8, malformed UTF-8, selection, deletion, and mixed-width UTF-8 pointer hit-testing cases.
- Artifact: `nekoedit-linux-x86_64`; archive SHA-256 `aa47ef8e0645e734f7dd7bd072cd31f51cc755907113603de6aebf8ab48917a7`; artifact expiry reported as 2026-11-13.
- User feedback: the printable symbol input set `!@#$%^&*()_+{}|:"<>?` works in the tested Actions build. The user also reported that the UTF-8 formatting/editing change looked fine and that earlier implementations remained usable. These are user-reported results, separate from CI verification.

### Outcome and scope

This task changes documentation only; it does not intentionally modify editor code or the launch interface. The existing Wayland launch form remains supported: `./nekoedit --backend=wayland` (or `./build/nekoedit --backend=wayland` when running the Makefile output).

No feature development is being started in this entry. The next development task should begin only after reading the changelog directory and inspecting the current source/branch/CI state.


---

## 2026-11-06 — Scope Open-mode search to the current directory

**Purpose:** Correct a file-picker state leak reported during manual use, where opening an empty text file could appear to activate a different file. Preserve the existing scrollable picker, checkbox, and editable path/search interaction.

### Diagnosis and implementation

- Inspection found that picker_scan_directory reset the selected row but did not clear the Open-mode Search field when rebuilding the listing. A no-match query could therefore survive a location change. Since Open previously allowed an unmatched field value to be treated as a literal path/name regardless of which control had focus, pressing the footer Open button after navigation could open a same-named file from the new directory even though no row was selected.
- Open-mode directory scans now clear the scoped search text, caret/view state, match flag, and select-all state. Save-mode filename text is deliberately preserved during directory scans.
- picker_confirm_action now distinguishes list focus from Search-field focus. With list focus, Open can only use the explicitly selected regular-file row. A literal path/name remains supported only while the Search field has focus.
- Updated docs/FILE_PICKER.md to make the search scope, explicit-selection rule, and executable-file behavior clear. The picker lists regular files without filtering by extension or execute permission; it treats a selected executable-bit file as document bytes and never executes it.

### Regression coverage

- Added a stale.txt fixture inside the nested directory. The regression test enters stale.txt as an unmatched search in the parent directory, navigates into the directory that actually contains that file, and clicks Open with no selected row.
- The test asserts that directory navigation clears the old query, Open leaves the picker open without changing the active document, and an explicit row-1 selection then opens the exact zero-byte empty.txt.
- The earlier row-1 zero-byte Open checks remain in place for both single-click-plus-Open and double-click activation, including the exact active path and empty document length.

### Verification

- GitHub Actions [Build and test #243](https://github.com/GraderGamer2/NekoEdit/actions/runs/42241453789) passed all eight workflow steps on [51a9b4d491665406ccc695d9724889bc6834ff66](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66).
- Passed: toolchain inspection, freestanding x86-64 build/ELF checks, command-line smoke tests, the complete Wayland mock-compositor suite (including the new stale-query regression), executable inspection, and artifact upload.
- Artifact: nekoedit-linux-x86_64, 27,249 bytes; SHA-256 d5549748f2e58f95da6cc176d630c087af15efd4b7b298ce6106dce5c484c664; artifact ID 13515965431; expires 2026-11-13 15:16:20 UTC.
- A local build was not run in this runtime because outbound DNS access to GitHub was unavailable; CI built and tested the exact pushed commit.

### Remaining validation and constraints

- The user has not yet re-tested this patch in the real GNOME Wayland desktop. The mock-compositor regression is automated evidence for the specific stale-query failure mode, not a claim that the user's manual symptom has been confirmed fixed on their machine.
- Existing picker constraints remain: 128 entries maximum, 15 visible rows, ASCII-only path/name typing, no clipboard paste or partial Shift selection, and no symbolic-link traversal. Search remains a case-insensitive prefix match over the current directory's loaded regular-file entries.
- Mouse-wheel scrolling, the proportional draggable scrollbar, the bordered Show hidden checkbox, and editable location/name fields were already implemented and remain unchanged. No runtime dependencies or launch-interface changes were introduced.

**Source/test/documentation commit:** [51a9b4d49166](https://github.com/GraderGamer2/NekoEdit/commit/51a9b4d491665406ccc695d9724889bc6834ff66).  
**Branch/PR:** early-alpha, PR [#2](https://github.com/GraderGamer2/NekoEdit/pull/2) remains open and unmerged.
