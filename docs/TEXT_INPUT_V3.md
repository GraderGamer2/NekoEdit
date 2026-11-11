# Wayland text-input-v3 integration

NekoEdit implements an opt-in `zwp_text_input_v3` client for the document surface. It is disabled by default until a real input-method handoff is validated; set `NEKOEDIT_ENABLE_TEXT_INPUT=1` to exercise it. The capability-aware Mutter smoke test now starts a second editor with this opt-in and checks the compositor-dependent activation boundary.

## State synchronization

A text-input state update is double-buffered. NekoEdit sends `set_text_change_cause`, `set_surrounding_text`, and `set_cursor_rectangle` before the matching `commit` request. The cause is:

- `input_method` (0) for changes applied from text-input-v3 events such as preedit/commit/delete and for text-input focus enter/leave synchronization.
- `other` (1) for editor-originated keyboard and pointer changes, including changes to the document caret or selection anchor.

After a state commit succeeds, the local cause resets to `input_method`, matching the protocol's default. When a matching `done` event changes the document or preedit, NekoEdit resends state with the IME cause. A stale serial still allows pending text events to be applied, but it does not trigger a state resynchronization commit until a matching serial is received.

## Preedit and UTF-8

Preedit bytes are staged separately and accepted only after NUL-termination, UTF-8 validation, and cursor byte-offset boundary validation. `cursor_begin` and `cursor_end` are byte offsets, not code-point indexes; `(-1,-1)` hides the IME cursor. A reversed selection range is normalized for rendering while the cursor remains at `cursor_begin`.

The preedit string is drawn as a temporary overlay; it is not committed into the document buffer. Committed text and delete-surrounding requests use the existing document editing/history paths. Surrounding-text windows are limited to 4,000 bytes and aligned to UTF-8 boundaries.

## Mock coverage

The Wayland mock verifies enable/disable and enter/leave, set-content-type and serial synchronization, text change cause ordering, editor-originated selection movement (cause 1), IME-originated updates (cause 0), valid and malformed multibyte preedit updates, forward/reversed/hidden cursor ranges, multibyte commit, selection deletion, and UTF-8-boundary-safe surrounding deletion.

Build and test [#833](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452) passed the live activation handshake with Ubuntu 24.04's GNOME Shell 46 / Mutter. Its log confirms that this compositor advertised `zwp_text_input_manager_v3`, NekoEdit bound the manager, received `enter`, enabled the focused document, and committed text-input state. The same run retained the ordinary Right Alt Compose and pt_BR dead-key canaries. This is direct compositor/client evidence for the activation path; it is not evidence of an IBus/Fcitx provider exchange.

The live Mutter probe is intentionally narrower than a full IME test:
- If the compositor advertises `zwp_text_input_manager_v3`, it verifies the manager bind, text-input `enter`, focused-document `enable`, and outbound state commit.
- If the global is absent, it verifies that the opt-in does not create a partial text-input object and that ordinary XKB key delivery and save remain functional.

This confirms protocol discovery and client-side activation only. It does not synthesize `preedit_string`, `commit_string`, or `delete_surrounding_text` from IBus/Fcitx, nor does it establish correct behavior with a real input-method engine. The existing Wayland mock remains responsible for deterministic incoming-event, UTF-8, cursor-offset, delete, and serial regression tests. A live IBus/Fcitx composition pass and desktop-session checks are still required before enabling text-input-v3 by default.

The mock does not replace a live compositor/input-method test. GNOME/Mutter behavior with a physical keyboard and installed IME still requires desktop validation.
