require 'net/http'

module Cucumber
  module Formatter
    # Quacks like an IO and executes a HTTP request with the data as body on flush
    class HTTPIO
      attr_reader :req
      
      def initialize(url, https_verify_mode=nil)
        @https_verify_mode = https_verify_mode
        @closed = false
        @body = ''
        
        uri = URI(url)
        query_pairs = uri.query ? URI.decode_www_form(uri.query) : []
        
        # Build headers from query parameters prefixed with http-
        http_query_pairs = query_pairs.select {|pair| pair[0] =~ /^http-/}
        http_query_pairs_wthout_prefix = http_query_pairs.map do |pair|
          [
            pair[0][5..-1], # remove http- prefix
            pair[1]
          ]
        end
        headers = {
          'content-type' => 'application/json'
        }.merge(Hash[http_query_pairs_wthout_prefix])

        # Update the query with the http-* parameters removed
        remaining_query_pairs = query_pairs - http_query_pairs
        new_query_hash = Hash[remaining_query_pairs]
        uri.query = URI.encode_www_form(new_query_hash) unless new_query_hash.empty?

        @req = Net::HTTP::Post.new(uri)
        headers.each do |header, value|
          @req[header] = value
        end
        
        @http = Net::HTTP.new(uri.hostname, uri.port)
        if uri.scheme == 'https'
          @http.use_ssl = true
          @http.verify_mode = https_verify_mode if https_verify_mode
        end
      end
      
      def write(chunk)
        @body += chunk
      end
      
      def closed?
        @closed
      end
      
      def flush
        @req.body = @body
        res = @http.request(@req)
        raise "Not OK" unless Net::HTTPOK === res
      end
      
      def close
        @closed = true
      end
    end
  end
end