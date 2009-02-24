require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    # Represents the background node which contains any background steps and all the feature elements.
    class Background
      include FeatureElement

      attr_writer :feature_elements
      attr_reader :status

      def initialize(comment = Ast::Comment.new(""), line=0, keyword="", steps=[])
        @comment, @line, @keyword, @steps = comment, line, keyword, steps
        attach_steps(steps)

        @status = :passed
        @name = "" # TODO: send it in
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

      def matches_tags?(tag_names, check_elements=true)
        @feature.matches_tags?(tag_names, false) || 
        (check_elements && @feature_elements.detect{|e| e.matches_tags?(tag_names)})
      end

      def source_indent(text_length)
        max_line_length - text_length
      end

      def max_line_length
        lengths = (@steps + [self]).map{|e| e.text_length}
        lengths.max
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
        visitor.step_mother.new_world! do
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
        visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(text_length))

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
          @steps_visited = false
          #Since the steps have already been executed they will not be re-run, they will just be displayed
          visit_background_and_steps(visitor)
        end

        previous
      end
    end
  end
end
