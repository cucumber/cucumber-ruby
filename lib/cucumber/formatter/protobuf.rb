# Messages used by JSON formatter
# messages.Envelope_GherkinDocument
# messages.Envelope_Pickle
# messages.Envelope_TestStepMatched
# messages.Envelope_TestStepFinished

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

        config.on_event :pickle, &method(:on_pickle)


        config.on_event :gherkin_source_parsed, &method(:on_gherkin_source_parsed)
        config.on_event :gherkin_source_read, &method(:on_gherkin_source_read)
        config.on_event :step_activated, &method(:on_step_activated)
        config.on_event :step_definition_registered, &method(:on_step_definition_registered)
        config.on_event :test_case_finished, &method(:on_test_case_finished)
        config.on_event :test_case_started, &method(:on_test_case_started)
        config.on_event :test_run_finished, &method(:on_test_run_finished)
        config.on_event :test_run_started, &method(:on_test_run_started)
        config.on_event :test_step_finished, &method(:on_test_step_finished)
        config.on_event :test_step_started, &method(:on_test_step_started)
      end

      def on_gherkin_source_parsed(event)
        Cucumber::Messages::Envelope.new(
          gherkinDocument: event.gherkin_document
        ).write_delimited_to(@io)
      end

      def on_pickle(event)
        pickle_by_test_case[event.test_case] = event.pickle

        Cucumber::Messages::Envelope.new(
          pickle: event.pickle
        ).write_delimited_to(@io)
      end

      def on_gherkin_source_read(event)
      end

      def on_step_activated(event)
      end

      def on_step_definition_registered(event)
      end

      def on_test_case_finished(event)
        Cucumber::Messages::Envelope.new(
          testCaseFinished:EventToProtobuf.test_case_finished(event)
        ).write_delimited_to(@io)
      end

      def on_test_case_started(event)
        event.test_case.test_steps.reject(&:hook?).each_with_index do |step, step_index|
          test_case_by_test_step[step] = event.test_case
          test_step_index[step] = step_index
        end
        # @io.write("Got event test_case_started with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end

      def on_test_step_finished(event)
        return if event.test_step.hook?

        test_case = test_case_by_test_step[event.test_step]
        pickle_id = pickle_by_test_case[test_case].id
        step_index = test_step_index[event.test_step]

        Cucumber::Messages::Envelope.new(
          testStepFinished:EventToProtobuf.test_step_finished(event, pickle_id, step_index)
        ).write_delimited_to(@io)
      end

      def on_test_run_finished(event)
        # @io.write("Got event test_run_finished with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end

      def on_test_run_started(event)
      end

      def on_test_step_started(event)
        # @io.write("Got event test_step_started with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end

      def pickle_by_test_case
        @pickle_by_test_case ||= {}
      end

      def test_case_by_test_step
        @test_case_by_test_step ||= {}
      end

      def test_step_index
        @test_step_index ||= {}
      end
    end

    class EventToProtobuf
      def self.test_step_finished(event, pickle_id, index)
        Cucumber::Messages::TestStepFinished.new(
          pickleId: pickle_id,
          index: index,
          testResult: self.test_result(event.result),
          timestamp: self.timestamp
        )
      end

      def self.test_case_finished(event)
        # Cucumber::Messages::TestCaseFinished.new(
        #   pickleId: "some.pickle.id",
        #   timestamp: self.timestamp,
        #   testResult: self.test_result(event.result)
        # )
      end

      def self.test_result(result)
        message_data = {
          message: "",
          duration: self.nanos_to_duration(result.duration.nanoseconds)
        }

        case result
        when Cucumber::Core::Test::Result::Unknown
          message_data[:status] = :UNKNOWN
        when Cucumber::Core::Test::Result::Passed
          message_data[:status] = :PASSED
        when Cucumber::Core::Test::Result::Skipped
          message_data[:status] = :SKIPPED
        when Cucumber::Core::Test::Result::Pending
          message_data[:status] = :PENDING
        when Cucumber::Core::Test::Result::Undefined
          message_data[:status] = :UNDEFINED
        when Cucumber::Core::Test::Result::Failed
          message_data[:status] = :FAILED
          message_data[:message] = result.exception.to_s
        end

        Cucumber::Messages::TestResult.new(**message_data)
      end

      def self.nanos_to_duration(nanos)
        seconds = (nanos / 10 ** 9).to_i
        nanos = nanos - (seconds * (10 ** 9))

        Cucumber::Messages::Duration.new(
          seconds: seconds,
          nanos: nanos
        )
      end

      def self.timestamp
        # Note: this is probably horribly wrong ...

        now = Time.now
        Cucumber::Messages::Timestamp.new(
          seconds: now.to_i,
          nanos: (now.to_f.modulo(1) * 10**9).to_i
        )
      end
    end
  end
end

