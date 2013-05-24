module Cucumber
  module Ast
    # Holds an Array of StepInvocation objects
    class StepInvocations
      include Enumerable

      def initialize(steps)
        @steps = steps
        @steps.each do |step|
          step.step_collection = self
        end
      end

      def accept(visitor)
        visitor.visit_steps(self) do
          @steps.each do |step|
            step.accept(visitor)
          end
        end
      end

      def each(&proc)
        @steps.each(&proc)
      end

      def max_line_length(feature_element)
        lengths = (@steps + [feature_element]).map{|e| e.text_length}
        lengths.max
      end

      def skip_invoke!
        @steps.each{ |step_invocation| step_invocation.skip_invoke! }
      end

      def +(step_invocations)
        dup(step_invocations)
      end

      # Duplicates this instance and adds +step_invocations+ to the end
      def dup(step_invocations = [])
        StepInvocations.new(@steps + step_invocations)
      end

      def exception
        @exception ||= ((failed = @steps.detect {|step| step.exception}) && failed.exception)
      end

      def status
        @steps.each do |step_invocation| 
          return step_invocation.status if step_invocation.status != :passed
        end
        :passed
      end

      def failed?
        status == :failed
      end

      def previous_step(step)
        i = @steps.index(step) || -1
        @steps[i-1]
      end

      def length
        @steps.length
      end

      def to_sexp
        @steps.map{|step| step.to_sexp}
      end
    end
  end
end
