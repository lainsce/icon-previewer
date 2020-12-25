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
    public class WelcomeView : Gtk.ScrolledWindow {
        private MainWindow win;
        public WelcomeView (MainWindow win) {
            this.win = win;

            var welcome_view = new Granite.Widgets.Welcome (
                _("No App Icon Open"),
                _("Open app icon to begin previewing")
            );
            welcome_view.append ("document-open", _("Open App Icon"), "Opens an app icon for viewing.");
            welcome_view.append ("help-contents", _("Icon Guidelines"), "Check the Icon guidelines in your browser.");

            welcome_view.activated.connect ((option) => {
                switch (option) {
                    case 0:
                        win.on_open ();
                        break;
                    case 1:
                        try {
					        GLib.AppInfo.launch_default_for_uri ("https://elementary.io/docs/human-interface-guidelines#iconography", null);
					    } catch (Error e) {
					        message ("Err: %s", e.message);
					    }
					    break;
                }
            });
            this.add (welcome_view);
        }
    }
}
