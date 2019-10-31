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

        config.on_event :test_case_started, &method(:on_test_case_started)
        config.on_event :test_case_finished, &method(:on_test_case_finished)
        config.on_event :test_step_started, &method(:on_test_step_started)
        config.on_event :test_step_finished, &method(:on_test_step_finished)
        config.on_event :test_run_finished, &method(:on_test_run_finished)
      end

      def on_test_case_started(event)
        # @io.write("Got event test_case_started with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end

      def on_test_step_started(event)
        # @io.write("Got event test_step_started with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end

      def on_test_step_finished(event)
        @io.write EventToProtobuf.test_step_finished(event).to_proto
      end

      def on_test_case_finished(event)
        @io.write EventToProtobuf.test_case_finished(event).to_proto
      end

      def on_test_run_finished(event)
        # @io.write("Got event test_run_finished with:\n")
        # @io.write event.inspect
        # @io.write "\n"
      end
    end

    class EventToProtobuf
      def self.test_step_finished(event)
        Cucumber::Messages::TestStepFinished.new(
          pickleId: "some.pickle.id",
          index: 1,
          testResult: self.test_result(event.result),
          timestamp: self.timestamp
        )
      end

      def self.test_case_finished(event)
        Cucumber::Messages::TestCaseFinished.new(
          pickleId: "some.pickle.id",
          timestamp: self.timestamp,
          testResult: self.test_result(event.result)
        )
      end

      def self.test_result(result)
        Cucumber::Messages::TestResult.new(
          status: :FAILED,
          message: "Everything fails ....",
          duration: self.nanos_to_duration(result.duration.nanoseconds)
        )
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

