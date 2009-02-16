module Cucumber
  module Ast
    # Holds an Array of Step or StepDefinition
    class StepCollection
      def initialize(steps)
        @steps = steps
        @steps.each{|step| step.step_collection = self}
      end

      def accept(visitor)
        @steps.each do |step|
          visitor.visit_step(step)
        end
      end

      def step_invocations_from_cells(cells)
        StepCollection.new(@steps.map{|step| step.step_invocation_from_cells(cells)})
      end

      def each_step(&proc)
        @steps.each(&proc)
      end

      def previous_step(step)
        i = @steps.index(step) || -1
        @steps[i-1]
      end

      def at_lines?(lines)
        @steps.detect {|step| step.at_lines?(lines)}
      end

      def empty?
        @steps.empty?
      end

      def max_line_length(feature_element)
        lengths = (@steps + [feature_element]).map{|e| e.text_length}
        lengths.max
      end

      def to_sexp
        @steps.map{|step| step.to_sexp}
      end
    end
  end
end