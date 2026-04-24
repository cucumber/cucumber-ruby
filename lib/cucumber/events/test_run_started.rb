# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Events
    # Event fired once all test cases have been filtered before
    # the first one is executed.
    class TestRunStarted < Base
      # @return [Array<Cucumber::Core::Test::Case>] the test cases to be executed
      attr_reader :test_cases

      def self.event_id
        :test_run_started
      end

      def initialize(test_cases)
        @test_cases = test_cases
        super()
      end
    end
  end
end
