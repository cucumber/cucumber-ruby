require 'cucumber/messages'

module Cucumber
  module Filters

    class BroadcastTestCaseEnvelope < Core::Filter.new(:config)
      def test_case(test_case)
        config.notify :envelope, Cucumber::Messages::Envelope.new(
          testCase: Cucumber::Messages::TestCase.new(
            id: test_case.id,
            testSteps: test_case.test_steps.map { |step| test_step_to_message(step) }
          )
        )
        self
      end

      private

      def test_step_to_message(test_step)
        Cucumber::Messages::TestCase::TestStep.new(
          id: test_step.id,
          hookId: test_step.hook? ? "123" : nil,
          pickleStepId: test_step.hook? ? nil : "456"
        )
      end
    end
  end
end