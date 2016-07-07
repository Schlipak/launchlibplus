# -*- coding: utf-8 -*-

module LLibPlus
  class ThreadManager
    @@semaphone = Mutex.new
    @@threads = Array.new

    def self.add
      self.clean_threads
      @@semaphone.synchronize do
        thr = Thread.new { yield Thread.current }
        @@threads << thr
        LLibPlus::Logger.debug "Creating #{thr} from #{__caller__(3)}"
        return thr
      end
    end

    def self.register(thr)
      self.clean_threads
      @@semaphone.synchronize do
        @@threads << thr if thr.is_a? Thread
        LLibPlus::Logger.debug "Registering #{thr} from #{__caller__(3)}"
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
        LLibPlus::Logger.debug "Terminating #{thr}"
        Thread.kill thr
      end
    end

  end

  class JobQueue
    @@queue = Queue.new
    @@worker = nil

    def self.push(&job)
      LLibPlus::Logger.debug "Pushing job #{self.job_inspect(job)} from #{__caller__}"
      @@queue << job
      self.start_worker if @@worker.nil?
    end

    def self.stop
      return if @@worker.nil?
      GLib::Source.remove @@worker
      @@worker = nil
    end

    def self.start_worker
      @@worker = GLib::Idle.add do
        job = @@queue.pop
        LLibPlus::Logger.debug "Running job #{self.job_inspect(job)}"
        job.call
        if @@queue.empty?
          @@worker = nil
          GLib::Source::REMOVE
        else
          GLib::Source::CONTINUE
        end
      end
    end

    private
    def self.job_inspect(job)
      "#<#{job.class}:#{job.address}>"
    end
  end
end
