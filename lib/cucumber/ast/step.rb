require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      def initialize(step_mother, outline, gwt, name, *inline_args)
        @step_mother, @outline, @gwt, @name, @inline_args = step_mother, outline, gwt, name, inline_args
      end

      def accept(visitor)
        if @outline
          visit_name_and_inline_args(visitor, :outline, nil)
        else
          begin
            invocation = @step_mother.invocation(@name)
            invocation.invoke(*@inline_args)
            visit_name_and_inline_args(visitor, :passed, invocation)
          rescue StepMom::Pending
            visit_name_and_inline_args(visitor, :pending, nil)
          rescue Exception => error
            visit_name_and_inline_args(visitor, :failed, invocation)
            visitor.visit_step_error(error)
          end
        end
      end

      def execute_with_arguments(arguments)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(/<#{name}>/, value)
        end
        invocation = @step_mother.invocation(name_with_arguments_replaced)
        invocation.invoke(*@inline_args)
      end

      private

      def visit_name_and_inline_args(visitor, status, invocation)
        visitor.visit_step_name(@gwt, @name, status, invocation)
        @inline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg, status)
        end
      end
    end
  end
end
