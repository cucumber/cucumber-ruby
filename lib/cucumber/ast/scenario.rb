require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Scenario
      include FeatureElement
      
      def initialize(background, comment, tags, line, keyword, name, steps)
        @background, @comment, @tags, @line, @keyword, @name = background, comment, tags, line, keyword, name
        attach_steps(steps)
        
        step_invocations = steps.map{|step| step.step_invocation}
        if @background
          @steps = @background.step_collection(step_invocations)
        else
          @steps = StepCollection.new(step_invocations)
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

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_colon_line(@line), source_indent(text_length))

        skip = @background && @background.failed?
        skip_invoke! if skip
        visitor.step_mother.before_and_after(self, skip) do
          visitor.visit_steps(@steps)
        end
      end

      def skip_invoke!
        @steps.each{|step_invocation| step_invocation.skip_invoke!}
        @feature.next_feature_element(self) do |next_one|
          next_one.skip_invoke!
        end
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
