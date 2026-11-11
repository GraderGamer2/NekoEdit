import Gio from 'gi://Gio';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const BUS_NAME = 'org.nekoedit.TestHarness';
const OBJECT_PATH = '/org/nekoedit/TestHarness';

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
  </interface>
</node>`;

export default class NekoEditMutterTestExtension extends Extension {
    enable() {
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
        console.log('NekoEdit Mutter test bridge is ready');
    }

    disable() {
        if (this._nameOwnerId) {
            Gio.bus_unown_name(this._nameOwnerId);
            this._nameOwnerId = 0;
        }
        if (this._dbusObject) {
            this._dbusObject.unexport();
            this._dbusObject = null;
        }
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
        return `target=${target.get_pid()} focus=${focusedPid}`;
    }

}
