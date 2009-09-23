require 'cucumber/core_ext/string'

module Cucumber
  module LanguageSupport
    module StepDefinitionMethods
      def step_match(name_to_match, name_to_report)
        if(arguments = arguments_from(name_to_match))
          StepMatch.new(self, name_to_match, name_to_report, arguments)
        else
          nil
        end
      end

      def backtrace_line
        "#{file_colon_line}:in `#{regexp_source}'"
      end

      def text_length
        regexp_source.jlength
      end
    end
  end
end