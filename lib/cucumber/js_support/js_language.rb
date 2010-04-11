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
      def initialize(js_language, regexp, proc)
        @js_language, @regexp, @proc = js_language, regexp.ToString, proc
      end

      def invoke(args)
        args.map! { |arg| "'#{arg}'"  }
        @js_language.current_world.eval("var block = #{@proc.ToString}; block(#{args.join(',')});")
      end

      # TODO: Handle complex args
      def arguments_from(step_name)
        matches = eval_js "#{@regexp}.exec('#{step_name}')"
        if matches
          matches[1..-1].map do |match|
            JsArg.new(match)
          end
        end
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
        @step_definitions = []
        @world = JsWorld.new

        @world["jsLanguage"] = self
        @world.load(File.dirname(__FILE__) + '/js_dsl.js')
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

      def step_matches(name_to_match, name_to_format)
        @step_definitions.map do |step_definition|
          if(arguments = step_definition.arguments_from(name_to_match))
            StepMatch.new(step_definition, name_to_match, name_to_format, arguments)
          else
            nil
          end
        end.compact
      end

      def addStepDefinition(this, argumentsFrom, regexp, func)
        @step_definitions << JsStepDefinition.new(self, regexp, func)
      end

      def current_world
        @world
      end

    end
  end
end
