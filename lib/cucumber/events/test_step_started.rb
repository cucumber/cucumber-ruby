# frozen_string_literal: true

module Cucumber
  module Events
    # Signals that a {Cucumber::Core::Test::Step} is about to be executed
    class TestStepStarted < Core::Event::Base
      # @return [Cucumber::Core::Test::Step] the test step to be executed
      attr_reader :test_step

      def self.event_id
        :test_step_started
      end

      def initialize(test_step)
        @test_step = test_step
        super()
      end
    end
  end
end
