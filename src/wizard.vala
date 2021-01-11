using Gtk;

namespace IconPreview {
	[GtkTemplate (ui = "/com/github/lainsce/icon-previewer/wizard.ui")]
	class Wizard : Gtk.Dialog {
		[GtkChild]
		Dazzle.FileChooserEntry location;

		[GtkChild]
		Entry icon_title;

		[GtkChild]
		Spinner spin;

		[GtkChild]
		Button accept_button;


		public signal void open (File file);

		construct {
			use_header_bar = (int) Gtk.Settings.get_default ().gtk_dialogs_use_header;
			location.file = File.new_for_path (Path.build_filename (Environment.get_home_dir (), "Projects"));

			icon_title.notify["text"].connect (() => {
				accept_button.sensitive = icon_title.text.length > 0;
				if (!("." in icon_title.text)) {
					icon_title.secondary_icon_name = "dialog-warning-symbolic";
					icon_title.secondary_icon_tooltip_text = _("Expecting at least one “.”");
				} else {
					icon_title.secondary_icon_name = null;
					icon_title.secondary_icon_tooltip_text = null;
				}
			});
		}

		public Wizard (Window parent) {
			Object (transient_for: parent);
		}

		public override void response (int response) {
			if (response == ResponseType.ACCEPT) {
				new_icon.begin ();
			} else {
				destroy ();
			}
		}

		private async void launch (File file) {
			open (file);
			try {
				yield AppInfo.launch_default_for_uri_async (file.get_uri (), null);
			} catch (Error e) {
				critical ("Failed to open %s: %s", file.get_basename (), e.message);
			}
		}

		private async void new_icon () {
			spin.visible = spin.active = true;

			yield launch (yield colour ());

			Idle.add (() => {
				destroy ();
				return Source.REMOVE;
			});
		}

		private async File colour () {
			var dest = File.new_for_path (Path.build_filename (location.file.get_path (), icon_title.text + ".Source.svg"));
			var from = File.new_for_uri ("resource:///com/github/lainsce/icon-previewer/templates/colour.svg");
			try {
				var p = dest.get_parent ();
				if (!p.query_exists ()) {
					p.make_directory_with_parents ();
				}
				yield from.copy_async (dest, NONE);
				message ("Copied %s -> %s", from.get_uri (), dest.get_uri ());
			} catch (Error e) {
				critical ("Error: %s", e.message);
			}
			return dest;
		}
	}
}
