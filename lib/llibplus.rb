# -*- coding: utf-8 -*-

require 'gtk2'
Dir[File.dirname(__FILE__) + '/**/*.rb'].each {|f| require f}

module LLibPlus
  class App
    def initialize
      @win = Gtk::Window.new 'Launch Library'
      @win.set_wmclass 'llibplus', 'LLibPlus'
      @win.set_icon File.join(File.dirname(__FILE__), '../res/icon.png')
      @win.set_size_request 900, 600

      LLibPlus::Logger.init
      LLibPlus::ResManager.init.loadResources

      self.setupSignals
      self.setupLayout
    end

    def setupSignals
      Signal.trapEach :SIGINT, :SIGTERM, :SIGEXIT do |sig|
        sig = Signal.list.key(sig) || 'Unknown'
        $stderr.puts "\r*** Received SIG#{sig} ***"
        exit! 0
      end

      @win.signal_connect 'delete_event' do
        Gtk.main_quit
      end
    end

    def setupLayout
      @globalContainer = Gtk::VBox.new false, 10
      @win.add @globalContainer
      self.createMenuBar
    end

    def createMenuBar
      @menuBar = Gtk::MenuBar.new

      file = Gtk::MenuItem.new 'File'
      help = Gtk::MenuItem.new 'Help'

      fileMenu = Gtk::Menu.new
      helpMenu = Gtk::Menu.new

      file.submenu = fileMenu
      help.submenu = helpMenu

      @menuBar.append file
      @menuBar.append help

      group = Gtk::AccelGroup.new

      exitOption = Gtk::ImageMenuItem.new Gtk::Stock::QUIT, group
      exitOption.signal_connect 'activate' do
        Gtk.main_quit
      end
      fileMenu.append exitOption
      contents = Gtk::ImageMenuItem.new Gtk::Stock::HELP, group
      contents.signal_connect 'activate' do
        dialog = Gtk::MessageDialog.new(
          @win,
          Gtk::Dialog::MODAL,
          Gtk::MessageDialog::INFO,
          Gtk::MessageDialog::BUTTONS_OK,
          "This is where I'd put the help\n\nIF I HAD ONE!"
        )
        dialog.run
        dialog.destroy
      end
      about = Gtk::ImageMenuItem.new Gtk::Stock::ABOUT, group
      about.signal_connect 'activate' do
        Gtk::AboutDialog.show(@win, {
          :name => 'Launch Library Plus',
          :program_name => 'Launch Library Plus',
          :version => "v#{LLibPlus::VERSION_NUMBER} - #{LLibPlus::VERSION_NAME}",
          :authors => ['Guillaume de Matos'],
          :copyright => "© 2016-2017",
          :comments => 'Gtk+ Ruby application for LaunchLibrary.net',
          :website => 'https://launchlibrary.net/',
          :logo => LLibPlus::ResManager.getPixbuf(:icon_svg, :big)
        })
      end
      helpMenu.append contents
      helpMenu.append about

      @win.add_accel_group group

      @globalContainer.pack_start @menuBar, false, false, 0
    end

    def run!
      @win.show_all
      Gtk.main
    end
  end
end
