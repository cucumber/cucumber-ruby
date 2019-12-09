require 'cucumber/messages'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format protobuf</tt>
    class Protobuf
      include Console
      include Io
      attr_reader :config, :current_feature_uri

      def initialize(config)
        @config = config
        @io = ensure_io(config.out_stream)
        config.on_event :envelope, &method(:on_envelope)
      end

      def on_envelope(message)
        message.envelope.write_ndjson_to(@io)
      end
    end
  end
end
