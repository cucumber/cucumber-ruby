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
      def accept(visitor, formats)
        @step_mother.execute_step_definition(@name, @world, *@inline_args)
        visitor.visit_step_name(format(formats, :passed))
        @inline_args.each do |inline_arg|
          visitor.visit_inline_arg(inline_arg)
        end
      rescue StepMom::Pending => e
        visitor.visit_step_name(format(formats, :pending))
      rescue Exception => e
        visitor.visit_step_name(format(formats, :failed))
        visitor.visit_step_error(e)
      end

      private

      def format(formats, status)
        line = if (status == :pending)
          @gwt + " " + @name
        else
          @gwt + " " + @step_mother.format(@name, format_for(formats, status, :param))
        end
        line_format = format_for(formats, status)
        if Proc === line_format
          line_format.call(line)
        else
          line_format % line
        end
      end

      def format_for(formats, *keys)
        key = keys.join('_').to_sym
        fmt = formats[key]
        raise "No format for #{key.inspect}: #{formats.inspect}" if fmt.nil?
        fmt
      end
    end
  end
end
