# -*- coding: utf-8 -*-

require 'launchy'

module LLibPlus
  class MenuBar < Gtk::MenuBar
    def initialize(win)
      super()
      @win = win

      self.setup_menus
      self.setup_signals
    end

    def setup_menus
      @fileMenuItem = Gtk::MenuItem.new({
        :label => 'File',
        :use_underline => true,
        :mnemonic => '_File'
      })
      @helpMenuItem = Gtk::MenuItem.new({
        :label => 'Help',
        :use_underline => true,
        :mnemonic => '_Help'
      })

      @fileMenu = Gtk::Menu.new
      @helpMenu = Gtk::Menu.new

      @fileMenuItem.submenu = @fileMenu
      @helpMenuItem.submenu = @helpMenu

      self.append @fileMenuItem
      self.append @helpMenuItem

      @accel_group = Gtk::AccelGroup.new

      @parametersOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::PREFERENCES,
        :accel_group => @accel_group
      })
      @fileMenu.append @parametersOption
      @fileMenu.append Gtk::SeparatorMenuItem.new

      @exitOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::QUIT,
        :accel_group => @accel_group
      })
      @fileMenu.append @exitOption

      @helpOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::HELP,
        :accel_group => @accel_group
      })
      @helpMenu.append @helpOption

      @aboutOption = Gtk::ImageMenuItem.new({
        :stock => Gtk::Stock::ABOUT,
        :accel_group => @accel_group
      })
      @helpMenu.append @aboutOption
    end

    def setup_signals
      @parametersOption.signal_connect 'activate' do
        LLibPlus::Preferences.new({
          :transient_for => @win,
          :use_header_bar => 1
        }).run
      end
      @parametersOption.add_accelerator(
        'activate', @accel_group,
        Gdk::Keyval::KEY_p,
        Gdk::ModifierType::CONTROL_MASK,
        Gtk::AccelFlags::VISIBLE
      )

      @exitOption.signal_connect 'activate' do
        LLibPlus::ThreadManager.finalize
        Gtk.main_quit
      end
      @exitOption.add_accelerator(
        'activate', @accel_group,
        Gdk::Keyval::KEY_q,
        Gdk::ModifierType::CONTROL_MASK,
        Gtk::AccelFlags::VISIBLE
      )

      @helpOption.add_accelerator(
        'activate', @accel_group,
        Gdk::Keyval::KEY_F1,
        0,
        Gtk::AccelFlags::VISIBLE
      )
      @helpOption.signal_connect 'activate' do
        dialog = LLibPlus::HelpDialog.new({
          :title => 'Help',
          :parent => @win,
          :transient_for => @win,
          :flags => :modal,
          :type => :info
        }).run!
      end

      @aboutOption.add_accelerator(
        'activate', @accel_group,
        Gdk::Keyval::KEY_F7,
        0,
        Gtk::AccelFlags::VISIBLE
      )
      @aboutOption.signal_connect 'activate' do
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
        dialog.logo = ResManager.get_pixbuf(:icon_svg, :big) || ResManager.get_pixbuf(:icon_png)

        dialog.run
        dialog.destroy
      end

      @win.add_accel_group @accel_group
    end
  end

  class HelpDialog < Gtk::Dialog
    def initialize(args)
      super

      self.add_button Gtk::Stock::CLOSE, :accept
      self.setup_content
    end

    def setup_content
      self.child.set_size_request 250, 150

      @issueButton = Gtk::Button.new(:label => 'Open an issue on Github')
      @issueButton.signal_connect 'clicked' do
        Launchy.open 'https://github.com/Schlipak/launchlibplus/issues'
      end
      @issueButton.border_width = 2
      self.child.pack_start(@issueButton)

      @websiteButton = Gtk::Button.new(:label => 'LaunchLibrary.net')
      @websiteButton.signal_connect 'clicked' do
        Launchy.open 'https://launchlibrary.net/'
      end
      @websiteButton.border_width = 2
      self.child.pack_start(@websiteButton)
    end

    def run!
      self.show_all
      self.run
      self.destroy
    end
  end
end
