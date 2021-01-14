using Gtk;

namespace IconPreview {
  [GtkTemplate (ui = "/com/github/lainsce/iconpreviewer/iconexporter.ui")]
  public class Exporter : Popover {
    public new string name { get; set; }

    [GtkChild]
    Image regular_image128;

    [GtkChild]
    Image regular_image64;

    [GtkChild]
    Image regular_image48;

    [GtkChild]
    Image regular_image32;

    [GtkChild]
    Box regular_box128;

    [GtkChild]
    Box regular_box64;

    [GtkChild]
    Box regular_box48;

    [GtkChild]
    Box regular_box32;

    [GtkChild]
    Label regular_size128;

    [GtkChild]
    Label regular_size64;

    [GtkChild]
    Label regular_size48;

    [GtkChild]
    Label regular_size32;

    [GtkChild]
    Image symbolic_image;

    [GtkChild]
    Box symbolic_box;

    [GtkChild]
    Label symbolic_size;

    public void update_regular128 (File? source128) {
      if (source128 != null) {
        regular_box128.show ();
        FileIcon icon128 = new FileIcon (source128);
        regular_image128.set_from_gicon (icon128, BUTTON);
        regular_size128.set_label (get_file_size (source128));
    	regular_size128.hide ();
      } else {
        regular_box128.hide ();
      }
    }
    public void update_regular64 (File? source64) {
      if (source64 != null) {
        regular_box64.show ();
        FileIcon icon64 = new FileIcon (source64);
        regular_image64.set_from_gicon (icon64, BUTTON);
        regular_size64.set_label (get_file_size (source64));
    	regular_size64.hide ();
      } else {
        regular_box64.hide ();
      }
    }
    public void update_regular48 (File? source48) {
      if (source48 != null) {
        regular_box48.show ();
        FileIcon icon48 = new FileIcon (source48);
        regular_image48.set_from_gicon (icon48, BUTTON);
        regular_size48.set_label (get_file_size (source48));
    	regular_size48.hide ();
      } else {
        regular_box48.hide ();
      }
    }
    public void update_regular32 (File? source32) {
      if (source32 != null) {
        regular_box32.show ();
        FileIcon icon32 = new FileIcon (source32);
        regular_image32.set_from_gicon (icon32, BUTTON);
        regular_size32.set_label (get_file_size (source32));
    	regular_size32.hide ();
      } else {
        regular_box32.hide ();
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

    public File get_regular128 () {
      return ((FileIcon) regular_image128.gicon).get_file ();
    }
    public File get_regular64 () {
      return ((FileIcon) regular_image64.gicon).get_file ();
    }
    public File get_regular48 () {
      return ((FileIcon) regular_image48.gicon).get_file ();
    }
    public File get_regular32 () {
      return ((FileIcon) regular_image32.gicon).get_file ();
    }

    public File get_symbolic () {
      return ((FileIcon) symbolic_image.gicon).get_file ();
    }

  }
}
