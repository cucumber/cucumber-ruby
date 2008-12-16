require 'cucumber/step_definition'
require 'cucumber/core_ext/string'

module Cucumber
  module Ast
    class Step
      attr_reader :name

      def initialize(gwt, name)
        @gwt, @name = gwt, name
        @status = :pending
      end

      def step_def=(step_def)
        @step_def = step_def
      end

      def execute
        return if @step_def.nil?
        @step_def.execute
        @status = :passed
      rescue Exception
        @status = :failed
      end

      # Returns a formatted representation of this step's name as a String.
      # The +formats+ argument must be a Hash that has the following keys:
      #
      # * <tt>:param   - formats each parameter
      # * <tt>:pending - formats the whole line when the step is pending
      # * <tt>:passed  - formats the whole line when the step is passed
      # * <tt>:failed  - formats the whole line when the step is failed
      # * <tt>:skipped - formats the whole line when the step is skipped
      #
      # The values of each key can be either a String or a Proc.
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
          @gwt + " " + @name.gzub(@step_def.regexp, format_for(formats, @status, :param))
        end
        line_format = format_for(formats, @status)
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
