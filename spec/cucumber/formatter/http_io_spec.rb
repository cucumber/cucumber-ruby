# frozen_string_literal: true

require 'stringio'
require 'webrick'
require 'webrick/https'
require 'spec_helper'
require 'cucumber/formatter/io'
require 'spec/support/shared_context/http_server'
require 'spec/support/webrick_proc_handler_alias'

module Cucumber
  module Formatter
    class DummyFormatter
      include Io

      def initialize(config = nil); end

      def io(path_or_url_or_io, error_stream)
        ensure_io(path_or_url_or_io, error_stream)
      end
    end

    class DummyReporter
      def report(banner); end
    end

    describe HTTPIO do
      include_context 'an HTTP server accepting file requests'

      # Close during the test so the request is done while server still runs
      after { io.close }

      context 'created by Io#ensure_io' do
        it 'returns a IOHTTPBuffer' do
          url = start_server
          io = DummyFormatter.new.io("#{url}/s3 -X PUT", nil)
          expect(io).to be_a(Cucumber::Formatter::IOHTTPBuffer)
        end

        it 'uses CurlOptionParser to pass correct options to IOHTTPBuffer' do
          url = start_server
          io = DummyFormatter.new.io("#{url}/s3 -X GET -H 'Content-Type: text/json'", nil)

          expect(io.uri).to eq(URI("#{url}/s3"))
          expect(io.method).to eq('GET')
          expect(io.headers).to eq('Content-Type' => 'text/json')
        end
      end
    end

    describe CurlOptionParser do
      describe '.parse' do
        context 'when a simple URL is given' do
          it 'returns the URL' do
            url, = described_class.parse('http://whatever.ltd')
            expect(url).to eq('http://whatever.ltd')
          end

          it 'uses PUT as the default method' do
            _, http_method = described_class.parse('http://whatever.ltd')
            expect(http_method).to eq('PUT')
          end

          it 'does not specify any header' do
            _, _, headers = described_class.parse('http://whatever.ltd')
            expect(headers).to eq({})
          end
        end

        it 'detects the HTTP method with the flag -X' do
          expect(described_class.parse('http://whatever.ltd -X POST')).to eq(
            ['http://whatever.ltd', 'POST', {}]
          )
          expect(described_class.parse('http://whatever.ltd -X PUT')).to eq(
            ['http://whatever.ltd', 'PUT', {}]
          )
        end

        it 'detects the HTTP method with the flag --request' do
          expect(described_class.parse('http://whatever.ltd --request GET')).to eq(
            ['http://whatever.ltd', 'GET', {}]
          )
        end

        it 'can recognize headers set with option -H and double quote' do
          expect(described_class.parse('http://whatever.ltd -H "Content-Type: text/json" -H "Authorization: Bearer abcde"')).to eq(
            [
              'http://whatever.ltd',
              'PUT',
              {
                'Content-Type' => 'text/json',
                'Authorization' => 'Bearer abcde'
              }
            ]
          )
        end

        it 'can recognize headers set with option -H and single quote' do
          expect(described_class.parse("http://whatever.ltd -H 'Content-Type: text/json' -H 'Content-Length: 12'")).to eq(
            [
              'http://whatever.ltd',
              'PUT',
              {
                'Content-Type' => 'text/json',
                'Content-Length' => '12'
              }
            ]
          )
        end

        it 'supports all options at once' do
          expect(described_class.parse('http://whatever.ltd -H "Content-Type: text/json" -X GET -H "Transfer-Encoding: chunked"')).to eq(
            [
              'http://whatever.ltd',
              'GET',
              {
                'Content-Type' => 'text/json',
                'Transfer-Encoding' => 'chunked'
              }
            ]
          )
        end
      end
    end
  end
end
