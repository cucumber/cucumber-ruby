module Cucumber
  class Runtime
    
    class Results
      def initialize(configuration)
        @configuration = configuration
      end
      
      def step_visited(step) #:nodoc:
        steps << step unless steps.index(step)
      end
      
      def scenario_visited(scenario) #:nodoc:
        scenarios << scenario unless scenarios.index(scenario)
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
      
      def failure?
        if @configuration.wip?
          scenarios(:passed).any?
        else
          scenarios(:failed).any? ||
          (@configuration.strict? && (steps(:undefined).any? || steps(:pending).any?))
        end
      end
    end
    
  end
end