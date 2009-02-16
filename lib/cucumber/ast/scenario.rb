require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Scenario
      include FeatureElement
      attr_writer :background
      
      def initialize(comment, tags, line, keyword, name, steps)
        @comment, @tags, @line, @keyword, @name = comment, tags, line, keyword, name
        attach_steps(steps)
        @steps = StepCollection.new(steps.map{|step| step.step_invocation})
      end

      def matches_scenario_names?(scenario_names)
        scenario_names.detect{|name| @name == name}
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), source_indent(text_length))
        visitor.visit_steps(@steps)

        visitor.step_mother.scenario_executed(self) unless @executed
        @executed = true
      end

      def to_sexp
        sexp = [:scenario, @line, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp
      end

    end
  end
end
