# frozen_string_literal: true

module Cucumber
  module Events
    class TestRunHookFinished < Base
      attr_reader :hook, :test_result

      def self.event_id
        :test_run_hook_finished
      end

      def initialize(hook, test_result)
        @hook = hook
        @test_result = test_result
        super()
      end
    end
  end
end
