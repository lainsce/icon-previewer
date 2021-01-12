using Gtk;

namespace IconPreview {
  [GtkTemplate (ui = "/com/github/lainsce/icon-previewer/iconexporter.ui")]
  public class Exporter : Popover {
    public new string name { get; set; }

    [GtkChild]
    Image regular_image;

    [GtkChild]
    Box regular_box;

    [GtkChild]
    Label regular_size;

    [GtkChild]
    Image symbolic_image;

    [GtkChild]
    Box symbolic_box;

    [GtkChild]
    Label symbolic_size;

    public void update_regular (File? source) {
      if (source != null) {
        regular_box.show ();
        FileIcon icon = new FileIcon (source);
        regular_image.set_from_gicon (icon, BUTTON);
        regular_size.set_label (get_file_size (source));
    	regular_size.hide ();
      } else {
        regular_box.hide ();
      }
    }
    public void update_symbolic (File? source) {
      if (source != null) {
        symbolic_box.show ();
        FileIcon icon = new FileIcon (source);
        symbolic_image.set_from_gicon (icon, BUTTON);
        symbolic_size.set_label (get_file_size (source));
        symbolic_size.hide ();
      } else {
        symbolic_box.hide ();
      }
    }

    private string get_file_size (File file) {
      string result = "";
      try {
        FileInfo info = file.query_info ("standard", 0);
        result = "(" + format_size (info.get_size ()) + ")";
      } catch (Error e) {
      	debug ("Couldn't get file size");
      }
      return result;
    }

    public File get_regular () {
      return ((FileIcon) regular_image.gicon).get_file ();
    }

    public File get_symbolic () {
      return ((FileIcon) symbolic_image.gicon).get_file ();
    }

  }
}
