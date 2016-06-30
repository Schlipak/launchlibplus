# -*- coding: utf-8 -*-

module LLibPlus
  class ResourceError < StandardError
  end

  class ResManager
    @@svgScales = {
      :tiny => 48,
      :small => 64,
      :medium => 128,
      :big => 256,
      :large => 512
    }.freeze

    def self.init(path = '../../res')
      @@path = path
      @@resources = Hash.new
      self
    end

    def self.loadResources
      absPath = File.realpath File.join(File.dirname(__FILE__), @@path)
      LLibPlus::Logger.info "Loading resources from #{absPath}"
      glob = File.join(absPath, '*')
      Dir.glob(glob).sort.each do |entry|
        next unless File.file? entry
        name = File.basename(entry).sub(/\.[\w\d]+$/, '')
        name += "_#{File.extname(entry).tr('.', '')}"

        next if OS.windows? and File.extname(entry) == '.svg'

        @@resources[name.to_sym] = Hash.new
        LLibPlus::Logger.debug "Create resource ID :#{name.to_sym}"

        pixbuf = Gdk::Pixbuf.new entry
        # pixmap, mask = pixbuf.render_pixmap_and_mask 1
        @@svgScales.each do |key, scale|
          if File.extname(entry) == '.svg' then
            pixbuf = Gdk::Pixbuf.new entry, scale, scale
            # pixmap, mask = pixbuf.render_pixmap_and_mask 1
          end

          @@resources[name.to_sym][key] = {
            :pixbuf => pixbuf
            # :pixmap => pixmap,
            # :mask => mask
          }
        end
      end
      LLibPlus::Logger.info "#{@@resources.size} resources loaded"
    end

    def self.refresh
      @@resources.clear
      self.loadResources
    end

    def self.getResource(name)
      @@resources[name]
    end

    def self.getPixbuf(name, scale = :medium)
      @@resources.dig(name, scale, :pixbuf)
    end

    # def self.getPixmap(name, scale = :medium)
    #   @@resources.dig(name, scale, :pixmap)
    # end
    #
    # def self.getMask(name, scale = :medium)
    #   @@resources.dig(name, scale, :mask)
    # end
  end
end
