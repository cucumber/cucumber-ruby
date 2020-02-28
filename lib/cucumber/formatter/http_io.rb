require 'net/http'

module Cucumber
  module Formatter
    # Quacks like an IO and executes a HTTP request with the data as body on flush
    class HTTPIO
      def initialize(url, https_verify_mode=nil)
        @url = url
        @https_verify_mode = https_verify_mode
        @closed = false
        @body = ''
      end
      
      def write(chunk)
        @body += chunk
      end
      
      def closed?
        @closed
      end
      
      def flush
        uri = URI(@url)
        req = Net::HTTP::Post.new(uri)
        req.body = @body
        http = Net::HTTP.new(uri.hostname, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = @https_verify_mode if @https_verify_mode
        end
        res = http.request(req)
        raise "Not OK" unless Net::HTTPOK === res
      end
      
      def close
        @closed = true
      end
    end
  end
end