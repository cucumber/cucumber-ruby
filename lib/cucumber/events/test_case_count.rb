# coding: utf-8
# frozen_string_literal: true
require 'cucumber/core/events'

module Cucumber
  module Events

    # Event fired once all test cases have been filtered.
    class TestCaseCount < Core::Event.new(:test_cases)

      # @return [Array<Cucumber::Core::Test::Case>] the test cases to be executed
      attr_reader :test_cases
    end

  end
end
