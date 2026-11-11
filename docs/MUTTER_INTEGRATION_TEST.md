# GNOME Shell / Mutter integration smoke test

This test exercises NekoEdit through an actual GNOME Shell 46 / Mutter Wayland compositor, rather than the repository's protocol mock. GNOME Shell, the nested display server, and the test bridge are test-only: the editor remains freestanding and does not link GNOME, GTK, Mutter, libwayland, or an input automation library.

## What it covers

The test starts GNOME Shell in nested Wayland mode inside Xvfb and a private D-Bus session. It launches the normal NekoEdit executable against that compositor with a temporary HOME and a separately installed `pt_BR.UTF-8` NLP1 pack.

A small GNOME Shell extension is copied into that temporary HOME and enabled through an isolated GLib keyfile GSettings backend under the temporary XDG config directory. The harness launches Shell in explicit `user` session mode, checks the persisted extension UUID before startup, and does not use a D-Bus-activated dconf service. The harness verifies both focus layers: it explicitly focuses GNOME Shell's outer X11 host window (Xvfb has no window manager), then activates NekoEdit's inner Wayland `MetaWindow` by PID. The nested compositor receives XTest events on its outer host window and forwards them to the focused inner Wayland toplevel. The extension exports a deliberately narrow D-Bus interface used only by the test to:

1. Find and activate NekoEdit's actual Mutter `MetaWindow` by process ID, then report the focused window PID.
2. Send XTest keyboard events from Xvfb using the explicit `us(intl)` / `compose:ralt` host keymap after confirming both focus layers.

The harness first sends Ctrl+A, `x`, and Ctrl+S and checks that the document contains exactly `x`. Only after that canary succeeds does it test:

1. `Multi_key`, period, period, producing U+2026 (…).
2. `dead_grave`, `dead_circumflex`, `A`, which must resolve through the separate `pt_BR.UTF-8` locale pack to U+1EA6 (Ầ).
3. Ctrl+S, followed by an exact UTF-8 byte comparison against `…Ầ`.

The extension, GSettings keyfile, editor preferences, locale pack, and runtime directory are all created below the temporary test root. Nothing is installed into the real user's GNOME session or home directory.

## Run it

On Ubuntu 24.04, install the test-only tools and run:

    sudo apt-get update
    sudo apt-get install --no-install-recommends gnome-shell xvfb xauth dbus-daemon libglib2.0-bin xdotool x11-xkb-utils
    make clean all
    make test-mutter

The Make target builds the optional locale packs separately and launches the harness under `xvfb-run` and `dbus-run-session`. The CI workflow runs this after its pinned-source locale verification and pack build. The host X server provides the nested compositor's display, its outer-window input focus, and XTest keyboard events. GNOME Shell receives the events on its outer X11 window and forwards them through the actual Wayland `wl_keyboard` path to NekoEdit's focused toplevel.

## Validation boundary

This is compositor-level Wayland event-path coverage, not a physical-keyboard test. The harness confirms that both the X11 host window and NekoEdit's inner Wayland toplevel have focus before input. The host X server's XTest event path and the inner Wayland window focus are checked separately; both are required for the injected events to reach the editor. The tested input is synthetic and does not validate physical keyboard hardware, the user's desktop session, other keyboard layouts, input-method-v3 preedit, or complex-script shaping. Those still require manual desktop checks.

The test extension exposes only focus-by-PID and readiness operations on the private CI D-Bus session. It does not enable GNOME Shell's arbitrary Eval interface. The extension and all test tools are removed with the temporary directory after success; none becomes an editor runtime dependency. Ordinary `make test` and `make test-wayland` remain usable without GNOME Shell or Xvfb.
