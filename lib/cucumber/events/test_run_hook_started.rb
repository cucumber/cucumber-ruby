# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    class TestRunHookStarted < Core::Event.new(:hook)
      attr_reader :hook
    end
  end
end
