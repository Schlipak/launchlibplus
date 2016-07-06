# -*- coding: utf-8 -*-

module LLibPlus
  class DataFetcher
    def initialize
      self
    end

    def fetch(request)
      Logger.info "Fetching data #{request.debug}"
      th = ThreadManager.add do
        begin
          sleep 1
          raise LLibPlus::NotImplementedError.new('Fetch call not implemented', :warning)
        rescue Exception => e
          unless e.is_a? GraphicError
            JobQueue.push do
              ErrorDialog.new(e, :error).run!
            end
          end
        end
      end
    end
  end
end
