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
          raise NotImplementedError.new, 'Fetch call not implemented'
        rescue Exception => e
          JobQueue.push do
            ErrorDialog.new(e, :warning).run!
          end
        end
      end
    end
  end
end
