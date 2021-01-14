using Gtk;

namespace IconPreview {
	public Cairo.Surface? render_by_id (Rsvg.Handle svg, string id, File file, int output_size) {
		if (svg.has_sub (id)) {
			try {
			    Rsvg.Rectangle size;
			    Rsvg.Rectangle viewport = { 0.0, 0.0, svg.width, svg.height };
			    svg.get_geometry_for_layer (id, viewport, null, out size);
			    var surface = new Cairo.SvgSurface (file.get_path (), output_size, output_size);
			    surface.set_document_unit (Cairo.SvgUnit.PX);
			    var cr = new Cairo.Context (surface);
			    cr.scale (output_size / size.width, output_size / size.height);
			    cr.translate (-size.x, -size.y);
			    cr.fill ();
			    svg.render_cairo (cr);
			    return surface;
			} catch (Error e) {
		    }
		}
		return null;
	}

	public File create_tmp_file (string id) {
		FileIOStream stream;
		try {
		    return File.new_tmp ("XXXXXX-" + id.substring (1, -1) + ".svg", out stream);
		} catch (Error e) {
		}
		return (File) null;
	}
}
