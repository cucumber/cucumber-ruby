require 'cucumber/ast/has_steps'
require 'cucumber/ast/names'
require 'cucumber/ast/location'

module Cucumber
  module Ast
    class Background #:nodoc:
      include HasSteps
      include Names
      include HasLocation
      attr_accessor :feature

      def initialize(language, location, comment, keyword, title, description, raw_steps)
        @language, @location, @comment, @keyword, @title, @description, @raw_steps = language, location, comment, keyword, title, description, raw_steps
        @failed = nil
        @first_collection_created = false
        attach_steps(@raw_steps)
      end

      def feature_elements
        feature.feature_elements
      end

      def step_invocations
        @step_invocations ||= steps.step_invocations(true)
      end

      def step_collection(scenario_step_invocations)
        if(@first_collection_created)
          steps.step_invocations(true).dup(scenario_step_invocations)
        else
          @first_collection_created = true
          step_invocations.dup(scenario_step_invocations)
        end
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_background_name(@keyword, name, file_colon_line, source_indent(first_line_length))
        with_visitor(hook_context, visitor) do
          visitor.runtime.before(hook_context)
          skip_invoke! if failed?
          visitor.visit_steps(step_invocations)
          @failed = step_invocations.any? { |step_invocation| step_invocation.exception || step_invocation.status != :passed }
          visitor.runtime.after(hook_context) if @failed || feature_elements.empty?
        end
      end

      def with_visitor(scenario, visitor)
        @current_visitor = visitor
        if self != scenario && scenario.respond_to?(:with_visitor)
          scenario.with_visitor(visitor) do
            yield
          end
        else
          yield
        end
      end

      def accept_hook?(hook)
        if hook_context != self
          hook_context.accept_hook?(hook)
        else
          # We have no scenarios, just ask our feature
          feature.accept_hook?(hook)
        end
      end

      def skip_invoke!
        step_invocations.each{|step_invocation| step_invocation.skip_invoke!}
      end

      def failed?
        !!@failed
      end

      def hook_context
        feature_elements.first || self
      end

      def to_sexp
        sexp = [:background, line, @keyword]
        sexp += [name] unless name.empty?
        comment = @comment.to_sexp
        sexp += [comment] if comment
        sexp += steps.to_sexp if steps.any?
        sexp
      end

      def fail!(exception)
        @failed = true
        @exception = exception
        @current_visitor.visit_exception(@exception, :failed)
      end

      # Override this method, as there are situations where the background
      # wind up being the one called fore Before scenarios, and
      # backgrounds don't have tags.
      def source_tags
        []
      end

      def source_tag_names
        source_tags.map { |tag| tag.name }
      end

      private

      def steps
        @steps ||= StepCollection.new(@raw_steps)
      end

    end
  end
end
