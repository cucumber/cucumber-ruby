require 'cucumber/core/filter'
require 'cucumber/step_match'

module Cucumber
  module Filters
    class ActivateSteps < Core::Filter.new(:step_definitions, :configuration)

      def test_case(test_case)
        CaseFilter.new(test_case, step_definitions, configuration).test_case.describe_to receiver
      end

      class CaseFilter
        def initialize(test_case, step_definitions, configuration)
          @original_test_case = test_case
          @step_definitions = step_definitions
          @configuration = configuration
        end

        def test_case
          @original_test_case.with_steps(new_test_steps)
        end

        private

        def new_test_steps
          @original_test_case.test_steps.map(&self.method(:attempt_to_activate))
        end

        def attempt_to_activate(test_step)
          find_match(test_step).activate(test_step)
        end

        def find_match(test_step)
          match = @step_definitions.find_match(test_step)
          return NoStepMatch.new(test_step.source.last, test_step.name) unless match
          return SkippingStepMatch.new if @configuration.dry_run?
          match
        end
      end
    end
  end
end
