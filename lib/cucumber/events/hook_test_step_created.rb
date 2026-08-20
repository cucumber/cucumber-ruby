# frozen_string_literal: true

module Cucumber
  module Events
    # Event fired when a step is created from a hook
    class HookTestStepCreated < Core::Event::Base
      attr_reader :test_step, :hook

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
