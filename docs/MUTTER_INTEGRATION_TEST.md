# GNOME Shell / Mutter integration smoke test

This test exercises NekoEdit through an actual GNOME Shell 46 / Mutter Wayland compositor, rather than the repository's protocol mock. GNOME Shell, the nested display server, and the test bridge are test-only: the editor remains freestanding and does not link GNOME, GTK, Mutter, libwayland, or an input automation library.

## What it covers

The test starts GNOME Shell in nested Wayland mode inside Xvfb and a private D-Bus session. It launches the normal NekoEdit executable against that compositor with a temporary HOME and a separately installed `pt_BR.UTF-8` NLP1 pack.

A small GNOME Shell extension is copied into that temporary HOME and enabled through a private dconf profile. It exports a deliberately narrow D-Bus interface used only by the test to:

1. Find and activate NekoEdit's actual Mutter `MetaWindow` by process ID, then report the focused window PID.
2. Send individual XKB keysyms and Ctrl-modified keysyms through Mutter's Clutter virtual keyboard.

The harness first sends Ctrl+A, `x`, and Ctrl+S and checks that the document contains exactly `x`. Only after that canary succeeds does it test:

1. `Multi_key`, period, period, producing U+2026 (…).
2. `dead_grave`, `dead_circumflex`, `A`, which must resolve through the separate `pt_BR.UTF-8` locale pack to U+1EA6 (Ầ).
3. Ctrl+S, followed by an exact UTF-8 byte comparison against `…Ầ`.

The extension, dconf database, editor preferences, locale pack, and runtime directory are all created below the temporary test root. Nothing is installed into the real user's GNOME session or home directory.

## Run it

On Ubuntu 24.04, install the test-only tools and run:

    sudo apt-get update
    sudo apt-get install --no-install-recommends gnome-shell xvfb xauth dbus-daemon libglib2.0-bin
    make clean all
    make test-mutter

The Make target builds the optional locale packs separately and launches the harness under `xvfb-run` and `dbus-run-session`. The CI workflow runs this after its pinned-source locale verification and pack build. The host X server is used only to provide the nested compositor's display; keyboard events are injected inside Mutter with `Clutter.Seat.create_virtual_device()` and `Clutter.VirtualInputDevice.notify_keyval()`.

## Validation boundary

This is compositor-level Wayland event-path coverage, not a physical-keyboard test. Mutter creates the virtual keyboard device and delivers the resulting key events to the focused NekoEdit Wayland toplevel. This avoids treating focus on GNOME Shell's outer X11 host window as proof that its inner Wayland client has focus. The tested input is synthetic and does not validate physical keyboard hardware, the user's desktop session, other keyboard layouts, input-method-v3 preedit, or complex-script shaping. Those still require manual desktop checks.

The test extension exposes only focus-by-PID, keyval, shortcut, and readiness operations on the private CI D-Bus session. It does not enable GNOME Shell's arbitrary Eval interface. The extension and all test tools are removed with the temporary directory after success; none becomes an editor runtime dependency. Ordinary `make test` and `make test-wayland` remain usable without GNOME Shell or Xvfb.
