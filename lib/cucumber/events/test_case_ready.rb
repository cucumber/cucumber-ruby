# frozen_string_literal: true

module Cucumber
  module Events
    class TestCaseReady < Base
      attr_reader :test_case

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
