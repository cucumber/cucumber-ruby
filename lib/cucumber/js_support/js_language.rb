require 'v8'

module Cucumber
  module JsSupport

    class JsSteps
      def initialize
        @steps = []
      end

      def addStepDefinition(this, argumentsFrom, regexp, func)
        @steps << regexp.ToString
      end

      def match(step)
        @steps.find do |regexp|
          puts "#{step} =~ #{Regexp.new(regexp)}"
          step =~ Regexp.new(regexp)
        end
      end
    end

    class JsLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
        @steps = JsSteps.new
        @step_def_files = []
      end

      def load_code_file(js_file)
        V8::Context.open do |context|
          context["jsLanguage"] = @steps
          context.load(js_file)
        end
      end

      def alias_adverbs(adverbs)
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class)
        puts "We don't need no stinking snippets"
      end

      def begin_scenario(scenario)
      end

      def end_scenario
      end

      def step_matches(step_name, name_to_report)
        puts @steps.match(step_name)

        # V8::Context.open do |context|
        #   step_block = @steps.match(step_name)
        #   context.eval(step_block.ToString)
        # end
      end

    end
  end
end