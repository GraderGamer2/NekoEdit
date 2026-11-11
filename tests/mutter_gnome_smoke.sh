#!/usr/bin/env bash
# Run inside an Xvfb display and a private D-Bus session.
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: $0 PATH/TO/nekoedit PATH/TO/pt_BR.UTF-8.nlp" >&2
    exit 2
fi

case "$1" in
    /*) APP_BINARY="$1" ;;
    *) APP_BINARY="$(pwd)/$1" ;;
esac
LOCALE_PACK="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSION_UUID="nekoedit-test@nekoedit.local"
BUS_NAME="org.nekoedit.TestHarness"
OBJECT_PATH="/org/nekoedit/TestHarness"
DBUS_INTERFACE="org.nekoedit.TestHarness"

for tool in gnome-shell gsettings gdbus xdotool setxkbmap; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "missing integration-test tool: $tool" >&2
        exit 2
    fi
done
if [ -z "${DISPLAY:-}" ] || [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    echo "run this test under xvfb-run and dbus-run-session" >&2
    exit 2
fi
if [ ! -x "$APP_BINARY" ] || [ ! -f "$LOCALE_PACK" ]; then
    echo "editor executable or separate pt_BR locale pack is missing" >&2
    exit 2
fi
if ! gnome-shell --help 2>&1 | grep -q -- '--nested'; then
    echo "this smoke test requires GNOME Shell with the --nested option" >&2
    exit 2
fi

TEST_ROOT="$(mktemp -d /tmp/nekoedit-mutter.XXXXXX)"
APP_PID=
SHELL_PID=
RESULT=failed

cleanup() {
    set +e
    if [ -n "$APP_PID" ]; then
        kill "$APP_PID" 2>/dev/null
        wait "$APP_PID" 2>/dev/null
    fi
    if [ -n "$SHELL_PID" ]; then
        kill "$SHELL_PID" 2>/dev/null
        wait "$SHELL_PID" 2>/dev/null
    fi
    if [ "$RESULT" = passed ]; then
        rm -rf "$TEST_ROOT"
    else
        echo "Mutter integration diagnostics (temporary directory: $TEST_ROOT)" >&2
        for log in "$TEST_ROOT/mutter.log" "$TEST_ROOT/nekoedit.log"; do
            if [ -f "$log" ]; then
                echo "--- $log ---" >&2
                tail -n 120 "$log" >&2
            fi
        done
        if [ -f "$TEST_ROOT/document.txt" ]; then
            echo "--- document bytes ---" >&2
            od -An -tx1c "$TEST_ROOT/document.txt" >&2
        fi
    fi
}
trap cleanup EXIT

EXTENSION_DIR="$TEST_ROOT/home/.local/share/gnome-shell/extensions/$EXTENSION_UUID"
mkdir -p "$TEST_ROOT/home/.nekoedit/locales" "$TEST_ROOT/runtime" \
    "$TEST_ROOT/config/glib-2.0/settings" "$EXTENSION_DIR"
chmod 700 "$TEST_ROOT/home" "$TEST_ROOT/home/.nekoedit" \
    "$TEST_ROOT/home/.nekoedit/locales" "$TEST_ROOT/runtime" \
    "$TEST_ROOT/config" "$TEST_ROOT/config/glib-2.0" \
    "$TEST_ROOT/config/glib-2.0/settings" "$EXTENSION_DIR"
cp "$SCRIPT_DIR/mutter_extension/metadata.json" "$EXTENSION_DIR/metadata.json"
cp "$SCRIPT_DIR/mutter_extension/extension.js" "$EXTENSION_DIR/extension.js"
cp "$LOCALE_PACK" "$TEST_ROOT/home/.nekoedit/locales/pt_BR.UTF-8.nlp"
printf 'seed' > "$TEST_ROOT/document.txt"
printf 'x' > "$TEST_ROOT/expected_probe.txt"
python3 - "$TEST_ROOT/expected.txt" <<'PY'
import pathlib
import sys
pathlib.Path(sys.argv[1]).write_bytes("…Ầ".encode("utf-8"))
PY

export HOME="$TEST_ROOT/home"
export XDG_RUNTIME_DIR="$TEST_ROOT/runtime"
export XDG_CONFIG_HOME="$TEST_ROOT/config"
export XDG_DATA_HOME="$TEST_ROOT/home/.local/share"
export GSETTINGS_BACKEND="keyfile"
export WAYLAND_DISPLAY="nekoedit-mutter-${BASHPID}"
export NEKOEDIT_LOCALE="pt_BR.UTF-8"
export LC_ALL="C.UTF-8"
export XKB_DEFAULT_RULES="evdev"
export XKB_DEFAULT_MODEL="pc105"
export XKB_DEFAULT_LAYOUT="us"
export XKB_DEFAULT_VARIANT="intl"
export XKB_DEFAULT_OPTIONS="compose:ralt"
export LIBGL_ALWAYS_SOFTWARE="1"
export MUTTER_DEBUG_DISABLE_HW_CURSORS="1"
export NO_AT_BRIDGE="1"

# Write GNOME settings directly to a temporary GLib keyfile. This avoids a
# D-Bus-activated dconf daemon inheriting a different environment/profile from
# the test process. Both the gsettings client and nested Shell use this backend.
gsettings set org.gnome.shell disable-user-extensions false
gsettings set org.gnome.shell disabled-extensions "[]"
gsettings set org.gnome.shell enabled-extensions "['$EXTENSION_UUID']"
ENABLED_EXTENSIONS="$(gsettings get org.gnome.shell enabled-extensions)"
if [[ "$ENABLED_EXTENSIONS" != *"$EXTENSION_UUID"* ]]; then
    echo "test extension was not persisted in the isolated GSettings backend: $ENABLED_EXTENSIONS" >&2
    exit 1
fi
if [ ! -s "$XDG_CONFIG_HOME/glib-2.0/settings/keyfile" ]; then
    echo "private GSettings keyfile was not created" >&2
    exit 1
fi
echo "Isolated GNOME enabled extensions: $ENABLED_EXTENSIONS"

# Set the Xvfb host keymap as well as Mutter's XKB defaults. xdotool resolves
# named keysyms against this map before sending XTest events to GNOME Shell.
setxkbmap -layout us -variant intl -option compose:ralt
setxkbmap -query > "$TEST_ROOT/keymap.txt"
grep -Eq 'layout:[[:space:]]*us' "$TEST_ROOT/keymap.txt"
grep -Eq 'variant:[[:space:]]*intl' "$TEST_ROOT/keymap.txt"
grep -Eq 'options:.*compose:ralt' "$TEST_ROOT/keymap.txt"

echo "Starting $(gnome-shell --version) as a nested Wayland user session"
gnome-shell --mode=user --wayland --nested --no-x11 --sm-disable \
    --wayland-display="$WAYLAND_DISPLAY" \
    > "$TEST_ROOT/mutter.log" 2>&1 &
SHELL_PID=$!

SOCKET="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
READY=0
for attempt in $(seq 1 150); do
    if [ -S "$SOCKET" ]; then
        READY=1
        break
    fi
    if ! kill -0 "$SHELL_PID" 2>/dev/null; then
        break
    fi
    sleep 0.1
done
if [ "$READY" -ne 1 ]; then
    echo "nested Mutter did not create its Wayland socket: $SOCKET" >&2
    exit 1
fi

# Wait until the temporary extension has exported its narrowly scoped test API.
HARNESS_READY=0
for attempt in $(seq 1 100); do
    if gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
        --method "$DBUS_INTERFACE.Ping" >/dev/null 2>&1; then
        HARNESS_READY=1
        break
    fi
    if ! kill -0 "$SHELL_PID" 2>/dev/null; then
        break
    fi
    sleep 0.1
done
if [ "$HARNESS_READY" -ne 1 ]; then
    echo "temporary Mutter input extension did not register its D-Bus API" >&2
    exit 1
fi

# Let the compositor finish its initial registry/configure cycle before the
# freestanding editor connects.
sleep 0.5
NEKOEDIT_LOCALE=pt_BR.UTF-8 "$APP_BINARY" \
    "$TEST_ROOT/document.txt" > "$TEST_ROOT/nekoedit.log" 2>&1 &
APP_PID=$!

for attempt in $(seq 1 50); do
    if ! kill -0 "$APP_PID" 2>/dev/null; then
        echo "NekoEdit exited before accepting input" >&2
        exit 1
    fi
    sleep 0.1
done

# GNOME Shell is itself an X11 client in this nested setup. Clutter's
# X11 virtual-input implementation injects key events with XTest, so the outer
# GNOME Shell host window must have X input focus as well as NekoEdit's inner
# Wayland MetaWindow. Bare Xvfb has no window manager to do click-to-focus.
SHELL_WINDOW=
for attempt in $(seq 1 100); do
    SHELL_WINDOW="$(xdotool search --onlyvisible --pid "$SHELL_PID" 2>/dev/null | head -n 1 || true)"
    if [ -n "$SHELL_WINDOW" ]; then
        break
    fi
    sleep 0.1
done
if [ -z "$SHELL_WINDOW" ]; then
    SHELL_WINDOW="$(xdotool search --onlyvisible --name 'GNOME Shell' 2>/dev/null | head -n 1 || true)"
fi
if [ -z "$SHELL_WINDOW" ]; then
    echo "could not find GNOME Shell's visible outer X11 window" >&2
    xdotool search --onlyvisible --name '.*' >&2 || true
    exit 1
fi
xdotool windowraise "$SHELL_WINDOW"
xdotool windowfocus --sync "$SHELL_WINDOW"
OUTER_FOCUS="$(xdotool getwindowfocus -f)"
if [ "$OUTER_FOCUS" != "$SHELL_WINDOW" ]; then
    echo "GNOME Shell outer X11 window did not acquire input focus: window=$SHELL_WINDOW focus=$OUTER_FOCUS" >&2
    exit 1
fi

GEOMETRY="$(xdotool getwindowgeometry --shell "$SHELL_WINDOW")"
SHELL_WIDTH="$(printf '%s\n' "$GEOMETRY" | awk -F= '$1 == "WIDTH" {print $2}')"
SHELL_HEIGHT="$(printf '%s\n' "$GEOMETRY" | awk -F= '$1 == "HEIGHT" {print $2}')"
if [ -z "$SHELL_WIDTH" ] || [ -z "$SHELL_HEIGHT" ] || [ "$SHELL_WIDTH" -lt 800 ] || [ "$SHELL_HEIGHT" -lt 480 ]; then
    echo "unexpected nested Mutter window geometry: $GEOMETRY" >&2
    exit 1
fi
CENTER_X=$((SHELL_WIDTH / 2))
CENTER_Y=$((SHELL_HEIGHT / 2))
xdotool mousemove --sync --window "$SHELL_WINDOW" "$CENTER_X" "$CENTER_Y"
xdotool click 1
sleep 0.25

# Also activate and verify the actual Wayland MetaWindow. Focusing the outer
# X11 host alone does not prove which nested Wayland toplevel owns keyboard focus.
FOCUS_RESULT=
for attempt in $(seq 1 100); do
    FOCUS_RESULT="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
        --method "$DBUS_INTERFACE.Activate" "$APP_PID" 2>/dev/null || true)"
    if [[ "$FOCUS_RESULT" == *"target=$APP_PID focus=$APP_PID"* ]]; then
        break
    fi
    if ! kill -0 "$APP_PID" 2>/dev/null; then
        break
    fi
    sleep 0.1
done
if [[ "$FOCUS_RESULT" != *"target=$APP_PID focus=$APP_PID"* ]]; then
    echo "Mutter did not focus NekoEdit's Wayland toplevel: $FOCUS_RESULT" >&2
    exit 1
fi
OUTER_FOCUS="$(xdotool getwindowfocus -f)"
if [ "$OUTER_FOCUS" != "$SHELL_WINDOW" ]; then
    echo "GNOME Shell lost outer X11 input focus after inner activation: window=$SHELL_WINDOW focus=$OUTER_FOCUS" >&2
    exit 1
fi
echo "GNOME focus verified: outer X11=$SHELL_WINDOW; inner Wayland=$FOCUS_RESULT"

# Send a basic key/save canary through XTest after both focus layers have
# been confirmed. The X server delivers it to GNOME Shell's focused host window,
# and the nested compositor forwards it as Wayland wl_keyboard input.
xdotool key --clearmodifiers --delay 120 ctrl+a
xdotool key --delay 120 x
xdotool key --clearmodifiers --delay 120 ctrl+s

PROBE_SAVED=0
for attempt in $(seq 1 50); do
    if cmp -s "$TEST_ROOT/document.txt" "$TEST_ROOT/expected_probe.txt"; then
        PROBE_SAVED=1
        break
    fi
    if ! kill -0 "$APP_PID" 2>/dev/null; then
        break
    fi
    sleep 0.1
done
if [ "$PROBE_SAVED" -ne 1 ]; then
    echo "XTest keyboard input did not deliver the basic edit/save canary" >&2
    echo "NekoEdit PID: $APP_PID" >&2
    echo "last MetaWindow activation result: $FOCUS_RESULT" >&2
    exit 1
fi

# Replace the canary with the Compose and dead-key paths under test.
# Right Alt is Multi_key under us(intl), and Shift+6 is dead_circumflex.
xdotool key --clearmodifiers --delay 120 ctrl+a
xdotool key --delay 120 Multi_key
xdotool key --delay 120 period
xdotool key --delay 120 period
xdotool key --delay 120 dead_grave
xdotool key --delay 120 shift+6
xdotool key --delay 120 shift+a
xdotool key --clearmodifiers --delay 120 ctrl+s

SAVED=0
for attempt in $(seq 1 100); do
    if cmp -s "$TEST_ROOT/document.txt" "$TEST_ROOT/expected.txt"; then
        SAVED=1
        break
    fi
    if ! kill -0 "$APP_PID" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

if [ "$SAVED" -ne 1 ]; then
    echo "ordinary keyboard canary passed, but expected Compose output U+2026 U+1EA6 (…Ầ) was not saved" >&2
    echo "NekoEdit PID: $APP_PID" >&2
    echo "last MetaWindow activation result: $FOCUS_RESULT" >&2
    exit 1
fi
if ! kill -0 "$SHELL_PID" 2>/dev/null; then
    echo "nested Mutter exited during keyboard input" >&2
    exit 1
fi

echo "PASS: GNOME Shell/Mutter delivered Multi_key and a two-mark dead-key chain"
echo "PASS: Ctrl+S saved the expected UTF-8 bytes (U+2026 U+1EA6)"
RESULT=passed
