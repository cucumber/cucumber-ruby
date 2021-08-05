# frozen_string_literal: true

require 'cucumber/core/filter'

# The following fake objects was previously declared within `describe` scope.
# Declaring into scope did not isolate them.
#
# Moving those into a dedicated support file explitely state that those are available
# globaly as soon as they are required once.

module FakeObjects
  module ModuleOne
    def method_one
      1
    end
  end

  module ModuleMinusOne
    def method_one
      -1
    end
  end

  module ModuleTwo
    def method_two
      2
    end
  end

  module ModuleThree
    def method_three
      3
    end
  end

  class ClassOne
  end

  class Actor
    attr_accessor :name

    def initialize(name)
      @name = name
    end
  end

  class FlakyStepActions < ::Cucumber::Core::Filter.new
    def test_case(test_case)
      failing_test_steps = test_case.test_steps.map do |step|
        step.with_action { raise Failure }
      end
      passing_test_steps = test_case.test_steps.map do |step|
        step.with_action {}
      end

      test_case.with_steps(failing_test_steps).describe_to(receiver)
      test_case.with_steps(passing_test_steps).describe_to(receiver)
    end
  end
end
