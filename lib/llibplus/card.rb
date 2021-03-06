# -*- coding: utf-8 -*-

require_relative '../monkeypatch/object'

module LLibPlus
  class Card < Gtk::ListBoxRow
    include ::AppObject
    attr_reader :type

    TYPES = {
      :launch => 'LLibPlus::LaunchCard',
      :mission => 'LLibPlus::MissionCard',
      :vehicule => 'LLibPlus::VehiculeCard'
    }

    def self.create(data, type = :launch)
      begin
        klass = Object.const_get TYPES[type]
      rescue StandardError => e
        ErrorDialogQueue.push [e.message, :fatal]
        return nil
      end
      klass.new(data, type)
    end

    def initialize(data, type = :launch)
      super()
      self.activatable = true
      self.selectable = false

      @data = data
      @type = type

      Logger.debug "Creating card #{self.debug}"
      self.create_metamethods
    end

    def to_s
      @data['name']
    end

    def create_metamethods
      @data.each do |key, _|
        self.class.send(:define_method, key.to_sym) do
          @data[key]
        end
      end
    end
  end

  class LaunchCard < Card
    GOOGLE_MAPS_BASE_URL = 'https://www.google.com/maps/?q='

    attr_reader :date
    def initialize(*args)
      super
      @date = Date.parse(@data['isonet'])
      if self.tbd?
        @date = Date.new(@date.year, @date.month, -1)
      end

      self.setup_layout
      self
    end

    def tbd?
      @data['tbdtime'] == 1
    end

    def <=>(other)
      return nil unless other.is_a? self.class
      self.date <=> other.date
    end

    def setup_layout
      frame = Gtk::Frame.new
      self.add frame
      @container = Gtk::Box.new :vertical
      @container.border_width = 10
      frame.add @container

      title = Gtk::Box.new :horizontal
      name = Gtk::Label.new("<b>#{self.name.gsub('&', '&amp;')}</b>")
      name.use_markup = true
      title.pack_start(name, {
        :expand => false, :shrink => true, :fill => true, :padding => 0
      })
      date = Gtk::Label.new(@date.to_print(self.tbd?))
      title.pack_end date
      @container.pack_start(title, {
        :expand => false, :shrink => true, :fill => true, :padding => 5
      })

      @container.pack_start(Gtk::Separator.new(:horizontal), {
        :expand => true, :shrink => true, :fill => true, :padding => 0
      })

      self.setup_location
      self.setup_mission
    end

    def setup_location
      @locationContainer = Gtk::Box.new :horizontal
      @locationContainer.border_width = 5

      launching_from = Gtk::Label.new('<i>Launching from:</i> ')
      launching_from.use_markup = true
      @locationContainer.pack_start(launching_from)
      location_label = if self.location['pads'].empty?
        'Unknown pad'
      else
        self.location['pads'].first['name']
      end
      location_label = Gtk::Label.new(location_label)
      @locationContainer.pack_start(location_label)

      location_link = GOOGLE_MAPS_BASE_URL + [
        self.location['pads'].first['latitude'],
        self.location['pads'].first['longitude']
      ].join(',')
      location_icon = Gtk::Image.new(
      :icon_name => 'mark-location-symbolic',
      :size => Gtk::IconSize::BUTTON
      )
      @locationLink = Gtk::EventBox.new
      @locationLink.add location_icon
      @locationLink.signal_connect 'button_press_event' do
        Launchy.open location_link
      end
      self.setup_hover
      @locationContainer.pack_end(@locationLink)

      @container.pack_start(@locationContainer, {
        :expand => true, :shrink => true, :fill => true, :padding => 0
      })
    end

    def setup_hover
      @@cursorPointer ||= Gdk::Cursor.new('pointer')
      @@cursorDefault ||= Gdk::Cursor.new('default')

      @locationLink.signal_connect 'enter_notify_event' do
        toplevel = @locationLink.toplevel
        win = toplevel.window
        win.set_cursor @@cursorPointer
      end
      @locationLink.signal_connect 'leave_notify_event' do
        toplevel = @locationLink.toplevel
        win = toplevel.window
        win.set_cursor @@cursorDefault
      end
    end

    def setup_mission
      @missionContainer = Gtk::Box.new :horizontal
      @missionContainer.border_width = 5

      primary_mission_label = Gtk::Label.new('<i>Primary Mission:</i> ')
      primary_mission_label.use_markup = true
      @missionContainer.pack_start(primary_mission_label)

      mission_name = if self.missions.empty?
        'Unknown mission'
      else
        self.missions.first['name']
      end
      mission_desc = if self.missions.empty?
        ''
      else
        self.missions.first['description']
      end

      mission_desc_label = Gtk::Label.new("#{mission_name}#{"\n" unless mission_desc.empty?}#{mission_desc}")
      mission_desc_label.set_line_wrap true
      @missionContainer.pack_start(mission_desc_label)

      @container.pack_start(@missionContainer, {
        :expand => true, :shrink => true, :fill => true, :padding => 0
      })
    end
  end

  class MissionCard < Card
    def initialize(*args)
      super
      self.setup_layout
      self
    end

    def <=>(other)
      return nil unless other.is_a? self.class
      self.name <=> other.name
    end

    def setup_layout
      frame = Gtk::Frame.new
      self.add frame
      @container = Gtk::Box.new :vertical
      @container.border_width = 10
      frame.add @container

      name = Gtk::Label.new("<b>#{self.name.gsub('&', '&amp;')}</b>")
      name.use_markup = true
      @container.pack_start(name, {
        :expand => false, :shrink => true, :fill => true, :padding => 0
      })
    end
  end

  class VehiculeCard < Card
    def initialize(*args)
      super
      self.setup_layout
      self
    end

    def <=>(other)
      return nil unless other.is_a? self.class
      self.name <=> other.name
    end

    def setup_layout
      frame = Gtk::Frame.new
      self.add frame
      @container = Gtk::Box.new :vertical
      @container.border_width = 10
      frame.add @container

      name = Gtk::Label.new("<b>#{self.name.gsub('&', '&amp;')}</b>")
      name.use_markup = true
      @container.pack_start(name, {
        :expand => false, :shrink => true, :fill => true, :padding => 0
      })
    end
  end
end
