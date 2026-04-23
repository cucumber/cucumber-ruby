# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired when a step is created from a hook
    class HookTestStepCreated < BaseEventNew
      attr_reader :test_step, :hook

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :hook_test_step_created
      end

      def initialize(test_step, hook)
        @test_step = test_step
        @hook = hook
        super()
      end
    end
  end
end
