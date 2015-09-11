require 'cucumber/core_ext/instance_exec'
require 'cucumber/rb_support/rb_dsl'
require 'cucumber/rb_support/rb_world'
require 'cucumber/rb_support/rb_step_definition'
require 'cucumber/rb_support/rb_hook'
require 'cucumber/rb_support/rb_transform'
require 'cucumber/rb_support/snippet'
require 'cucumber/gherkin/i18n'
require 'multi_test'

module Cucumber
  module RbSupport
    # Raised if a World block returns Nil.
    class NilWorld < StandardError
      def initialize
        super("World procs should never return nil")
      end
    end

    # Raised if there are 2 or more World blocks.
    class MultipleWorld < StandardError
      def initialize(first_proc, second_proc)
        message = "You can only pass a proc to #World once, but it's happening\n"
        message << "in 2 places:\n\n"
        message << RbSupport.backtrace_line(first_proc, 'World') << "\n"
        message << RbSupport.backtrace_line(second_proc, 'World') << "\n\n"
        message << "Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc\n"
        message << "or http://wiki.github.com/cucumber/cucumber/a-whole-new-world.\n\n"
        super(message)
      end
    end

    # The Ruby implementation of the programming language API.
    class RbLanguage
      include LanguageSupport::LanguageMethods
      attr_reader :current_world,
                  :step_definitions

      all_keywords = ::Gherkin3::DIALECTS.keys.map do |dialect_name|
        dialect = ::Gherkin3::Dialect.for(dialect_name)
        dialect.given_keywords + dialect.when_keywords + dialect.then_keywords + dialect.and_keywords + dialect.but_keywords
      end
      Cucumber::Gherkin::I18n.code_keywords_for(all_keywords.flatten.uniq.sort).each do |adverb|
        RbDsl.alias_adverb(adverb.strip)
      end

      def initialize(runtime)
        @runtime = runtime
        @step_definitions = []
        RbDsl.rb_language = self
        @world_proc = @world_modules = nil
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

      def snippet_text(code_keyword, step_name, multiline_arg, snippet_type = :regexp)
        snippet_class = typed_snippet_class(snippet_type)
        snippet_class.new(code_keyword, step_name, multiline_arg).to_s
      end

      def begin_rb_scenario(scenario)
        create_world
        extend_world
        connect_world(scenario)
      end

      def register_rb_hook(phase, tag_expressions, proc)
        add_hook(phase, RbHook.new(self, tag_expressions, proc))
      end

      def register_rb_transform(regexp, proc)
        add_transform(RbTransform.new(self, regexp, proc))
      end

      def register_rb_step_definition(regexp, proc_or_sym, options)
        step_definition = RbStepDefinition.new(self, regexp, proc_or_sym, options)
        @step_definitions << step_definition
        step_definition
      end

      def build_rb_world_factory(world_modules, proc)
        if(proc)
          raise MultipleWorld.new(@world_proc, proc) if @world_proc
          @world_proc = proc
        end
        @world_modules ||= []
        @world_modules += world_modules
      end

      def load_code_file(code_file)
        load File.expand_path(code_file) # This will cause self.add_step_definition, self.add_hook, and self.add_transform to be called from RbDsl
      end

      def begin_scenario(scenario)
        begin_rb_scenario(scenario)
      end

      def end_scenario
        @current_world = nil
      end

      private

      def create_world
        if(@world_proc)
          @current_world = @world_proc.call
          check_nil(@current_world, @world_proc)
        else
          @current_world = Object.new
        end
      end

      def extend_world
        @current_world.extend(RbWorld)
        MultiTest.extend_with_best_assertion_library(@current_world)
        (@world_modules || []).each do |mod|
          @current_world.extend(mod)
        end
      end

      def connect_world(scenario)
        @current_world.__cucumber_runtime = @runtime
        @current_world.__natural_language = scenario.language
      end

      def check_nil(o, proc)
        if o.nil?
          begin
            raise NilWorld.new
          rescue NilWorld => e
            e.backtrace.clear
            e.backtrace.push(RbSupport.backtrace_line(proc, "World"))
            raise e
          end
        else
          o
        end
      end

      SNIPPET_TYPES = {
        :regexp => Snippet::Regexp,
        :classic => Snippet::Classic,
        :percent => Snippet::Percent
      }

      def typed_snippet_class(type)
        SNIPPET_TYPES.fetch(type || :regexp)
      end

      def self.cli_snippet_type_options
        SNIPPET_TYPES.keys.sort_by(&:to_s).map do |type|
          SNIPPET_TYPES[type].cli_option_string(type)
        end
      end
    end

    def self.backtrace_line(proc, name)
      location = Cucumber::Core::Ast::Location.from_source_location(*proc.source_location)
      "#{location.to_s}:in `#{name}'"
    end
  end
end
