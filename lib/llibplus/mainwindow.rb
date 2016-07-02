# -*- coding: utf-8 -*-

module LLibPlus
  class MainWindow
    WINDOW_CLASS = ['llibplus', 'LLibPlus']

    def initialize
      @win = Gtk::Window.new :toplevel
      @win.title = 'Launch Library Plus'
      @win.set_wmclass *WINDOW_CLASS
      @win.set_icon File.join(File.dirname(__FILE__), '../../res/img/icon.png')
      @win.set_size_request 800, 500
      @win.set_position Gtk::WindowPosition::CENTER

      self.setupSignals
      self.setupLayout
    end

    def setupSignals
      Signal.trapEach :SIGINT, :SIGTERM do |sig|
        sig = Signal.list.key(sig) || 'Unknown'
        $stderr.puts "\r*** Received SIG#{sig} ***"
        exit! 0
      end

      @win.signal_connect 'delete_event' do
        Gtk.main_quit
      end
    end

    def setupLayout
      @globalContainer = Gtk::Box.new :vertical, 10
      @win.add @globalContainer
      self.createMenuBar
    end

    def createMenuBar
      @menuBar = Gtk::MenuBar.new

      file = Gtk::MenuItem.new({
        :label => 'File',
        :use_underline => true,
        :mnemonic => '_File'
      })
      help = Gtk::MenuItem.new({
        :label => 'Help',
        :use_underline => true,
        :mnemonic => '_Help'
      })

      fileMenu = Gtk::Menu.new
      helpMenu = Gtk::Menu.new

      file.submenu = fileMenu
      help.submenu = helpMenu

      @menuBar.append file
      @menuBar.append help

      group = Gtk::AccelGroup.new

      parametersOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::PREFERENCES,
        :accel_group => group
      })
      parametersOption.signal_connect 'activate' do
        LLibPlus::Preferences.new({
          :transient_for => @win,
          :use_header_bar => 1
        }).run
      end
      parametersOption.add_accelerator(
        'activate', group,
        Gdk::Keyval::KEY_p,
        Gdk::ModifierType::CONTROL_MASK,
        Gtk::AccelFlags::VISIBLE
      )
      fileMenu.append parametersOption
      fileMenu.append Gtk::SeparatorMenuItem.new

      exitOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::QUIT,
        :accel_group => group
      })
      exitOption.signal_connect 'activate' do
        Gtk.main_quit
      end
      exitOption.add_accelerator(
        'activate', group,
        Gdk::Keyval::KEY_q,
        Gdk::ModifierType::CONTROL_MASK,
        Gtk::AccelFlags::VISIBLE
      )
      fileMenu.append exitOption

      helpOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::HELP,
        :accel_group => group
      })
      helpOption.signal_connect 'activate' do
        dialog = Gtk::MessageDialog.new({
          :parent => @win,
          :flags => :modal,
          :type => :info,
          :buttons => :ok,
          :message => "This is where I'd put the help\n\nIF I HAD ONE!"
        })
        dialog.run
        dialog.destroy
      end
      helpOption.add_accelerator(
        'activate', group,
        Gdk::Keyval::KEY_F1,
        0,
        Gtk::AccelFlags::VISIBLE
      )

      aboutOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::ABOUT,
        :accel_group => group
      })
      aboutOption.signal_connect 'activate' do
        dialog = Gtk::AboutDialog.new
        dialog.set_transient_for @win
        dialog.name = 'Launch Library Plus'
        dialog.program_name = 'Launch Library Plus'
        dialog.version = "v#{LLibPlus::VERSION_NUMBER} - #{LLibPlus::VERSION_NAME}"
        dialog.authors = ['Guillaume de Matos <g.de.matos@free.fr>']
        dialog.license = File.read(File.join(File.dirname(__FILE__), '../../LICENSE'))
        dialog.copyright = "© 2016-2017"
        dialog.comments = 'Gtk+ Ruby application for LaunchLibrary.net'
        dialog.website = 'https://launchlibrary.net/'
        dialog.logo = ResManager.getPixbuf(:icon_svg, :big) || ResManager.getPixbuf(:icon_png)

        dialog.run
        dialog.destroy
      end
      aboutOption.add_accelerator(
        'activate', group,
        Gdk::Keyval::KEY_F7,
        0,
        Gtk::AccelFlags::VISIBLE
      )

      helpMenu.append helpOption
      helpMenu.append aboutOption

      @win.add_accel_group group

      @globalContainer.pack_start(@menuBar, {
        :expand => false,
        :fill => false,
        :padding => 10
      })
    end

    def run!
      @win.show_all
      Gtk.main
    end
  end
end
