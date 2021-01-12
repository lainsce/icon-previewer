using Gtk;

namespace IconPreview {
	public class Colour : Box, Previewer {
		const string RES_PATH = "/com/github/lainsce/iconpreviewer/icons/";
		const string BASE_THEME = "io.elementary.stylesheet.blueberry";
		static string[] colours;

		private ColourPane light = new ColourPane ();
		private ColourPane dark = new ColourPane ();
		private Exporter exporter;

		private File _icon;
		public File previewing {
			get {
				return _icon;
			}
			set {
			    try {
				    _icon = value;
				    var svg = new Rsvg.Handle.from_gfile_sync (_icon, FLAGS_NONE);
				    var hicolor = create_tmp_file ("#hicolor");
				    render_by_id (svg, "#hicolor", hicolor, 128);

				    var symbolic = create_tmp_file ("#symbolic");
        			render_by_id (svg, "#symbolic", symbolic, 16);

				    light.name = dark.name = _icon.get_basename ();

				    if (hicolor != null) {
					    light.hicolor = dark.hicolor = hicolor;
				    } else {
					    light.hicolor = dark.hicolor = _icon;
				    }

				    exporter.update_regular (light.hicolor);
				    exporter.update_symbolic (symbolic);
				    exporter.name = light.name;
				    light.symbolic = dark.symbolic = symbolic;
				} catch (Error e) {
		        }
			}
		}

		public Colour (Exporter e) {
			exporter = e;
		}

		class construct {
			set_css_name ("colour-view");
		}

		static construct {
			try {
				colours = resources_enumerate_children (RES_PATH, NONE);
			} catch (Error e) {
				critical ("Failed to load sample icons: %s", e.message);
			}
		}

		construct {
			light.theme = BASE_THEME;
			dark.theme = BASE_THEME + "-dark";

			homogeneous = true;
			add (light);
			add (dark);

			shuffle ();
		}

		public void shuffle () {
			var samples_names = random_selection (colours, 9);
			var samples = new File[9];

			for (var j = 0; j < 9; j++) {
				samples[j] = File.new_for_uri ("resource:/" + RES_PATH + samples_names[j]);
			}

			light.load_samples (samples);
			dark.load_samples (samples);
		}

		public Gdk.Pixbuf screenshot () {
			var w = get_allocated_width ();
			var content_h = get_allocated_height ();

			Gdk.Pixbuf logo;
			try {
				logo = new Gdk.Pixbuf.from_resource_at_scale ("/com/github/lainsce/iconpreviewer/badge.svg", 16, -1, true);
			} catch (Error e) {
				critical (e.message);
				logo = new Gdk.Pixbuf (RGB, false, 1, 2, 2);
			}
			var layout = create_pango_layout (_("Icon Previewer"));
			var font_description = new Pango.FontDescription ();
			font_description.set_weight (Pango.Weight.SEMIBOLD);
			font_description.set_size (Pango.SCALE * 10);
			layout.set_font_description (font_description);

			var padding = 12;

			var img_height = logo.get_height ();
			var img_width = logo.get_width ();
			Pango.Rectangle txt_extents;

			layout.get_pixel_extents (null, out txt_extents);

			var surface = new Cairo.ImageSurface (ARGB32, w, content_h);
			var context = new Cairo.Context (surface);

			draw (context);

			var img_x = 0;
			var txt_x = img_width + padding;
			if (get_direction () == RTL) {
				img_x = txt_extents.width + padding;
				txt_x = 0;
			}

			var img_y = 0;
			var txt_y = 0;
			if (txt_extents.height < img_height) {
				txt_y = (img_height - txt_extents.height) / 2;
			} else {
				img_y = (txt_extents.height - img_height) / 2;
			}

			context.save ();
			Gdk.cairo_set_source_pixbuf (context, logo,
										 padding + img_x, padding + img_y);
			context.rectangle (padding + img_x, padding + img_y, img_width, img_height);
			context.fill ();
			context.restore ();

			context.move_to (padding + txt_x, padding + txt_y);
			Pango.cairo_show_layout (context, layout);

			return Gdk.pixbuf_get_from_surface (surface, 0, 0, w, content_h);
		}
    }
}
