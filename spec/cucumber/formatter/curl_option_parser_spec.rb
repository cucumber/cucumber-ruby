# frozen_string_literal: true

require 'stringio'
require 'webrick'
require 'webrick/https'
require 'spec_helper'
require 'cucumber/formatter/io'
require 'support/shared_context/http_server'

describe Cucumber::Formatter::CurlOptionParser do
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
