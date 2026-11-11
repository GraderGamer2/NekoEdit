# GNOME Shell / Mutter integration smoke test

This test exercises NekoEdit through GNOME Shell 46 / Mutter's native Wayland backend, not the repository's protocol mock. GNOME Shell, Mutter, the native virtual-input session, and the test extension are test-only; the editor remains freestanding and does not link GNOME, GTK, Mutter, libwayland, X11, or an input automation library.

## What it covers

The test starts GNOME Shell with Mutter's native `--headless` backend and a `1280x720` virtual monitor. This avoids the nested-X11 input path, where XTEST events are not accepted as physical input by Mutter's Wayland seat. It launches the normal NekoEdit executable against the compositor's private Wayland socket with a temporary HOME and a separately installed `pt_BR.UTF-8` NLP1 pack.

A small GNOME Shell extension is copied into that temporary HOME and enabled through an isolated GLib keyfile GSettings backend. The extension reports the actual focused Mutter `MetaWindow` by process ID and creates a session using Mutter's `org.gnome.Mutter.RemoteDesktop` D-Bus API. It calls `CreateSession`, `Start`, and `NotifyKeyboardKeysym` through the same GNOME Shell D-Bus connection, which is required by Mutter's same-peer session permission check. On the native headless backend, Mutter creates its native virtual keyboard device and injects key events directly through its input seat; no XTEST device or host X window is involved.

The harness sends Ctrl+A, `x`, and Ctrl+S and checks that the document contains exactly `x`. Only after that canary succeeds does it test:

1. `Multi_key`, period, period, producing U+2026 (…).
2. `dead_grave`, `dead_circumflex`, `A`, which must resolve through the separate `pt_BR.UTF-8` locale pack to U+1EA6 (Ầ).
3. Ctrl+S, followed by an exact UTF-8 byte comparison against `…Ầ`.

The extension, remote-desktop session, GSettings keyfile, editor preferences, locale pack, Wayland runtime directory, and temporary monitor are all limited to the test process and its temporary HOME. No remote-desktop daemon, network listener, RDP port, or user desktop session is configured.

## Run it

On Ubuntu 24.04:

    sudo apt-get update
    sudo apt-get install --no-install-recommends gnome-shell dbus-daemon libglib2.0-bin
    make clean all
    make test-mutter

The Make target builds optional locale packs separately and launches the harness under `dbus-run-session`. The headless compositor publishes a private Wayland socket under the test's temporary `XDG_RUNTIME_DIR`; NekoEdit connects to that socket exactly as it would to a normal Wayland compositor.

## Validation boundary

This is real GNOME Shell/Mutter native Wayland seat coverage with a native virtual input device. It validates Wayland key delivery, shortcuts, `Multi_key`, and locale-specific dead-key composition without depending on Xvfb, nested-X11 focus, physical keyboard hardware, or the user's desktop session. It does not validate physical hardware, other desktop environments, input-method-v3 preedit, or complex-script shaping; those still require separate desktop checks.

The temporary extension exports only readiness, focus-by-PID, and narrowly scoped remote-keyboard operations on the private CI D-Bus session. It does not enable GNOME Shell's arbitrary Eval interface. The extension and all temporary data are removed after success; none becomes an editor runtime dependency. Ordinary `make test` and `make test-wayland` remain usable without GNOME Shell.
