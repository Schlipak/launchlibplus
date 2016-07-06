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
        :stock => Gtk::Stock::DIALOG_INFO,
        :func => :info
      },
      :question => {
        :title => 'Question',
        :stock => Gtk::Stock::DIALOG_QUESTION,
        :func => :info
      },
      :warning => {
        :title => 'Warning',
        :stock => Gtk::Stock::DIALOG_WARNING,
        :func => :warn
      },
      :error => {
        :title => 'Error',
        :stock => Gtk::Stock::DIALOG_ERROR,
        :func => :error
      },
      :fatal => {
        :title => 'Fatal Error',
        :icon_name => 'process-stop',
        :func => :fatal
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

      if not [:info, :question].include? @level
        self.add_button 'Report on GitHub', :help
      end
      self.add_button Gtk::Stock::CLOSE, :accept
      self.signal_connect 'response' do |btn, resp|
        if resp == Gtk::ResponseType::HELP
          Launchy.open LINK_REPORT_ISSUES
        else
          self.destroy
          if @level == :fatal
            Gtk.main_quit
            exit! 1
          end
        end
      end

      bbox = self.child.children.first.children.first
      bbox.halign = Gtk::Align::END if bbox.is_a? Gtk::ButtonBox

      vbox = Gtk::Box.new :vertical, 10
      hbox = Gtk::Box.new :horizontal, 10
      if LEVELS.dig(@level, :stock).nil?
        image = Gtk::Image.new(
          :icon_name => LEVELS.dig(@level, :icon_name),
          :size => Gtk::IconSize::DIALOG
        )
      else
        image = Gtk::Image.new(
          :stock => LEVELS.dig(@level, :stock),
          :size => Gtk::IconSize::DIALOG
        )
      end
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

      callTraceText.signal_connect 'button-release-event' do
        callTraceText.select_all true
      end

      callTraceWin.add callTraceText
      expander.add callTraceWin

      vbox.pack_start(hbox, :expand => false, :fill => false)
      vbox.pack_start(expander, :expand => true, :fill => true)
      self.child.add(vbox)
    end

    def run!
      Logger.send(LEVELS.dig(@level, :func), @error.debug)
      self.show_all
    end
  end
end
