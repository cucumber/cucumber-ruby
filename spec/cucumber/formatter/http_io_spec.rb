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

      def start_server(url)
        uri = URI(url)
        @received_body_io = StringIO.new

        webrick_options = {
          Port: uri.port,
          Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
          AccessLog: []
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

        Thread.new do
          @server.start
        end
      end

      context 'created by Io#ensure_io' do
        it 'creates an IO that POSTs with HTTP' do
          url = 'http://localhost:9987'
          start_server(url)
          sent_body = 'X' * 10 # 10Mb

          io = ensure_io(url)
          io.write(sent_body)
          io.flush
          io.close
          sleep(0.1)
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body).to eq(sent_body)
        end
      end

      context 'created with constructor (because we need to relax SSL verification during testing)' do
        it 'POSTs with HTTPS' do
          url = 'https://localhost:9987'
          start_server(url)
          sent_body = 'X' * 10 # 10Mb

          io = HTTPIO.open(url, OpenSSL::SSL::VERIFY_NONE)
          io.write(sent_body)
          io.flush
          io.close
          sleep(0.1)
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body).to eq(sent_body)
        end
      end

      it 'sets HTTP method when http-method is set' do
        uri, method, = HTTPIO.build_uri_and_headers('http://localhost:9987?http-method=PUT&foo=bar')
        expect(method).to eq('PUT')
        expect(uri.to_s).to eq('http://localhost:9987?foo=bar')
      end

      it 'sets Content-Type header when http-content-type query parameter set' do
        uri, _method, headers = HTTPIO.build_uri_and_headers('http://localhost:9987?http-content-type=text/plain&foo=bar')
        expect(headers['content-type']).to eq('text/plain')
        expect(uri.to_s).to eq('http://localhost:9987?foo=bar')
      end

      after do
        @server&.shutdown
      end
    end
  end
end
