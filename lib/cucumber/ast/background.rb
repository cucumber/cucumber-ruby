require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Background
      include FeatureElement
      attr_writer :feature

      def initialize(comment, line, keyword, name, steps)
        @comment, @line, @keyword, @name, @steps = comment, line, keyword, name, StepCollection.new(steps)
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
        visitor.visit_background_name(@keyword, @name, file_colon_line(@line), source_indent(text_length))
        visitor.step_mother.before(self)
        visitor.visit_steps(@step_invocations)
        @failed = @step_invocations.detect{|step_invocation| step_invocation.exception}
        visitor.step_mother.after(self) if @failed
      end

      def accept_hook?(hook)
        # TODO: When background is involved - no tag based hook filtering is occurring with
        # the current implementation. All hooks will be executed. This is because of the line
        #   visitor.step_mother.before(self)
        # in the #accept method above. Instead, we should really be passing the first scenario
        # here. We currently don't have access to that, so a refactoring is in order to make that happen.
        true
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