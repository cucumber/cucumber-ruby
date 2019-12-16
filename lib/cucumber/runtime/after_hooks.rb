# frozen_string_literal: true

module Cucumber
  class Runtime
    class AfterHooks
      def initialize(hooks, scenario, id_generator)
        @hooks = hooks
        @scenario = scenario
        @id_generator = id_generator
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
          Hooks.after_hook(@id_generator.new_id, hook, &action)
        end
      end
    end
  end
end
