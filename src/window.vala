using Gtk;
namespace IconPreview {
	[GtkTemplate (ui = "/com/github/lainsce/icon-previewer/window.ui")]
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
			{ "copy-screenshot", copy_screenshot },
			{ "refresh", refresh },
			{ "shuffle", shuffle },
			{ "menu", open_menu },
			{ "export", open_export },
			{ "export-save", save_export, "s" }
		};

		FileMonitor monitor = null;

		private File _file;
		public File file {
			set {
				try {
					// Hopefully this doesn't render the SVG?
					var svg = new Rsvg.Handle.from_gfile_sync (value, FLAGS_NONE);

					Rsvg.Rectangle hicolor = { 0.0, 0.0, svg.width, svg.height };

					if (svg.has_sub ("#hicolor")) {
            			Rsvg.Rectangle viewport = { 0.0, 0.0, svg.width, svg.height };
						svg.get_geometry_for_layer ( "#hicolor", viewport, null, out hicolor);
					}

					// Colour (App) icons must be 128 by 128 and
					// and can contain a symbolic icon
					if (hicolor.height == 128 && hicolor.width == 128) {
						mode = COLOUR;
					// anything else is unsupported
					} else {
						// We are very specific about what we like
						_file = null;
						_load_failed ();
						// Give up now
						return;
					}
				} catch (Error e) {
					// rsvg didn't like it (not an SVG?)
					critical ("Failed to load %s: %s", value.get_basename (), e.message);
					_file = null;
					_load_failed ();
					return;
				}
				try {
					// If we are already monitoring an open file
					if (monitor != null) {
						// Stop doing that
						monitor.cancel ();
					}
					// Watch for updates
					monitor = value.monitor_file (NONE, null);
					monitor.changed.connect (file_updated);
				} catch (Error e) {
					// Failed to watch the file
					critical ("Unable to watch icon: %s", e.message);
				}
				_file = value;
				// Actually display the thing
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

			// Bind the actions
			add_action_entries (ACTION_ENTRIES, this);

			// Listen for changes to the mode
			notify["mode"].connect (mode_changed);
			// Manually trigger a change
			mode_changed ();

			// For some reason MenuButton doesn't have a menu_id property
			menu.menu_model = application.get_menu_by_id ("win-menu");

			// Connect exporter popover to button
			exporter = new Exporter ();
			exportbtn.set_popover (exporter);

			// Bind export action state to button visibility
			var action = lookup_action ("export");
			action.bind_property ("enabled", exportbtn, "visible", GLib.BindingFlags.SYNC_CREATE);
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
				// Effectively close the old previewer
				old.destroy ();
			} else {
				// We have an open file now
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

		// win.new always expects an argument
		private void new_icon () {
			var wiz = new Wizard (this);
			wiz.open.connect (@new => file = @new);
			wiz.run ();
		}

		// Screenshot the previewer
		private void screenshot () requires (content.visible_child is Previewer) {
			var buf = ((Previewer) content.visible_child).screenshot ();

			var s = new ScreenshotSaver (this, buf);
			s.show ();
		}

		// Screenshot the previewer
		private void copy_screenshot () requires (content.visible_child is Previewer) {
			var buf = ((Previewer) content.visible_child).screenshot ();

			var s = new ScreenshotSaver (this, buf);
			s.copy ();
		}

		// Open file chooser for exporting
		private void save_export (GLib.Action _act, Variant? arg) {
			string title = "";
			string filename = exporter.name;
			filename = filename.substring (0, filename.last_index_of (".svg"));
			filename = filename.substring (0, filename.last_index_of (".Source"));
			File file = null;
			switch (arg as string) {
				case "regular": {
					title = _("Save Regular");
					filename = filename + ".svg";
					file = exporter.get_regular ();
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

		// Open the export popover (win.export)
		private void open_export () {
			exportbtn.clicked ();
		}

		// Manually reload the current icon (win.refresh)
		// Requires:
		//     The must be an open file to reload
		private void refresh () requires (file != null) {
			// Trigger a dummy changed event
			file_updated (file, null, CHANGED);
		}

		// Change the random comparison icons (win.shuffle)
		// Requires:
		//     The should be an open previewer to shuffle
		private void shuffle () requires (content.visible_child is Previewer) {
			((Previewer) content.visible_child).shuffle ();
		}

		// The currently open file was modified
		// Requires:
		//     The source of the event shouldn't be null and a previewer has no
		//     chance of displaying null, equally there must be an active
		//     previewer to display the modified icon in
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

		// Wrapper for win.menu
		private void open_menu () {
			menu.clicked ();
		}
	}

}
