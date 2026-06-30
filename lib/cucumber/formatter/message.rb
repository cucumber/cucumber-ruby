# frozen_string_literal: true

require_relative 'io'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format message</tt>
    class Message
      include Io

      def initialize(config)
        @io = ensure_io(config.out_stream, config.error_stream)
        config.on_event :envelope, &method(:output_envelope)
      end

      def output_envelope(event)
        envelope = event.envelope
        @io.write(envelope.to_json)
        @io.write("\n")
      end
    end
  end
end
