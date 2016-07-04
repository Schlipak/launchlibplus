# -*- coding: utf-8 -*-

module LLibPlus
  class Animation < Gtk::Image
    attr_reader :pixbuf, :width, :height, :frames, :currentFrame
    attr_accessor :pauseFrame, :timing

    def initialize(pixbuf, width, height, frames, currentFrame = 0)
      super()
      @pixbuf = pixbuf
      @width = width
      @height = height
      @frames = frames

      @timing = 0.2
      @currentFrame = currentFrame
      @pauseFrame = 0
      @stop = false
      @semaphone = Mutex.new
      @thread = nil
      self.set_frame @currentFrame
    end

    def set_frame(frame)
      @currentFrame = frame
      self.update_frame
    end

    def update_frame
      buf = Gdk::Pixbuf.new(
        Gdk::Pixbuf::COLORSPACE_RGB,
        true, 8,
        @width, @height
      )
      @pixbuf.copy_area(
        @width * @currentFrame, 0,
        @width, @height,
        buf, 0, 0
      )
      self.set_from_pixbuf buf
    end

    def running?
      !@thread.nil?
    end

    def start
      return unless @thread.nil?
      th = Thread.new do
        loop do
          @currentFrame = (@currentFrame + 1) % @frames
          self.set_frame @currentFrame

          @semaphone.synchronize do
            if @stop and @currentFrame == @pauseFrame
              @stop = false
              @thread = nil
              Thread.kill Thread.current
            end
          end

          sleep @timing
        end
      end
      @semaphone.synchronize do
        @thread = th
        LLibPlus::ThreadManager.register th
      end
    end

    def stop
      @semaphone.synchronize do
        @stop = true
      end
    end
  end
end
