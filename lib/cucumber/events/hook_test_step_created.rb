# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired when a step is created from a hook
    class HookTestStepCreated < Core::Event.new(:test_step, :hook)
      attr_reader :test_step, :hook
    end
  end
end
