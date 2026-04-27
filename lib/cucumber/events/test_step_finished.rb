# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Events
    # Signals that a {Cucumber::Core::Test::Step} has finished executing
    class TestStepFinished < Base
      # @return [Cucumber::Core::Test::Step] the test step that was executed
      attr_reader :test_step

      # @return [Cucumber::Core::Test::Result] the result of running the {Cucumber::Core::Test::Step}
      attr_reader :result

      def self.event_id
        :test_step_finished
      end

      def initialize(test_step, result)
        @test_step = test_step
        @result = result
        super()
      end
    end
  end
end
