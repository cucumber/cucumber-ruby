# frozen_string_literal: true

require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format message</tt>
    class Message
      include Io

      def initialize(config)
        @config = config
        @io = ensure_io(config.out_stream)
        config.on_event :envelope, &method(:on_envelope)
      end

      def on_envelope(event)
        event.envelope.write_ndjson_to(@io)
      end
    end
  end
end
