# -*- coding: utf-8 -*-

require 'gtk3'
require 'os'
require 'fileutils'

Gtk::Settings.default.gtk_theme_name = 'win32' if OS.windows?
Dir[File.dirname(__FILE__) + '/**/*.rb'].each {|f| require f}

resource_path = File.realpath(File.join(File.dirname(__FILE__), '../res/ui'))
gresource_bin = "#{resource_path}/llibplus.gresource"
gresource_xml = "#{resource_path}/llibplus.gresource.xml"

system("glib-compile-resources",
       "--target", gresource_bin,
       "--sourcedir", resource_path,
       gresource_xml)
gschema_bin = "#{resource_path}/gschemas.compiled"
system("glib-compile-schemas", resource_path)

at_exit do
  FileUtils.rm_f([gresource_bin, gschema_bin])
end

resource = Gio::Resource.load(gresource_bin)
Gio::Resources.register(resource)
ENV['GSETTINGS_SCHEMA_DIR'] = resource_path

module LLibPlus
  class App
    private
    DATA = [
      "[Desktop Entry]",
      "Name=Launch Library Plus",
      "Exec=#{File.realpath(File.join(File.dirname(__FILE__), '../bin/llib+'))}",
      "StartupNotify=true",
      "Terminal=false",
      "Type=Application",
      "Comment=Gtk+ Ruby client for LaunchLibrary.net",
      "Icon=#{File.realpath(File.join(File.dirname(__FILE__), '../res/img/icon.svg'))}",
      "Categories=Application;"
    ].join("\n")

    def createDesktopEntry(filename, action = 'Creating')
      LLibPlus::Logger.info "#{action} desktop file at #{filename}"
      fd = File.new filename, 'w+'
      fd.puts DATA
      fd.close
    end

    def updateDesktopEntry(filename)
      version = nil
      File.new(filename).each_line do |line|
        if /^\s*Exec=(.*)$/.match line then
          if $1 != File.realpath(File.join(File.dirname(__FILE__), '../bin/llib+')) then
            File.truncate filename, 0
            return self.send(:createDesktopEntry, filename, 'Updating')
          end
        end
      end
    end

    def checkDesktopEntry
      return unless OS.posix?
      path = File.join(Dir.home, '.local/share/applications')
      return unless File.exist? path
      filename = File.join(path, "#{LLibPlus::MainWindow::WINDOW_CLASS.first}.desktop")
      return self.send(:createDesktopEntry, filename) unless File.exist? filename
      self.send(:updateDesktopEntry, filename)
    end

    public
    def initialize
      @parser = LLibPlus::Parser.new
      @options = @parser.parse!

      LLibPlus::Logger.init(@options[:loglevel] || :WARN)

      self.send :checkDesktopEntry

      LLibPlus::ResManager.init.loadResources
      @win = LLibPlus::MainWindow.new
    end

    def run!
      @win.run!
    end
  end
end
