require 'cucumber/core/filter'
require 'cucumber/ast/facade'
require 'cucumber/hooks'

module Cucumber
  module Filters

    class PrepareWorld < Core::Filter.new(:runtime)

      def test_case(test_case)
        CaseFilter.new(runtime, test_case).test_case.describe_to receiver
      end

      class CaseFilter
        def initialize(runtime, original_test_case)
          @runtime, @original_test_case = runtime, original_test_case
        end

        def test_case
          init_scenario = Cucumber::Hooks.before_hook(@original_test_case.source) do
            @runtime.begin_scenario(scenario)
          end
          steps = [init_scenario] + @original_test_case.test_steps
          @original_test_case.with_steps(steps)
        end

        private

        def scenario
          @scenario ||= Ast::Facade.new(test_case).build_scenario
        end
      end

    end

  end
end
