# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired when a step is created from a hook
    class HookTestStepCreated
      attr_reader :test_step, :hook

      # @return [Symbol] the underscored name of the class to be used as the key in an event registry
      def self.event_id
        :hook_test_step_created
      end

      def initialize(test_step, hook)
        @test_step = test_step
        @hook = hook
      end

      def to_h
        {
          test_step: test_step,
          hook: hook
        }
      end

      def event_id
        self.class.event_id
      end
    end
  end
end
