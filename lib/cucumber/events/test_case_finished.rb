# frozen_string_literal: true

module Cucumber
  module Events
    # Event fired when a Test::Case is created from a Pickle
    class TestCaseFinished < Base
      # @return [Cucumber::Core::Test::Case] that was executed
      attr_reader :test_case

      # @return [Cucumber::Core::Test::Result] the result of running the {Cucumber::Core::Test::Case}
      attr_reader :result

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :test_case_finished
      end

      def initialize(test_case, result)
        @test_case = test_case
        @result = result
        super()
      end
    end
  end
end
