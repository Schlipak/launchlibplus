# -*- coding: utf-8 -*-

require 'net/http'
require 'openssl'
require 'cgi'
require 'timeout'
require 'json'

module LLibPlus
  BASE_URL = 'https://launchlibrary.net/1.2/'.freeze

  class DataFetcher
    def self.fetch(query, params, type = :launch)
      Logger.info "Fetching #{query}#{'?' unless params.empty?}#{URI.encode_www_form params} (:#{type})"
      data = nil
      begin
        thr = ThreadManager.add do
          begin
            data = query_send(query, params)
            unless data[:done]
              raise DataFetchError.new('Error while fetching data')
            end
            data = JSON.parse(data[:body].join)
          rescue Exception => e
            unless e.is_a? GraphicError
              JobQueue.push do
                ErrorDialog.new(e, :error).run!
              end
            end
          end
        end
      ensure
        thr.join
        return APIData.new(data, type)
      end
    end

    private
    def self.query_send(query, params)
      data = {:body => [], :done => false}
      begin
        url = URI.parse(BASE_URL + query)
        url.query = URI.encode_www_form params
        status = Timeout::timeout(5, LLibPlus::TimeoutError) do
          http = Net::HTTP.new url.host, url.port
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          http.request_get(url.path) do |resp|
            resp.read_body do |frag|
              data[:body] << frag
            end
          end
          data[:done] = true
        end
      rescue ::EOFError => e
        raise LLibPlus::EOFError.new
      rescue Exception => e
        raise GraphicError.new(e.message, :error)
      end
      data
    end
  end
end
