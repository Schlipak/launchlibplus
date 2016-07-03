# -*- coding: utf-8 -*-

require 'optparse'
require 'logger'

module LLibPlus
  class Parser
    USAGE = "llib+ [options]"

    attr_reader :parser, :options

    def initialize
      @options = Hash.new
      @parser = nil
    end

    def parse!
      begin
        @parser = OptionParser.new(USAGE, 23, "\t") do |opts|
          opts.on('-h', '--help', 'Show the usage') do
            $stdout.puts @parser.help
            exit! 0
          end

          opts.on('-v', '--version', 'Show the program version') do
            $stdout.puts "LaunchLibPlus v#{LLibPlus::VERSION_NUMBER} - #{LLibPlus::VERSION_NAME}"
            exit! 0
          end

          opts.on('--log-level LEVEL', "Set the logger minimum level (#{::Logger::Severity.constants.to_s.tr ':', ''}, default WARN)") do |v|
            v = v.to_sym
            raise LLibPlus::InvalidLogLevel.new, "Invalid log level :#{v}" unless ::Logger::Severity.constants.include? v
            @options[:loglevel] = v
          end
        end
        @parser.parse!
      rescue StandardError => e
        $stderr.puts "[#{e.class}] #{e.message}"
        exit! 1
      ensure
        return @options
      end
    end

    def help
      @parser.help
    end
  end
end
