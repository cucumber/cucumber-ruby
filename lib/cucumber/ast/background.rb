require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background
      include FeatureElement

      def initialize(comment, line, keyword, steps)
        @comment, @line, @keyword = comment, line, keyword
        attach_steps(steps)
        @steps = StepCollection.new(steps.map{|step| step.step_invocation})
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_background_name(@keyword, "TODO BG NAME", file_colon_line(@line), source_indent(text_length))

        visitor.visit_steps(@steps)
      end

      def text_length
        20
      end
    end
  end
end