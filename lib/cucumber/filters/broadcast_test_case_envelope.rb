require 'cucumber/messages'

module Cucumber
  module Filters
    class BroadcastTestCaseEnvelope < Core::Filter.new(:config)
      def test_case(test_case)
        config.notify :envelope, test_case.to_envelope
        test_case.describe_to(receiver)
      end
    end
  end
end
