# -*- coding: utf-8 -*-

module LLibPlus
  class ContentContainer < Gtk::Paned
    def initialize
      super(:horizontal)
      self.border_width = 0
    end
  end

  class Sidebar < Gtk::Box
    attr_reader :frame

    def initialize(mainContent)
      super(:vertical, 0)
      @mainContent = mainContent

      self.set_size_request 300, -1
      self.border_width = 10

      @frame = Gtk::Frame.new 'Menu'
      self.pack_start(@frame, {
        :expand => true,
        :fill => true,
        :padding => 0
      })

      @button = Gtk::Button.new :label => 'Animate'
      @frame.add @button
      @button.signal_connect 'clicked' do
        if @mainContent.logoImage.running?
          @mainContent.logoImage.stop
        else
          @mainContent.logoImage.start
        end
      end
    end
  end

  class MainContent < Gtk::Overlay
    attr_reader :notebook, :logoImage

    def initialize
      super
      self.set_size_request 300, -1
      self.border_width = 10

      @notebook = Gtk::Notebook.new
      self.add_logo_background
      self.init_notebook
    end

    def add_logo_background
      @logoImage = LLibPlus::Animation.new(
        LLibPlus::ResManager.get_pixbuf(:anim_rocket_png),
        100, 128, 30,
        6
      )
      self.add_overlay @logoImage
      @logoImage.timing = 0.05
      @logoImage.pauseFrame = 6
    end

    def init_notebook
      @page1 = Gtk::Box.new :vertical, 10
      @page1.pack_start Gtk::Button.new(:label => 'CONTENT 1')
      @notebook.append_page @page1

      self.add_overlay @notebook
    end

    def notebook_visible=(b)
      raise ArgumentError, "Unsupported argument type #{b.class.class}:#{b.class}" unless [true, false].include? b
      if b
        @notebook.show
      else
        @notebook.hide
      end
    end
  end
end
