require 'v8'

module Cucumber
  module JsSupport

    class JsWorld
      def initialize
        V8::Context.open do |context|
          @world = context
        end
      end

      def method_missing(method_name, *args)
        @world.send(method_name, *args)
      end
    end

    class JsStepDefinition
      def initialize(js_language, proc) #(rb_language, regexp, proc)
        @js_language, @proc = js_language, proc
      end

      def invoke(args)
        puts @js_language.current_world.eval("var block = #{@proc.ToString}; block(#{args});")
      end
    end

    class JsArg
      def initialize(arg)
        @arg = arg
      end

      def val
        @arg
      end
    end

    class JsLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
        @steps = []
        @world = JsWorld.new

        @world["jsLanguage"] = self
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
        step_definition = match(step_name)
        args = [JsArg.new(2)]
        if step_definition
          [StepMatch.new(step_definition, step_name, name_to_report, args)]
        else
          nil
        end
      end

      def addStepDefinition(this, argumentsFrom, regexp, func)
        @steps << {:regexp => regexp.ToString,
        :block  => JsStepDefinition.new(self, func)}
      end

      def match(step_name)
        matching_step = @steps.select do |step|
          match?(step[:regexp], step_name)
        end
        matching_step[0][:block]
      end

      def current_world
        @world
      end

      private
      def match?(regexp, step_name)
        eval_js "#{regexp}.exec('#{step_name}')"
      end

    end
  end
end
