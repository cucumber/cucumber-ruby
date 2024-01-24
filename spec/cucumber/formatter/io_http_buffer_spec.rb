# frozen_string_literal: true

require 'stringio'
require 'webrick'
require 'webrick/https'
require 'spec_helper'
require 'cucumber/formatter/io'

module WEBrick
  module HTTPServlet
    class ProcHandler < AbstractServlet
      alias do_PUT do_GET # Webrick #mount_proc only works with GET,HEAD,POST,OPTIONS by default
    end
  end
end

RSpec.shared_context 'an HTTP server accepting file requests' do
  let(:putreport_returned_location) { URI('/s3').to_s }
  let(:success_banner) do
    [
      'View your Cucumber Report at:',
      'https://reports.cucumber.io/reports/<some-random-uid>'
    ].join("\n")
  end
  let(:failure_banner) { 'Oh noooo, something went horribly wrong :(' }

  after do
    @server&.shutdown
  end

  def start_server
    uri = URI('http://localhost')
    @received_body_io = StringIO.new
    @received_headers = []
    @request_count = 0

    read_io, write_io = IO.pipe
    webrick_options = {
      Port: 0,
      Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
      AccessLog: [],
      StartCallback: proc do
        write_io.write(1) # write "1", signal a server start message
        write_io.close
      end
    }
    if uri.scheme == 'https'
      webrick_options[:SSLEnable] = true
      # Set up a self-signed cert
      webrick_options[:SSLCertName] = [%w[CN localhost]]
    end

    @server = WEBrick::HTTPServer.new(webrick_options)
    mount_s3_endpoint
    mount_404_endpoint
    mount_401_endpoint
    mount_report_endpoint
    mount_redirect_endpoint

    Thread.new { @server.start }
    read_io.read(1) # read a byte for the server start signal
    read_io.close

    "http://localhost:#{@server.config[:Port]}"
  end

  private

  def mount_s3_endpoint
    @server.mount_proc '/s3' do |req, res|
      @request_count += 1
      IO.copy_stream(req.body_reader, @received_body_io)
      @received_headers << req.header
      if req['authorization']
        res.status = 400
        res.body = 'Do not send Authorization header to S3'
      end
    end
  end

  def mount_404_endpoint
    @server.mount_proc '/404' do |req, res|
      @request_count += 1
      @received_headers << req.header
      res.status = 404
      res.header['Content-Type'] = 'text/plain;charset=utf-8'
      res.body = failure_banner
    end
  end

  def mount_401_endpoint
    @server.mount_proc '/401' do |req, res|
      @request_count += 1
      @received_headers << req.header
      res.status = 401
      res.header['Content-Type'] = 'text/plain;charset=utf-8'
      res.body = failure_banner
    end
  end

  def mount_report_endpoint
    @server.mount_proc '/putreport' do |req, res|
      @request_count += 1
      IO.copy_stream(req.body_reader, @received_body_io)
      @received_headers << req.header

      if req.request_method == 'GET'
        res.status = 202 # Accepted
        res.header['location'] = putreport_returned_location if putreport_returned_location
        res.header['Content-Type'] = 'text/plain;charset=utf-8'
        res.body = success_banner
      else
        res.set_redirect(
          WEBrick::HTTPStatus::TemporaryRedirect,
          '/s3'
        )
      end
    end
  end

  def mount_redirect_endpoint
    @server.mount_proc '/loop_redirect' do |req, res|
      @request_count += 1
      @received_headers << req.header
      res.set_redirect(
        WEBrick::HTTPStatus::TemporaryRedirect,
        '/loop_redirect'
      )
    end
  end
end

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

    describe IOHTTPBuffer do
      include_context 'an HTTP server accepting file requests'

      let(:url) { start_server }
      # JRuby seems to have some issues with huge reports. At least during tests
      # Maybe something to see with Webrick configuration.
      let(:report_size) { RUBY_PLATFORM == 'java' ? 8_000 : 10_000_000 }
      let(:sent_body) { 'X' * report_size }

      it 'raises an error on close when server in unreachable' do
        io = described_class.new("#{url}/404", 'PUT')

        expect { io.close }.to(raise_error("request to #{url}/404 failed with status 404"))
      end

      it 'raises an error on close when the server is unreachable' do
        io = described_class.new('http://localhost:9987', 'PUT')
        expect { io.close }.to(raise_error(/Failed to open TCP connection to localhost:9987/))
      end

      it 'raises an error on close when there is too many redirect attempts' do
        io = described_class.new("#{url}/loop_redirect", 'PUT')
        expect { io.close }.to(raise_error("request to #{url}/loop_redirect failed (too many redirections)"))
      end

      it 'sends the content over HTTP' do
        io = described_class.new("#{url}/s3", 'PUT')
        io.write(sent_body)
        io.flush
        io.close
        @received_body_io.rewind
        received_body = @received_body_io.read
        expect(received_body).to eq(sent_body)
      end

      it 'sends the content over HTTPS' do
        io = described_class.new("#{url}/s3", 'PUT', {}, OpenSSL::SSL::VERIFY_NONE)
        io.write(sent_body)
        io.flush
        io.close
        @received_body_io.rewind
        received_body = @received_body_io.read
        expect(received_body).to eq(sent_body)
      end

      it 'follows redirections and sends body twice' do
        io = described_class.new("#{url}/putreport", 'PUT')
        io.write(sent_body)
        io.flush
        io.close
        @received_body_io.rewind
        received_body = @received_body_io.read
        expect(received_body).to eq("#{sent_body}#{sent_body}")
      end

      it 'only sends body once' do
        io = described_class.new("#{url}/putreport", 'GET')
        io.write(sent_body)
        io.flush
        io.close
        @received_body_io.rewind
        received_body = @received_body_io.read
        expect(received_body).to eq(sent_body)
      end

      it 'does not send headers to 2nd PUT request' do
        io = described_class.new("#{url}/putreport", 'GET', { Authorization: 'Bearer abcdefg' })
        io.write(sent_body)
        io.flush
        io.close
        expect(@received_headers[0]['authorization']).to eq(['Bearer abcdefg'])
        expect(@received_headers[1]['authorization']).to eq([])
      end

      it 'reports the body of the response to the reporter' do
        reporter = DummyReporter.new
        allow(reporter).to receive(:report)

        io = described_class.new("#{url}/putreport", 'GET', {}, nil, reporter)
        io.write(sent_body)
        io.flush
        io.close

        expect(reporter).to have_received(:report).with(success_banner)
      end

      it 'reports the body of the response to the reporter when request failed' do
        reporter = DummyReporter.new
        allow(reporter).to receive(:report)

        begin
          io = described_class.new("#{url}/401", 'GET', {}, nil, reporter)
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
          io = described_class.new("#{url}/putreport", 'GET')
          io.write(sent_body)
          io.flush
          io.close
          @received_body_io.rewind
          received_body = @received_body_io.read
          expect(received_body).to eq('')
        end
      end
    end
  end
end
