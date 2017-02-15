require 'securerandom'

module Cucumber
  module Formatter
    class EventStream

      def initialize(config)
        @config, @io = config, config.out_stream
        @series = SecureRandom.uuid
        write_event type: "start"
        config.on_event :test_run_starting, -> (event) {
          write_event \
            type: "test-run-starting",
            testCases: event.test_cases.map(&:location)
        }
        config.on_event :test_case_finished, -> (event) {
          write_event \
            type: "test-case-finished", 
            location: event.test_case.location,
            result: {
              status: event.result.to_sym.to_s
              duration: event.result.duration
            }
        }
      end

      private

      def write_event(attributes)
        data = attributes.merge({
          series: @series,
          timestamp: Time.now.to_i
        })
        @io.puts data.to_json
      end
    end
  end
end

