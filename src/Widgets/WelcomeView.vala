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
                _("Let's get started!"),
                _("Start by opening your icon.")
            );
            welcome_view.append ("document-open", _("Open App Icon"), "Opens an icon for viewing. Should be the 128px sized one.");

            welcome_view.activated.connect ((option) => {
                switch (option) {
                    case 0:
                        configure ();
                        break;
                }
            });
            this.add (welcome_view);
        }

        private void configure () {
            win.on_open ();
            win.stack.set_visible_child_name ("preview");
        }
    }
}
