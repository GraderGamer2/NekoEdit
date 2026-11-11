# GNOME Shell / Mutter integration smoke test

This test exercises NekoEdit through GNOME Shell 46 / Mutter's native Wayland backend, not only the repository's protocol mock. GNOME Shell, Mutter, the native virtual-input session, and the test extension are test-only; the editor remains freestanding and does not link GNOME, GTK, Mutter, libwayland, X11, or an input automation library.

## What it covers

Before the live compositor test, CI runs `make test-xkb-native`. That host-side test asks libxkbcommon to compile the same `evdev` / `pc105` / `us(intl)` / `compose:ralt` keymap, passes its generated XKB text through NekoEdit's assembly parser, and verifies that `Multi_key`, `dead_grave`, and `dead_circumflex` survive parsing at the same keycode/group/level positions. `libxkbcommon-dev` is a CI test dependency only; it is not linked into NekoEdit.

The test starts GNOME Shell with Mutter's native `--headless` backend and a `1280x720` virtual monitor. This avoids the nested-X11 input path, where XTEST events are not accepted as physical input by Mutter's Wayland seat. The temporary GNOME keyfile configures `org.gnome.desktop.input-sources` to use `us(intl)`, `compose:ralt`, and `pc105`; the harness reads back and verifies these settings before Shell starts. `XKB_DEFAULT_*` environment variables alone do not configure Mutter's native seat, which starts with a plain `us` map. Only after the keymap is applied does the harness launch the normal NekoEdit executable against the compositor's private Wayland socket with a temporary HOME and a separately installed `pt_BR.UTF-8` NLP1 pack.

A small GNOME Shell extension is copied into that temporary HOME and enabled through an isolated GLib keyfile GSettings backend. The extension reports the actual focused Mutter `MetaWindow` by process ID, creates a session using Mutter's `org.gnome.Mutter.RemoteDesktop` D-Bus API, and uses its native pointer-notification methods to move into and click the editor's document body before typing. It calls `CreateSession` and `Start` through the same GNOME Shell D-Bus connection, which is required by Mutter's same-peer session permission check. The harness sends and releases Ctrl_L before launching NekoEdit: Mutter creates the native virtual keyboard lazily on the first `NotifyKeyboardKeysym` press, and this primes the `wl_seat` keyboard capability before the editor binds the seat. The extension then activates NekoEdit and sends the actual test sequence through the native input seat; no XTEST device or host X window is involved.

The harness first activates NekoEdit by PID, then sends a native pointer move and left-button click at the center of the document body. It then sends Ctrl+A and `x`, followed by Ctrl+S and Enter. Save confirmation is enabled by default in NekoEdit, so Enter explicitly accepts the confirmation modal; without it, Ctrl+S intentionally leaves the file unchanged. The harness checks that the saved document contains exactly `x`. Only after that canary succeeds does it test:

1. Right Alt (`compose:ralt`) as `Multi_key`, period, period, producing U+2026 (…).
2. Under the verified `us(intl)` keymap, the grave key (`dead_grave`), Shift+6 (`dead_circumflex`), and Shift+A, which must resolve through the separate `pt_BR.UTF-8` locale pack to U+1EA6 (Ầ).
3. Ctrl+S and Enter to accept the default save-confirmation modal, followed by an exact UTF-8 byte comparison against `…Ầ`.

Build and test [#833](https://github.com/GraderGamer2/NekoEdit/actions/runs/43103083452) completed this full sequence successfully on Ubuntu 24.04 with GNOME Shell 46 / Mutter 46.2. The log shows the compositor actually advertised text-input-v3, so the live manager/enter/enable/state-commit branch was exercised rather than only the no-global fallback.

After that Compose test, the first editor process is closed and a second instance is launched with `NEKOEDIT_ENABLE_TEXT_INPUT=1`. The Python probe is the direct parent of this second process; using `nm` symbol addresses and read-only `/proc/<pid>/mem`, it observes the client state without adding debug hooks to the application. It also activates the real Mutter window and clicks the document area. If Mutter advertises `zwp_text_input_manager_v3`, the probe requires a successful manager bind, a text-input `enter`, document `enable`, and at least one committed state update. If the compositor does not advertise the global, it requires all text-input objects to remain inactive and verifies that ordinary physical-keyboard/XKB typing and the confirmed save path still work with the opt-in environment variable set. The branch is selected from the actual registry result, not from a compositor-version assumption.

## Live IBus Simple phase

After the text-input-v3 manager/focus handshake, the test changes only the temporary GNOME input-source settings to `('ibus', 'xkb:us:intl:eng')`. This is the IBus Simple keyboard engine for the same `us(intl)` layout; the original physical-XKB/Compose test has already completed and remains unchanged. The harness waits until `ibus engine` reports that exact engine as the active global engine.

The second NekoEdit process receives the explicit `NEKOEDIT_ENABLE_TEXT_INPUT=1` opt-in. Mutter's native virtual keyboard sends IBus Simple's built-in Compose sequence `Multi_key`, `o`, Backspace, `o`, `c`. The probe reads NekoEdit's existing preedit state through its parent-owned `/proc/<pid>/mem` mapping and requires the preedit to progress from U+00B7 MIDDLE DOT to `o`, return to U+00B7 after Backspace, and show `o` again without changing document bytes. The final `c` must commit U+00A9 COPYRIGHT SIGN (UTF-8 `C2 A9`), clear preedit, and survive the normal Ctrl+S / Enter save-confirmation flow exactly.

This is intended as a real IBus engine-to-GNOME-Shell-to-Mutter-to-NekoEdit integration test, not a mock IBus signal. The live Compose preedit/commit phase remains pending a passing CI run. The `ibus` command and IBus Simple engine are test-session dependencies only; GNOME Shell starts its normal session IBus daemon, and NekoEdit still links no IBus, D-Bus, GNOME, or other runtime library. Provider-originated delete-surrounding remains a deterministic Wayland-mock case, and Fcitx/other engines still need separate validation.

The extension, remote-desktop session, GSettings keyfile, editor preferences, locale pack, Wayland runtime directory, and temporary monitor are all limited to the test process and its temporary HOME. The one pre-launch Ctrl_L press is released before NekoEdit is started and exists only to instantiate the virtual keyboard device. GNOME Shell applies `us(intl)` and `compose:ralt` to Mutter's actual backend keymap before NekoEdit connects, so the tested keysyms correspond to keys that exist in that map. No remote-desktop daemon, network listener, RDP port, or user desktop session is configured.

## Run it

On Ubuntu 24.04:

    sudo apt-get update
    sudo apt-get install --no-install-recommends gnome-shell ibus dbus-daemon libglib2.0-bin libxkbcommon-dev
    make clean all
    make test-xkb-native
    make test-mutter

The Make target builds optional locale packs separately and launches the harness under `dbus-run-session`. The headless compositor publishes a private Wayland socket under the test's temporary `XDG_RUNTIME_DIR`; NekoEdit connects to that socket exactly as it would to a normal Wayland compositor.

## Validation boundary

This is real GNOME Shell/Mutter native Wayland seat coverage with a native virtual input device. It validates Wayland pointer focus, key delivery, shortcuts, `Multi_key`, locale-specific dead-key composition, the default save-confirmation interaction, and the text-input-v3 client activation boundary. When the compositor exports the manager, the probe verifies client-side bind/focus/enable/state-commit; when it does not, the probe verifies graceful opt-in fallback to physical XKB typing. It now injects live IBus Simple preedit and commit through GNOME Shell/Mutter. It does not validate provider-originated delete-surrounding, Fcitx, other third-party engines, physical keyboard hardware, other desktop environments, or complex-script shaping; those remain separate checks.

The temporary extension exports only readiness, focus-by-PID, and narrowly scoped remote-keyboard operations on the private CI D-Bus session. It does not enable GNOME Shell's arbitrary Eval interface. The extension and all temporary data are removed after success; none becomes an editor runtime dependency. Ordinary `make test` and `make test-wayland` remain usable without GNOME Shell.
