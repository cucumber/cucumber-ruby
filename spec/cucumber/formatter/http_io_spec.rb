# frozen_string_literal: true
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
        @received_body = nil
        
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
        @server.mount_proc '/' do |req, res|
          @received_body = req.body
        end

        Thread.new do
          @server.start
        end
      end

      context 'created by Io#ensure_io' do
        it 'creates an IO that POSTs with HTTP' do
          url = 'http://localhost:9987'
          start_server(url)
          sent_body = 'X' * 10000000 # 10Mb

          io = ensure_io(url)
          io.write(sent_body)
          io.flush
          io.close
          expect(@received_body).to eq(sent_body)
        end
      end
      
      context 'created with constructor (because we need to relax SSL verification during testing)' do
        it 'POSTs with HTTPS' do
          url = 'https://localhost:9987'
          start_server(url)
          sent_body = 'X' * 10000000 # 10Mb

          io = HTTPIO.new(url, OpenSSL::SSL::VERIFY_NONE)
          io.write(sent_body)
          io.flush
          io.close
          expect(@received_body).to eq(sent_body)
        end
      end

      after do
        @server.shutdown 
      end
    end
  end
end
