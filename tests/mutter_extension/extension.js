import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const BUS_NAME = 'org.nekoedit.TestHarness';
const OBJECT_PATH = '/org/nekoedit/TestHarness';
const REMOTE_DESKTOP_BUS = 'org.gnome.Mutter.RemoteDesktop';
const REMOTE_DESKTOP_PATH = '/org/gnome/Mutter/RemoteDesktop';
const REMOTE_DESKTOP_IFACE = 'org.gnome.Mutter.RemoteDesktop';
const REMOTE_SESSION_IFACE = 'org.gnome.Mutter.RemoteDesktop.Session';

const DBUS_XML = `
<node>
  <interface name="org.nekoedit.TestHarness">
    <method name="Ping">
      <arg type="s" name="status" direction="out"/>
    </method>
    <method name="Activate">
      <arg type="u" name="pid" direction="in"/>
      <arg type="s" name="result" direction="out"/>
    </method>
    <method name="ClickEditor">
      <arg type="u" name="pid" direction="in"/>
      <arg type="s" name="status" direction="out"/>
    </method>
    <method name="PointerStatus">
      <arg type="s" name="status" direction="out"/>
    </method>
    <method name="ApplyKeymap">
      <arg type="s" name="status" direction="out"/>
    </method>
    <method name="BeginInput"/>
    <method name="InputStatus">
      <arg type="s" name="status" direction="out"/>
    </method>
    <method name="SendKey">
      <arg type="u" name="keysym" direction="in"/>
      <arg type="b" name="pressed" direction="in"/>
    </method>
    <method name="SendKeycode">
      <arg type="u" name="keycode" direction="in"/>
      <arg type="b" name="pressed" direction="in"/>
    </method>
    <method name="EndInput"/>
  </interface>
</node>`;

export default class NekoEditMutterTestExtension extends Extension {
    enable() {
        this._remoteSessionPath = null;
        this._inputState = 'not-started';
        this._inputPending = 0;
        this._inputError = null;
        this._pointerStatus = 'not-started';

        this._dbusObject = Gio.DBusExportedObject.wrapJSObject(DBUS_XML, this);
        this._dbusObject.export(Gio.DBus.session, OBJECT_PATH);
        this._nameOwnerId = Gio.bus_own_name(
            Gio.BusType.SESSION,
            BUS_NAME,
            Gio.BusNameOwnerFlags.NONE,
            null,
            null,
            null
        );
        console.log('NekoEdit Mutter headless test bridge is ready');
    }

    disable() {
        this._stopRemoteSession();
        if (this._nameOwnerId) {
            Gio.bus_unown_name(this._nameOwnerId);
            this._nameOwnerId = 0;
        }
        if (this._dbusObject) {
            this._dbusObject.unexport();
            this._dbusObject = null;
        }
    }

    _callRemoteDesktop(method, parameters, replyType, callback) {
        Gio.DBus.session.call(
            REMOTE_DESKTOP_BUS,
            REMOTE_DESKTOP_PATH,
            REMOTE_DESKTOP_IFACE,
            method,
            parameters,
            replyType,
            Gio.DBusCallFlags.NONE,
            5000,
            null,
            callback
        );
    }

    _callRemoteSession(method, parameters, replyType, callback) {
        if (!this._remoteSessionPath)
            throw new Error('Mutter RemoteDesktop session has not been created');
        Gio.DBus.session.call(
            REMOTE_DESKTOP_BUS,
            this._remoteSessionPath,
            REMOTE_SESSION_IFACE,
            method,
            parameters,
            replyType,
            Gio.DBusCallFlags.NONE,
            5000,
            null,
            callback
        );
    }

    _stopRemoteSession() {
        if (!this._remoteSessionPath)
            return;
        const path = this._remoteSessionPath;
        this._remoteSessionPath = null;
        Gio.DBus.session.call(
            REMOTE_DESKTOP_BUS,
            path,
            REMOTE_SESSION_IFACE,
            'Stop',
            null,
            new GLib.VariantType('()'),
            Gio.DBusCallFlags.NONE,
            1000,
            null,
            (connection, result) => {
                try {
                    connection.call_finish(result);
                } catch (_error) {
                    // Shell shutdown may already have closed the remote session.
                }
            }
        );
    }

    Ping() {
        return 'ready';
    }

    Activate(pid) {
        const target = global.get_window_actors()
            .map(actor => actor.meta_window)
            .find(window => window && window.get_pid() === pid);
        if (!target)
            return `target=missing requested_pid=${pid}`;

        target.activate(global.get_current_time());
        const focused = global.display.focus_window;
        const focusedPid = focused ? focused.get_pid() : 0;
        const rect = target.get_frame_rect();
        return `target=${target.get_pid()} focus=${focusedPid} frame=${rect.x},${rect.y},${rect.width},${rect.height}`;
    }

    ClickEditor(pid) {
        if (this._inputState !== 'ready' || !this._remoteSessionPath)
            throw new Error('native Mutter input session is not ready');

        const target = global.get_window_actors()
            .map(actor => actor.meta_window)
            .find(window => window && window.get_pid() === pid);
        if (!target)
            throw new Error(`NekoEdit MetaWindow not found for PID ${pid}`);

        const [pointerX, pointerY] = global.get_pointer();
        const rect = target.get_frame_rect();
        // Click well inside the document body, below the title/menu area.
        const targetX = rect.x + rect.width * 0.5;
        const targetY = rect.y + rect.height * 0.65;
        const dx = targetX - pointerX;
        const dy = targetY - pointerY;

        this._pointerStatus = `moving:${Math.round(targetX)},${Math.round(targetY)}`;
        this._callRemoteSession(
            'NotifyPointerMotionRelative',
            new GLib.Variant('(dd)', [dx, dy]),
            new GLib.VariantType('()'),
            (connection, result) => {
                try {
                    connection.call_finish(result);
                } catch (error) {
                    this._pointerStatus = `failed:motion:${String(error)}`;
                    return;
                }

                this._callRemoteSession(
                    'NotifyPointerButton',
                    new GLib.Variant('(ib)', [0x110, true]),
                    new GLib.VariantType('()'),
                    (pressConnection, pressResult) => {
                        try {
                            pressConnection.call_finish(pressResult);
                        } catch (error) {
                            this._pointerStatus = `failed:press:${String(error)}`;
                            return;
                        }

                        this._callRemoteSession(
                            'NotifyPointerButton',
                            new GLib.Variant('(ib)', [0x110, false]),
                            new GLib.VariantType('()'),
                            (releaseConnection, releaseResult) => {
                                try {
                                    releaseConnection.call_finish(releaseResult);
                                    this._pointerStatus = `clicked:${Math.round(targetX)},${Math.round(targetY)}`;
                                } catch (error) {
                                    this._pointerStatus = `failed:release:${String(error)}`;
                                }
                            }
                        );
                    }
                );
            }
        );

        return this._pointerStatus;
    }

    PointerStatus() {
        return this._pointerStatus;
    }

    ApplyKeymap() {
        // Use the same Mutter backend API GNOME Shell's KeyboardManager calls.
        // This avoids relying on a session-source activation that can be late
        // in a minimal headless user session.
        global.backend.set_keymap('us', 'intl', 'compose:ralt', 'pc105');
        global.backend.lock_layout_group(0);
        return 'layout=us variant=intl options=compose:ralt model=pc105';
    }

    BeginInput() {
        if (this._inputState !== 'not-started')
            return;

        this._inputState = 'starting';
        this._inputError = null;
        this._callRemoteDesktop(
            'CreateSession',
            null,
            new GLib.VariantType('(o)'),
            (connection, result) => {
                try {
                    const [path] = connection.call_finish(result).deep_unpack();
                    this._remoteSessionPath = path;
                } catch (error) {
                    this._inputError = String(error);
                    this._inputState = 'failed';
                    return;
                }

                this._callRemoteSession(
                    'Start',
                    null,
                    new GLib.VariantType('()'),
                    (sessionConnection, startResult) => {
                        try {
                            sessionConnection.call_finish(startResult);
                            this._inputState = 'ready';
                            console.log('NekoEdit native Mutter virtual keyboard is ready');
                        } catch (error) {
                            this._inputError = String(error);
                            this._inputState = 'failed';
                        }
                    }
                );
            }
        );
    }

    InputStatus() {
        if (this._inputState === 'failed')
            return `failed:${this._inputError ?? 'unknown error'}`;
        return `${this._inputState}:pending=${this._inputPending}`;
    }

    SendKey(keysym, pressed) {
        if (this._inputState !== 'ready' || !this._remoteSessionPath)
            throw new Error(`native Mutter keyboard is not ready (${this._inputState})`);

        this._inputPending++;
        this._callRemoteSession(
            'NotifyKeyboardKeysym',
            new GLib.Variant('(ub)', [keysym, pressed]),
            new GLib.VariantType('()'),
            (connection, result) => {
                try {
                    connection.call_finish(result);
                } catch (error) {
                    this._inputError = String(error);
                    this._inputState = 'failed';
                }
                this._inputPending--;
            }
        );
    }

    // This variant bypasses Mutter's keysym-to-keycode lookup and injects the
    // Linux evdev keycode, which is required for physical-layout IME testing.
    SendKeycode(keycode, pressed) {
        if (this._inputState !== 'ready' || !this._remoteSessionPath)
            throw new Error(`native Mutter keyboard is not ready (${this._inputState})`);

        this._inputPending++;
        this._callRemoteSession(
            'NotifyKeyboardKeycode',
            new GLib.Variant('(ub)', [keycode, pressed]),
            new GLib.VariantType('()'),
            (connection, result) => {
                try {
                    connection.call_finish(result);
                } catch (error) {
                    this._inputError = String(error);
                    this._inputState = 'failed';
                }
                this._inputPending--;
            }
        );
    }

    EndInput() {
        this._stopRemoteSession();
        this._inputState = 'not-started';
        this._inputPending = 0;
        this._inputError = null;
    }
}
