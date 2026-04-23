# frozen_string_literal: true

module Cucumber
  module Events
    class TestCaseReady < BaseEventNew
      attr_reader :test_case

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :test_case_ready
      end

      def initialize(test_case)
        @test_case = test_case
        super()
      end
    end
  end
end
