require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      def initialize(step_mother, outline, gwt, name, *inline_args)
        @step_mother, @outline, @gwt, @name, @inline_args = step_mother, outline, gwt, name, inline_args
      end

      # Executes the step and calls methods back on +visitor+
      def accept(visitor, world)
        if @outline
          visitor.visit_step_name(@gwt, @name, :outline)
        else
          execute(@name, world)
          visitor.visit_step_name(@gwt, @name, :passed)
        end
        @inline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg)
        end
      rescue StepMom::Pending => e
        visitor.visit_step_name(@gwt, @name, :pending)
      rescue Exception => e
        visitor.visit_step_name(@gwt, @name, :failed)
        visitor.visit_step_error(e)
      end

      def execute(name, world)
        @step_mother.execute_step_by_name(name, world, *@inline_args)
      end

      def execute_with_arguments(arguments, world)
        name_with_arguments_replaced = @name
        arguments.each do |name, value|
          name_with_arguments_replaced = name_with_arguments_replaced.gsub(/<#{name}>/, value)
        end
        execute(name_with_arguments_replaced, world)
      end
    end
  end
end
