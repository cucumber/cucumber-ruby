require 'net/http'

module Cucumber
  module Formatter
    class HTTPIO
      class << self
        # Returns an IO that will write to a HTTP request's body
        def open(url, https_verify_mode = nil)
          @https_verify_mode = https_verify_mode
          uri, method, headers = build_uri_method_headers(url)

          http = build_client(uri, https_verify_mode)

          writer = HTTPWriter.new
          writer.start_request(http, uri, method, headers)
          writer
        end

        def build_uri_method_headers(url)
          uri = URI(url)
          query_pairs = uri.query ? URI.decode_www_form(uri.query) : []

          # Build headers from query parameters prefixed with http- and extract HTTP method
          http_query_pairs = query_pairs.select { |pair| pair[0] =~ /^http-/ }
          http_query_hash_without_prefix = Hash[http_query_pairs.map do |pair|
                                                  [
                                                    pair[0][5..-1].downcase, # remove http- prefix
                                                    pair[1]
                                                  ]
                                                end]
          method = http_query_hash_without_prefix.delete('method') || 'PUT'
          headers = {
            'transfer-encoding' => 'chunked'
          }.merge(http_query_hash_without_prefix)

          # Update the query with the http-* parameters removed
          remaining_query_pairs = query_pairs - http_query_pairs
          new_query_hash = Hash[remaining_query_pairs]
          uri.query = URI.encode_www_form(new_query_hash) unless new_query_hash.empty?
          [uri, method, headers]
        end

        private

        def build_client(uri, https_verify_mode)
          http = Net::HTTP.new(uri.hostname, uri.port)
          if uri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = https_verify_mode if https_verify_mode
          end
          http
        end
      end
    end

    class HTTPWriter
      def initialize
        @read_io, @write_io = IO.pipe
      end

      def start_request(http, uri, method, headers)
        @req_thread = Thread.new do
          begin
            final_uri = test_uri(http, uri, method, headers)

            req = build_request(final_uri, method, headers)
            req.body_stream = @read_io

            res = http.request(req)
            raise_on_errors(res, req)
          rescue StandardError => e
            @http_error = e
          end
        end
      end

      def test_uri(http, uri, method, headers, attempt = 10)
        raise StandardError, "request to #{uri} failed (too many redirections)" if attempt <= 0

        req = build_request(uri, method, headers)
        res = http.request(req)
        raise_on_errors(res, req)

        return test_uri(http, res['Location'], method, headers, attempt - 1) if res.code.to_i >= 300
        uri
      end

      def raise_on_errors(res, req)
        raise StandardError, "request to #{req.uri} failed with status #{res.code}" if res.code.to_i >= 400
      end

      def close
        @write_io.close
        begin
          @req_thread.join
        rescue StandardError
          nil
        end
        raise @http_error unless @http_error.nil?
      end

      def write(data)
        @write_io.write(data)
      end

      def flush
        @write_io.flush
      end

      def closed?
        @write_io.closed?
      end

      private

      def build_request(uri, method, headers)
        method_class_name = "#{method[0].upcase}#{method[1..-1].downcase}"
        req = Net::HTTP.const_get(method_class_name).new(uri)
        headers.each do |header, value|
          req[header] = value
        end
        req
      end
    end

    class CurlOptionParser
      def self.parse(options)
        chunks = options.split(/\s/).compact
        http_method = 'PUT'
        url = chunks[0]
        headers = ''

        last_flag = nil
        chunks.each do |chunk|
          if ['-X', '--request'].include?(chunk)
            last_flag = '-X'
            next
          end

          if chunk == '-H'
            last_flag = '-H'
            next
          end

          if last_flag == '-X'
            http_method = chunk
            last_flag = nil
          end

          headers += chunk if last_flag == '-H'
        end

        [
          url,
          http_method,
          make_headers(headers)
        ]
      end

      def self.make_headers(headers)
        hash_headers = {}
        headers.split('"').map do |header|
          next unless header.include?(':')

          chunks = header.split(':')
          hash_headers[chunks[0]] = chunks[1].strip
        end

        hash_headers
      end
    end
  end
end
