# frozen_string_literal: true

require 'cucumber/cucumber_expressions/parameter_type_registry'
require 'cucumber/cucumber_expressions/cucumber_expression'
require 'cucumber/cucumber_expressions/regular_expression'
require 'cucumber/cucumber_expressions/cucumber_expression_generator'
require 'cucumber/deprecate'
require 'cucumber/glue/dsl'
require 'cucumber/glue/snippet'
require 'cucumber/glue/hook'
require 'cucumber/glue/proto_world'
require 'cucumber/glue/step_definition'
require 'cucumber/glue/world_factory'
require 'cucumber/gherkin/i18n'
require 'multi_test'
require 'cucumber/step_match'
require 'cucumber/step_definition_light'
require 'cucumber/events/step_definition_registered'

module Cucumber
  module Glue
    def self.backtrace_line(proc, name)
      location = Cucumber::Core::Test::Location.from_source_location(*proc.source_location)
      "#{location}:in `#{name}'"
    end

    # Raised if a World block returns Nil.
    class NilWorld < StandardError
      def initialize
        super('World procs should never return nil')
      end
    end

    # Raised if there are 2 or more World blocks.
    class MultipleWorld < StandardError
      def initialize(first_proc, second_proc)
        # TODO: [LH] - Just use a heredoc here to fix this up
        message = String.new
        message << "You can only pass a proc to #World once, but it's happening\n"
        message << "in 2 places:\n\n"
        message << Glue.backtrace_line(first_proc, 'World') << "\n"
        message << Glue.backtrace_line(second_proc, 'World') << "\n\n"
        message << "Use Ruby modules instead to extend your worlds. See the Cucumber::Glue::Dsl#World RDoc\n"
        message << "or http://wiki.github.com/cucumber/cucumber/a-whole-new-world.\n\n"
        super(message)
      end
    end

    # TODO: This class has too many responsibilities, split off
    class RegistryAndMore
      attr_reader :current_world, :step_definitions

      all_keywords = ::Gherkin::DIALECTS.keys.map do |dialect_name|
        dialect = ::Gherkin::Dialect.for(dialect_name)
        dialect.given_keywords + dialect.when_keywords + dialect.then_keywords + dialect.and_keywords + dialect.but_keywords
      end
      Cucumber::Gherkin::I18n.code_keywords_for(all_keywords.flatten.uniq.sort).each do |adverb|
        Glue::Dsl.alias_adverb(adverb.strip)
      end

      def self.cli_snippet_type_options
        registry = CucumberExpressions::ParameterTypeRegistry.new
        cucumber_expression_generator = CucumberExpressions::CucumberExpressionGenerator.new(registry)
        Snippet::SNIPPET_TYPES.keys.sort_by(&:to_s).map do |type|
          Snippet::SNIPPET_TYPES[type].cli_option_string(type, cucumber_expression_generator)
        end
      end

      def initialize(runtime, configuration)
        @runtime = runtime
        @configuration = configuration
        @step_definitions = []
        Glue::Dsl.rb_language = self
        @world_proc = @world_modules = nil
        @parameter_type_registry = CucumberExpressions::ParameterTypeRegistry.new
        cucumber_expression_generator = CucumberExpressions::CucumberExpressionGenerator.new(@parameter_type_registry)
        @configuration.register_snippet_generator(Snippet::Generator.new(cucumber_expression_generator))
      end

      def step_matches(name_to_match)
        @step_definitions.each_with_object([]) do |step_definition, result|
          if (arguments = step_definition.arguments_from(name_to_match))
            result << StepMatch.new(step_definition, name_to_match, arguments)
          end
        end
      end

      def register_rb_hook(type, tag_expressions, proc, name: nil)
        hook = add_hook(type, Hook.new(@configuration.id_generator.new_id, self, tag_expressions, proc, name: name))
        @configuration.notify(:envelope, hook.to_envelope(type))
        hook
      end

      def define_parameter_type(parameter_type)
        @configuration.notify :envelope, parameter_type_envelope(parameter_type)

        @parameter_type_registry.define_parameter_type(parameter_type)
      end

      def register_rb_step_definition(string_or_regexp, proc_or_sym, options)
        step_definition = StepDefinition.new(@configuration.id_generator.new_id, self, string_or_regexp, proc_or_sym, options)
        @step_definitions << step_definition
        @configuration.notify :step_definition_registered, step_definition
        @configuration.notify :envelope, step_definition.to_envelope
        step_definition
      rescue Cucumber::CucumberExpressions::UndefinedParameterTypeError => e
        # TODO: add a way to extract the parameter type directly from the error.
        type_name = e.message.match(/^Undefined parameter type ['|{](.*)['|}].?$/)[1]

        @configuration.notify :undefined_parameter_type, type_name, string_or_regexp
      end

      def build_rb_world_factory(world_modules, namespaced_world_modules, proc)
        if proc
          raise MultipleWorld.new(@world_proc, proc) if @world_proc

          @world_proc = proc
        end
        @world_modules ||= []
        @world_modules += world_modules

        @namespaced_world_modules ||= Hash.new { |h, k| h[k] = [] }
        namespaced_world_modules.each do |namespace, world_module|
          @namespaced_world_modules[namespace] << world_module unless @namespaced_world_modules[namespace].include?(world_module)
        end
      end

      def load_code_file(code_file)
        return unless File.extname(code_file) == '.rb'

        # This will cause self.add_step_definition, self.add_hook, and self.define_parameter_type to be called from Glue::Dsl

        if Cucumber.use_legacy_autoloader
          load File.expand_path(code_file)
        else
          require File.expand_path(code_file)
        end
      end

      def begin_scenario(test_case)
        @current_world = WorldFactory.new(@world_proc).create_world
        @current_world.extend(ProtoWorld.for(@runtime, test_case.language))
        MultiTest.extend_with_best_assertion_library(@current_world)
        @current_world.add_modules!(@world_modules || [], @namespaced_world_modules || {})
      end

      def end_scenario
        @current_world = nil
      end

      def install_plugin(configuration, registry)
        hooks[:install_plugin].each do |hook|
          hook.invoke('InstallPlugin', [configuration, registry])
        end
      end

      def before_all
        hooks[:before_all].each do |hook|
          hook.invoke('BeforeAll', [])
        end
      end

      def after_all
        hooks[:after_all].each do |hook|
          hook.invoke('AfterAll', [])
        end
      end

      def add_hook(type, hook)
        hooks[type.to_sym] << hook
        hook
      end

      def clear_hooks
        @hooks = nil
      end

      def hooks_for(type, scenario) # :nodoc:
        hooks[type.to_sym].select { |hook| scenario.accept_hook?(hook) }
      end

      def create_expression(string_or_regexp)
        return CucumberExpressions::CucumberExpression.new(string_or_regexp, @parameter_type_registry) if string_or_regexp.is_a?(String)
        return CucumberExpressions::RegularExpression.new(string_or_regexp, @parameter_type_registry) if string_or_regexp.is_a?(Regexp)

        raise ArgumentError, 'Expression must be a String or Regexp'
      end

      private

      def parameter_type_envelope(parameter_type)
        # TODO: should this be moved to Cucumber::Expression::ParameterType#to_envelope ??
        # Note: that would mean that cucumber-expression would depend on cucumber-messages
        Cucumber::Messages::Envelope.new(
          parameter_type: Cucumber::Messages::ParameterType.new(
            id: @configuration.id_generator.new_id,
            name: parameter_type.name,
            regular_expressions: parameter_type.regexps.map(&:to_s),
            prefer_for_regular_expression_match: parameter_type.prefer_for_regexp_match,
            use_for_snippets: parameter_type.use_for_snippets,
            source_reference: Cucumber::Messages::SourceReference.new(
              uri: parameter_type.transformer.source_location[0],
              location: Cucumber::Messages::Location.new(line: parameter_type.transformer.source_location[1])
            )
          )
        )
      end

      def hooks
        @hooks ||= Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
