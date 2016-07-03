# -*- coding: utf-8 -*-

module LLibPlus
  class ThreadManager
    @@semaphone = Mutex.new
    @@threads = Array.new

    def self.add_job
      @@semaphone.synchronize do
        @@threads << Thread.new do
          yield
        end
      end
      self.clean_threads
    end

    def self.clean_threads
      @@semaphone.synchronize do
        @@threads.each do |th|
          @@threads.delete(th) if th.stop?
        end
      end
    end

    def self.finalize
      @@semaphone.synchronize do
        @@threads.each do |th|
          @@threads.delete th
          next if th.stop?
          LLibPlus::Logger.info "Terminating #{th}"
          Thread.kill th
        end
      end
    end
  end
end
