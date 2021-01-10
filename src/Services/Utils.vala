/*
 * Copyright (C) 2021 Lains
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
namespace IconPreviewer.Services.Utils {
    public Gtk.InfoBar pop_infobar () {
        var label = new Gtk.Label (_("Please choose an icon that has a filename formatted as Reverse Domain Name Notation, used for applications."));
        var infobar = new Gtk.InfoBar ();
        infobar.get_style_context ().add_class ("ip-infobar");
        infobar.message_type = Gtk.MessageType.INFO;
        infobar.set_show_close_button (true);
        infobar.get_content_area ().add (label);
        infobar.show_all ();

        infobar.revealed = true;

        infobar.close.connect (() => {
            infobar.set_revealed (false);
        });

        infobar.response.connect (() => {
            infobar.set_revealed (false);
        });

        return infobar;
    }
    public string split_words (string txt) {
        string result = "";
        try {
            var r = new Regex ("[a-z]+");
            string[] lines = r.split (txt);

            var r2 = new Regex ("[A-Z]+");
            string[] lines2 = r2.split (txt);

            if (lines[1] != null && lines2[1] != null) {
                result = lines[0] + lines2[1] + " " + lines[1] + lines2[2];
            } else {
                result = txt.substring (0, 1).up () + txt.substring (1).down ();
            }
        } catch (RegexError e) {
            message ("Err: %s", e.message);
        }
        return result;
    }

    public string title_case (string txt) {
        string result = "";
        string 3rd_name = "";
        string 4th_name = "";

        var names = txt.replace ("."," ").replace ("_"," ").split (" ");

        if (names[0] != null && names[1] != null && names[2] != null) {
            // A RDNN can have up to 4 different parts. We'll use only the necessary ones.
            3rd_name = names[2].substring (0, 1).up () + names[2].substring (1).down ();
            4th_name = names[3].substring (0, 1).up () + names[3].substring (1).down ();

            if (4th_name != null) {
                if (4th_name == "Devel") {
                    result = split_words (names[2]) + " (Nightly)";
                } else {
                    if (4th_name.contains ("-")) {
                        var no_dash_4th_name = 4th_name.replace ("-", " ").split (" ");
                        result = no_dash_4th_name[0].substring (0, 1).up () + no_dash_4th_name[0].substring (1).down () + " "
                                 + no_dash_4th_name[1].substring (0, 1).up () + no_dash_4th_name[1].substring (1).down ();
                    } else {
                        result = split_words (names[3]);
                    }
                }
            } else {
                if (3rd_name.contains ("-")) {
                    var no_dash_3rd_name = 3rd_name.replace ("-", " ").split (" ");
                    result = no_dash_3rd_name[0].substring (0, 1).up () + no_dash_3rd_name[0].substring (1).down () + " "
                             + no_dash_3rd_name[1].substring (0, 1).up () + no_dash_3rd_name[1].substring (1).down ();
                } else {
                    if (3rd_name == "Eog") {
                        result = "Eye of GNOME";
                    } else {
                        result = split_words (names[2]);
                    }
                }
            }
        }
        return result;
    }

    public Gtk.Grid make_grid (string appn, string iconn, int size, bool dark) {
        var grid = new Gtk.Grid ();
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.row_spacing = 6;

        if (iconn != null) {
            var iconm = new Gtk.Image ();
            iconm.gicon = new ThemedIcon (iconn);
            iconm.pixel_size = size;
            grid.attach (iconm, 0, 0, 1, 1);
        }

        if (appn != null) {
            var label = new Gtk.Label (appn);
            label.halign = Gtk.Align.CENTER;
            label.justify = Gtk.Justification.CENTER;
            label.lines = 2;
            label.max_width_chars = 16;
            label.wrap_mode = Pango.WrapMode.WORD_CHAR;
            label.set_ellipsize (Pango.EllipsizeMode.END);

            if (dark) {
                label.get_style_context ().add_class ("light_text");
                label.get_style_context ().remove_class ("dark_text");
            } else {
                label.get_style_context ().add_class ("dark_text");
                label.get_style_context ().remove_class ("light_text");
            }
            grid.attach (label, 0, 1, 1, 1);
        }

        return grid;
    }

    public Gtk.Button make_button (string iconn, int size) {
        var button = new Gtk.Button.from_icon_name (iconn, Gtk.IconSize.DIALOG);
        ((Gtk.Image) button.get_image ()).pixel_size = size;
        button.valign = Gtk.Align.CENTER;
        return button;
    }

    public Gdk.Pixbuf? make_pixbuf (int size, string path) {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, size, size, true);
            return pixbuf;
        } catch (Error e) {
            message ("Err: %s", e.message);
        }
        return null;
    }

    public Gtk.Image? make_image (string path, int size) {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file_at_scale (path, size, size, true);
            var image = new Gtk.Image.from_pixbuf (pixbuf);
            return image;
        } catch (Error e) {
            message ("Err: %s", e.message);
        }
        return null;
    }
}
