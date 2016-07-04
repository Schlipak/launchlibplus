# coding: utf-8

require 'date'
require File.expand_path("../lib/llibplus.rb", __FILE__)

Gem::Specification.new do |spec|
  spec.name             = 'llibplus'
  spec.version          = LLibPlus::VERSION_NUMBER
  spec.date             = Date.today.to_s

  spec.authors          = ['Guillaume Schlipak']
  spec.email            = ['g.de.matos@free.fr']

  spec.summary          = %q{Graphical app for LaunchLibrary.net}
  spec.description      = %q{A graphical application for LaunchLibrary.net in Gtk+}
  spec.homepage         = 'http://schlipak.github.io'
  spec.license          = 'MIT'

  spec.files            = [
    Dir.glob('lib/**/*.rb'),
    Dir.glob('res/**/*'),
    'LICENSE'
  ].flatten.delete_if {|f| not File.file? f}

  spec.executables      = ['llib+']
  spec.require_paths    = ['lib']

  spec.add_dependency   'gtk3', '~> 3.0', '>= 3.0.8'
  spec.add_dependency   'os', '~> 0.9.6'
  spec.add_dependency   'mono_logger', '~> 1.1'
  spec.add_dependency   'launchy', '~> 2.4', '>= 2.4.3'
end
