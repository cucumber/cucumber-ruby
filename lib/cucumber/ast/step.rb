require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_writer :world

      def initialize(step_mother, gwt, name, *inline_args)
        @step_mother, @gwt, @name, @inline_args = step_mother, gwt, name, inline_args
      end

      # Executes the step and calls methods back on +visitor+
      def accept(visitor)
        @step_mother.execute_step(@name, @world, *@inline_args)
        visitor.visit_step_name(@gwt, @name, :passed)
        @inline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg)
        end
      rescue StepMom::Pending => e
        visitor.visit_step_name(@gwt, @name, :pending)
      rescue Exception => e
        visitor.visit_step_name(@gwt, @name, :failed)
        visitor.visit_step_error(e)
      end
    end
  end
end
