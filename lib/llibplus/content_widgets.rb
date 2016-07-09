# -*- coding: utf-8 -*-

require_relative '../monkeypatch/object'

module LLibPlus
  class ContentContainer < Gtk::Paned
    include ::AppObject

    def initialize
      super(:horizontal)
      self.border_width = 0
    end

    def to_s
      ''
    end

    def to_str
      self.debug
    end
  end

  class Sidebar < Gtk::Box
    include ::AppObject

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

      @button = Gtk::Button.new :label => 'Fetch data'
      @frame.add @button
      @button.signal_connect 'clicked' do
        if @mainContent.logoImage.running?
          @mainContent.logoImage.stop
        else
          @button.set_sensitive false
          @mainContent.stack_visible = false
          @mainContent.logoImage.start
          ThreadManager.add do
            data = DataFetcher.fetch('launch/next/50')
            page = @mainContent.get_clear_page 'Launches'
            data['launches'].sort_by! do |launch|
              launch['name']
            end
            data['launches'].each do |launch|
              card = LLibPlus::Card.new launch
              page[:content].add card
            end
            JobQueue.push do
              @mainContent.logoImage.stop
              @mainContent.stack_visible = true
              @button.set_sensitive true
            end
          end
        end
      end
    end
  end

  class MainContent < Gtk::Overlay
    include ::AppObject

    attr_reader :stack, :logoImage
    PAGES = ['Launches', 'Missions', 'Vehicules'].freeze

    def initialize
      super
      self.set_size_request 400, -1
      self.border_width = 10

      @container = Gtk::Box.new :vertical
      @container.border_width = 10
      self.add_logo_background
      self.add_overlay @container

      @pages = Array.new
      self.init_stack
      self.init_stack_switcher

      @container.pack_start(
        @stackSwitcher,
        :padding => 10
      )
      @container.pack_start(
        @stack,
        :expand => true,
        :fill => true
      )
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

    def init_stack
      @stack = Gtk::Stack.new
      @stack.set_transition_duration 400
      @stack.set_transition_type Gtk::Stack::TransitionType::SLIDE_LEFT_RIGHT

      PAGES.each do |name|
        newPage = Hash.new
        @pages << newPage
        newPage[:name] = name

        newPage[:window] = Gtk::ScrolledWindow.new(nil, nil)
        newPage[:window].expand = true
        newPage[:window].set_kinetic_scrolling true

        newPage[:content] = Gtk::ListBox.new
        newPage[:content].set_sort_func do |one, another|
          one.date <=> another.date
        end
        newPage[:window].add newPage[:content]
        @stack.add_titled(newPage[:window], name, name)
      end
    end

    def get_page(name)
      @pages.each do |page|
        return page if page[:name] == name
      end
      nil
    end

    def get_clear_page(name)
      page = self.get_page(name)
      return nil if page.nil?
      page[:content].children.each do |child|
        page[:content].remove child
      end
      page
    end

    def init_stack_switcher
      @stackSwitcher = Gtk::StackSwitcher.new
      @stackSwitcher.set_stack @stack
      @stackSwitcher.children.each do |child|
        child.hexpand = true
      end
    end

    def reset_scroll
      @stack.children.each do |child|
        child.vadjustment.set_value 0
      end
    end

    def stack_visible=(b)
      raise ArgumentError, "Unsupported argument type #{b.class.class}:#{b.class}" unless [true, false].include? b
      if b
        @stack.show_all
        self.reset_scroll
      else
        @stack.hide
      end
    end
  end

  class StatusBar < Gtk::Box
    include ::AppObject

    attr_reader :status, :progress

    def initialize
      super(:horizontal)
      self.set_homogeneous true
      self.border_width = 0

      @status = Gtk::Statusbar.new
      @progress = Gtk::ProgressBar.new
      @context = @status.get_context_id 'Status'

      self.pack_start(@status, {
        :resize => true,
        :fill => true,
        :shrink => true,
        :padding => 0
      })
      self.pack_start(@progress, {
        :resize => true,
        :fill => true,
        :shrink => true,
        :padding => 10
      })

      @status.push @context, 'TEST STATUS'
    end
  end

  class Card < Gtk::ListBoxRow
    include ::AppObject

    GOOGLE_MAPS_BASE_URL = 'https://www.google.com/maps/?q='

    attr_reader :type, :frame, :container, :date
    def initialize(data, type = :launch)
      super()
      self.activatable = true
      self.selectable = false

      @data = data
      @type = type
      @labels = Hash.new
      @links = Hash.new

      Logger.debug "Creating card #{self.debug}"

      @date = Date.parse(@data['isonet'])
      if self.tbd?
        @date = Date.new(@date.year, @date.month, -1)
      end

      self.create_metamethods
      self.setup_layout
    end

    def to_s
      @data['name']
    end

    def tbd?
      @data['tbdtime'] == 1
    end

    def create_metamethods
      @data.each do |key, _|
        self.class.send(:define_method, key.to_sym) do
          @data[key]
        end
      end
    end

    def setup_layout
      @frame = Gtk::Frame.new
      self.add @frame
      @container = Gtk::Box.new :vertical
      @container.border_width = 10
      @frame.add @container

      @title = Gtk::Box.new :horizontal
      @labels[:name] = Gtk::Label.new("<b>#{self.name.gsub('&', '&amp;')}</b>")
      @labels[:name].use_markup = true
      @title.pack_start(@labels[:name], {
        :expand => false, :shrink => true, :fill => true, :padding => 0
      })
      @labels[:date] = Gtk::Label.new(@date.to_print(self.tbd?))
      @title.pack_end @labels[:date]
      @container.pack_start(@title, {
        :expand => false, :shrink => true, :fill => true, :padding => 5
      })

      @container.pack_start(Gtk::Separator.new(:horizontal), {
        :expand => true, :shrink => true, :fill => true, :padding => 0
      })

      self.setup_location
    end

    def setup_location
      @locationContainer = Gtk::Box.new :horizontal
      @locationContainer.border_width = 5

      @labels[:launchingFrom] = Gtk::Label.new('<i>Launching from:</i> ')
      @labels[:launchingFrom].use_markup = true
      @locationContainer.pack_start(@labels[:launchingFrom])
      location_text = if self.location['pads'].empty?
        'Unknown pad'
      else
        self.location['pads'].first['name']
      end
      @labels[:location] = Gtk::Label.new(location_text)
      @locationContainer.pack_start(@labels[:location])

      @locationLink = GOOGLE_MAPS_BASE_URL + [
        self.location['pads'].first['latitude'],
        self.location['pads'].first['longitude']
      ].join(',')
      @locationIcon = Gtk::Image.new(
      :icon_name => 'mark-location-symbolic',
      :size => Gtk::IconSize::BUTTON
      )
      @links[:location] = Gtk::EventBox.new
      @links[:location].add @locationIcon
      @links[:location].signal_connect 'button_press_event' do
        Launchy.open @locationLink
      end
      self.setup_hover
      @locationContainer.pack_end(@links[:location])

      @container.pack_start(@locationContainer, {
        :expand => true, :shrink => true, :fill => true, :padding => 0
      })
    end

    def setup_hover
      @@cursorPointer ||= Gdk::Cursor.new('pointer')
      @@cursorDefault ||= Gdk::Cursor.new('default')

      @links[:location].signal_connect 'enter_notify_event' do
        toplevel = @links[:location].toplevel
        win = toplevel.window
        win.set_cursor @@cursorPointer
      end
      @links[:location].signal_connect 'leave_notify_event' do
        toplevel = @links[:location].toplevel
        win = toplevel.window
        win.set_cursor @@cursorDefault
      end
    end
  end
end
