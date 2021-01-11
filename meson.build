project('com.github.lainsce.icon-previewer', ['vala', 'c'], version: '1.0.0')
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments([
		'--target-glib=2.40',
	],
	language: 'vala',
)
add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)
i18n = import('i18n')

datadir = join_paths(get_option('prefix'), get_option('datadir'))
bindir = join_paths(get_option('prefix'), get_option('bindir'))
localedir = join_paths(get_option('prefix'), get_option('localedir'))

application_id = 'com.github.lainsce.icon-previewer'
profile = ''

conf = configuration_data()
conf.set_quoted('G_LOG_DOMAIN', application_id)
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('LOCALE_DIR', localedir)
conf.set_quoted('APP_ID', application_id)
conf.set_quoted('PROFILE', profile)

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language: 'c')
add_global_arguments('-DG_LOG_DOMAIN="@0@"'.format (application_id), language: 'c')

subdir('data')
subdir('po')
subdir('src')

meson.add_install_script('meson/post_install.py', join_paths(get_option('prefix'), get_option('datadir')))
