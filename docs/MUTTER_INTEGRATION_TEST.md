# GNOME Shell / Mutter integration smoke test

This test exercises NekoEdit through an actual GNOME Shell Wayland compositor, rather than the repository's protocol mock. It is deliberately a test-only dependency: the editor remains freestanding and does not link GNOME, GTK, Mutter, libwayland, or an input automation library.

## What it covers

The test starts GNOME Shell as a nested Wayland compositor inside Xvfb and a private D-Bus session. It applies the XKB us(intl) layout with the compose:ralt option, starts the normal freestanding NekoEdit executable on the nested Wayland socket, focuses its surface, and sends XTest keyboard events through the outer X server.

The test replaces a temporary document's contents with this input sequence:

1. Right Alt as Multi_key, followed by period and period. This must produce U+2026 (…).
2. dead_grave, Shift+6 (dead_circumflex), then Shift+A. With the separately installed pt_BR.UTF-8 pack selected, this must resolve the two-mark chain to U+1EA6 (Ầ).
3. Ctrl+S saves the document. The test compares its exact UTF-8 bytes with the expected string.

The locale pack is copied into a temporary HOME under .nekoedit/locales. It is not linked into or embedded in the executable. The test also uses a private XDG_RUNTIME_DIR and removes its temporary state after a successful run.

## Run it

On Ubuntu 24.04, install the test-only tools and run:

    sudo apt-get update
    sudo apt-get install --no-install-recommends gnome-shell xvfb xauth xdotool x11-xkb-utils dbus-daemon
    make clean all
    make test-mutter

The Make target builds the optional locale packs separately and launches the harness under xvfb-run and dbus-run-session. The CI workflow runs this after its pinned-source locale verification and pack build.

The CI runner currently uses Ubuntu 24.04's GNOME Shell 46 interface, which exposes the --nested and --wayland-display options. See the [Ubuntu gnome-shell manual](https://manpages.ubuntu.com/manpages/noble/man1/gnome-shell.1.html) and the [GNOME Mutter nested-running guide](https://github.com/GNOME/mutter/blob/main/doc/building-and-running.md). The current Mutter development guide uses the Devkit workflow; this test intentionally pins the older nested interface available on the workflow's Ubuntu 24.04 image.

## Validation boundary

This is compositor integration coverage, not a physical-keyboard test. XTest generates virtual input events. It proves that a real GNOME Shell/Mutter Wayland session starts, publishes a socket and keymap, delivers the tested keys to NekoEdit, and allows the editor to save the expected result. It does not validate the user's physical keyboard firmware, the user's running desktop session, other keyboard layouts, input-method-v3 preedit behavior, or live GNOME desktop rendering on the target machine. Those still require a manual desktop check.

The production binary has no dependency on any of the test packages. The ordinary make test and make test-wayland targets remain usable without installing GNOME Shell or Xvfb.
