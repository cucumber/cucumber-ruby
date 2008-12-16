require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_reader :name, :error

      def initialize(step_mother, gwt, name)
        @step_mother, @gwt, @name = step_mother, gwt, name
        @status = :pending
      end

      def step_def=(step_def)
        @step_def = step_def
      end

      def execute_in(world)
        @step_mother.execute_step_definition(name, world)
        @status = :passed
      rescue Exception => e
        @error = e
        @status = :failed
      end

      # Returns a formatted representation of this step's name as a String.
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
      def format(formats)
        line = if (@status == :pending)
          @gwt + " " + @name
        else
          @gwt + " " + @step_mother.format(@name, format_for(formats, @status, :param))
        end
        line_format = format_for(formats, @status)
        if Proc === line_format
          line_format.call(line)
        else
          line_format % line
        end
      end

    private

      def format_for(formats, *keys)
        key = keys.join('_').to_sym
        fmt = formats[key]
        raise "No format for #{key.inspect}: #{formats.inspect}" if fmt.nil?
        fmt
      end
    end
  end
end
