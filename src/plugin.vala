/*
 * @pkg gtk+-3.0
 * @pkg libxfce4panel-2.0
 */

using Xfce;

namespace DarkMan
{
	public class Plugin : Xfce.PanelPlugin
	{
			private Gtk.Button button;
			private Gtk.Image  image;
			private Client client;

			public override void @construct ()
			{

				button = panel_create_button() as Gtk.Button;
				client = new Client();
				image  = new Gtk.Image.from_icon_name("weather-severe-alert", Gtk.IconSize.BUTTON);
				button.add(image);


				client.mode_changed.connect((m) => {
					switch(m) {
				case Mode.DARK :
					image.icon_name = "weather-clear-night";
					break;
				case Mode.LIGHT:
					image.icon_name = "weather-clear";
					break;
				default        :
					image.icon_name = "weather-severe-alert";
					break;
				}
				button.tooltip_text = @"Selected theme profile: $(m.value())";
				button.sensitive = true;
			});

				client.notify["connected"].connect(() => {
					if(client.connected) {
					client.mode_changed(client.mode);
						button.opacity = 1.0;
					} else {
						button.opacity = 0.5;
						button.tooltip_text += "\nDarkMan service not running...";
					}
				});

				button.clicked.connect(() => {
					button.set_sensitive(false);
					button.tooltip_text = "";
					client.toggle_mode.begin();
				});

				menu_show_about ();

				about.connect (() =>
				               Gtk.show_about_dialog (null,
				                                      "program-name", Config.PACKAGE_NAME,
				                                      "comments", "Framework for dark-mode and light-mode transitions on Linux desktop",
				                                      "logo-icon-name", "preferences-desktop-theme",
				                                      "license-type", Gtk.License.GPL_3_0,
				                                      "version", Config.VERSION,
				                                      null));
				destroy.connect (() => {
					Gtk.main_quit ();
				});

				add (button);
				add_action_widget (button);
				show_all();

				client.start();
			}
	}

}

[ModuleInit]
public Type xfce_panel_module_init (TypeModule module)
{
	return typeof (DarkMan.Plugin);
}
