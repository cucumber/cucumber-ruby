require 'cucumber/core/filter'

module Cucumber
  module Filters
    class ActivateSteps < Core::Filter.new(:step_definitions)

      def test_case(test_case)
        CaseFilter.new(test_case, step_definitions).test_case.describe_to receiver
      end

      class CaseFilter
        def initialize(test_case, step_definitions)
          @original_test_case = test_case
          @step_definitions = step_definitions
        end

        def test_case
          @original_test_case.with_steps(new_test_steps)
        end

        private

        def new_test_steps
          @original_test_case.test_steps.map(&self.method(:attempt_to_activate))
        end

        def attempt_to_activate(test_step)
          @step_definitions.find_match(test_step).activate(test_step)
        end
      end
    end
  end
end
