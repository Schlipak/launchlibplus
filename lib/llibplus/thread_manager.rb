# -*- coding: utf-8 -*-

module LLibPlus
  class ThreadManager
    @@threads = Array.new

    def self.add_job
      @@threads << Thread.new do
        yield
      end
    end

    def finalize
      @@threads.each do |th|
        next if th.stop?
        LLibPlus::Logger.info "Terminating #{th}"
        Thread.kill th
      end
    end
  end
end
