# frozen_string_literal: true

require 'cucumber/html_formatter'

require_relative 'io'

module Cucumber
  module Formatter
    class HTML
      include Io

      def initialize(config)
        @io = ensure_io(config.out_stream, config.error_stream)
        @html_formatter = Cucumber::HTMLFormatter::Formatter.new(@io)
        @html_formatter.write_pre_message
        config.on_event :envelope, &method(:output_envelope)
      end

      def output_envelope(event)
        envelope = event.envelope
        @html_formatter.write_message(envelope)
        # TODO: Move this conditional logic into the HTML formatter proper
        @html_formatter.write_post_message if envelope.test_run_finished
      end
    end
  end
end
