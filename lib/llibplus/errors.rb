# -*- coding: utf-8 -*-

module LLibPlus
  class GenericError < StandardError
    attr_reader :reference

    def initialize(ref = nil)
      @reference = ref
    end
  end

  InvalidLogLevel = Class.new(GenericError)
  DeveloperError = Class.new(GenericError)
  GraphicError = Class.new(GenericError)

  class ErrorDialog < Gtk::Dialog
    LEVELS = {
      :info => {
        :title => 'Info',
        :stock => Gtk::Stock::DIALOG_INFO
      },
      :question => {
        :title => '???',
        :stock => Gtk::Stock::DIALOG_QUESTION
      },
      :warning => {
        :title => 'Warning',
        :stock => Gtk::Stock::DIALOG_WARNING
      },
      :error => {
        :title => 'Error',
        :stock => Gtk::Stock::DIALOG_ERROR
      }
    }

    def initialize(err, level = :info)
      super({
        :parent => $win,
        :transient_for => $win,
        :flags => :modal,
        :title => LEVELS.dig(level, :title)
      })
      raise DeveloperError.new, "Wrong level type :#{level}" if LEVELS[level].nil?
      @error = err
      @level = level

      self.setup_layout
      self
    end

    def setup_layout
      self.resizable = false
      self.set_size_request 350, -1

      self.add_button Gtk::Stock::CLOSE, :accept
      self.signal_connect 'response' do
        self.destroy
      end

      vbox = Gtk::Box.new :vertical, 10

      hbox = Gtk::Box.new :horizontal, 10
      image = Gtk::Image.new(
        :stock => LEVELS.dig(@level, :stock),
        :size => Gtk::IconSize::DIALOG
      )
      hbox.pack_start image

      label = Gtk::Label.new @error.to_s
      hbox.pack_start label

      expander = Gtk::Expander.new 'Developer info'
      expander.expanded = false

      callTraceWin = Gtk::ScrolledWindow.new
      callTraceWin.set_min_content_height 100
      callTraceWin.set_shadow_type :in
      callTraceWin.set_policy :never, :automatic

      callTraceText = Gtk::TextView.new
      callTraceText.set_editable false
      callTraceText.set_wrap_mode :word
      callTraceText.buffer.text = "#{@error.debug}\n\n"
      callTraceText.buffer.text += caller.join("\n")

      callTraceWin.add callTraceText
      expander.add callTraceWin

      vbox.pack_start(hbox, :expand => false, :fill => false)
      vbox.pack_start(expander, :expand => true, :fill => true)
      self.child.add(vbox)
    end

    def run!
      Logger.warn @error.debug
      self.show_all
    end
  end
end
