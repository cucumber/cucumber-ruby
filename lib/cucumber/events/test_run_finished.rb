require 'cucumber/core/events'

module Cucumber
  module Events

    # Event fired after aall test cases have finished executing
    TestRunFinished = Class.new(Core::Event.new)

  end
end
