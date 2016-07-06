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

      @button = Gtk::Button.new :label => 'Animate'
      @frame.add @button
      @button.signal_connect 'clicked' do
        if @mainContent.logoImage.running?
          @mainContent.logoImage.stop
        else
          @mainContent.stack_visible = false
          @mainContent.logoImage.start
          ThreadManager.add do
            sleep 2
            @mainContent.logoImage.stop
            @mainContent.stack_visible = true
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

        newPage[:content] = Gtk::Box.new :vertical
        30.times do
          btn = Gtk::Button.new(:label => name)
          newPage[:content].pack_start(btn, :padding => 2)
          btn.signal_connect 'clicked' do
            DataFetcher.new.fetch nil
          end
        end
        newPage[:window].add newPage[:content]
        @stack.add_titled(newPage[:window], name, name)
      end
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

  class Card < Gtk::Grid
    include ::AppObject
    def initialize(*args)
      super
    end
  end
end
