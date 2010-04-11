require 'v8'

module Cucumber
  module JsSupport

    class World
      def initialize
        V8::Context.open do |context|
          @world = context
        end
      end

      def method_missing(method_name, *args)
        @world.send(method_name, *args)
      end
    end

    class JsSteps
      def initialize
        @steps = []
      end

      def addStepDefinition(this, argumentsFrom, regexp, func)
        @steps << {:regexp => regexp.ToString,
        :block  => func}
      end

      def match(step_name)
        matching_step = @steps.select do |step|
          match?(step[:regexp], step_name)
        end
        matching_step[0][:block]
      end

      private
      def match?(regexp, step_name)
        eval_js "#{regexp}.exec('#{step_name}')"
      end
    end

    class JsLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
        @steps = JsSteps.new
        @world = World.new

        @world["jsLanguage"] = @steps
      end

      def load_code_file(js_file)
        @world.load(js_file)
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
        step_block = @steps.match(step_name)
        args = 2
        puts @world.eval("var block = #{step_block.ToString}; block(#{args});")
        []
      end

    end
  end
end
