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

    def initialize
      super(:vertical, 0)
      self.set_size_request 300, -1
      self.border_width = 10

      @frame = Gtk::Frame.new 'Menu'
      self.pack_start(@frame, {
        :expand => true,
        :fill => true,
        :padding => 0
      })
    end
  end

  class MainContent < Gtk::Overlay
    attr_reader :notebook

    def initialize
      super
      self.set_size_request 300, -1
      self.border_width = 10

      @notebook = Gtk::Notebook.new
      self.add_logo_background
      self.init_notebook
    end

    def add_logo_background
      frame = 0
      buf = Gdk::Pixbuf.new(
        Gdk::Pixbuf::COLORSPACE_RGB,
        true, 8,
        200, 256
      )
      LLibPlus::ResManager.get_pixbuf(:rocket_anim_png).copy_area(
        200 * frame, 0,
        200, 256,
        buf, 0, 0
      )
      @logoImage = Gtk::Image.new
      @logoImage.set_from_pixbuf buf
      self.add_overlay @logoImage unless @logoImage.nil?
      return if @logoImage.nil?
      LLibPlus::ThreadManager.add_job do
        loop do
          frame = (frame + 1) % 8
          buf = Gdk::Pixbuf.new(
            Gdk::Pixbuf::COLORSPACE_RGB,
            true, 8,
            200, 256
          )
          LLibPlus::ResManager.get_pixbuf(:rocket_anim_png).copy_area(
            200 * frame, 0,
            200, 256,
            buf, 0, 0
          )
          @logoImage.set_from_pixbuf buf
          sleep 0.5
        end
      end
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
