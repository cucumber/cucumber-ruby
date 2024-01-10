# frozen_string_literal: true

module CCK
  module Helpers
    def message_type(message)
      message.to_h.each do |key, value|
        return key unless value.nil?
      end
    end

    def parse_ndjson_file(path)
      parse_ndjson(File.read(path))
    end

    def parse_ndjson(ndjson)
      Cucumber::Messages::NdjsonToMessageEnumerator.new(ndjson)
    end
  end
end
