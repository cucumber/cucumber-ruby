# frozen_string_literal: true

module Cucumber
  class Runtime
    class AfterHooks
      def initialize(hooks, scenario)
        @hooks = hooks
        @scenario = scenario
      end

      def apply_to(test_case)
        test_case.with_steps(
          test_case.test_steps + after_hooks.reverse
        )
      end

      private

      def after_hooks
        @hooks.map do |hook|
          action = ->(result) { hook.invoke('After', @scenario.with_result(result)) }
          Hooks.after_hook(hook.location, &action)
        end
      end
    end
  end
end
