# -*- coding: utf-8 -*-

require 'mono_logger'

module LLibPlus
  class Logger
    def self.init(loglevel = :WARN)
      @@logger = ::MonoLogger.new STDOUT
      @@logger.level = ::MonoLogger.const_get loglevel
      @@logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime}]: #{severity} -- #{msg}\n"
      end
      self.define_singleton_methods
    end

    def self.define_singleton_methods
      ::MonoLogger::Severity.constants.each do |level|
        define_singleton_method(level.to_s.downcase) do |*args|
          @@logger.send(level.to_s.downcase.to_sym, *args)
        end
      end
    end
  end
end
