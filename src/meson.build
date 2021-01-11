deps = [
	dependency('gtk+-3.0'),
	dependency('librsvg-2.0', version: '>= 2.46'),
	dependency('libdazzle-1.0'),
	dependency('libhandy-1')
]

config = configure_file(input: 'config.vala.in', output: 'config.vala', configuration: conf)

sources = [
	config,
	'views/utils.vala',
	'views/utils.vala',
	'views/colourpane.vala',
	'views/colour.vala',
	'exporter/exporter.vala',
	'wizard.vala',
	'saver.vala',
	'common.vala',
	'window.vala',
	'main.vala'
]

gnome = import('gnome')

sources += gnome.compile_resources('resources',
  'resource.gresource.xml'
)

sources += gnome.compile_resources('icons',
  'icons/icons.gresource.xml',
  source_dir: 'icons/'
)

executable(meson.project_name(), sources, dependencies: deps, install: true)

