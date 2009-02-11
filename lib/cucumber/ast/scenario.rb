require 'cucumber/ast/feature_element'

module Cucumber
  module Ast
    class Scenario
      include FeatureElement
      
      attr_writer :background
      attr_writer :feature
      
      def initialize(comment, tags, line, keyword, name, steps)
        @comment, @tags, @line, @keyword, @name, @steps = comment, tags, line, keyword, name, steps
        attach_steps(steps)
        @status = :passed
      end

      def status
        @steps.map{|step| step.status}
      end

      def matches_scenario_names?(scenario_names)
        scenario_names.detect{|name| @name == name}
      end

      def accept(visitor)
        visitor.visit_comment(@comment)
        visitor.visit_tags(@tags)
        visitor.visit_scenario_name(@keyword, @name, file_line(@line), source_indent(text_length))
        visitor.visit_steps(step_invocations(visitor))

        visitor.scenario_executed(self) unless @executed
        @executed = true
      end

      def accept_steps(visitor)
        previous = @background.status
        @steps.each do |step|
          step_invocation = visitor.step_invocation(step, previous, @background.world)
          visitor.visit_step(step_invocation)
          previous = step_invocation.status
        end
      end

      def to_sexp
        sexp = [:scenario, @line, @keyword, @name]
        comment = @comment.to_sexp
        sexp += [comment] if comment
        tags = @tags.to_sexp
        sexp += tags if tags.any?
        steps = @steps.map{|step| step.to_sexp}
        sexp += steps if steps.any?
        sexp
      end

      private

      # TODO: delegate to background
      def step_invocations(visitor)
        @step_invocations ||= StepCollection.new(@steps.map{|step| visitor.step_invocation(step, @background.world)})
      end

    end
  end
end
