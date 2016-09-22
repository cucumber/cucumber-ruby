# frozen_string_literal: true
module Cucumber
  module Formatter
    module LegacyApi

      class Results
        def initialize
          # Optimization - quicker lookup.
          @inserted_steps = {}
          @inserted_scenarios = {}
        end

        def step_visited(step) #:nodoc:
          step_id = step.object_id

          return if @inserted_steps.key?(step_id)
          @inserted_steps[step_id] = step
          steps.push(step)
        end

        def scenario_visited(scenario) #:nodoc:
          scenario_id = scenario.object_id

          return if @inserted_scenarios.key?(scenario_id)
          @inserted_scenarios[scenario_id] = scenario
          scenarios.push(scenario)
        end

        def steps(status = nil) #:nodoc:
          @steps ||= []
          if(status)
            @steps.select{|step| step.status == status}
          else
            @steps
          end
        end

        def scenarios(status = nil) #:nodoc:
          @scenarios ||= []
          if(status)
            @scenarios.select{|scenario| scenario.status == status}
          else
            @scenarios
          end
        end
      end

    end
  end
end
