require 'cucumber/ast/has_steps'
require 'cucumber/ast/names'
require 'cucumber/ast/empty_background'
require 'cucumber/ast/location'
require 'cucumber/unit'

module Cucumber
  module Ast
    class Scenario #:nodoc:
      include HasSteps
      include Names
      include HasLocation

      attr_reader   :feature_tags
      attr_accessor :feature

      def initialize(language, location, background, comment, tags, feature_tags, keyword, title, description, raw_steps)
        @language, @location, @background, @comment, @tags, @feature_tags, @keyword, @title, @description, @raw_steps = language, location, background, comment, tags, feature_tags, keyword, title, description, raw_steps
        @exception = @executed = nil
        attach_steps(@raw_steps)
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit

        visitor.visit_comment(@comment) unless @comment.empty?
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, name, file_colon_line, source_indent(first_line_length))

        skip_invoke! if @background.failed?
        with_visitor(visitor) do
          visitor.execute(self, skip_hooks?)
        end
        @executed = true
      end

      def to_units(background)
        [Unit.new(background.step_invocations + step_invocations)]
      end

      # Returns true if one or more steps failed
      def failed?
        steps.failed? || !!@exception
      end

      def fail!(exception)
        @exception = exception
        @current_visitor.visit_exception(@exception, :failed)
      end

      # Returns true if all steps passed
      def passed?
        !failed?
      end

      # Returns the first exception (if any)
      def exception
        @exception || steps.exception
      end

      # Returns the status
      def status
        return :failed if @exception
        steps.status
      end

      def to_sexp
        sexp = [:scenario, line, @keyword, name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        sexp += steps.to_sexp if steps.any?
        sexp
      end

      def with_visitor(visitor)
        @current_visitor = visitor
        yield
        @current_visitor = nil
      end

      def skip_invoke!
        steps.skip_invoke!
      end

      def steps
        @steps ||= @background.step_collection(step_invocations)
      end

      private

      def step_invocations
        @raw_steps.map{|step| step.step_invocation}
      end

      def skip_hooks?
        @background.failed? || @executed
      end

    end
  end
end
