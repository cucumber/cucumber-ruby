require 'cucumber/constantize'
require 'cucumber/runtime/for_programming_languages'
require 'cucumber/runtime/step_hooks'
require 'cucumber/runtime/before_hooks'
require 'cucumber/runtime/after_hooks'
require 'cucumber/events/step_match'
require 'cucumber/gherkin/steps_parser'

module Cucumber

  class Runtime

    class SupportCode

      require 'forwardable'
      class StepInvoker

        def initialize(support_code)
          @support_code = support_code
        end

        def steps(steps)
          steps.each { |step| step(step) }
        end

        def step(step)
          location = Core::Ast::Location.of_caller
          @support_code.invoke_dynamic_step(step[:text], multiline_arg(step, location))
        end

        def multiline_arg(step, location)
          if argument = step[:argument]
            if argument[:type] == :DocString
              MultilineArgument.doc_string(argument[:content], argument[:content_type], location)
            else
              MultilineArgument::DataTable.from(argument[:rows].map { |row| row[:cells].map { |cell| cell[:value] } })
            end
          else
            MultilineArgument.from(nil)
          end
        end
      end

      include Constantize

      attr_reader :ruby
      def initialize(user_interface, configuration=Configuration.default)
        @configuration = configuration
        @runtime_facade = Runtime::ForProgrammingLanguages.new(self, user_interface)
        @ruby = Cucumber::RbSupport::RbLanguage.new(@runtime_facade, @configuration)
      end

      def configure(new_configuration)
        @configuration = Configuration.new(new_configuration)
      end

      # Invokes a series of steps +steps_text+. Example:
      #
      #   invoke(%Q{
      #     Given I have 8 cukes in my belly
      #     Then I should not be thirsty
      #   })
      def invoke_dynamic_steps(steps_text, i18n, location)
        parser = Cucumber::Gherkin::StepsParser.new(StepInvoker.new(self), i18n.iso_code)
        parser.parse(steps_text)
      end

      # @api private
      # This allows users to attempt to find, match and execute steps
      # from code as the features are running, as opposed to regular
      # steps which are compiled into test steps before execution.
      #
      # These are commonly called nested steps.
      def invoke_dynamic_step(step_name, multiline_argument, location=nil)
        matches = step_matches(step_name)
        raise UndefinedDynamicStep, step_name if matches.empty?
        matches.first.invoke(multiline_argument)
      end

      def load_files!(files)
        log.debug("Code:\n")
        files.each do |file|
          load_file(file)
        end
        log.debug("\n")
      end

      def load_files_from_paths(paths)
        files = paths.map { |path| Dir["#{path}/**/*.rb"] }.flatten
        load_files! files
      end

      def unmatched_step_definitions
        @ruby.unmatched_step_definitions
      end

      def snippet_text(step_keyword, step_name, multiline_arg) #:nodoc:
        @configuration.snippet_generators.map { |generator|
          generator.call(step_keyword, step_name, multiline_arg, @configuration.snippet_type)
        }.join("\n")
      end

      def fire_hook(name, *args)
        @ruby.send(name, *args)
      end

      def step_definitions
        @ruby.step_definitions
      end

      def find_after_step_hooks(test_case)
        scenario = RunningTestCase.new(test_case)
        hooks = @ruby.hooks_for(:after_step, scenario)
        StepHooks.new hooks
      end

      def apply_before_hooks(test_case)
        scenario = RunningTestCase.new(test_case)
        hooks = @ruby.hooks_for(:before, scenario)
        BeforeHooks.new(hooks, scenario).apply_to(test_case)
      end

      def apply_after_hooks(test_case)
        scenario = RunningTestCase.new(test_case)
        hooks = @ruby.hooks_for(:after, scenario)
        AfterHooks.new(hooks, scenario).apply_to(test_case)
      end

      def find_around_hooks(test_case)
        scenario = RunningTestCase.new(test_case)

        @ruby.hooks_for(:around, scenario).map do |hook|
          Hooks.around_hook(test_case.source) do |run_scenario|
            hook.invoke('Around', scenario, &run_scenario)
          end
        end
      end

      def step_matches(step_name)
        return step_match_library.step_matches(step_name)
      end

      private

      def step_match_library
        AssertUnambiguousMatch.new(
          @configuration.guess? ? AttemptToGuessAmbiguousMatch.new(@ruby) : @ruby
        )
      end

      def load_file(file)
        log.debug("  * #{file}\n")
        @ruby.load_code_file(file)
      end

      def log
        Cucumber.logger
      end

      require 'delegate'
      class CachesStepMatch < SimpleDelegator
        def step_matches(step_name) #:nodoc:
          @match_cache ||= {}

          matches = @match_cache[step_name]
          return matches if matches

          @match_cache[step_name] = super(step_name)
        end
      end

      class AssertUnambiguousMatch
        def initialize(step_match_library)
          @step_match_library = step_match_library
        end

        def step_matches(step_name)
          result = @step_match_library.step_matches(step_name)
          raise Cucumber::Ambiguous.new(step_name, result, false) if result.length > 1
          result
        end
      end

      class AttemptToGuessAmbiguousMatch
        def initialize(step_match_library)
          @step_match_library = step_match_library
        end

        def step_matches(step_name)
          best_matches(step_name, @step_match_library.step_matches(step_name))
        end

        private

        def best_matches(step_name, step_matches) #:nodoc:
          no_groups      = step_matches.select {|step_match| step_match.args.length == 0}
          max_arg_length = step_matches.map {|step_match| step_match.args.length }.max
          top_groups     = step_matches.select {|step_match| step_match.args.length == max_arg_length }

          if no_groups.any?
            longest_regexp_length = no_groups.map {|step_match| step_match.text_length }.max
            no_groups.select {|step_match| step_match.text_length == longest_regexp_length }
          elsif top_groups.any?
            shortest_capture_length = top_groups.map {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } }.min
            top_groups.select {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } == shortest_capture_length }
          else
            top_groups
          end
        end

      end


    end
  end
end
