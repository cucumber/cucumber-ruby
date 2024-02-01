# frozen_string_literal: true

require 'stringio'
require 'webrick'
require 'webrick/https'
require 'spec_helper'
require 'cucumber/formatter/io'
require 'support/shared_context/http_server'
require 'support/webrick_proc_handler_alias'

module Cucumber
  module Formatter
    class DummyReporter
      def report(banner); end
    end

    describe IOHTTPBuffer do
      include_context 'an HTTP server accepting file requests'

      # JRuby seems to have some issues with huge reports. At least during tests
      # Maybe something to see with Webrick configuration.
      let(:report_size) { RUBY_PLATFORM == 'java' ? 8_000 : 10_000_000 }
      let(:sent_body) { 'X' * report_size }

      it 'raises an error on close when server in unreachable' do
        io = described_class.new("#{server_url}/404", 'PUT')

        expect { io.close }.to(raise_error("request to #{server_url}/404 failed with status 404"))
      end

      it 'raises an error on close when the server is unreachable' do
        io = described_class.new('http://localhost:9987', 'PUT')

        expect { io.close }.to(raise_error(/Failed to open TCP connection to localhost:9987/))
      end

      it 'raises an error on close when there is too many redirect attempts' do
        io = described_class.new("#{server_url}/loop_redirect", 'PUT')

        expect { io.close }.to(raise_error("request to #{server_url}/loop_redirect failed (too many redirections)"))
      end

      it 'sends the content over HTTP' do
        io = described_class.new("#{server_url}/s3", 'PUT')
        io.write(sent_body)
        io.flush
        io.close
        server.received_body_io.rewind
        received_body = server.received_body_io.read

        expect(received_body).to eq(sent_body)
      end

      it 'sends the content over HTTPS' do
        io = described_class.new("#{server_url}/s3", 'PUT', {}, OpenSSL::SSL::VERIFY_NONE)
        io.write(sent_body)
        io.flush
        io.close
        server.received_body_io.rewind
        received_body = server.received_body_io.read

        expect(received_body).to eq(sent_body)
      end

      it 'follows redirections and sends body twice' do
        io = described_class.new("#{server_url}/putreport", 'PUT')
        io.write(sent_body)
        io.flush
        io.close
        server.received_body_io.rewind
        received_body = server.received_body_io.read

        expect(received_body).to eq("#{sent_body}#{sent_body}")
      end

      it 'only sends body once' do
        io = described_class.new("#{server_url}/putreport", 'GET')
        io.write(sent_body)
        io.flush
        io.close
        server.received_body_io.rewind
        received_body = server.received_body_io.read

        expect(received_body).to eq(sent_body)
      end

      it 'does not send headers to 2nd PUT request' do
        io = described_class.new("#{server_url}/putreport", 'GET', { Authorization: 'Bearer abcdefg' })
        io.write(sent_body)
        io.flush
        io.close

        expect(server.received_headers[0]['authorization']).to eq(['Bearer abcdefg'])
        expect(server.received_headers[1]['authorization']).to eq([])
      end

      it 'reports the body of the response to the reporter' do
        reporter = DummyReporter.new
        allow(reporter).to receive(:report)
        io = described_class.new("#{server_url}/putreport", 'GET', {}, nil, reporter)
        io.write(sent_body)
        io.flush
        io.close

        expect(reporter).to have_received(:report).with(success_banner)
      end

      it 'reports the body of the response to the reporter when request failed' do
        reporter = DummyReporter.new
        allow(reporter).to receive(:report)

        begin
          io = described_class.new("#{server_url}/401", 'GET', {}, nil, reporter)
          io.write(sent_body)
          io.flush
          io.close
        rescue StandardError
          # no-op
        end

        expect(reporter).to have_received(:report).with(failure_banner)
      end

      context 'when the location http header is not set on 202 response' do
        let(:putreport_returned_location) { nil }

        it 'does not follow the location' do
          io = described_class.new("#{server_url}/putreport", 'GET')
          io.write(sent_body)
          io.flush
          io.close
          server.received_body_io.rewind
          received_body = server.received_body_io.read

          expect(received_body).to eq('')
        end
      end
    end
  end
end
