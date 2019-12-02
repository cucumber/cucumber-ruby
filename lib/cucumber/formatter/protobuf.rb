# Messages used by JSON formatter
# messages.Envelope_GherkinDocument
# messages.Envelope_Pickle
# messages.Envelope_TestStepMatched
# messages.Envelope_TestStepFinished

require 'cucumber/messages'
require 'pry'

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

      def on_step_activated(event)
      end

      def on_test_run_started(event)
      end

      def on_test_case_started(event)
      end

      def on_test_step_started(event)
        binding.pry unless event.test_step.is_a?(Cucumber::Core::Test::HookStep)

        # @io.write("Got event test_step_started with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end

      def on_test_step_finished(event)
        Cucumber::Messages::Envelope.new(
          testStepFinished: EventToProtobuf.test_step_finished(event)
        ).write_ndjson_to(@io)
      end

      def on_test_case_finished(event)
        Cucumber::Messages::Envelope.new(
          testCaseFinished: EventToProtobuf.test_case_finished(event)
        ).write_ndjson_to(@io)
      end

      def on_test_run_finished(event)
        # @io.write("Got event test_run_finished with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end
    end

    class EventToProtobuf
      def self.step_definition_registered(event)

      end

      def self.test_step_finished(event)
        Cucumber::Messages::TestStepFinished.new(
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

