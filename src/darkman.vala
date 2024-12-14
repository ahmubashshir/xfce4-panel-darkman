/*
 * @pkg gtk+-3.0
 * @pkg libxfce4panel-2.0
 */

using Xfce;

namespace DarkMan
{
	private enum Mode {
		UNKNOWN, DARK, LIGHT;

		public string to_string()
		{
			switch(this) {
			case DARK   :
				return "DarkMan.Mode.DARK";
			case LIGHT  :
				return "DarkMan.Mode.LIGHT";
			case UNKNOWN:
				return "DarkMan.Mode.UNKNOWN";
			default     :
				warn_if_reached();
				return "DarkMan.Mode.Invalid";
			}
		}

		public Mode toggle()
		{
			switch (this) {
			case DARK :
				return LIGHT;
			case LIGHT:
				return DARK;
			default   :
				return UNKNOWN;
			}
		}

		public string @value()
		{
			switch(this) {
			case DARK   :
				return "dark";
			case LIGHT  :
				return "light";
			case UNKNOWN:
				return "unknown";
			default     :
				warn_if_reached();
				return "invalid";
			}
		}

		public static Mode from_string(string mode)
		{
			switch(mode.down()) {
			case "dark" :
				return DARK;
			case "light":
				return LIGHT;
			default     :
				warn_if_reached();
				return UNKNOWN;
			}
		}
	}

	[DBus (name = "nl.whynothugo.darkman")]
	private interface ClientProxy : Object
	{
		[DBus (name = "ModeChanged")]
		public async signal void mode_changed(string mode);

		[DBus (name = "Mode")]
		public abstract string mode { owned get; set; }
	}

	[SingleInstance]
	private class Client: Object
	{
			public const string bus_name = "nl.whynothugo.darkman";
			public const string obj_path = "/nl/whynothugo/darkman";
			public bool  connected { get; private set; }

			private DBusConnection? bus  = null;
			private ClientProxy?    proxy = null;
			private ulong           hid   = 0;

			public Mode mode { get; private set; }
			public async signal void mode_changed(Mode mode);

			public async void toggle_mode()
			{
				if (proxy == null) yield bus_connect();
				if (proxy != null) proxy.mode = mode.toggle().value();
			}

			public void start()
			{
				if (bus == null)
					setup_bus.begin((o, r) => setup_bus.end(r));
			}


			private async void setup_bus()
			{
				try {
					bus = yield Bus.get(BusType.SESSION, null);
				} catch (IOError e) {
					bus = null;
					message(@"$(e.message)");
				}
				if (bus == null) return;

				bus.signal_subscribe(
				    "org.freedesktop.DBus",        // Sender
				    "org.freedesktop.DBus",        // interface
				    "NameOwnerChanged",            // Signal name
				    "/org/freedesktop/DBus",       // Object path
				    bus_name, DBusSignalFlags.MATCH_ARG0_NAMESPACE,
				(c, s, o, i, n, p) => {
					string old = p.get_child_value(1).get_string();
					string @new= p.get_child_value(2).get_string();
					if(old != @new) bus_disconnect.begin();
					if(@new != "")  bus_connect.begin();
					}
			);

				yield bus_connect();
			}

			private async void bus_connect()
			{
				if (connected) return;
				try {
					proxy = yield bus.get_proxy<ClientProxy>(bus_name, obj_path);
					hid = proxy.mode_changed.connect((mode) => {
						this.mode = Mode.from_string(mode);
						mode_changed(this.mode);
					});
					if (mode == Mode.UNKNOWN)
						proxy.mode_changed(proxy.mode);
					else
						proxy.mode = mode.value();

					connected = true;
				} catch (IOError e) {
					message(@"$(e.message)");
				}
			}

			private async void bus_disconnect()
			{
				if(! connected) return;
				proxy.disconnect(hid);
				proxy = null;
				connected = false;
			}
	}
}
