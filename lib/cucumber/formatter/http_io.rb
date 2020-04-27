require 'net/http'
require 'tempfile'

module Cucumber
  module Formatter
    class HTTPIO
      class << self
        # Returns an IO that will write to a HTTP request's body
        def open(url, https_verify_mode = nil)
          @https_verify_mode = https_verify_mode
          uri, method, headers = CurlOptionParser.parse(url)
          IOHTTPBuffer.new(uri, method, headers, https_verify_mode)
        end
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
        str_scanner = /("(?<key>[^":]+)\s*:\s*(?<value>[^":]+)")|('(?<key1>[^':]+)\s*:\s*(?<value1>[^':]+)')/

        headers.scan(str_scanner) do |header|
          header = header.compact!
          hash_headers[header[0]] = header[1]&.strip
        end

        hash_headers
      end
    end

    class IOHTTPBuffer
      attr_reader :uri, :method, :headers

      def initialize(uri, method, headers = {}, https_verify_mode = nil)
        @uri = URI(uri)
        @method = method
        @headers = headers
        @write_io = Tempfile.new('cucumber', encoding: 'UTF-8')
        @https_verify_mode = https_verify_mode
      end

      def close
        post_content(@uri, @method, @headers)
        @write_io.close
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

      def post_content(uri, method, headers, attempt = 10)
        content = @write_io
        http = build_client(uri, @https_verify_mode)

        raise StandardError, "request to #{uri} failed (too many redirections)" if attempt <= 0
        req = build_request(
          uri,
          method,
          headers.merge(
            'Content-Length' => content.size.to_s
          )
        )

        content.rewind
        req.body_stream = content

        begin
          response = http.request(req)
        rescue SystemCallError
          # We may get the redirect response before pushing the file.
          response = http.request(build_request(uri, method, headers))
        end

        case response
        when Net::HTTPSuccess
          response
        when Net::HTTPRedirection
          post_content(URI(response['Location']), method, headers, attempt - 1)
        else
          raise StandardError, "request to #{uri} failed with status #{response.code}"
        end
      end

      def build_request(uri, method, headers)
        method_class_name = "#{method[0].upcase}#{method[1..-1].downcase}"
        req = Net::HTTP.const_get(method_class_name).new(uri)
        headers.each do |header, value|
          req[header] = value
        end
        req
      end

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
end
