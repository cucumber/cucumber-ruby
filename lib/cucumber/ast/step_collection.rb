module Cucumber
  module Ast
    # Holds an Array of Step or StepDefinition
    class StepCollection #:nodoc:
      include Enumerable

      def initialize(steps)
        @steps = steps
        @steps.each{|step| step.step_collection = self}
      end

      def accept(visitor)
        visitor.visit_steps(self) do
          @steps.each do |step|
            step.accept(visitor)
          end
        end
      end

      def step_invocations(background = false)
        StepInvocations.new(@steps.map{ |step|
          i = step.step_invocation
          i.background = background
          i
        })
      end

      def step_invocations_from_cells(cells)
        @steps.map{|step| step.step_invocation_from_cells(cells)}
      end

      def each(&proc)
        @steps.each(&proc)
      end

      def max_line_length(feature_element)
        lengths = (@steps + [feature_element]).map{|e| e.text_length}
        lengths.max
      end

      def exception
        @exception ||= ((failed = @steps.detect {|step| step.exception}) && failed.exception)
      end

      def failed?
        status == :failed
      end

      def passed?
        status == :passed
      end

      def status
        @steps.each{|step_invocation| return step_invocation.status if step_invocation.status != :passed}
        :passed
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
