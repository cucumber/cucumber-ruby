module Cucumber
  module Ast
    class Background < Scenario

      attr_accessor :world
      attr_reader :status

      def initialize(comment, line, keyword, steps)
        @record_executed_steps = true
        super(comment, Tags.new(1, []), line, keyword, "", steps)
      end

      def accept(visitor)
        @world = visitor.new_world
        if already_visited_steps?
          @status = execute_steps(visitor)
        else
          @status = visit_background_and_steps(visitor, @steps)
          @steps_visited = true
        end
      end

      def step_executed(step)
        @feature.step_executed(step) if @feature && @record_executed_steps
      end

      def already_visited_steps?
        @steps_visited
      end

      def to_sexp #:nodoc:
        sexp = [:background, @line, @keyword]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.map{|step| step.to_sexp}
        sexp += steps if steps.any?
        sexp
      end
      
      private

      def visit_background_and_steps(visitor, steps)
        visitor.visit_comment(@comment)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), source_indent(text_length))

        previous = :passed
        steps.each do |step|
          step.previous = previous
          step.world    = @world
          visitor.visit_step(step)
          previous = step.status
        end
        previous
      end
      
      def execute_steps(visitor)
        previous = :passed
        executed_steps = []
        exception = nil
        @steps.each do |step|
          executed_step, previous, _ = step.execute_as_new(@world, previous, visitor, @line)
          executed_steps << executed_step
          exception ||= executed_step.exception
        end
        @steps = executed_steps
        
        if exception && @status != :failed
          without_recording_steps do
            @steps_visited = false
            #Since the steps have already been executed they will not be re-run, they will just be displayed
            visitor.visit_background(self)
          end 
        end

        previous
      end

      def without_recording_steps
        @record_executed_steps = false
        yield
        @record_executed_steps = true
      end

    end
  end
end
