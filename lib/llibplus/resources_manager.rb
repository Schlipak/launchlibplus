# -*- coding: utf-8 -*-

module LLibPlus
  ResourceError = Class.new(StandardError)

  class ResManager
    SVG_SCALES = {
      :tiny => 48,
      :small => 64,
      :medium => 128,
      :big => 256,
      :large => 512
    }.freeze

    FILE_EXTENSIONS = [
      '.jpg', '.jpeg',
      '.png', '.gif', '.svg'
    ].freeze

    def self.init(path = '../../res/img')
      @@path = path
      @@resources = Hash.new
      self
    end

    def self.load_resources
      absPath = File.realpath File.join(File.dirname(__FILE__), @@path)
      LLibPlus::Logger.info "Loading resources from #{absPath}"
      glob = File.join(absPath, '*')
      Dir.glob(glob).sort.each do |entry|
        next unless File.file? entry
        name = File.basename(entry).sub(/\.[\w\d]+$/, '')
        name += "_#{File.extname(entry).tr('.', '')}"

        next unless FILE_EXTENSIONS.include? File.extname(entry)
        next if OS.windows? and File.extname(entry) == '.svg'

        @@resources[name.to_sym] = Hash.new
        LLibPlus::Logger.debug "Create resource ID :#{name.to_sym}"

        pixbuf = Gdk::Pixbuf.new entry
        SVG_SCALES.each do |key, scale|
          if File.extname(entry) == '.svg'
            pixbuf = Gdk::Pixbuf.new entry, scale, scale
          end

          @@resources[name.to_sym][key] = {
            :pixbuf => pixbuf,
            :image => Gtk::Image.new({
              :pixbuf => pixbuf
            })
          }
        end
      end
      LLibPlus::Logger.info "#{@@resources.size} resources loaded"
    end

    def self.refresh
      @@resources.clear
      self.load_resources
    end

    def self.get_resource(name)
      @@resources[name]
    end

    def self.get_pixbuf(name, scale = :medium)
      @@resources.dig(name, scale, :pixbuf)
    end

    def self.get_image(name, scale = :medium)
      @@resources.dig(name, scale, :image)
    end
  end
end
