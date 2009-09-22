require 'cucumber/core_ext/string'

module Cucumber
  module LanguageSupport
    module StepDefinitionMethods
      def step_match(name_to_match, name_to_report)
        if(captures = captures(name_to_match))
          StepMatch.new(self, name_to_match, name_to_report, captures)
        else
          nil
        end
      end

      # Formats the matched arguments of the associated Step. This method
      # is usually called from visitors, which render output.
      #
      # The +format+ can either be a String or a Proc.
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
      def format_args(step_name, format)
        step_name.gzub(captures(step_name), starts(step_name), format)
      end

      def backtrace_line
        "#{file_colon_line}:in `#{regexp.inspect}'"
      end

      def text_length
        regexp.inspect.jlength
      end
    end
  end
end