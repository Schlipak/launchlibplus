# -*- coding: utf-8 -*-

module LLibPlus
  class GenericError < StandardError
    attr_reader :reference

    def initialize(ref = nil)
      @reference = ref
    end
  end

  class InvalidLogLevel < GenericError
  end

  class GraphicError < GenericError
  end
end
