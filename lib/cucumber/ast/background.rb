module Cucumber
  module Ast
    # Represents the background node which contains any background steps and all the feature elements.
    class Background

      attr_accessor :world
      attr_writer :feature_elements, :feature
      attr_reader :status

      def initialize(comment = Ast::Comment.new(""), line=0, keyword="", steps=[])
        @comment, @line, @keyword = comment, line, keyword
        steps.each {|step| step.scenario = self}
        @steps = steps
        @record_executed_steps = true
        @status = :passed
      end

      def accept(visitor)
        @feature_elements.each do |feature_element|
          if @feature.visit?(feature_element)
            visit_background_and_feature_element(visitor, feature_element)
          end
        end
      end

      def already_visited_steps?
        @steps_visited
      end
      
      def undefined?
        @steps.empty?
      end
            
      def matches_scenario_names?(scenario_names)
        @feature_elements.detect{|e| e.matches_scenario_names?(scenario_names)}
      end

      def tagged_with?(tag_names, check_elements=true)
        @feature.tagged_with?(tag_names, false) || 
        (check_elements && @feature_elements.detect{|e| e.tagged_with?(tag_names)})
      end

      def step_executed(step)
        @feature.step_executed(step) if @feature && @record_executed_steps
      end

      def text_length
        @keyword.jlength
      end

      def source_indent(text_length)
        max_line_length - text_length
      end

      def max_line_length
        lengths = (@steps + [self]).map{|e| e.text_length}
        lengths.max
      end
       
      def file_line(line = @line)
        @feature.file_line(line) if @feature
      end

      def backtrace_line(name = "#{@keyword} #{@name}", line = @line)
        @feature.backtrace_line(name, line) if @feature
      end

      def to_sexp #:nodoc:
        if undefined?
          sexp = @feature_elements.map{|e| e.to_sexp}          
        else
          sexp = [:background, @line, @keyword] 
          comment = @comment.to_sexp
          sexp += [comment] if comment
          steps = @steps.map{|step| step.to_sexp}
          sexp += steps if steps.any?
          sexp += @feature_elements.map{|e| e.to_sexp}
          [sexp]
        end
      end
      
      private

      def visit_background_and_feature_element(visitor, feature_element)
        visitor.world(self) do |world|
          @world = world
          unless undefined?
            if already_visited_steps?
              @status = execute_steps(visitor)
            else
              @status = visit_background_and_steps(visitor)
              @steps_visited = true
            end
          end
          visitor.visit_feature_element(feature_element)
        end
      end

      def visit_background_and_steps(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), source_indent(text_length))

        previous = :passed
        @steps.each do |step|
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
            visit_background_and_steps(visitor)
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
