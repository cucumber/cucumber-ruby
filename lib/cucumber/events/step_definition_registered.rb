# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Events
    # Event fired after each step definition has been registered
    class StepDefinitionRegistered < Base
      # The step definition that was just registered.
      #   @return [RbSupport::RbStepDefinition]
      attr_reader :step_definition

      # The underscored name of the class to be used as the key in an event registry
      #   @return [Symbol]
      def self.event_id
        :step_definition_registered
      end

      def initialize(step_definition)
        @step_definition = step_definition
        super()
      end
    end
  end
end
