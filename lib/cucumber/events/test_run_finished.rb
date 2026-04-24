# frozen_string_literal: true

module Cucumber
  module Events
    # Event fired after all test cases have finished executing
    class TestRunFinished < BaseEventNew
      attr_reader :success

      def self.event_id
        :test_run_finished
      end

      def initialize(success = nil)
        @success = success
        super()
      end
    end
  end
end
