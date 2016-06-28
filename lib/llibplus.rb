# -*- coding: utf-8 -*-

Dir[File.dirname(__FILE__) + '/llibplus/*.rb'].each {|f| require f}

module LLibPlus
  class App
    def initialize
      puts "App init"
    end

    def run!
      puts "App run!"
    end
  end
end
