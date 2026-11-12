#!/usr/bin/env bash
# Run inside a private D-Bus session; GNOME Shell uses Mutter's native headless backend.
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

for tool in gnome-shell gsettings gdbus ibus dbus-update-activation-environment; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "missing integration-test tool: $tool" >&2
        exit 2
    fi
done
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
    echo "run this test under dbus-run-session" >&2
    exit 2
fi
if [ ! -x "$APP_BINARY" ] || [ ! -f "$LOCALE_PACK" ]; then
    echo "editor executable or separate pt_BR locale pack is missing" >&2
    exit 2
fi
if ! gnome-shell --help 2>&1 | grep -q -- '--headless'; then
    echo "this smoke test requires GNOME Shell with the native --headless backend" >&2
    exit 2
fi
if ! gnome-shell --help 2>&1 | grep -q -- '--virtual-monitor'; then
    echo "this smoke test requires Mutter's --virtual-monitor option" >&2
    exit 2
fi

TEST_ROOT="$(mktemp -d /tmp/nekoedit-mutter.XXXXXX)"
APP_PID=
SHELL_PID=
IBUS_PID=
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
    if [ -n "$IBUS_PID" ]; then
        kill "$IBUS_PID" 2>/dev/null
        wait "$IBUS_PID" 2>/dev/null
    fi
    if [ "$RESULT" = passed ]; then
        rm -rf "$TEST_ROOT"
    else
        echo "Mutter integration diagnostics (temporary directory: $TEST_ROOT)" >&2
        for log in "$TEST_ROOT/mutter.log" "$TEST_ROOT/nekoedit.log" "$TEST_ROOT/ibus-daemon.log"; do
            if [ -f "$log" ]; then
                echo "--- $log ---" >&2
                tail -n 160 "$log" >&2
            fi
        done
        if [ -f "$TEST_ROOT/document.txt" ]; then
            echo "--- document bytes ---" >&2
            od -An -tx1c "$TEST_ROOT/document.txt" >&2
        fi
    fi
}
trap cleanup EXIT

ibus_name_has_owner() {
    local owner
    owner="$(gdbus call --session --dest org.freedesktop.DBus \
        --object-path /org/freedesktop/DBus \
        --method org.freedesktop.DBus.NameHasOwner "$1" \
        2>/dev/null || true)"
    [[ "$owner" == *"true"* ]]
}

ibus_bus_has_owner() {
    ibus_name_has_owner org.freedesktop.IBus
}

ibus_portal_has_owner() {
    ibus_name_has_owner org.freedesktop.portal.IBus
}

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
export LIBGL_ALWAYS_SOFTWARE="1"
export MUTTER_DEBUG_DISABLE_HW_CURSORS="1"
export NO_AT_BRIDGE="1"
export XDG_SESSION_TYPE="wayland"
unset DISPLAY IBUS_ADDRESS IBUS_DAEMON_PID || true

# dbus-run-session inherited the runner's environment before this script
# created the isolated HOME/XDG tree. Services activated by the session bus
# therefore need an explicit environment refresh or ibus-portal will look for
# the IBus socket under the runner's original config directory.
dbus-update-activation-environment \
    HOME XDG_RUNTIME_DIR XDG_CONFIG_HOME XDG_DATA_HOME \
    XDG_SESSION_TYPE WAYLAND_DISPLAY

# The headless harness does not launch gnome-session or a systemd user manager.
# Start IBus's normal GNOME-mode service command after the private HOME, XDG
# paths and Wayland session variables are set, but before GNOME Shell starts.
# This prevents Shell's startup IBus portal/input-context requests from racing
# an IBus daemon that would normally be started by gnome-session.target.
if ! ibus_bus_has_owner; then
    echo "Starting the isolated GNOME-mode IBus daemon before headless GNOME Shell"
    ibus-daemon --panel disable --verbose > "$TEST_ROOT/ibus-daemon.log" 2>&1 &
    IBUS_PID=$!
fi
IBUS_READY=0
for attempt in $(seq 1 100); do
    if ibus_bus_has_owner; then
        IBUS_READY=1
        break
    fi
    if [ -n "$IBUS_PID" ] && ! kill -0 "$IBUS_PID" 2>/dev/null; then
        echo "IBus daemon exited before owning org.freedesktop.IBus" >&2
        tail -n 160 "$TEST_ROOT/ibus-daemon.log" >&2 || true
        exit 1
    fi
    sleep 0.1
done
if [ "$IBUS_READY" -ne 1 ]; then
    echo "IBus daemon did not acquire org.freedesktop.IBus on the private session bus" >&2
    tail -n 160 "$TEST_ROOT/ibus-daemon.log" >&2 || true
    exit 1
fi

# ibus-portal is a separate D-Bus-activated process. Its IBus client resolves
# the private socket from IBUS_ADDRESS first, then from the user's IBus config
# socket file. Publish the daemon's actual address to future D-Bus activations.
IBUS_ADDRESS="$(ibus address 2>/dev/null || true)"
if [ -z "$IBUS_ADDRESS" ] || [ "$IBUS_ADDRESS" = "(null)" ]; then
    echo "IBus daemon owns its session name but has not published a usable IBus address" >&2
    tail -n 160 "$TEST_ROOT/ibus-daemon.log" >&2 || true
    exit 1
fi
export IBUS_ADDRESS
dbus-update-activation-environment IBUS_ADDRESS

# Force a fresh activation after the address and isolated HOME/XDG paths have
# been published. Merely seeing org.freedesktop.IBus on the session bus does
# not prove the separately activated portal can connect to the IBus socket.
if ! ibus_portal_has_owner; then
    gdbus call --session --dest org.freedesktop.DBus \
        --object-path /org/freedesktop/DBus \
        --method org.freedesktop.DBus.StartServiceByName \
        org.freedesktop.portal.IBus 0 >/dev/null
fi
PORTAL_READY=0
for attempt in $(seq 1 100); do
    if ibus_portal_has_owner; then
        PORTAL_READY=1
        break
    fi
    sleep 0.1
done
if [ "$PORTAL_READY" -ne 1 ]; then
    echo "IBus portal did not acquire org.freedesktop.portal.IBus after its activation environment was refreshed" >&2
    tail -n 160 "$TEST_ROOT/ibus-daemon.log" >&2 || true
    exit 1
fi
echo "IBus daemon address and IBus portal activation verified"

if ! ibus list-engine --name-only | grep -Fxq 'xkb:us:intl:eng'; then
    echo "IBus Simple does not provide the required xkb:us:intl:eng test engine" >&2
    ibus list-engine --name-only >&2 || true
    exit 1
fi
echo "Isolated IBus bus and xkb:us:intl:eng engine verified before GNOME Shell startup"

# GNOME Shell writes its extension selection into this temporary GLib keyfile.
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
# Mutter's native seat starts with a plain "us" map; XKB_DEFAULT_* variables
# do not configure it. GNOME Shell's KeyboardManager reads the desktop
# input-sources settings and applies the layout/options to the Mutter backend.
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+intl')]"
gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us+intl')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['compose:ralt']"
gsettings set org.gnome.desktop.input-sources xkb-model "pc105"
INPUT_SOURCES="$(gsettings get org.gnome.desktop.input-sources sources)"
INPUT_MRU="$(gsettings get org.gnome.desktop.input-sources mru-sources)"
INPUT_OPTIONS="$(gsettings get org.gnome.desktop.input-sources xkb-options)"
INPUT_MODEL="$(gsettings get org.gnome.desktop.input-sources xkb-model)"
if [[ "$INPUT_SOURCES" != *"us+intl"* || "$INPUT_MRU" != *"us+intl"* || \
      "$INPUT_OPTIONS" != *"compose:ralt"* || "$INPUT_MODEL" != *"pc105"* ]]; then
    echo "temporary GNOME XKB settings are incomplete: sources=$INPUT_SOURCES mru=$INPUT_MRU options=$INPUT_OPTIONS model=$INPUT_MODEL" >&2
    exit 1
fi
echo "Isolated GNOME enabled extensions: $ENABLED_EXTENSIONS"
echo "Isolated GNOME XKB settings: sources=$INPUT_SOURCES options=$INPUT_OPTIONS model=$INPUT_MODEL"

echo "Starting $(gnome-shell --version) with Mutter's native headless backend"
gnome-shell --mode=user --wayland --no-x11 --headless --virtual-monitor 1280x720 \
    --sm-disable --wayland-display="$WAYLAND_DISPLAY" \
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
    echo "headless Mutter did not create its Wayland socket: $SOCKET" >&2
    exit 1
fi

# Wait until the temporary extension has exported its narrow D-Bus test API.
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

# Create the remote-desktop session before NekoEdit is launched. Mutter
# lazily creates its virtual keyboard on the first key press; priming it now
# makes wl_seat advertise keyboard capability before NekoEdit binds the seat.
# Ctrl_L alone has no shortcut effect in the empty test session.
gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.BeginInput" >/dev/null

INPUT_READY=0
for attempt in $(seq 1 100); do
    INPUT_STATUS="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
        --method "$DBUS_INTERFACE.InputStatus" 2>/dev/null || true)"
    if [[ "$INPUT_STATUS" == *"ready:pending=0"* ]]; then
        INPUT_READY=1
        break
    fi
    if [[ "$INPUT_STATUS" == *"failed:"* ]]; then
        echo "Mutter native virtual keyboard setup failed: $INPUT_STATUS" >&2
        exit 1
    fi
    sleep 0.1
done
if [ "$INPUT_READY" -ne 1 ]; then
    echo "Mutter native virtual keyboard session did not become ready: $INPUT_STATUS" >&2
    exit 1
fi

# NotifyKeyboardKeysym creates the native virtual device on its first press.
# Press/release Ctrl_L before the editor starts so its first wl_seat state
# already includes a keyboard; no editor window exists to receive this key.
gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.SendKey" 65507 true >/dev/null
sleep 0.05
gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.SendKey" 65507 false >/dev/null
sleep 0.25
INPUT_STATUS="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.InputStatus" 2>/dev/null || true)"
if [[ "$INPUT_STATUS" != *"ready:pending=0"* ]]; then
    echo "Mutter virtual-keyboard priming did not complete: $INPUT_STATUS" >&2
    exit 1
fi
echo "Mutter virtual keyboard device created before NekoEdit launch"

# The backend keymap must be active before the editor binds wl_keyboard so the
# first keymap FD it receives is already us(intl)+compose:ralt. This also avoids
# depending on NekoEdit's runtime keymap-replacement path in this smoke test.
sleep 0.5
KEYMAP_RESULT="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.ApplyKeymap")"
if [[ "$KEYMAP_RESULT" != *"layout=us variant=intl options=compose:ralt model=pc105"* ]]; then
    echo "Mutter did not apply the expected us(intl) keymap before editor startup: $KEYMAP_RESULT" >&2
    exit 1
fi
echo "Mutter startup keymap applied: $KEYMAP_RESULT"
sleep 0.3
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
echo "Mutter native headless focus verified: $FOCUS_RESULT"

# A MetaWindow activation is not a substitute for the app's own pointer focus
# path. Move a native Mutter virtual pointer into the document body and click.
POINTER_RESULT="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.ClickEditor" "$APP_PID")"
POINTER_READY=0
for attempt in $(seq 1 50); do
    POINTER_STATUS="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
        --method "$DBUS_INTERFACE.PointerStatus" 2>/dev/null || true)"
    if [[ "$POINTER_STATUS" == *"clicked:"* ]]; then
        POINTER_READY=1
        break
    fi
    if [[ "$POINTER_STATUS" == *"failed:"* ]]; then
        echo "Mutter virtual pointer could not focus NekoEdit's document area: $POINTER_STATUS" >&2
        exit 1
    fi
    sleep 0.05
done
if [ "$POINTER_READY" -ne 1 ]; then
    echo "Mutter virtual pointer click did not complete: $POINTER_STATUS (initial: $POINTER_RESULT)" >&2
    exit 1
fi
echo "Mutter document-area pointer focus verified: $POINTER_STATUS"
sleep 0.25

send_key() {
    gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
        --method "$DBUS_INTERFACE.SendKey" "$1" "$2" >/dev/null
}
send_keysym() {
    local keysym="$1"
    send_key "$keysym" true
    sleep 0.05
    send_key "$keysym" false
    sleep 0.05
}
send_shortcut() {
    local modifier="$1"
    local keysym="$2"
    send_key "$modifier" true
    sleep 0.05
    send_key "$keysym" true
    sleep 0.05
    send_key "$keysym" false
    sleep 0.05
    send_key "$modifier" false
    sleep 0.05
}
wait_for_input_idle() {
    local status
    for attempt in $(seq 1 50); do
        status="$(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
            --method "$DBUS_INTERFACE.InputStatus" 2>/dev/null || true)"
        if [[ "$status" == *"ready:pending=0"* ]]; then
            return 0
        fi
        if [[ "$status" == *"failed:"* ]]; then
            echo "Mutter native virtual input failed: $status" >&2
            return 1
        fi
        sleep 0.05
    done
    echo "Mutter virtual keyboard did not drain pending events: $status" >&2
    return 1
}

# Basic typing and Save shortcut are a canary independent of Compose handling.
# Save confirmation is enabled by default: Enter accepts the modal opened by
# Ctrl+S. The file is not written until this explicit confirmation is sent.
send_shortcut 65507 97
send_keysym 120
send_shortcut 65507 115
send_keysym 65293
wait_for_input_idle

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
    echo "native Mutter virtual keyboard did not complete the basic edit/save canary after Enter confirmed Ctrl+S" >&2
    echo "NekoEdit PID: $APP_PID" >&2
    echo "input status: $(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" --method "$DBUS_INTERFACE.InputStatus" 2>&1 || true)" >&2
    exit 1
fi

# Replace the canary with the Compose and locale-specific two-dead-key chain.
send_shortcut 65507 97
send_keysym 65312
send_keysym 46
send_keysym 46
send_keysym 65104
send_keysym 65106
send_keysym 65
send_shortcut 65507 115
send_keysym 65293
wait_for_input_idle

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
    echo "ordinary keyboard canary passed, but expected Compose output U+2026 U+1EA6 (…Ầ) was not saved after Enter confirmed Ctrl+S" >&2
    echo "NekoEdit PID: $APP_PID" >&2
    echo "input status: $(gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" --method "$DBUS_INTERFACE.InputStatus" 2>&1 || true)" >&2
    exit 1
fi
if ! kill -0 "$SHELL_PID" 2>/dev/null; then
    echo "headless Mutter exited during keyboard input" >&2
    exit 1
fi

echo "PASS: native Mutter virtual keyboard delivered Multi_key and a two-mark dead-key chain"
echo "PASS: Ctrl+S saved the expected UTF-8 bytes (U+2026 U+1EA6)"

# Close the first editor before the independent text-input-v3 opt-in probe.
# Keep the Mutter virtual-input session alive for the second editor instance.
kill "$APP_PID" 2>/dev/null || true
wait "$APP_PID" 2>/dev/null || true
APP_PID=

# Switch only the second phase to GNOME Shell's real IBus Simple engine. Its
# xkb:us:intl:eng descriptor applies the same us(intl) layout while routing
# keys through IBus and GNOME Shell's Clutter.InputMethod bridge. IBus is
# already running and its bus owner was verified before GNOME Shell startup.
gsettings set org.gnome.desktop.input-sources sources "[('ibus', 'xkb:us:intl:eng')]"
gsettings set org.gnome.desktop.input-sources mru-sources "[('ibus', 'xkb:us:intl:eng')]"
IBUS_ENGINE=""
for attempt in $(seq 1 100); do
    if IBUS_ENGINE="$(ibus engine 2>/dev/null)"; then
        :
    else
        IBUS_ENGINE=""
    fi
    if [ "$IBUS_ENGINE" = "xkb:us:intl:eng" ]; then
        break
    fi
    sleep 0.1
done
if [ "$IBUS_ENGINE" != "xkb:us:intl:eng" ]; then
    echo "GNOME Shell did not activate the expected IBus Simple engine: $IBUS_ENGINE" >&2
    echo "IBus engines:" >&2
    ibus list-engine --name-only >&2 || true
    exit 1
fi
echo "GNOME Shell IBus engine verified: $IBUS_ENGINE"

: > "$TEST_ROOT/text-input-document.txt"
echo "Probing live IBus preedit/commit through text-input-v3 with a second NekoEdit process"
python3 "$SCRIPT_DIR/mutter_text_input_probe.py" \
    "$APP_BINARY" "$TEST_ROOT/text-input-document.txt" \
    "$TEST_ROOT/text-input-nekoedit.log"

gdbus call --session --dest "$BUS_NAME" --object-path "$OBJECT_PATH" \
    --method "$DBUS_INTERFACE.EndInput" >/dev/null
RESULT=passed
