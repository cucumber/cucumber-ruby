# frozen_string_literal: true

require 'stringio'
require 'webrick'
require 'webrick/https'
require 'spec_helper'
require 'cucumber/formatter/io'
require 'support/shared_context/http_server'

module Cucumber
  module Formatter
    class DummyFormatter
      include Io

      def initialize(config = nil); end

      def io(path_or_url_or_io, error_stream)
        ensure_io(path_or_url_or_io, error_stream)
      end
    end

    describe HTTPIO do
      include_context 'an HTTP server accepting file requests'

      # Close during the test so the request is done while server still runs
      after { io.close }

      let(:io) { DummyFormatter.new.io("#{server_url}/s3 -X GET -H 'Content-Type: text/json'", nil) }

      context 'created by Io#ensure_io' do
        it 'returns a IOHTTPBuffer' do
          expect(io).to be_a(Cucumber::Formatter::IOHTTPBuffer)
        end

        it 'uses CurlOptionParser to pass correct options to IOHTTPBuffer' do
          expect(io.uri).to eq(URI("#{server_url}/s3"))
          expect(io.method).to eq('GET')
          expect(io.headers).to eq('Content-Type' => 'text/json')
        end
      end
    end
  end
end
