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
namespace IconPreviewer.Services.DialogUtils {
    public Gtk.FileChooserNative create_file_chooser (string title, Gtk.FileChooserAction action) {
        var chooser = new Gtk.FileChooserNative (title, null, action, null, null);
        var filter = new Gtk.FileFilter ();
        filter.set_filter_name (_("SVG files"));
        filter.add_pattern ("*.svg");
        chooser.add_filter (filter);
        return chooser;
    }

    public Gtk.Dialog create_dialog (MainWindow window) {
        var dialog = new Gtk.Dialog ();
        dialog.set_transient_for (window);
        dialog.set_modal (true);
        return dialog;
    }
}
