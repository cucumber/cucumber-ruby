require 'securerandom'
require 'date'

module Cucumber
  module Formatter
    class EventStream
      PROTOCOL_VERSION = "0.0.1"

      def initialize(config)
        @config = config
        @series_id = SecureRandom.uuid
        set_up_event_handlers
      end

      private

      def on(event_name, &block)
        @config.on_event(event_name, &block)
      end

      def emit(event_data)
        @config.out_stream.puts(event_data.to_json)
      end

      def ms_since_epoch
        Integer(DateTime.now.strftime('%Q'))
      end

      def set_up_event_handlers
        on(:test_run_started) do
         emit({
            type: "start",
            timestamp: ms_since_epoch,
            series: @series_id
          })
        end

        on(:gherkin_source_read) do |event|
          emit({
            type: "source",
            timestamp: ms_since_epoch,
            series: @series_id,
            uri: event.path, # TODO: should be uri
            data: event.source,
            media: {
              encoding: "utf-8",
              type: "text/vnd.cucumber.gherkin+plain"
            }
          })
        end
      end
    end
  end
end
