require 'cucumber/gherkin/i18n'

module Cucumber
  module Formatter
    module LegacyApi

      # This is what's passed to the constructor of the formatters
      class RuntimeFacade < Struct.new(:results, :support_code, :configuration)
        def unmatched_step_definitions
          support_code.unmatched_step_definitions
        end

        def snippet_text(step_keyword, step_name, multiline_arg) #:nodoc:
          support_code.snippet_text(Cucumber::Gherkin::I18n.code_keyword_for(step_keyword).strip, step_name, multiline_arg)
        end

        def unknown_programming_language?
          support_code.unknown_programming_language?
        end

        def scenarios(status = nil)
          results.scenarios(status)
        end

        def steps(status = nil)
          results.steps(status)
        end

        def step_match(step_name, name_to_report=nil)
          support_code.step_match(step_name, name_to_report)
        end
      end

    end
  end
end
