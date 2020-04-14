# frozen_string_literal: true

require 'stringio'
require 'webrick'
require 'webrick/https'
require 'spec_helper'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    describe HTTPIO do
      include Io

      # rubocop:disable Metrics/MethodLength
      def start_server
        uri = URI('http://localhost')
        @received_body_io = StringIO.new

        rd, wt = IO.pipe
        webrick_options = {
          Port: 0,
          Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
          AccessLog: [],
          StartCallback: proc do
                           wt.write(1) # write "1", signal a server start message
                           wt.close
                         end
        }
        if uri.scheme == 'https'
          webrick_options[:SSLEnable] = true
          # Set up a self-signed cert
          webrick_options[:SSLCertName] = [%w[CN localhost]]
        end

        @server = WEBrick::HTTPServer.new(webrick_options)
        @server.mount_proc '/' do |req, _res|
          IO.copy_stream(req.body_reader, @received_body_io)
        end

        @server.mount_proc '/404' do |_req, res|
          res.status = 404
        end

        @server.mount_proc '/redirect' do |_req, res|
          res.set_redirect(
            WEBrick::HTTPStatus::TemporaryRedirect,
            '/'
          )
        end

        @server.mount_proc '/loop_redirect' do |_req, res|
          res.set_redirect(
            WEBrick::HTTPStatus::TemporaryRedirect,
            '/loop_redirect'
          )
        end

        Thread.new do
          @server.start
        end
        rd.read(1) # read a byte for the server start signal
        rd.close

        "http://localhost:#{@server.config[:Port]}"
      end
      # rubocop:enable Metrics/MethodLength

      context 'created by Io#ensure_io' do
        it 'creates an IO that PUTs with HTTP' do
          url = start_server
          sent_body = 'X' * 10_000_000 # 10Mb

          io = ensure_io("#{url}/ -X POST")
          io.write(sent_body)
          io.flush
          io.close
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body).to eq(sent_body)
        end

        it 'streams HTTP body to server' do
          url = start_server
          sent_body = 'X' * 10_000_000

          io = ensure_io("#{url}/ -X POST")
          io.write(sent_body)
          io.flush
          sleep 0.2 # ugh
          # Not calling io.close
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body.length).to be > 0
        end

        it 'notifies user if the server responds with error' do
          url = start_server
          io = ensure_io("#{url}/404 -X POST")
          expect { io.close }.to(raise_error("request to #{url}/404 failed with status 404"))
        end

        it 'notifies user if the server is unreachable' do
          io = ensure_io('http://localhost:9987')
          expect { io.close }.to(raise_error(/Failed to open TCP connection to localhost:9987/))
        end

        it 'follows redirects' do
          url = start_server
          sent_body = 'X' * 10_000_000

          io = ensure_io("#{url}/redirect -X POST")
          io.write(sent_body)
          io.flush
          io.close
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body).to eq(sent_body)
        end

        it 'raises an error when maximum redirection is reached' do
          url = start_server
          io = ensure_io("#{url}/loop_redirect -X POST")
          expect { io.close }.to(raise_error("request to #{url}/loop_redirect failed (too many redirections)"))
        end
      end

      context 'created with constructor (because we need to relax SSL verification during testing)' do
        it 'PUTs with HTTPS' do
          url = start_server
          sent_body = 'X' * 10_000_000 # 10Mb

          io = HTTPIO.open("#{url}/ -X POST", OpenSSL::SSL::VERIFY_NONE)
          io.write(sent_body)
          io.flush
          io.close
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body).to eq(sent_body)
        end
      end

      it 'default method is PUT' do
        uri, method, = HTTPIO.build_uri_method_headers('http://localhost:9987?foo=bar')
        expect(method).to eq('PUT')
        expect(uri.to_s).to eq('http://localhost:9987?foo=bar')
      end

      it 'sets HTTP method when -X is set' do
        uri, method, = HTTPIO.build_uri_method_headers('http://localhost:9987?foo=bar -X GET')
        expect(method).to eq('GET')
        expect(uri.to_s).to eq('http://localhost:9987?foo=bar')
      end

      it 'sets Content-Type header when -H is set' do
        uri, _method, headers = HTTPIO.build_uri_method_headers('http://localhost:9987?foo=bar -H "content-type: text/plain"')
        expect(headers['content-type']).to eq('text/plain')
        expect(uri.to_s).to eq('http://localhost:9987?foo=bar')
      end

      after do
        @server&.shutdown
      end
    end

    describe CurlOptionParser do
      context '.parse' do
        context 'when a simple URL is given' do
          it 'returns the URL' do
            url, = CurlOptionParser.parse('http://whatever.ltd')
            expect(url).to eq('http://whatever.ltd')
          end

          it 'uses PUT as the default method' do
            _, http_method = CurlOptionParser.parse('http://whatever.ltd')
            expect(http_method).to eq('PUT')
          end

          it 'does not specify any header' do
            _, _, headers = CurlOptionParser.parse('http://whatever.ltd')
            expect(headers).to eq({})
          end
        end

        it 'detects the HTTP method with the flag -X' do
          expect(CurlOptionParser.parse('http://whatever.ltd -X POST')).to eq(
            ['http://whatever.ltd', 'POST', {}]
          )
        end

        it 'detects the HTTP method with the flag --request' do
          expect(CurlOptionParser.parse('http://whatever.ltd --request GET')).to eq(
            ['http://whatever.ltd', 'GET', {}]
          )
        end

        it 'can recognize headers set with option -H' do
          expect(CurlOptionParser.parse('http://whatever.ltd -H "Content-Type: text/json"')).to eq(
            [
              'http://whatever.ltd',
              'PUT',
              {
                'Content-Type' => 'text/json'
              }
            ]
          )
        end

        it 'can recognize headers set with option -H and single quote' do
          expect(CurlOptionParser.parse("http://whatever.ltd -H 'Content-Type: text/json' 'Content-Length: 12'")).to eq(
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

        it 'can recognize multiple headers set with option -H' do
          expect(CurlOptionParser.parse('http://whatever.ltd -H "Content-Type: text/json" "Transfer-Encoding: chunked"')).to eq(
            [
              'http://whatever.ltd',
              'PUT',
              {
                'Content-Type' => 'text/json',
                'Transfer-Encoding' => 'chunked'
              }
            ]
          )
        end

        it 'supports multiple -H options' do
          expect(CurlOptionParser.parse('http://whatever.ltd -H "Content-Type: text/json" -H "Transfer-Encoding: chunked"')).to eq(
            [
              'http://whatever.ltd',
              'PUT',
              {
                'Content-Type' => 'text/json',
                'Transfer-Encoding' => 'chunked'
              }
            ]
          )
        end

        it 'supports all options at once' do
          expect(CurlOptionParser.parse('http://whatever.ltd -H "Content-Type: text/json" -X GET -H "Transfer-Encoding: chunked"')).to eq(
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

      context '.make_headers' do
        it 'transforms a string into a hash' do
          expect(CurlOptionParser.make_headers(%("Content-Type: text/json"))).to eq(
            'Content-Type' => 'text/json'
          )
        end

        it 'supports single quote too' do
          expect(CurlOptionParser.make_headers(%('Content-Type: text/json'))).to eq(
            'Content-Type' => 'text/json'
          )
        end

        it 'supports mixed data' do
          expect(CurlOptionParser.make_headers(%('Content-Type: text/json' "Content-Length:12" "Content:'bad'"))).to eq(
            'Content-Type' => 'text/json',
            'Content-Length' => '12',
            'Content' => "'bad'"
          )
        end
      end
    end
  end
end
