# -*- coding: utf-8 -*-

require 'gtk3'
require 'os'

Gtk::Settings.default.gtk_theme_name = 'win32' if OS.windows?

Dir[File.dirname(__FILE__) + '/**/*.rb'].each {|f| require f}

module LLibPlus
  class App
    def initialize
      @parser = LLibPlus::Parser.new
      @options = @parser.parse!

      LLibPlus::Logger.init(@options[:loglevel] || :WARN)
      LLibPlus::ResManager.init.loadResources

      @win = LLibPlus::MainWindow.new
    end

    def run!
      @win.run!
    end
  end
end
