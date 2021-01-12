deps = [
	dependency('gtk+-3.0'),
	dependency('librsvg-2.0', version: '>= 2.46'),
	dependency('libdazzle-1.0'),
	dependency('libhandy-1')
]

config = configure_file(input: 'Config.vala.in', output: 'Config.vala', configuration: conf)

sources = [
	config,
	'Utils.vala',
	'ColourPane.vala',
	'Colour.vala',
	'MainWindow.vala',
	'Common.vala',
	'IconExporter.vala',
	'IconSaver.vala',
	'NewIconWizard.vala',
	'Application.vala'
]

gnome = import('gnome')

sources += gnome.compile_resources('resources',
  'app.gresource.xml'
)

sources += gnome.compile_resources('icons',
  'icons/icons.gresource.xml',
  source_dir: 'icons/'
)

executable(meson.project_name(), sources, dependencies: deps, install: true)

