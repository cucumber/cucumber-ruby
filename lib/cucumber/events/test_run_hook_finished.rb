# frozen_string_literal: true

require 'cucumber/core/events'

module Cucumber
  module Events
    class TestRunHookFinished < Core::Event.new(:hook, :test_result)
      attr_reader :hook, :test_result
    end
  end
end
