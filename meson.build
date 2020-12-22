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

sources = files(
    'src/Application.vala',
    'src/MainWindow.vala',
)

asresources = gnome.compile_resources(
    'as-resources', join_paths('data', 'com.github.lainsce.icon-previewer.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required: true)
dependencies = [
    dependency('gtk+-3.0'),
    dependency('libhandy-1'),
    dependency('granite'),
    m_dep,
]

# Let's define our executable
executable(
    meson.project_name(),
    sources,
    asresources,
    dependencies: dependencies,
    install : true
)

subdir('data')

meson.add_install_script('meson/post_install.py', join_paths(get_option('prefix'), get_option('datadir')))
