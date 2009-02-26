require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Scenario
      include FeatureElement
      
      def initialize(background, comment, tags, line, keyword, name, steps)
        @background, @comment, @tags, @line, @keyword, @name = background, comment, tags, line, keyword, name
        attach_steps(steps)
        
        if @background
          @steps = @background.step_collection(steps.map{|step| step.step_invocation})
        else
          @steps = StepCollection.new(steps.map{|step| step.step_invocation})
        end
      end

      def feature=(feature)
        @feature = feature
        @background.feature = feature if @background
      end

      def descend?(visitor)
        visitor.matches_lines?(self) &&
        visitor.included_by_tags?(self) &&
        !visitor.excluded_by_tags?(self) &&
        visitor.matches_scenario_names?(self)
      end

      def visit(visitor)
        visitor.step_mother.execute_scenario(self) do
          # TODO: visit background if we're the first. Otherwise just execute it. Skip if nil
          if @background
            @background.visit_if_first(visitor, self)
          end
          visitor.visit_feature_element(self)
        end
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(text_length))
        visitor.visit_steps(@steps)
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
