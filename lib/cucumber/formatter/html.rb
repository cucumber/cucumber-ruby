# frozen_string_literal: true

require 'cucumber/query'
require 'cucumber/html_formatter'

require_relative 'io'

module Cucumber
  module Formatter
    class HTML
      include Io

      def initialize(config)
        @io = ensure_io(config.out_stream, config.error_stream)
        @repository = Cucumber::Repository.new
        @query = Cucumber::Query.new(@repository)
        @html_formatter = Cucumber::HTMLFormatter::Formatter.new(@io)
        @html_formatter.write_pre_message
        config.on_event :envelope, &method(:output_envelope)
      end

      def output_envelope(envelope)
        @repository.update(envelope)
        @html_formatter.write_message(envelope)
        @html_formatter.write_post_message if envelope.test_run_finished
      end
    end
  end
end
