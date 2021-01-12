using Gtk;
namespace IconPreview {
	[GtkTemplate (ui = "/com/github/lainsce/iconpreviewer/mainwindow.ui")]
	public class Window : Hdy.ApplicationWindow {
		[GtkChild]
		Stack content;

		[GtkChild]
		MenuButton menu;

		[GtkChild]
		MenuButton exportbtn;

		Exporter exporter;

		const GLib.ActionEntry[] ACTION_ENTRIES = {
			{ "open", open },
			{ "new-icon", new_icon },
			{ "screenshot", screenshot },
			{ "refresh", refresh },
			{ "shuffle", shuffle },
			{ "guide", guide },
			{ "menu", open_menu },
			{ "export", open_export },
			{ "export-save", save_export, "s" }
		};

		FileMonitor monitor = null;

		private File _file;
		public File file {
			set {
				try {
					var svg = new Rsvg.Handle.from_gfile_sync (value, FLAGS_NONE);

					Rsvg.Rectangle hicolor128 = { 0.0, 0.0, svg.width, svg.height };
					Rsvg.Rectangle hicolor64 = { 0.0, 0.0, svg.width, svg.height };
					Rsvg.Rectangle hicolor32 = { 0.0, 0.0, svg.width, svg.height };

					if (svg.has_sub ("#128")) {
            			Rsvg.Rectangle viewport = { 0.0, 0.0, svg.width, svg.height };
						svg.get_geometry_for_layer ( "#128", viewport, null, out hicolor128);
					}
					if (svg.has_sub ("#64")) {
            			Rsvg.Rectangle viewport1 = { 0.0, 0.0, svg.width, svg.height };
						svg.get_geometry_for_layer ( "#64", viewport1, null, out hicolor64);
					}
					if (svg.has_sub ("#32")) {
            			Rsvg.Rectangle viewport2 = { 0.0, 0.0, svg.width, svg.height };
						svg.get_geometry_for_layer ( "#32", viewport2, null, out hicolor32);
					}

					if (hicolor128.height == 128 && hicolor128.width == 128 &&
					    hicolor64.height == 64 && hicolor64.width == 64 &&
					    hicolor32.height == 32 && hicolor32.width == 32) {
						mode = COLOUR;
					} else {
						_file = null;
						_load_failed ();
						return;
					}
				} catch (Error e) {
					critical ("Failed to load %s: %s", value.get_basename (), e.message);
					_file = null;
					_load_failed ();
					return;
				}
				try {
					if (monitor != null) {
						monitor.cancel ();
					}
					monitor = value.monitor_file (NONE, null);
					monitor.changed.connect (file_updated);
				} catch (Error e) {
					critical ("Unable to watch icon: %s", e.message);
				}
				_file = value;
				refresh ();
			}

			get {
				return _file;
			}
		}

		public Mode mode { get; set; default = INITIAL; }

		// A hack to get construction to work properly
		public Application app {
			construct {
				application = value;
			}

			private get {
				return application as Application;
			}
		}

		public Window (Application app) {
			Object (app: app);
		}

		construct {
		    Hdy.init ();

			add_action_entries (ACTION_ENTRIES, this);

			notify["mode"].connect (mode_changed);
			mode_changed ();

			exporter = new Exporter ();
			exportbtn.set_popover (exporter);

			var action = lookup_action ("export");
			action.bind_property ("enabled", exportbtn, "visible", GLib.BindingFlags.SYNC_CREATE);

            Gtk.Settings.get_default().set_property("gtk-theme-name", "io.elementary.stylesheet.grape");
            Gtk.Settings.get_default().set_property("gtk-icon-theme-name", "elementary");
            Gtk.Settings.get_default().set_property("gtk-font-name", "Inter 9");
		}

		private void _load_failed () {
			var dlg = new MessageDialog (this, MODAL, WARNING, CANCEL, _("This file is defective"));
			dlg.secondary_text = _("Please start from a template to ensure that your file will work as an elementary OS icon");
			dlg.response.connect (() => dlg.destroy ());
			dlg.show ();
		}

		private void mode_changed () {
			switch (mode) {
				case INITIAL:
					title = _("Icon Previewer");
					((SimpleAction) lookup_action ("refresh")).set_enabled (false);
					((SimpleAction) lookup_action ("shuffle")).set_enabled (false);
					((SimpleAction) lookup_action ("export")).set_enabled (false);
					((SimpleAction) lookup_action ("screenshot")).set_enabled (false);
					((SimpleAction) lookup_action ("copy-screenshot")).set_enabled (false);
					break;
				case COLOUR:
					_mode_changed (new Colour (exporter));
					break;
			}
		}

		private void _mode_changed (Previewer view) {
			var old = content.visible_child;
			view.show ();
			content.add (view);
			content.visible_child = view;
			if (old is Previewer) {
				old.destroy ();
			} else {
				((SimpleAction) lookup_action ("refresh")).set_enabled (true);
				((SimpleAction) lookup_action ("shuffle")).set_enabled (true);
				((SimpleAction) lookup_action ("export")).set_enabled (true);
				((SimpleAction) lookup_action ("screenshot")).set_enabled (true);
				((SimpleAction) lookup_action ("copy-screenshot")).set_enabled (true);
			}
		}

		private void open () {
			var dlg = new FileChooserDialog (_("Select Icon"), this, OPEN, _("_Open"),
		                                             Gtk.ResponseType.ACCEPT,
		                                             _("Cancel"), Gtk.ResponseType.CANCEL);
			dlg.modal = true;
			var filter = new Gtk.FileFilter ();
			filter.set_filter_name (_("Icons"));
			filter.add_pattern ("*.svg");
			filter.add_mime_type ("image/svg+xml");
			dlg.add_filter (filter);
			dlg.response.connect (res => {
				if (res == ResponseType.ACCEPT) {
					file = dlg.get_file ();
				}
				dlg.close ();
			});
			dlg.show ();
		}

		private void new_icon () {
			var wiz = new Wizard (this);
			wiz.open.connect (@new => file = @new);
			wiz.run ();
		}

		private void screenshot () requires (content.visible_child is Previewer) {
			var buf = ((Previewer) content.visible_child).screenshot ();

			var s = new ScreenshotSaver (this, buf);
			s.show ();
		}

		private void guide () {
            try {
		        GLib.AppInfo.launch_default_for_uri ("https://elementary.io/docs/human-interface-guidelines#iconography", null);
		    } catch (Error e) {
		        message ("Err: %s", e.message);
		    }
		}

		private void save_export (GLib.Action _act, Variant? arg) {
			string title = "";
			string filename = exporter.name;
			filename = filename.substring (0, filename.last_index_of (".svg"));
			filename = filename.substring (0, filename.last_index_of (".Source"));
			File file = null;
			switch (arg as string) {
				case "regular128": {
					title = _("Save Regular");
					filename = filename + "128.svg";
					file = exporter.get_regular128 ();
					break;
				}
				case "regular64": {
					title = _("Save Regular");
					filename = filename + "64.svg";
					file = exporter.get_regular64 ();
					break;
				}
				case "regular32": {
					title = _("Save Regular");
					filename = filename + "32.svg";
					file = exporter.get_regular32 ();
					break;
				}
				case "symbolic": {
					title = _("Save Symbolic");
					filename = filename + "-symbolic.svg";
					file = exporter.get_symbolic ();
					break;
				}
			}
			var dlg = new FileChooserNative (title, this, SAVE, _("_Save"), null);
			dlg.modal = true;
			dlg.do_overwrite_confirmation = true;
			dlg.set_current_folder (Environment.get_home_dir ());
			dlg.set_current_name (filename);

			var any = new Gtk.FileFilter ();
			any.set_filter_name (title + " " + _("Icon"));
			any.add_pattern ("*.svg");
			any.add_mime_type ("image/svg");
			dlg.add_filter (any);

			var svg = new Gtk.FileFilter ();
			svg.set_filter_name (_("SVG"));
			svg.add_pattern ("*.svg");
			svg.add_mime_type ("image/svg");
			dlg.add_filter (svg);

			if (dlg.run () == ResponseType.ACCEPT) {
				var dest = dlg.get_file ();
				try {
					file.copy (dest, FileCopyFlags.OVERWRITE);
				} catch (Error e) {
					var msg = new MessageDialog (this, MODAL, ERROR, CANCEL, _("Failed to save exported file"));
					msg.secondary_text = e.message;
					msg.response.connect (() => msg.destroy ());
					msg.show ();
				}
			}
		}

		private void open_export () {
			exportbtn.clicked ();
		}

		private void refresh () requires (file != null) {
			file_updated (file, null, CHANGED);
		}

		private void shuffle () requires (content.visible_child is Previewer) {
			((Previewer) content.visible_child).shuffle ();
		}

		private void file_updated (File src, File? dest, FileMonitorEvent evt) requires (src != null && content.visible_child is Previewer) {
			if (evt != CHANGED) {
				return;
			}
			((Previewer) content.visible_child).previewing = src;
			try {
				var info = src.query_info ("standard::display-name", NONE);
				title = info.get_display_name ();
			} catch (Error e) {
				critical ("Failed to fetch icon name: %s", e.message);
				title = _("Icon Previewer");
			}
		}

		private void open_menu () {
			menu.clicked ();
		}
	}

}
