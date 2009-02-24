require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Scenario
      include FeatureElement
      
      def initialize(background, comment, tags, line, keyword, name, steps)
        @background, @comment, @tags, @line, @keyword, @name = background, comment, tags, line, keyword, name
        attach_steps(steps)
        @steps = StepCollection.new(steps.map{|step| step.step_invocation})
      end

      def visit(visitor)
        # TODO: visit background if we're the first. Otherwise just execute it. Skip if nil
        visitor.visit_feature_element(self)
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(text_length))
        # TODO: Find a better way to capture errors in Before and After
        visitor.step_mother.execute_scenario(self) do
          visitor.visit_steps(@steps)
        end

        visitor.step_mother.scenario_visited(self)
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
