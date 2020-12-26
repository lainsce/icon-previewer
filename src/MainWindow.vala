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
*/
namespace IconPreviewer {
    public class MainWindow : Hdy.ApplicationWindow {
        public Gtk.Grid main_grid;
        public Gtk.Grid welcome_grid;
        public Gtk.Grid preview_grid;
        public Gtk.Grid app_icon_grid;
        public Gtk.Grid dialog_grid;
        public Gtk.Image icon_e;
        public Gtk.Image icon_k;
        public Gtk.Label label_e;
        public Gtk.Label label_k;
        public Gtk.Label label_app;
        public Gtk.Label label_id;
        public Gtk.Stack stack;
        public Gtk.Stack titlebar_stack;
        public Widgets.TitleBar titlebar;
        public Gtk.Application app { get; construct; }
        public GLib.File file;
        public Gee.ArrayList<GLib.File> files;
        int[] sizes = {16, 24, 32, 48, 64, 128};

        public string app_id = "com.github.lainsce.icon-previewer";
        public string app_name = "Icon Previewer";
        public string app_icon = "com.github.lainsce.icon-previewer";

        public MainWindow (Gtk.Application application) {
            GLib.Object (
                application: application,
                app: application,
                icon_name: "com.github.lainsce.icon-previewer",
                title: ("Icon Previewer")
            );

            key_press_event.connect ((e) => {
                uint keycode = e.hardware_keycode;

                if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                    if (match_keycode (Gdk.Key.q, keycode)) {
                        this.destroy ();
                    }
                }
                return false;
            });

            if (IconPreviewer.Application.gsettings.get_boolean("dark-mode")) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
            } else {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
            }

            if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                IconPreviewer.Application.gsettings.set_boolean("dark-mode", true);
            } else if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                IconPreviewer.Application.gsettings.set_boolean("dark-mode", false);
            }

            IconPreviewer.Application.grsettings.notify["prefers-color-scheme"].connect (() => {
                 if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK) {
                     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                     IconPreviewer.Application.gsettings.set_boolean("dark-mode", true);
                 } else if (IconPreviewer.Application.grsettings.prefers_color_scheme == Granite.Settings.ColorScheme.NO_PREFERENCE) {
                     Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                     IconPreviewer.Application.gsettings.set_boolean("dark-mode", false);
                 }
            });

            IconPreviewer.Application.gsettings.changed.connect (() => {
                if (IconPreviewer.Application.gsettings.get_boolean("dark-mode")) {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                } else {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                }
            });
        }

        construct {
            Hdy.init ();

            files = new Gee.ArrayList<GLib.File> ();

            int x = IconPreviewer.Application.gsettings.get_int("window-x");
            int y = IconPreviewer.Application.gsettings.get_int("window-y");
            int h = IconPreviewer.Application.gsettings.get_int("window-height");
            int w = IconPreviewer.Application.gsettings.get_int("window-width");

            if (x != -1 && y != -1) {
                this.move (x, y);
            }
            if (w != 0 && h != 0) {
                this.resize (w, h);
            }

            IconPreviewer.Application.gsettings.changed.connect (() => {
                if (IconPreviewer.Application.gsettings.get_boolean("dark-mode")) {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
                } else {
                    Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
                }
            });

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/icon-previewer/app.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var titlebar = new Widgets.TitleBar (this);
            titlebar.open.connect (on_open);
            titlebar.refresh.connect (on_refresh);

            var appa_label_grid = Services.Utils.make_grid (_("Calculator"), "accessories-calculator", 64, true);
            appa_label_grid.get_style_context ().add_class ("boxed");
            var appb_label_grid = Services.Utils.make_grid (_("Text Editor"), "accessories-text-editor", 64, true);
            appb_label_grid.get_style_context ().add_class ("boxed");
            var appc_label_grid = Services.Utils.make_grid (_("Camera"), "accessories-camera", 64, true);
            appc_label_grid.get_style_context ().add_class ("boxed");
            var appd_label_grid = Services.Utils.make_grid (_("Chat"), "internet-chat", 64, true);
            appd_label_grid.get_style_context ().add_class ("boxed");
            var appf_label_grid = Services.Utils.make_grid (_("Video Player"), "multimedia-video-player", 64, true);
            appf_label_grid.get_style_context ().add_class ("boxed");

            var appg_label_grid = Services.Utils.make_grid (_("Calculator"), "accessories-calculator", 64, false);
            appg_label_grid.get_style_context ().add_class ("boxed");
            var apph_label_grid = Services.Utils.make_grid (_("Text Editor"), "accessories-text-editor", 64, false);
            apph_label_grid.get_style_context ().add_class ("boxed");
            var appi_label_grid = Services.Utils.make_grid (_("Camera"), "accessories-camera", 64, false);
            appi_label_grid.get_style_context ().add_class ("boxed");
            var appj_label_grid = Services.Utils.make_grid (_("Chat"), "internet-chat", 64, false);
            appj_label_grid.get_style_context ().add_class ("boxed");
            var appl_label_grid = Services.Utils.make_grid (_("Video Player"), "multimedia-video-player", 64, false);
            appl_label_grid.get_style_context ().add_class ("boxed");

            icon_e = new Gtk.Image.from_icon_name (this.app_icon, Gtk.IconSize.DIALOG);
            icon_e.pixel_size = 64;
            label_e = new Gtk.Label (app_name);
            label_e.halign = Gtk.Align.CENTER;
            label_e.justify = Gtk.Justification.CENTER;
            label_e.lines = 2;
            label_e.max_width_chars = 16;
            label_e.wrap_mode = Pango.WrapMode.WORD_CHAR;
            label_e.set_ellipsize (Pango.EllipsizeMode.END);
            label_e.get_style_context ().add_class ("light_text");

            var appe_label_grid = new Gtk.Grid ();
            appe_label_grid.get_style_context ().add_class ("accented-dark");
            appe_label_grid.get_style_context ().add_class ("boxed");
            appe_label_grid.valign = Gtk.Align.CENTER;
            appe_label_grid.halign = Gtk.Align.CENTER;
            appe_label_grid.row_spacing = 6;
            appe_label_grid.attach (icon_e, 0, 0, 1, 1);
            appe_label_grid.attach (label_e, 0, 1, 1, 1);

            icon_k = new Gtk.Image.from_icon_name (this.app_icon, Gtk.IconSize.DIALOG);
            icon_k.pixel_size = 64;
            label_k = new Gtk.Label (app_name);
            label_k.halign = Gtk.Align.CENTER;
            label_k.justify = Gtk.Justification.CENTER;
            label_k.lines = 2;
            label_k.max_width_chars = 16;
            label_k.wrap_mode = Pango.WrapMode.WORD_CHAR;
            label_k.set_ellipsize (Pango.EllipsizeMode.END);
            label_k.get_style_context ().add_class ("dark_text");

            var appk_label_grid = new Gtk.Grid ();
            appk_label_grid.get_style_context ().add_class ("accented");
            appk_label_grid.get_style_context ().add_class ("boxed");
            appk_label_grid.valign = Gtk.Align.CENTER;
            appk_label_grid.halign = Gtk.Align.CENTER;
            appk_label_grid.row_spacing = 6;
            appk_label_grid.attach (icon_k, 0, 0, 1, 1);
            appk_label_grid.attach (label_k, 0, 1, 1, 1);

            var dark_side_grid = new Gtk.Grid ();
            dark_side_grid.row_spacing = 48;
            dark_side_grid.column_spacing = 48;
            dark_side_grid.column_homogeneous = true;
            dark_side_grid.expand = true;
            dark_side_grid.halign = Gtk.Align.CENTER;
            dark_side_grid.valign = Gtk.Align.CENTER;
            dark_side_grid.attach (appa_label_grid, 0, 0, 1, 1);
            dark_side_grid.attach (appb_label_grid, 1, 0, 1, 1);
            dark_side_grid.attach (appc_label_grid, 2, 0, 1, 1);
            dark_side_grid.attach (appd_label_grid, 0, 1, 1, 1);
            dark_side_grid.attach (appe_label_grid, 1, 1, 1, 1);
            dark_side_grid.attach (appf_label_grid, 2, 1, 1, 1);

            var light_side_grid = new Gtk.Grid ();
            light_side_grid.row_spacing = 48;
            light_side_grid.column_spacing = 48;
            light_side_grid.column_homogeneous = true;
            light_side_grid.expand = true;
            light_side_grid.valign = Gtk.Align.CENTER;
            light_side_grid.attach (appg_label_grid, 0, 0, 1, 1);
            light_side_grid.attach (apph_label_grid, 1, 0, 1, 1);
            light_side_grid.attach (appi_label_grid, 2, 0, 1, 1);
            light_side_grid.attach (appj_label_grid, 0, 1, 1, 1);
            light_side_grid.attach (appk_label_grid, 1, 1, 1, 1);
            light_side_grid.attach (appl_label_grid, 2, 1, 1, 1);

            var icon_grid = new Gtk.Grid ();
            icon_grid.get_style_context ().add_class ("ip-grid");
            icon_grid.row_homogeneous = true;
            icon_grid.column_spacing = 48;
            icon_grid.margin = 12;
            icon_grid.attach (dark_side_grid, 0, 0, 1, 1);
            icon_grid.attach (light_side_grid, 1, 0, 1, 1);

            label_app = new Gtk.Label (this.app_name);
            label_app.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            label_app.halign = Gtk.Align.START;

            label_id = new Gtk.Label (this.app_id);
            label_id.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            label_id.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            label_id.halign = Gtk.Align.START;

            var app_label_grid = new Gtk.Grid ();
            app_label_grid.margin = 6;
            app_label_grid.margin_start = 24;
            app_label_grid.valign = Gtk.Align.CENTER;
            app_label_grid.orientation = Gtk.Orientation.VERTICAL;
            app_label_grid.attach (label_app, 0, 0, 1, 1);
            app_label_grid.attach (label_id, 0, 1, 1, 1);

            app_icon_grid = new Gtk.Grid ();
            app_icon_grid.margin_bottom = 24;
            app_icon_grid.halign = Gtk.Align.CENTER;

            preview_grid = new Gtk.Grid ();
            preview_grid.attach (icon_grid, 0, 1, 1, 1);
            preview_grid.attach (app_label_grid, 0, 3, 1, 1);

            welcome_grid = new Gtk.Grid ();
            welcome_grid.attach (new Widgets.WelcomeView (this), 0, 1, 1, 1);

            dialog_grid = new Gtk.Grid ();
            dialog_grid.get_style_context ().add_class ("dialog-grid");
            dialog_grid.margin = 12;
            dialog_grid.row_spacing = 6;
            dialog_grid.column_spacing = 6;
            dialog_grid.valign = Gtk.Align.CENTER;
            dialog_grid.halign = Gtk.Align.CENTER;
            dialog_grid.hexpand = vexpand = true;

            stack = new Gtk.Stack ();
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            stack.add_named (welcome_grid, "welcome");
            stack.add_named (dialog_grid, "dialog");
            stack.add_named (preview_grid, "preview");

            // Used so the welcome titlebar, which is flat, and with no buttons
            // doesn't jump in size when transtitioning to the preview titlebar.
            var dummy_welcome_title_button = new Gtk.Button ();
            dummy_welcome_title_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            dummy_welcome_title_button.sensitive = false;

            var welcome_titlebar = new Hdy.HeaderBar ();
            welcome_titlebar.show_close_button = true;
            welcome_titlebar.has_subtitle = false;
            welcome_titlebar.title = "Icon Previewer";
            welcome_titlebar.set_decoration_layout ("close:maximize");
            welcome_titlebar.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            welcome_titlebar.get_style_context ().add_class ("welcome-title");

            welcome_titlebar.pack_start (dummy_welcome_title_button);

            titlebar_stack = new Gtk.Stack ();
            titlebar_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
            titlebar_stack.add_named (welcome_titlebar, "welcome-title");
            titlebar_stack.add_named (titlebar, "preview-title");

            main_grid = new Gtk.Grid ();
            main_grid.attach (titlebar_stack, 0, 0, 1, 1);
            main_grid.attach (stack, 0, 1, 1, 1);

            this.add (main_grid);
            this.set_size_request (360, 360);
            this.show_all ();
        }
#if VALA_0_42
        protected bool match_keycode (uint keyval, uint code) {
#else
        protected bool match_keycode (int keyval, uint code) {
#endif
            Gdk.KeymapKey [] keys;
            Gdk.Keymap keymap = Gdk.Keymap.get_for_display (Gdk.Display.get_default ());
            if (keymap.get_entries_for_keyval (keyval, out keys)) {
                foreach (var key in keys) {
                    if (code == key.keycode)
                        return true;
                    }
                }

            return false;
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y, w, h;
            get_position (out x, out y);
            get_size (out w, out h);
            IconPreviewer.Application.gsettings.set_int("window-x", x);
            IconPreviewer.Application.gsettings.set_int("window-y", y);
            IconPreviewer.Application.gsettings.set_int("window-width", w);
            IconPreviewer.Application.gsettings.set_int("window-height", h);

            return false;
        }

        // IO stuff
        public void on_open () {
            var dialog_title = new Gtk.Label (_("Select icon files"));
            dialog_title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);
            dialog_title.halign = Gtk.Align.START;

            var dialog_subtitle = new Gtk.Label (_("Each size is important to have to comply with the guidelines"));
            dialog_subtitle.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
            dialog_subtitle.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
            dialog_subtitle.halign = Gtk.Align.START;

            var dialog_icon_grid = new Gtk.Grid ();
            dialog_icon_grid.row_homogeneous = true;
            dialog_icon_grid.column_spacing = 32;
            dialog_icon_grid.margin = 12;
            dialog_icon_grid.halign = Gtk.Align.CENTER;
            for (int i = 0; i < sizes.length; i++) {
                int size = sizes[i];
                var dialog_icon = Services.Utils.make_button ("document-open-symbolic", size);
                dialog_icon.valign = Gtk.Align.CENTER;
                dialog_icon.get_style_context ().add_class ("bordered-boxed");
                dialog_icon.clicked.connect (() => {
                    File file = open_dialog_action ();
                    files.add (file);

                    try {
                        var pixbuf = new Gdk.Pixbuf.from_file_at_scale(file.get_path (), size, size, true);
                        var image = new Gtk.Image.from_pixbuf (pixbuf);

                        dialog_icon.set_image (image);
                        dialog_icon.sensitive = false;
                    } catch (Error e) {
                        message ("Err: %s", e.message);
                    }
                });
                dialog_icon_grid.attach (dialog_icon, i, 0, 1, 1);

                var dialog_label = new Gtk.Label ((@"$size" + "px"));
                dialog_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
                dialog_icon_grid.attach (dialog_label, i, 1, 1, 1);
            }

            var dialog_button_grid = new Gtk.Grid ();
            dialog_button_grid.column_spacing = 6;
            dialog_button_grid.halign = Gtk.Align.END;
            dialog_button_grid.hexpand = true;

            var cancel_button = new Gtk.Button.with_label (_("Cancel"));
            cancel_button.halign = Gtk.Align.END;
            cancel_button.clicked.connect (() => {
                files = null;
                stack.set_visible_child_name ("welcome");

                foreach (var c in dialog_icon_grid.get_children ()) {
                    c.destroy ();
                }

                for (int i = 0; i < sizes.length; i++) {
                    int size = sizes[i];
                    var dialog_icon = Services.Utils.make_button ("document-open-symbolic", size);
                    dialog_icon.valign = Gtk.Align.CENTER;
                    dialog_icon.get_style_context ().add_class ("bordered-boxed");
                    dialog_icon.clicked.connect (() => {
                        File file = open_dialog_action ();
                        files.add (file);

                        try {
                            var pixbuf = new Gdk.Pixbuf.from_file_at_scale(file.get_path (), size, size, true);
                            var image = new Gtk.Image.from_pixbuf (pixbuf);

                            dialog_icon.set_image (image);
                            dialog_icon.sensitive = false;
                        } catch (Error e) {
                            message ("Err: %s", e.message);
                        }
                    });
                    dialog_icon_grid.attach (dialog_icon, i, 0, 1, 1);

                    var dialog_label = new Gtk.Label ((@"$size" + "px"));
                    dialog_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
                    dialog_icon_grid.attach (dialog_label, i, 1, 1, 1);
                }
            });

            var ok_button = new Gtk.Button.with_label (_("Display Icons"));
            ok_button.halign = Gtk.Align.END;
            ok_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

            dialog_button_grid.attach (cancel_button, 0, 0, 1, 1);
            dialog_button_grid.attach (ok_button, 1, 0, 1, 1);

            if (dialog_grid.get_children () == null) {
                dialog_grid.attach (dialog_title, 0, 0, 6, 1);
                dialog_grid.attach (dialog_subtitle, 0, 1, 6, 1);
                dialog_grid.attach (dialog_icon_grid, 0, 2, 6, 1);
                dialog_grid.attach (dialog_button_grid, 3, 3, 1, 1);
            }

            dialog_grid.show_all ();
            stack.set_visible_child_name ("dialog");

            ok_button.clicked.connect (() => {
                for (int i = 0; i < sizes.length; i++) {
                    if (files[i].get_basename ().replace (".svg", "").contains (".")) {
                        this.app_id = files[i].get_basename ().replace (".svg", "");
                        this.app_name = Services.Utils.title_case (files[i].get_basename ().replace (".svg", ""));
                        this.app_icon = app_id;

                        stack.set_visible_child_name ("preview");
                        titlebar_stack.set_visible_child_name ("preview-title");

                        label_app.label = app_name;
                        label_id.label = app_id;
                        label_e.label = app_name;
                        label_k.label = app_name;

                        int size = sizes[i];
                        var icon = Services.Utils.make_image (files[i].get_path (), size);
                        icon.get_style_context ().add_class ("boxed");
                        app_icon_grid.attach (icon, i, 0, 1, 1);

                        var label = new Gtk.Label ((@"$size" + "px"));
                        label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
                        app_icon_grid.attach (label, i, 1, 1, 1);

                        var pixbuf = Services.Utils.make_pixbuf (64, files[4].get_path ());

                        icon_e.set_from_pixbuf (pixbuf);
                        icon_k.set_from_pixbuf (pixbuf);
                    } else {
                        // Reset icons to defaults if the icon chosen isn't RDNN.
                        this.app_id = "com.github.lainsce.icon-previewer";
                        this.app_name = "Icon Previewer";
                        this.app_icon = "com.github.lainsce.icon-previewer";

                        stack.set_visible_child_name ("welcome");
                        titlebar_stack.set_visible_child_name ("welcome-title");

                        welcome_grid.attach (Services.Utils.pop_infobar (), 0, 0, 1, 1);
                    }
                }
                app_icon_grid.show_all ();
                preview_grid.attach (app_icon_grid, 0, 4, 1, 1);
            });
        }

        public void on_refresh () {
            var pixbuf1 = Services.Utils.make_pixbuf (64, files[4].get_path ());

            foreach (var c in app_icon_grid.get_children ()) {
                c.destroy ();
            }

            for (int i = 0; i < sizes.length; i++) {
                if (files[i].get_basename ().replace (".svg", "").contains (".")) {
                    int size = sizes[i];
                    var icon = Services.Utils.make_image (files[i].get_path (), size);
                    icon.get_style_context ().add_class ("boxed");
                    app_icon_grid.attach (icon, i, 0, 1, 1);

                    var label = new Gtk.Label ((@"$size" + "px"));
                    label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
                    app_icon_grid.attach (label, i, 1, 1, 1);
                }
            }
            app_icon_grid.show_all ();
            preview_grid.attach (app_icon_grid, 0, 4, 1, 1);

            icon_e.set_from_pixbuf (pixbuf1);
            icon_k.set_from_pixbuf (pixbuf1);
        }

        public File open_dialog_action () {
            var chooser = Services.DialogUtils.create_file_chooser (_("Open file"), Gtk.FileChooserAction.OPEN);
            chooser.set_transient_for (this);
            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                file = chooser.get_file ();
                chooser.destroy();
            } else {
                chooser.destroy();
            }
            return file;
        }
    }
}
