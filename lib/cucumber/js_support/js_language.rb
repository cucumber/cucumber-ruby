require 'v8'

module Cucumber
  module JsSupport

    class JsWorld
      def initialize
        @world = V8::Context.new
      end

      def execute(js_function, args=[])
        args.map! { |arg| "'#{arg}'"  }
        @world.eval("var __cucumber_js_function = #{js_function.ToString}; __cucumber_js_function(#{args.join(',')});")
      end

      def method_missing(method_name, *args)
        @world.send(method_name, *args)
      end
    end

    class JsStepDefinition
      def initialize(js_language, regexp, js_function)
        @js_language, @regexp, @js_function = js_language, regexp.ToString, js_function
      end

      def invoke(args)
        @js_language.current_world.execute(@js_function, args)
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

      def file_colon_line
        # Not possible yet to get file/line of js function with V8/therubyracer
        ""
      end
    end

    class JsHook
      def initialize(js_language, tag_names, js_function)
        @js_language, @tag_names, @js_function = js_language, tag_names, js_function
      end

      def tag_expressions
        @tag_names
      end

      def invoke(location, scenario)
        @js_language.current_world.execute(@js_function)
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

      def addStepDefinition(regexp, js_function)
        @step_definitions << JsStepDefinition.new(self, regexp, js_function)
      end

      #TODO support tag_names
      def registerJsHook(phase, js_function)
        tag_names = []
        add_hook(phase, JsHook.new(self, tag_names, js_function))
      end

      def current_world
        @world
      end

    end
  end
end
