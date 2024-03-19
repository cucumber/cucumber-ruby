# frozen_string_literal: true

module Cucumber
  module Formatter
    class IOHTTPBuffer
      attr_reader :uri, :method, :headers

      def initialize(uri, method, headers = {}, https_verify_mode = nil, reporter = nil)
        @uri = URI(uri)
        @method = method
        @headers = headers
        @write_io = Tempfile.new('cucumber', encoding: 'UTF-8')
        @https_verify_mode = https_verify_mode
        @reporter = reporter || NoReporter.new
      end

      def close
        @reporter.report(response.body)
        @write_io.close
        return if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)

        raise StandardError, "request to #{uri} failed with status #{response.code}"
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

      def response
        @response ||= send_content(uri, method, headers)
      end

      def send_content(uri, method, headers, attempts_remaining = 10)
        content = (method == 'GET' ? StringIO.new : @write_io)
        http = build_client(uri)

        raise StandardError, "request to #{uri} failed (too many redirections)" if attempts_remaining <= 0

        request = build_request(uri, method, headers.merge('Content-Length' => content.size.to_s))
        content.rewind
        request.body_stream = content

        begin
          response = http.request(request)
        rescue SystemCallError
          # We may get the redirect response before pushing the file.
          response = http.request(build_request(uri, method, headers))
        end

        case response
        when Net::HTTPAccepted
          send_content(URI(response['Location']), 'PUT', {}, attempts_remaining - 1) if response['Location']
        when Net::HTTPRedirection
          send_content(URI(response['Location']), method, headers, attempts_remaining - 1)
        end
        response
      end

      def build_request(uri, method, headers)
        method_class_name = "#{method[0].upcase}#{method[1..].downcase}"
        Net::HTTP.const_get(method_class_name).new(uri).tap do |request|
          headers.each do |header, value|
            request[header] = value
          end
        end
      end

      def build_client(uri)
        Net::HTTP.new(uri.hostname, uri.port).tap do |http|
          if uri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = @https_verify_mode if @https_verify_mode
          end
        end
      end
    end
  end
end
