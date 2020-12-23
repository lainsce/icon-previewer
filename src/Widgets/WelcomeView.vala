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
                _("Start by making a new app icon.")
            );
            welcome_view.append ("document-new", _("New App Icon"), "Setups name and location.");

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
            // TODO: Dialog with icon creation from a pre-made SVG file
            // named by user in the chosen directory by the user.
            win.stack.set_visible_child_name ("preview");
        }
    }
}
