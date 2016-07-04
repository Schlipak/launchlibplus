# -*- coding: utf-8 -*-

module LLibPlus
  class GenericError < StandardError
    attr_reader :reference

    def initialize(ref = nil)
      @reference = ref
    end
  end

  InvalidLogLevel = Class.new(GenericError)
  GraphicError = Class.new(GenericError)

  class ErrorDialog < Gtk::MessageDialog
    def initialize(msg)
      super({
        :parent => $win,
        :transient_for => $win,
        :flags => :modal,
        :type => :error,
        :message => msg
      })
      self
    end

    def run!
      self.show_all
      self.run
      self.destroy
    end
  end
end
