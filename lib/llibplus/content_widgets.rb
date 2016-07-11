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

    DEFAULT_FETCH_REQUESTS = {
      :launch => {
        :page => 'Launches',
        :request => ['launch/next/50', {}]
      },
      :mission => {
        :page => 'Missions',
        :request => ['mission/next/50', {}]
      },
      :vehicule => {
        :page => 'Vehicules',
        :request => ['rocket', {:mode => 'verbose'}]
      }
    }

    attr_reader :frame
    def initialize(mainContent)
      super(:vertical, 0)
      @mainContent = mainContent

      self.set_size_request 300, -1
      self.border_width = 10

      setup_layout
    end

    private
    def setup_layout
      @frame = Gtk::Frame.new 'Menu'
      self.pack_start(@frame, {
        :expand => true,
        :fill => true,
        :padding => 0
      })

      @button = Gtk::Button.new :label => 'Fetch data'
      @frame.add @button

      setup_signals
    end

    def setup_signals
      @button.signal_connect 'clicked' do
        if @mainContent.logoImage.running?
          @mainContent.logoImage.stop
        else
          start_fetch
        end
      end
    end

    def start_fetch
      @button.set_sensitive false
      @mainContent.stack_visible = false
      @mainContent.logoImage.start
      ThreadManager.add do
        fetchThreads = Array.new
        DEFAULT_FETCH_REQUESTS.each do |key, req|
          fetchThreads << ThreadManager.add do
            data = DataFetcher.fetch(*req[:request], key)
            Thread.kill(Thread.current) if data.nil?
            @mainContent.clear req[:page]
            data.sort! if key == :launch
            data.each do |elem|
              card = LLibPlus::Card.create elem, key
              @mainContent.add(card, req[:page]) unless card.nil?
            end
          end
        end
        fetchThreads.each { |thr| thr.join }
        JobQueue.push do
          @mainContent.logoImage.stop
          @mainContent.stack_visible = true
          @button.set_sensitive true
        end
      end
    end
  end

  class MainContent < Gtk::Overlay
    include ::AppObject

    attr_reader :stack, :logoImage
    PAGES = {
      :launch => {
        :title => 'Launches'
      },
      :mission => {
        :title => 'Missions'
      },
      :vehicule => {
        :title => 'Vehicules'
      }
    }.freeze

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

      PAGES.each do |_, page|
        name = page[:title]

        newPage = Hash.new
        @pages << newPage
        newPage[:name] = name

        newPage[:window] = Gtk::ScrolledWindow.new(nil, nil)
        newPage[:window].expand = true
        newPage[:window].set_kinetic_scrolling true

        newPage[:content] = Gtk::ListBox.new
        newPage[:content].set_sort_func do |one, another|
          one <=> another
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

    def clear(name)
      page = self.get_page name
      return nil if page.nil?
      page[:content].children.each do |child|
        page[:content].remove child
      end
    end

    def add(card, name = 'Launches')
      page = self.get_page name
      page[:content].add card
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
end
