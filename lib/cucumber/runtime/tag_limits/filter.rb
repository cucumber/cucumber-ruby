require "cucumber/runtime/gated_receiver"

module Cucumber
  class Runtime
    module TagLimits
      class Filter
        def initialize(tag_limits, receiver)
          @gated_receiver = GatedReceiver.new(receiver)
          @test_case_index = TestCaseIndex.new
          @verifier = Verifier.new(tag_limits)
        end

        def test_case(test_case)
          gated_receiver.test_case(test_case)
          test_case_index.add(test_case)
        end

        def done
          verifier.verify!(test_case_index)
          gated_receiver.done
        end

        private

        attr_reader :gated_receiver
        attr_reader :test_case_index
        attr_reader :verifier
      end
    end
  end
end
