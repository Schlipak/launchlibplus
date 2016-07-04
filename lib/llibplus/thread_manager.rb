# -*- coding: utf-8 -*-

module LLibPlus
  class ThreadManager
    @@semaphone = Mutex.new
    @@threads = Array.new

    def self.add_job
      self.clean_threads
      @@semaphone.synchronize do
        thr = Thread.new { yield }
        @@threads << thr
        LLibPlus::Logger.debug "Creating #{thr}"
      end
    end

    def self.register(thr)
      self.clean_threads
      @@semaphone.synchronize do
        @@threads << thr if thr.is_a? Thread
        LLibPlus::Logger.debug "Registering #{thr}"
      end
    end

    def self.clean_threads
      @@semaphone.synchronize do
        @@threads.each do |thr|
          @@threads.delete(thr) unless thr.alive?
          LLibPlus::Logger.debug "Cleaning #{thr}" unless thr.alive?
        end
      end
    end

    def self.finalize
      @@threads.each do |thr|
        @@threads.delete thr
        next unless thr.alive?
        LLibPlus::Logger.info "Terminating #{thr}"
        Thread.kill thr
      end
    end
  end
end
