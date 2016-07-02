# -*- coding: utf-8 -*-

module LLibPlus
  class Preferences < Gtk::Dialog
    type_register

    class << self
      def init
        set_template :resource => '/schlipak/llibplus/prefs.ui'
      end

      def initialize(args)
        super(args)

        self.setupLayout
        self
      end

      def setupLayout
        nil
      end

      def run
        self.show_all
      end
    end
  end
end
