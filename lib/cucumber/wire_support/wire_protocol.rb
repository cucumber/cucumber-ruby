require 'cucumber/step_argument'

module Cucumber
  module WireSupport
    module WireProtocol
      def step_matches(step_name, formatted_step_name)
        raw_response = call_remote(:step_matches, 
          :step_name           => step_name)
          
        raw_response.args.map do |raw_step_match|
          step_definition = WireStepDefinition.new(raw_step_match['id'], self)
          args = raw_step_match['args'].map do |raw_arg|
            StepArgument.new(raw_arg['val'], raw_arg['pos'])
          end
          StepMatch.new(step_definition, step_name, formatted_step_name, args)
        end
      end
      
      def invoke(step_definition_id, args)
        raw_response = call_remote(:invoke, 
          :id   => step_definition_id, 
          :args => args)
        
        return if raw_response.message == 'success'
        raise WireException.new(raw_response.args)
      end

    end
  end
end