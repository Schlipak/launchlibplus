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

        self.setup_layout
        self
      end

      def setup_layout
        nil
      end

      def run
        self.show_all
      end
    end
  end
end
