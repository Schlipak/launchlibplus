# -*- coding: utf-8 -*-

require 'logger'

module LLibPlus
  class Logger
    def self.init
      @@file = File.open(
        File.join(Dir.home, 'llibplus.log'),
        File::CREAT | File::WRONLY | File::APPEND
      )
      @@logger = ::Logger.new(@@file, 'daily')
      @@logger.level = ::Logger::INFO
      @@logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime}]: #{severity} -- #{msg}\n"
      end
      self.defineSingletonMethods
    end

    def self.defineSingletonMethods
      ::Logger::Severity.constants.each do |level|
        define_singleton_method(level.to_s.downcase) do |*args|
          @@logger.send(level.to_s.downcase.to_sym, *args)
        end
      end
    end
  end
end
