require 'cucumber/step_argument'

module Cucumber
  module WireSupport
    module WireProtocol
      def step_matches(name_to_match, name_to_report)
        raw_response = call_remote(:step_matches, 
          :name_to_match => name_to_match)
        
        raw_response.params.map do |raw_step_match|
          step_definition = WireStepDefinition.new(raw_step_match['id'], self)
          step_args = raw_step_match['args'].map do |raw_arg|
            StepArgument.new(raw_arg['val'], raw_arg['pos'])
          end
          StepMatch.new(step_definition, name_to_match, name_to_report, step_args)
        end
      end
      
      def invoke(step_definition_id, args)
        raw_response = call_remote(:invoke, 
          :id   => step_definition_id, 
          :args => args)
      end
      
      def begin_scenario
        raw_response = call_remote(:begin_scenario)
      end

      def end_scenario
        raw_response = call_remote(:end_scenario)
      end
    end
  end
end