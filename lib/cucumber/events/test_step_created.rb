# frozen_string_literal: true

require_relative 'base_event_new'

module Cucumber
  module Events
    # Event fired when a TestStep is created from a PickleStep
    class TestStepCreated < BaseEventNew
      attr_reader :test_step, :pickle_step

      def self.event_id
        :test_step_created
      end

      def initialize(test_step, pickle_step)
        @test_step = test_step
        @pickle_step = pickle_step
        super()
      end
    end
  end
end
