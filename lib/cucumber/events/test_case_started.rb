# frozen_string_literal: true

require_relative 'base_event_new'

module Cucumber
  module Events
    # Signals that a {Cucumber::Core::Test::Case} is about to be executed
    class TestCaseStarted < BaseEventNew
      # @return [Cucumber::Core::Test::Case] the test case to be executed
      attr_reader :test_case

      def self.event_id
        :test_case_started
      end

      def initialize(test_case)
        @test_case = test_case
        super()
      end
    end
  end
end
