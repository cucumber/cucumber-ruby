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
          visitor.visit_step_name(@gwt, @name, :outline)
          visit_inline_args(visitor, :outline)
        else
          begin
            @step_mother.execute_step(@name, *@inline_args)
            visitor.visit_step_name(@gwt, @name, :passed)
            visit_inline_args(visitor, :passed)
          rescue StepMom::Pending
            visitor.visit_step_name(@gwt, @name, :pending)
            visit_inline_args(visitor, :pending)
          rescue Exception => error
            visitor.visit_step_name(@gwt, @name, :failed)
            visit_inline_args(visitor, :failed)
            visitor.visit_step_error(error)
          end
        end
      end

      def execute(name)
        @step_mother.execute_step_by_name(name, *@inline_args)
      end

      def execute_with_arguments(arguments)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(/<#{name}>/, value)
        end
        execute(name_with_arguments_replaced)
      end

      private

      def visit_inline_args(visitor, status)
        @inline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg, status)
        end
      end
    end
  end
end
