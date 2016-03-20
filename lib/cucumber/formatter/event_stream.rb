module Cucumber
  module Formatter
    class EventStream
      PROTOCOL_VERSION = "0.0.1"

      def initialize(config)
        @config = config
        set_up_event_handlers
      end

      private

      def on(event_name, &block)
        @config.on_event(event_name, &block)
      end

      def emit(event_data)
        @config.out_stream.puts(event_data.to_json)
      end

      def set_up_event_handlers
        on(:test_run_started) do
         emit({
            event: "TestRunStarted",
            protocol_version: PROTOCOL_VERSION
          })
        end

        on(:gherkin_source_read) do |event|
          emit({
            event: "GherkinSourceRead",
            id: "#{event.path}:1",
            source: event.source
          })
        end

        on(:before_test_case) do |event|
          emit({
            event: "TestCaseStarted",
            id: event.test_case.location
          })
        end

        on(:before_test_step) do |event|
          emit({
            event: "TestStepStarted",
            id: event.test_step.location
          })
        end

        on(:after_test_step) do |event|
          event_builder = TestStepResultEvent.new(@config)
          event.result.describe_to event_builder, event.test_step
          emit(event_builder)
        end

        on(:after_test_case) do |event|
          event_builder = TestCaseResultEvent.new(@config)
          event.result.describe_to event_builder, event.test_case
          emit(event_builder)
        end

        on(:finished_testing) do
          emit({
            event: "TestRunFinished"
          })
        end
      end

      class TestStepResultEvent
        def initialize(config)
          @config = config
          @data = {}
        end

        def passed(test_step)
          data[:event] = "TestStepPassed"
          data[:id] = test_step.location
        end

        def failed(test_step)
          data[:event] = "TestStepPassed"
          data[:id] = test_step.location
        end

        def duration(duration, test_step)
          data[:duration] = duration.nanoseconds
        end

        def exception(exception, test_case)
          data[:error_summary] = exception.message
          data[:error_detail] = exception.backtrace
        end

        def to_json
          data.to_json
        end

        private

        attr_reader :data
        private :data

        def emit(event_data)
          @config.out_stream.puts(event_data.to_json)
        end
      end

      class TestCaseResultEvent
        def initialize(config)
          @config = config
          @data = {}
        end

        def passed(test_step)
          data[:event] = "TestCasePassed"
          data[:id] = test_step.location
        end

        def failed(test_step)
          data[:event] = "TestCasePassed"
          data[:id] = test_step.location
        end

        def duration(duration, test_step)
          data[:duration] = duration.nanoseconds
        end

        def to_json
          data.to_json
        end

        private

        attr_reader :data
        private :data

        def emit(event_data)
          @config.out_stream.puts(event_data.to_json)
        end
      end

    end
  end
end
