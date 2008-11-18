require 'cucumber/formatters/ansicolor'

module Cucumber
  module Formatters
    class AutotestFormatter
      def initialize(io)
        @io = io
        @failed_scenarios = []
      end
      
      def step_didnt_pass(step, regexp, args)
        unless @failed_scenarios.include? step.scenario.name
          @failed_scenarios << step.scenario.name
          @io.puts step.scenario.name
        end
      end
      
      alias step_failed  step_didnt_pass
      alias step_pending step_didnt_pass
      alias step_skipped step_didnt_pass
    end
  end
end
