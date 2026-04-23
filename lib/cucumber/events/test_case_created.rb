# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired when a Test::Case is created from a Pickle
    class TestCaseCreated < BaseEventNew
      attr_reader :test_case, :pickle

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :test_case_created
      end

      def initialize(test_case, pickle)
        @test_case = test_case
        @pickle = pickle
        super()
      end
    end
  end
end
