using Gtk;

namespace IconPreview {
	public class DemoIcon : Box {
		private Image image = new Image ();
		private Label label = new Label (null);
		public File ?file { get; construct set; }
		public new string ?name { get; set; }

		public int size { get; construct set; default = 64; }
		class construct {
			set_css_name ("demo-icon");
		}

		construct {
			orientation = VERTICAL;
			spacing = 5;
			expand = false;
			valign = CENTER;

			label.ellipsize = END;
			label.max_width_chars = 30;

			bind_property ("size", image, "pixel_size");
			notify["file"].connect ((s, p) => {
				if (name != null) {
					var filename = name.substring (0, name.last_index_of (".svg"));
					filename = filename.substring (0, name.last_index_of (".Source"));
					var filename_parts = filename.split (".");
					label.label = filename_parts[filename_parts.length - 1];
					label.tooltip_text = filename;
					image.gicon = new FileIcon (file);
				}
			});

			pack_start (image);
			pack_end (label);
		}

		public DemoIcon (int size) {
			Object (size: size);
		}
	}

	[GtkTemplate (ui = "/com/github/lainsce/iconpreviewer/colourpane.ui")]
	public class ColourPane : Box {
		[GtkChild]
		Grid sizes;

		[GtkChild]
		Box grid;

		[GtkChild]
		Box small;

		CssProvider provider = null;
		List<DemoIcon> randoms;

		public File hicolor128 { get; set; }
		public File hicolor64 { get; set; }
		public File hicolor48 { get; set; }
		public File hicolor32 { get; set; }
		public File ?symbolic { get; set; }

		public new string name { get; set; }

		private string _theme = "io.elementary.stylesheet.blueberry";
		public string theme {
			get {
				return _theme;
			}

			set {
				var context = get_style_context ();
				context.remove_class (_theme.replace(".","-"));
				_theme = value;
				context.add_class (_theme.replace(".","-"));
				var parts = _theme.split ("-");
				if (parts.length > 1 && parts[1] == "dark") {
					provider = CssProvider.get_named (parts[0], "dark");
				} else {
					provider = CssProvider.get_named (_theme, null);
				}
				apply_css (this, provider);
			}
		}

		class construct {
			set_css_name ("pane");
		}

		construct {
			DemoIcon ico;

			notify["hicolor32"].connect (() => {
				if (symbolic == null) {
					sizes.get_child_at (0, 0).hide ();
					sizes.get_child_at (0, 1).hide ();
				}
				FileIcon icon1 = new FileIcon (hicolor32);
				var image = sizes.get_child_at (1, 0) as Image;
				image.set_from_gicon (icon1, BUTTON);
			});
			notify["hicolor48"].connect (() => {
				if (symbolic == null) {
					sizes.get_child_at (0, 0).hide ();
					sizes.get_child_at (0, 1).hide ();
				}
				FileIcon icon2 = new FileIcon (hicolor48);
				var image = sizes.get_child_at (2, 0) as Image;
				image.set_from_gicon (icon2, BUTTON);
			});
			notify["hicolor64"].connect (() => {
				if (symbolic == null) {
					sizes.get_child_at (0, 0).hide ();
					sizes.get_child_at (0, 1).hide ();
				}
				FileIcon icon3 = new FileIcon (hicolor64);
				var image = sizes.get_child_at (3, 0) as Image;
				image.set_from_gicon (icon3, BUTTON);
			});
			notify["hicolor128"].connect (() => {
				if (symbolic == null) {
					sizes.get_child_at (0, 0).hide ();
					sizes.get_child_at (0, 1).hide ();
				}
				FileIcon icon4 = new FileIcon (hicolor128);
				var image = sizes.get_child_at (4, 0) as Image;
				image.set_from_gicon (icon4, BUTTON);
			});

			notify["symbolic"].connect (() => {
				if (symbolic != null) {
					sizes.get_child_at (0, 1).show ();
					var image = sizes.get_child_at (0, 0) as Image;
					image.show ();
					FileIcon icon = new FileIcon (symbolic);
					image.set_from_gicon (icon, BUTTON);
				} else {
					sizes.get_child_at (0, 0).hide ();
					sizes.get_child_at (0, 1).hide ();
				}
			});

			for (var i = 0; i < 5; i++) {
				ico = new DemoIcon (64);
				small.add (ico);
				randoms.append (ico);
			}

			small.show_all ();

			for (var i = 0; i < 2; i++) {
			    ico = new DemoIcon (64);
			    grid.add (ico);
			    randoms.append (ico);
			}

            // A pause for the custom icon…
			ico = new DemoIcon (64);
			bind_property ("hicolor64", ico, "file");
			bind_property ("name", ico, "name");
			grid.add (ico);

			// Resume…
            for (var i = 2; i < 4; i++) {
			    ico = new DemoIcon (64);
			    grid.add (ico);
			    randoms.append (ico);
			}

			grid.show_all ();

			theme = theme;
		}

		public void load_samples (File[] samples) requires (samples.length == randoms.length ()) {
			// This is SUPER hardcoded…
			var idx = 0;
			foreach (var sample in randoms) {
				sample.name = samples[idx].get_basename ();
				sample.file = samples[idx];
				idx++;
			}
		}
	}
}
