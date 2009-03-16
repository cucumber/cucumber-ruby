require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background
      include FeatureElement
      attr_writer :feature

      def initialize(comment, line, keyword, steps)
        @comment, @line, @keyword, @steps = comment, line, keyword, StepCollection.new(steps)
        attach_steps(steps)
        @step_invocations = @steps.step_invocations(true)
      end

      def step_collection(step_invocations)
        unless(@first_collection_created)
          @first_collection_created = true
          @step_invocations.dup(step_invocations)
        else
          @steps.step_invocations(true).dup(step_invocations)
        end
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_background_name(@keyword, "", file_colon_line(@line), source_indent(text_length))
        visitor.step_mother.before_and_after(self)
        visitor.visit_steps(@step_invocations)
        @failed = @step_invocations.detect{|step_invocation| step_invocation.exception}
      end

      def failed?
        @failed
      end

      def text_length
        @keyword.jlength
      end

      def to_sexp
        sexp = [:background, @line, @keyword]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        steps = @steps.to_sexp
        sexp += steps if steps.any?
        sexp
      end
    end
  end
end