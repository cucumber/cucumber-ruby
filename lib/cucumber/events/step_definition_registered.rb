# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired after each step definition has been registered
    class StepDefinitionRegistered < Core::Event.new(:step_definition)
      # The step definition that was just registered.
      #
      # @return [RbSupport::RbStepDefinition]
      attr_reader :step_definition
    end
  end
end
