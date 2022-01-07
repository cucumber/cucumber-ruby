# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    # Event fired after all test cases have finished executing
    class TestRunFinished < Core::Event.new(:success)
      attr_reader :success
    end
  end
end
