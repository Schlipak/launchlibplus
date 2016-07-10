# -*- coding: utf-8 -*-

require_relative '../monkeypatch/object'

module LLibPlus
  class APIData
    include ::AppObject

    TYPES = {
      :launch => {
        :sort_by => 'name',
        :each => 'launches'
      },
      :mission => {
        :sort_by => 'name',
        :each => 'missions'
      },
      :vehicule => {
        :sort_by => 'name',
        :each => 'rockets'
      }
    }

    def initialize(data, type = :launch)
      @data = data
      @type = type

      raise DeveloperError.new("Unknown data type :#{type}") unless TYPES.include? type

      Logger.debug "Loaded #{self.inspect}"
    end

    def sort!
      begin
        @data[TYPES.dig(@type, :each)].sort_by! do |elem|
          elem[TYPES.dig(@type, :sort_by)]
        end
      rescue StandardError => e
        raise GraphicError.new(e.message, :error)
      ensure
        return self
      end
    end

    def each
      begin
        @data[TYPES.dig(@type, :each)].each do |elem|
          yield elem
        end
      rescue StandardError => e
        raise GraphicError.new(e.message, :error)
      end
    end

    def inspect
      "#<#{self.class}:#{self.address} @type=:#{@type}>"
    end

    def nil?
      @data.nil?
    end
  end
end
