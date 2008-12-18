require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_writer :world

      def initialize(step_mother, gwt, name, *inline_args)
        @step_mother, @gwt, @name, @inline_args = step_mother, gwt, name, inline_args
      end

      # Executes the step and calls back on +visitor+ with a formatted
      # representation of the step's name.
      # The +formats+ argument must be a Hash that has the same keys as the
      # colour codes in Formatters::ANSIColor.
      #
      # The value of each key must be either a String or a Proc.
      #
      # If it is a String it should be a format string according to
      # <tt>Kernel#sprinf</tt>, for example:
      #
      #   '<span class="param">%s</span></tt>'
      #
      # If it is a Proc, it should take one argument and return the formatted
      # argument, for example:
      #
      #   lambda { |param| "[#{param}]" }
      #
      def accept(visitor)
        @step_mother.execute_step_definition(@name, @world, *@inline_args)
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
