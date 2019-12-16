# frozen_string_literal: true

require 'cucumber/hooks'

module Cucumber
  class Runtime
    class BeforeHooks
      def initialize(hooks, scenario, id_generator)
        @hooks = hooks
        @scenario = scenario
        @id_generator = id_generator
      end

      def apply_to(test_case)
        test_case.with_steps(
          before_hooks + test_case.test_steps
        )
      end

      private

      def before_hooks
        @hooks.map do |hook|
          action_block = ->(result) { hook.invoke('Before', @scenario.with_result(result)) }
          Hooks.before_hook(@id_generator.new_id, hook, &action_block)
        end
      end
    end
  end
end
