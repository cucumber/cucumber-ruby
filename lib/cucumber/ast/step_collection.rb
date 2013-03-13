module Cucumber
  module Ast
    # Holds an Array of Step or StepDefinition
    class StepCollection #:nodoc:
      include Enumerable

      def initialize(steps)
        @steps = steps
        @steps.each{|step| step.step_collection = self}
      end

      def inspect
        @steps.map { |s| [s.class, s.object_id] }.join(', ')
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        @steps.each do |step|
          visitor.visit_step(step)
        end
      end

      def step_invocations(background = false)
        StepCollection.new(@steps.map{ |step|
          i = step.step_invocation
          i.background = background
          i
        })
      end

      def skip_invoke!
        @steps.each{|step_invocation| step_invocation.skip_invoke!}
      end

      def step_invocations_from_cells(cells)
        @steps.map{|step| step.step_invocation_from_cells(cells)}
      end

      def +(step_invocations)
        dup(step_invocations)
      end

      # Duplicates this instance and adds +step_invocations+ to the end
      def dup(step_invocations = [])
        StepCollection.new(@steps + step_invocations)
      end

      def each(&proc)
        @steps.each(&proc)
      end

      def previous_step(step)
        i = @steps.index(step) || -1
        @steps[i-1]
      end

      def empty?
        @steps.empty?
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
