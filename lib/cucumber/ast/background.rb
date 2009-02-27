require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background
      include FeatureElement
      attr_writer :feature

      def initialize(comment, line, keyword, steps)
        @comment, @line, @keyword, @steps = comment, line, keyword, StepCollection.new(steps)
        attach_steps(steps)
      end

      def step_collection(step_invocations)
        background_invocations = @steps.map do |step| 
          i = step.step_invocation
          i.background = true
          i
        end
        StepCollection.new(background_invocations + step_invocations)
      end

      def visit_if_first(visitor, scenario)
        if first_scenario?(scenario)
          @first_scenario = scenario
          visitor.visit_background(self)
        end
      end

      def first_scenario?(scenario)
        # If we're using 2 visitors, the 2nd pass will not be nil.
        @first_scenario.nil? || @first_scenario == scenario
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_background_name(@keyword, "", file_colon_line(@line), source_indent(text_length))
        # TODO: Use @first_scenario's background steps instead.
        # We're currently vising steps that won't be used in any scenarios :-/ 
        visitor.visit_steps(@steps.step_invocations)
      end

      def text_length
        @keyword.jlength
      end
    end
  end
end