# frozen_string_literal: true
require 'webrick'
require 'spec_helper'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    describe Io do
      include Io

      it 'converts to a HTTPIO' do
        port = 9983
        sent_body = 'X' * 10000000 # 10Mb
        received_body = nil
        @server = WEBrick::HTTPServer.new(
          Port: port, 
          Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
          AccessLog: []
        )
        @server.mount_proc '/' do |req, res|
          received_body = req.body
        end

        @thread = Thread.new do
          @server.start
        end

        io = ensure_io("http://localhost:#{port}")
        io.write(sent_body)
        io.flush
        io.close
        expect(received_body).to eq(sent_body)
      end
      
      after do
        if @server
          @server.shutdown 
        end
      end
    end
  end
end
