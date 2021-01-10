/*
* Copyright (c) 2021 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/
namespace IconPreviewer.Widgets {
    public class TitleBar : Hdy.HeaderBar {
        private MainWindow win;

        public signal void open ();
        public signal void refresh ();

        public TitleBar (MainWindow win) {
            this.win = win;

            var open_file_button = new Gtk.Button.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR);
            open_file_button.clicked.connect (() => open ());

            var refresh_button = new Gtk.ModelButton ();
            refresh_button.get_child ().destroy ();
            var refresh_button_accellabel = new Granite.AccelLabel.from_action_name (
                _("Refresh Icon…"),
                ""
            );
            refresh_button.add (refresh_button_accellabel);
            refresh_button.clicked.connect (() => refresh ());

            var gtk_settings = Gtk.Settings.get_default ();
            var dark_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic",
                                                                     "weather-clear-night-symbolic") {
                valign = Gtk.Align.CENTER,
                hexpand = true,
                margin = 12
            };
            dark_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

            var menu_grid = new Gtk.Grid ();
            menu_grid.margin = 6;
            menu_grid.row_spacing = 6;
            menu_grid.column_spacing = 12;
            menu_grid.orientation = Gtk.Orientation.VERTICAL;
            menu_grid.add (dark_switch);
            menu_grid.add (refresh_button);
            menu_grid.show_all ();

            var menu = new Gtk.Popover (null);
            menu.add (menu_grid);

            var menu_button = new Gtk.MenuButton ();
            menu_button.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));
            menu_button.has_tooltip = true;
            menu_button.tooltip_text = (_("Settings"));
            menu_button.popover = menu;

            pack_end (menu_button);
            pack_start (open_file_button);

            if (win.stack != null) {
                if (win.stack.get_visible_child_name () != "welcome") {
                    open_file_button.visible = true;
                } else {
                    open_file_button.visible = false;
                }
            }

            show_close_button = true;
            has_subtitle = false;
            title = "Icon Previewer";
            set_decoration_layout ("close:maximize");
        }
    }
}
