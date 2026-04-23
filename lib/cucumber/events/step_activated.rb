# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired when a step is activated
    class StepActivated < BaseEventNew
      # The test step that was matched.
      #   @return [Cucumber::Core::Test::Step]
      attr_reader :test_step

      # Information about the matching definition.
      #   @return [Cucumber::StepMatch]
      attr_reader :step_match

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :step_activated
      end

      def initialize(test_step, step_match)
        @test_step = test_step
        @step_match = step_match
        super()
      end
    end
  end
end
