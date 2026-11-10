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

for tool in gnome-shell setxkbmap xdotool; do
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

mkdir -p "$TEST_ROOT/home/.nekoedit/locales" "$TEST_ROOT/runtime"
chmod 700 "$TEST_ROOT/home" "$TEST_ROOT/home/.nekoedit" \
    "$TEST_ROOT/home/.nekoedit/locales" "$TEST_ROOT/runtime"
cp "$LOCALE_PACK" "$TEST_ROOT/home/.nekoedit/locales/pt_BR.UTF-8.nlp"
printf 'seed' > "$TEST_ROOT/document.txt"
python3 - "$TEST_ROOT/expected.txt" <<'PY'
import pathlib
import sys
pathlib.Path(sys.argv[1]).write_bytes("…Ầ".encode("utf-8"))
PY

export HOME="$TEST_ROOT/home"
export XDG_RUNTIME_DIR="$TEST_ROOT/runtime"
export WAYLAND_DISPLAY="nekoedit-mutter-$$"
export NEKOEDIT_LOCALE="pt_BR.UTF-8"
export LC_ALL="C.UTF-8"
export XKB_DEFAULT_RULES="evdev"
export XKB_DEFAULT_MODEL="pc105"
export XKB_DEFAULT_LAYOUT="us"
export XKB_DEFAULT_VARIANT="intl"
export XKB_DEFAULT_OPTIONS="compose:ralt"
export GSETTINGS_BACKEND="memory"
export LIBGL_ALWAYS_SOFTWARE="1"
export MUTTER_DEBUG_DISABLE_HW_CURSORS="1"
export NO_AT_BRIDGE="1"

# Configure the Xvfb host keymap as well as the XKB defaults inherited by
# Mutter, so XTest and the nested Wayland compositor agree on key positions.
setxkbmap -layout us -variant intl -option compose:ralt
setxkbmap -query > "$TEST_ROOT/keymap.txt"
grep -Eq 'layout:[[:space:]]*us' "$TEST_ROOT/keymap.txt"
grep -Eq 'variant:[[:space:]]*intl' "$TEST_ROOT/keymap.txt"
grep -Eq 'options:.*compose:ralt' "$TEST_ROOT/keymap.txt"

echo "Starting $(gnome-shell --version) as a nested Wayland compositor"
gnome-shell --wayland --nested --no-x11 --sm-disable \
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

# Focus the editor surface in the nested GNOME session. XTest sends virtual
# key events through the host X server; Mutter then delivers wl_keyboard events
# using the active us(intl) keymap.
xdotool mousemove --sync 640 360 click 1
sleep 0.25
xdotool key --clearmodifiers --delay 120 ctrl+a
xdotool key --delay 120 Multi_key
xdotool key --delay 120 period
xdotool key --delay 120 period
xdotool key --delay 120 dead_grave
xdotool key --delay 120 shift+6
xdotool key --delay 120 shift+a
xdotool key --delay 120 ctrl+s

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
    echo "expected UTF-8 output U+2026 U+1EA6 (…Ầ) was not saved" >&2
    exit 1
fi
if ! kill -0 "$SHELL_PID" 2>/dev/null; then
    echo "nested Mutter exited during keyboard input" >&2
    exit 1
fi

echo "PASS: GNOME Shell/Mutter delivered Multi_key and a two-mark dead-key chain"
echo "PASS: Ctrl+S saved the expected UTF-8 bytes (U+2026 U+1EA6)"
RESULT=passed
