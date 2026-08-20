# frozen_string_literal: true

module Cucumber
  module Events
    class TestRunHookStarted < Core::Event::Base
      attr_reader :hook

      def self.event_id
        :test_run_hook_started
      end

      def initialize(hook)
        @hook = hook
        super()
      end
    end
  end
end
