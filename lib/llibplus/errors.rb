# -*- coding: utf-8 -*-

module LLibPlus
  GenericError = Class.new(StandardError)

  InvalidLogLevel = Class.new(GenericError)
  DeveloperError = Class.new(GenericError)

  class GraphicError < GenericError
    attr_reader :type

    def initialize(msg, type = :error)
      super(msg)
      @type = type
      JobQueue.push do
        ErrorDialog.new(self, type).run!
      end
    end
  end

  NotImplementedError = Class.new(GraphicError)
  DataFetchError = Class.new(GraphicError)
  class TimeoutError < GraphicError
    def initialize(*args)
      super('Request timed out', :warning)
    end
  end

  class EOFError < GraphicError
    def initialize(*args)
      super('Reached end of file (maybe wrong SSL settings)', :warning)
    end
  end

  class ErrorDialog < Gtk::Dialog
    LEVELS = {
      :info => {
        :title => 'Info',
        :stock => Gtk::Stock::DIALOG_INFO,
        :action => Gtk::Stock::OK,
        :func => :info
      },
      :question => {
        :title => 'Question',
        :stock => Gtk::Stock::DIALOG_QUESTION,
        :action => Gtk::Stock::OK,
        :func => :info
      },
      :warning => {
        :title => 'Warning',
        :stock => Gtk::Stock::DIALOG_WARNING,
        :action => Gtk::Stock::CLOSE,
        :func => :warn
      },
      :error => {
        :title => 'Error',
        :stock => Gtk::Stock::DIALOG_ERROR,
        :action => Gtk::Stock::CLOSE,
        :func => :error
      },
      :fatal => {
        :title => 'Fatal Error',
        :icon_name => 'process-stop',
        :action => Gtk::Stock::QUIT,
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
      self.border_width = 10

      if not [:info, :question].include? @level
        self.add_button 'Report on GitHub', :help
      end
      self.add_button LEVELS.dig(@level, :action), :accept
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

      @bbox = self.child.children.first.children.first
      @bbox.halign = Gtk::Align::END if @bbox.is_a? Gtk::ButtonBox

      @vbox = Gtk::Box.new :vertical, 10
      @hbox = Gtk::Box.new :horizontal, 10
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
      @hbox.pack_start image

      errmsg = @error.to_s
      if errmsg.initial != errmsg.initial.capitalize
        errmsg = errmsg.capitalize
      end
      @label = Gtk::Label.new errmsg
      @hbox.pack_start @label

      @vbox.pack_start(@hbox, {
        :expand => false,
        :fill => false
      })

      self.setup_calltrace unless [:info, :question].include?(@level)
      self.child.add(@vbox)
    end

    def setup_calltrace
      @expander = Gtk::Expander.new 'Developer info'
      @expander.expanded = false
      @expanderBox = Gtk::Box.new :vertical, 5
      @expander.add @expanderBox

      @callTraceWin = Gtk::ScrolledWindow.new
      @callTraceWin.set_min_content_height 100
      @callTraceWin.set_shadow_type :in
      @callTraceWin.set_policy :never, :automatic

      @callTraceText = Gtk::TextView.new
      @callTraceText.set_editable false
      @callTraceText.set_wrap_mode :word
      @callTraceText.buffer.text = "#{@error.debug}\n\n"
      @callTraceText.buffer.text += caller.join("\n")

      @callTraceWin.add @callTraceText
      @expanderBox.pack_start(@callTraceWin, {
        :expand => true,
        :fill => true
      })

      @callTraceLink = Gtk::Label.new '<a href="#">Copy to clipboard</a>'
      @callTraceLink.use_markup = true
      @callTraceLink.halign = Gtk::Align::START
      @callTraceLink.signal_connect 'activate-link' do
        @callTraceText.select_all true
        @callTraceText.copy_clipboard
        true
      end
      @expanderBox.pack_start(@callTraceLink, {
        :expand => false,
        :fill => false,
        :shrink => true
      })

      @vbox.pack_start(@expander, {
        :expand => true,
        :fill => true,
        :padding => 10
      })
    end

    def run!
      Logger.send(LEVELS.dig(@level, :func), @error.debug)
      self.show_all
    end
  end
end
