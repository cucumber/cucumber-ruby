# frozen_string_literal: true

require 'net/http'
require 'tempfile'
require_relative 'curl_option_parser'
require_relative 'io_http_buffer'

module Cucumber
  module Formatter
    class HTTPIO
      # Returns an IO that will write to a HTTP request's body
      # https_verify_mode can be set to OpenSSL::SSL::VERIFY_NONE
      # to ignore unsigned certificate - setting to nil will verify the certificate
      def self.open(url, https_verify_mode = nil, reporter = nil)
        uri, method, headers = CurlOptionParser.parse(url)
        IOHTTPBuffer.new(uri, method, headers, https_verify_mode, reporter)
      end
    end
  end
end
