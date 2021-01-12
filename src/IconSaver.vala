using Gtk;

namespace IconPreview {
	[GtkTemplate (ui = "/com/github/lainsce/iconpreviewer/iconsaver.ui")]
	class ScreenshotSaver : Gtk.Dialog {
		[GtkChild]
		Image preview;

		public Gdk.Pixbuf pixbuf { get; set; }

		const GLib.ActionEntry[] ACTION_ENTRIES = {
			{ "close", _close },
			{ "copy", copy },
			{ "save", save },
		};

		const int WIDTH = 450;

		construct {
			bind_property ("pixbuf", preview, "pixbuf", DEFAULT, (binding, srcval, ref targetval) => {
				var src = (Gdk.Pixbuf) srcval;
				var ratio = ((double) src.width) / WIDTH;
				targetval.set_object (src.scale_simple (WIDTH, (int) (src.height / ratio), BILINEAR));
				return true;
			});

			var actions = new SimpleActionGroup ();
			actions.add_action_entries (ACTION_ENTRIES, this);
			insert_action_group ("dlg", actions);
		}

		public ScreenshotSaver (Window parent, Gdk.Pixbuf pixbuf) {
			Object (transient_for: parent, pixbuf: pixbuf);
		}

		private void _close () {
			destroy ();
		}

		public void copy () {
			Clipboard.get_default (get_display ()).set_image (pixbuf);
		}

		public void save () {
			var dlg = new FileChooserNative (_("Save Screenshot"), this, SAVE, _("_Save"), null);
			dlg.modal = true;
			dlg.do_overwrite_confirmation = true;
			try {
				var name = "%.png".printf (_("Preview"));
				var file = File.new_build_filename (Environment.get_home_dir (), "Projects", "Icons", name, null);
				dlg.set_file (file);
			} catch (Error e) {
				warning ("Can't set initial file: %s", e.message);
			}

			var any = new Gtk.FileFilter ();
			any.set_filter_name (_("Icon Previewer"));
			any.add_pattern ("*.png");
			any.add_mime_type ("image/png");
			any.add_pattern ("*.jpg");
			any.add_pattern ("*.jpeg");
			any.add_mime_type ("image/jpeg");
			dlg.add_filter (any);

			var png = new Gtk.FileFilter ();
			png.set_filter_name (_("PNG"));
			png.add_pattern ("*.png");
			png.add_mime_type ("image/png");
			dlg.add_filter (png);

			var jpeg = new Gtk.FileFilter ();
			jpeg.set_filter_name (_("JPEG"));
			jpeg.add_pattern ("*.jpg");
			jpeg.add_pattern ("*.jpeg");
			jpeg.add_mime_type ("image/jpeg");
			dlg.add_filter (jpeg);

			if (dlg.run () == ResponseType.ACCEPT) {
				var file = dlg.get_filename ();
				try {
					pixbuf.save (dlg.get_filename (), file.reverse ().split (".", 2)[0].reverse ());
				} catch (Error e) {
					var msg = new MessageDialog (this, MODAL, ERROR, CANCEL, _("Failed to save screenshot"));
					msg.secondary_text = e.message;
					msg.response.connect (() => msg.destroy ());
					msg.show ();
				}
			}

			destroy ();
		}
	}
}
