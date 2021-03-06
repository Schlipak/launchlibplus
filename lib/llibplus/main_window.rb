# -*- coding: utf-8 -*-

module LLibPlus
  class MainWindow
    WINDOW_CLASS = ['llibplus', 'LLibPlus']

    def initialize
      @win = Gtk::Window.new :toplevel
      $win = @win
      @win.title = 'Launch Library Plus'
      @win.set_wmclass *WINDOW_CLASS
      @win.set_icon File.join(File.dirname(__FILE__), '../../res/img/icon.png')
      @win.set_size_request 900, 600
      @win.set_position Gtk::WindowPosition::CENTER

      self.setup_signals
      self.setup_layout
    end

    def setup_signals
      Signal.trapEach :SIGINT, :SIGTERM do |sig|
        sig = Signal.list.key(sig) || 'Unknown'
        $stderr.puts "\r*** Received SIG#{sig} ***"
        LLibPlus::ThreadManager.finalize
        exit 0
      end

      @win.signal_connect 'delete_event' do
        Gtk.main_quit
      end
    end

    def setup_layout
      LLibPlus::Logger.info 'Setting up main layout'

      @globalContainer = Gtk::Box.new :vertical, 0
      @win.add @globalContainer
      self.create_menu_bar

      @contentContainer = LLibPlus::ContentContainer.new
      @globalContainer.pack_start(@contentContainer, {
        :expand => true,
        :fill => true,
        :padding => 0
      })

      @mainContent = LLibPlus::MainContent.new
      @sidebar = LLibPlus::Sidebar.new @mainContent

      @contentContainer.pack1(@sidebar, {
        :resize => false,
        :shrink => false
      })
      @contentContainer.pack2(@mainContent, {
        :resize => true,
        :shrink => false
      })
    end

    def create_menu_bar
      @menuBar = LLibPlus::MenuBar.new @win

      @globalContainer.pack_start(@menuBar, {
        :expand => false,
        :fill => false,
        :padding => 0
      })
    end

    def run!
      @win.show_all
      @mainContent.stack_visible = false
      Gtk.main
    end
  end
end
