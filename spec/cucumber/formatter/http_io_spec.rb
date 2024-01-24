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
