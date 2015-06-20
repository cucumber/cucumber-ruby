require 'cucumber/constantize'
require 'cucumber/runtime/for_programming_languages'
require 'cucumber/runtime/step_hooks'
require 'cucumber/runtime/before_hooks'
require 'cucumber/runtime/after_hooks'

module Cucumber

  class Runtime

    class SupportCode

      require 'forwardable'
      class StepInvoker
        include Gherkin::Rubify

        def initialize(support_code)
          @support_code = support_code
        end

        def uri(uri)
        end

        def step(step)
          location = Core::Ast::Location.of_caller
          @support_code.invoke_dynamic_step(step.name, multiline_arg(step, location))
        end

        def eof
        end

        def multiline_arg(step, location)
          if argument = step.doc_string
            MultilineArgument.doc_string(argument.value, argument.content_type, location.on_line(argument.line_range))
          else
            MultilineArgument.from(step.rows, location)
          end
        end
      end

      include Constantize

      def initialize(user_interface, configuration={})
        @configuration = Configuration.parse(configuration)
        @runtime_facade = Runtime::ForProgrammingLanguages.new(self, user_interface)
        @unsupported_programming_languages = []
        @programming_languages = []
        @language_map = {}
      end

      def configure(new_configuration)
        @configuration = Configuration.parse(new_configuration)
      end

      # Invokes a series of steps +steps_text+. Example:
      #
      #   invoke(%Q{
      #     Given I have 8 cukes in my belly
      #     Then I should not be thirsty
      #   })
      def invoke_dynamic_steps(steps_text, i18n, file_colon_line)
        file, line = file_colon_line.split(':')
        parser = Gherkin::Parser::Parser.new(StepInvoker.new(self), true, 'steps', false, i18n.iso_code)
        parser.parse(steps_text, file, line.to_i)
      end

      # @api private
      # This allows users to attempt to find, match and execute steps
      # from code as the features are running, as opposed to regular
      # steps which are compiled into test steps before execution.
      #
      # These are commonly called nested steps.
      def invoke_dynamic_step(step_name, multiline_argument, location=nil)
        begin
          step_match(step_name).invoke(multiline_argument)
        rescue Undefined => exception
          raise UndefinedDynamicStep, step_name
        end
      end

      # Loads and registers programming language implementation.
      # Instances are cached, so calling with the same argument
      # twice will return the same instance.
      #
      def load_programming_language(ext)
        return @language_map[ext] if @language_map[ext]
        programming_language_class = constantize("Cucumber::#{ext.capitalize}Support::#{ext.capitalize}Language")
        programming_language = programming_language_class.new(@runtime_facade)
        @programming_languages << programming_language
        @language_map[ext] = programming_language
        programming_language
      end

      def load_files!(files)
        log.debug("Code:\n")
        files.each do |file|
          load_file(file)
        end
        log.debug("\n")
      end

      def load_files_from_paths(paths)
        files = paths.map { |path| Dir["#{path}/**/*"] }.flatten
        load_files! files
      end

      def unmatched_step_definitions
        @programming_languages.map do |programming_language|
          programming_language.unmatched_step_definitions
        end.flatten
      end

      def snippet_text(step_keyword, step_name, multiline_arg) #:nodoc:
        load_programming_language('rb') if unknown_programming_language?
        @programming_languages.map do |programming_language|
          programming_language.snippet_text(step_keyword, step_name, multiline_arg, @configuration.snippet_type)
        end.join("\n")
      end

      def unknown_programming_language?
        @programming_languages.empty?
      end

      def fire_hook(name, *args)
        @programming_languages.each do |programming_language|
          programming_language.send(name, *args)
        end
      end

      def step_definitions
        @programming_languages.map do |programming_language|
          programming_language.step_definitions
        end.flatten
      end

      def find_match(test_step)
        begin
          match = step_match(test_step.name)
        rescue Cucumber::Undefined
          return NoStepMatch.new(test_step.source.last, test_step.name)
        end
        if @configuration.dry_run?
          return SkippingStepMatch.new
        end
        match
      end

      def find_after_step_hooks(test_case)
        ruby = load_programming_language('rb')
        scenario = RunningTestCase.new(test_case)
        hooks = ruby.hooks_for(:after_step, scenario)
        StepHooks.new hooks
      end

      def apply_before_hooks(test_case)
        ruby = load_programming_language('rb')
        scenario = RunningTestCase.new(test_case)
        hooks = ruby.hooks_for(:before, scenario)
        BeforeHooks.new(hooks, scenario).apply_to(test_case)
      end

      def apply_after_hooks(test_case)
        ruby = load_programming_language('rb')
        scenario = RunningTestCase.new(test_case)
        hooks = ruby.hooks_for(:after, scenario)
        AfterHooks.new(hooks, scenario).apply_to(test_case)
      end

      def find_around_hooks(test_case)
        ruby = load_programming_language('rb')
        scenario = RunningTestCase.new(test_case)

        ruby.hooks_for(:around, scenario).map do |hook|
          Hooks.around_hook(test_case.source) do |run_scenario|
            hook.invoke('Around', scenario, &run_scenario)
          end
        end
      end

      def step_match(step_name, name_to_report=nil) #:nodoc:
        @match_cache ||= {}

        match = @match_cache[[step_name, name_to_report]]
        return match if match

        @match_cache[[step_name, name_to_report]] = step_match_without_cache(step_name, name_to_report)
      end

      private

      def step_match_without_cache(step_name, name_to_report=nil)
        matches = matches(step_name, name_to_report)
        raise Undefined.new(step_name) if matches.empty?
        matches = best_matches(step_name, matches) if matches.size > 1 && guess_step_matches?
        raise Ambiguous.new(step_name, matches, guess_step_matches?) if matches.size > 1
        matches[0]
      end

      def guess_step_matches?
        @configuration.guess?
      end

      def matches(step_name, name_to_report)
        @programming_languages.map do |programming_language|
          programming_language.step_matches(step_name, name_to_report).to_a
        end.flatten
      end

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

      def load_file(file)
        if programming_language = programming_language_for(file)
          log.debug("  * #{file}\n")
          programming_language.load_code_file(file)
        else
          log.debug("  * #{file} [NOT SUPPORTED]\n")
        end
      end

      def log
        Cucumber.logger
      end

      def programming_language_for(step_def_file)
        if ext = File.extname(step_def_file)[1..-1]
          return nil if @unsupported_programming_languages.index(ext)
          begin
            load_programming_language(ext)
          rescue LoadError => e
            log.debug("Failed to load '#{ext}' programming language for file #{step_def_file}: #{e.message}\n")
            @unsupported_programming_languages << ext
            nil
          end
        else
          nil
        end
      end

    end
  end
end
