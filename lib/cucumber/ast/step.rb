require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      def initialize(scenario, outline, gwt, name, *multiline_args)
        @scenario, @outline, @gwt, @name, @multiline_args = scenario, outline, gwt, name, multiline_args
      end

      # TODO - Don't execute in accept. It should happen before - in Scenario.
      # Store the result in the step itself
      def accept(visitor, world, invoke)
        result = false
        if @outline
          visit_name_and_multiline_args(visitor, :outline, nil)
        else
          begin
            step_invocation = @scenario.step_invocation(@name, world)
            if invoke
              step_invocation.invoke(*@multiline_args)
              visit_name_and_multiline_args(visitor, :passed, step_invocation)
              result = true
            else
              visit_name_and_multiline_args(visitor, :skipped, step_invocation)
            end
          rescue StepMom::Missing
            visit_name_and_multiline_args(visitor, :missing, nil)
          rescue StepMom::Pending
            visit_name_and_multiline_args(visitor, :pending, step_invocation)
          rescue Exception => error
            visit_name_and_multiline_args(visitor, :failed, step_invocation)
            visitor.visit_step_error(error)
          end
        end
        result
      end

      def execute_with_arguments(arguments, world)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(/<#{name}>/, value)
        end
        step_invocation = @scenario.step_invocation(name_with_arguments_replaced, world)
        step_invocation.invoke(*@multiline_args)
      end

      def comment_padding
        max_length = @scenario.max_step_length
        max_length - text_length
      end

      def text_length
        @gwt.jlength + @name.jlength
      end

      private

      def visit_name_and_multiline_args(visitor, status, step_invocation)
        visitor.visit_step_name(@gwt, @name, status, step_invocation, comment_padding)
        @multiline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg, status)
        end
      end
    end
  end
end
