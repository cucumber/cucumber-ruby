require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      def initialize(scenario, outline, gwt, name, *multiline_args)
        @scenario, @outline, @gwt, @name, @multiline_args = scenario, outline, gwt, name, multiline_args
      end

      def accept(visitor)
        if @outline
          visit_name_and_multiline_args(visitor, :outline, nil)
        else
          begin
            invocation = @scenario.invocation(@name)
            invocation.invoke(*@multiline_args)
            visit_name_and_multiline_args(visitor, :passed, invocation)
          rescue StepMom::Missing
            visit_name_and_multiline_args(visitor, :missing, nil)
          rescue StepMom::Pending
            visit_name_and_multiline_args(visitor, :pending, invocation)
          rescue Exception => error
            visit_name_and_multiline_args(visitor, :failed, invocation)
            visitor.visit_step_error(error)
          end
        end
      end

      def execute_with_arguments(arguments)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(/<#{name}>/, value)
        end
        invocation = @scenario.invocation(name_with_arguments_replaced)
        invocation.invoke(*@multiline_args)
      end

      def comment_padding
        max_length = @scenario.max_step_length
        max_length - text_length
      end

      def text_length
        @gwt.jlength + @name.jlength
      end

      private

      def visit_name_and_multiline_args(visitor, status, invocation)
        visitor.visit_step_name(@gwt, @name, status, invocation, comment_padding)
        @multiline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg, status)
        end
      end
    end
  end
end
