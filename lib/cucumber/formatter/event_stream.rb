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

        on(:step_match) do
          emit({
            event: "StepDefinitionMatched",
          })
        end

        on(:test_case_starting) do |event|
          emit({
            event: "TestCaseStarted",
            id: event.test_case.location
          })
        end

        on(:test_step_starting) do |event|
          emit({
            event: "TestStepStarted",
            id: event.test_step.location
          })
        end

        on(:test_step_finished) do |test_step, result|
          event_builder = TestStepResultEvent.new(@config)
          result.describe_to event_builder, test_step
          emit(event_builder)
        end

        on(:test_case_finished) do |test_case, result|
          event_builder = TestCaseResultEvent.new(@config)
          result.describe_to event_builder, test_case
          emit(event_builder)
        end

        on(:test_run_finished) do
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
