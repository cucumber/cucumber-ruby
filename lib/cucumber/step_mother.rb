require 'cucumber/constantize'
require 'cucumber/core_ext/instance_exec'
require 'cucumber/language_support/language_methods'
require 'cucumber/formatter/duration'
require 'cucumber/cli/options'
require 'timeout'

module Cucumber
  # Raised when there is no matching StepDefinition for a step.
  class Undefined < StandardError
    attr_reader :step_name

    def initialize(step_name)
      super %{Undefined step: "#{step_name}"}
      @step_name = step_name
    end
    
    def nested!
      @nested = true
    end

    def nested?
      @nested
    end
  end

  # Raised when a StepDefinition's block invokes World#pending
  class Pending < StandardError
  end

  # Raised when a step matches 2 or more StepDefinitions
  class Ambiguous < StandardError
    def initialize(step_name, step_definitions, used_guess)
      message = "Ambiguous match of \"#{step_name}\":\n\n"
      message << step_definitions.map{|sd| sd.backtrace_line}.join("\n")
      message << "\n\n"
      message << "You can run again with --guess to make Cucumber be more smart about it\n" unless used_guess
      super(message)
    end
  end

  class TagExcess < StandardError
    def initialize(messages)
      super(messages.join("\n"))
    end
  end

  # This is the meaty part of Cucumber that ties everything together.
  class StepMother
    include Constantize
    include Formatter::Duration
    attr_writer :options, :visitor, :log

    def initialize
      @unsupported_programming_languages = []
      @programming_languages = []
      @language_map = {}
      @current_scenario = nil
    end

    def load_plain_text_features(feature_files)
      features = Ast::Features.new

      tag_counts = {}
      start = Time.new
      log.debug("Features:\n")
      feature_files.each do |f|
        feature_file = FeatureFile.new(f)
        feature = feature_file.parse(options, tag_counts)
        if feature
          features.add_feature(feature)
          log.debug("  * #{f}\n")
        end
      end
      duration = Time.now - start
      log.debug("Parsing feature files took #{format_duration(duration)}\n\n")
      
      check_tag_limits(tag_counts)
      
      features
    end

    def check_tag_limits(tag_counts)
      error_messages = []
      options[:tag_expression].limits.each do |tag_name, tag_limit|
        tag_locations = (tag_counts[tag_name] || [])
        tag_count = tag_locations.length
        if tag_count > tag_limit
          error = "#{tag_name} occurred #{tag_count} times, but the limit was set to #{tag_limit}\n  " +
            tag_locations.join("\n  ")
          error_messages << error
        end
      end
      raise TagExcess.new(error_messages) if error_messages.any?
    end

    def load_code_files(step_def_files)
      log.debug("Code:\n")
      step_def_files.each do |step_def_file|
        load_code_file(step_def_file)
      end
      log.debug("\n")
    end

    def load_code_file(step_def_file)
      if programming_language = programming_language_for(step_def_file)
        log.debug("  * #{step_def_file}\n")
        programming_language.load_code_file(step_def_file)
      else
        log.debug("  * #{step_def_file} [NOT SUPPORTED]\n")
      end
    end

    # Loads and registers programming language implementation.
    # Instances are cached, so calling with the same argument
    # twice will return the same instance.
    #
    def load_programming_language(ext)
      return @language_map[ext] if @language_map[ext]
      programming_language_class = constantize("Cucumber::#{ext.capitalize}Support::#{ext.capitalize}Language")
      programming_language = programming_language_class.new(self)
      @programming_languages << programming_language
      @language_map[ext] = programming_language
      programming_language
    end

    # Returns the options passed on the command line.
    def options
      @options ||= Cli::Options.new
    end

    def step_visited(step) #:nodoc:
      steps << step unless steps.index(step)
    end

    def steps(status = nil) #:nodoc:
      @steps ||= []
      if(status)
        @steps.select{|step| step.status == status}
      else
        @steps
      end
    end

    # Output +announcement+ alongside the formatted output.
    # This is an alternative to using Kernel#puts - it will display
    # nicer, and in all outputs (in case you use several formatters)
    #
    def announce(msg)
      msg.respond_to?(:join) ? @visitor.announce(msg.join("\n")) : @visitor.announce(msg.to_s)
    end

    # Suspends execution and prompts +question+ to the console (STDOUT).
    # An operator (manual tester) can then enter a line of text and hit
    # <ENTER>. The entered text is returned, and both +question+ and
    # the result is added to the output using #announce.
    #
    # If you want a beep to happen (to grab the manual tester's attention),
    # just prepend ASCII character 7 to the question:
    #
    #   ask("#{7.chr}How many cukes are in the external system?")
    #
    # If that doesn't issue a beep, you can shell out to something else
    # that makes a sound before invoking #ask.
    #
    def ask(question, timeout_seconds)
      STDOUT.puts(question)
      STDOUT.flush
      announce(question)

      if(Cucumber::JRUBY)
        answer = jruby_gets(timeout_seconds)
      else
        answer = mri_gets(timeout_seconds)
      end
      
      if(answer)
        announce(answer)
        answer
      else
        raise("Waited for input for #{timeout_seconds} seconds, then timed out.")
      end
    end

    # Embed +file+ of MIME type +mime_type+ into the output. This may or may
    # not be ignored, depending on what kind of formatter(s) are active.
    #
    def embed(file, mime_type)
      @visitor.embed(file, mime_type)
    end

    def scenarios(status = nil) #:nodoc:
      @scenarios ||= []
      if(status)
        @scenarios.select{|scenario| scenario.status == status}
      else
        @scenarios
      end
    end

    def invoke(step_name, multiline_argument=nil)
      begin
        step_match(step_name).invoke(multiline_argument)
      rescue Exception => e
        e.nested! if Undefined === e
        raise e
      end
    end

    # Invokes a series of steps +steps_text+. Example:
    #
    #   invoke(%Q{
    #     Given I have 8 cukes in my belly
    #     Then I should not be thirsty
    #   })
    def invoke_steps(steps_text, i18n, file_colon_line)
      file, line = file_colon_line.split(':')
      parser = Gherkin::Parser::Parser.new(StepInvoker.new(self), true, 'steps')
      parser.parse(steps_text, file, line.to_i)
    end

    class StepInvoker
      def initialize(step_mother)
        @step_mother = step_mother
      end

      def step(statement, multiline_arg, result)
        cucumber_multiline_arg = case(multiline_arg)
        when Gherkin::Formatter::Model::PyString
          multiline_arg.value
        when Array
          Ast::Table.new(multiline_arg.map{|row| row.cells})
        else
          nil
        end
        @step_mother.invoke(*[statement.name, cucumber_multiline_arg].compact) 
      end

      def eof
      end
    end

    # Returns a Cucumber::Ast::Table for +text_or_table+, which can either
    # be a String:
    #
    #   table(%{
    #     | account | description | amount |
    #     | INT-100 | Taxi        | 114    |
    #     | CUC-101 | Peeler      | 22     |
    #   })
    #
    # or a 2D Array:
    #
    #   table([
    #     %w{ account description amount },
    #     %w{ INT-100 Taxi        114    },
    #     %w{ CUC-101 Peeler      22     }
    #   ])
    #
    def table(text_or_table, file=nil, line_offset=0)
      if Array === text_or_table
        Ast::Table.new(text_or_table)
      else
        Ast::Table.parse(text_or_table, file, line_offset)
      end
    end

    # Returns a regular String for +string_with_triple_quotes+. Example:
    #
    #   """
    #    hello
    #   world
    #   """
    #
    # Is retured as: " hello\nworld"
    #
    def py_string(string_with_triple_quotes, file=nil, line_offset=0)
      Ast::PyString.parse(string_with_triple_quotes)
    end

    def step_match(step_name, name_to_report=nil) #:nodoc:
      matches = @programming_languages.map do |programming_language| 
        programming_language.step_matches(step_name, name_to_report).to_a
      end.flatten
      raise Undefined.new(step_name) if matches.empty?
      matches = best_matches(step_name, matches) if matches.size > 1 && options[:guess]
      raise Ambiguous.new(step_name, matches, options[:guess]) if matches.size > 1
      matches[0]
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

    def unmatched_step_definitions
      @programming_languages.map do |programming_language| 
        programming_language.unmatched_step_definitions
      end.flatten
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      load_programming_language('rb') if unknown_programming_language?
      @programming_languages.map do |programming_language|
        programming_language.snippet_text(step_keyword, step_name, multiline_arg_class)
      end.join("\n")
    end

    def unknown_programming_language?
      @programming_languages.empty?
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      unless skip_hooks
        @programming_languages.reverse.inject(block) do |blk, programming_language|
          proc do
            programming_language.around(scenario) do
              blk.call(scenario)
            end
          end
        end.call
      else
        yield
      end
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      scenario_visited(scenario)
    end

    def before(scenario) #:nodoc:
      return if options[:dry_run] || @current_scenario
      @current_scenario = scenario
      @programming_languages.each do |programming_language|
        programming_language.before(scenario)
      end
    end
    
    def after(scenario) #:nodoc:
      @current_scenario = nil
      return if options[:dry_run]
      @programming_languages.each do |programming_language|
        programming_language.after(scenario)
      end
    end
    
    def after_step #:nodoc:
      return if options[:dry_run]
      @programming_languages.each do |programming_language|
        programming_language.execute_after_step(@current_scenario)
      end
    end
    
    def after_configuration(configuration) #:nodoc
      @programming_languages.each do |programming_language|
        programming_language.after_configuration(configuration)
      end
    end

    private

    def programming_language_for(step_def_file) #:nodoc:
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

    def max_step_definition_length #:nodoc:
      @max_step_definition_length ||= step_definitions.map{|step_definition| step_definition.text_length}.max
    end

    def scenario_visited(scenario) #:nodoc:
      scenarios << scenario unless scenarios.index(scenario)
    end

    def log
      @log ||= Logger.new(STDOUT)
    end

    def mri_gets(timeout_seconds)
      begin
        Timeout.timeout(timeout_seconds) do
          STDIN.gets
        end
      rescue Timeout::Error => e
        nil
      end
    end

    def jruby_gets(timeout_seconds)
      answer = nil
      t = java.lang.Thread.new do
        answer = STDIN.gets
      end
      t.start
      t.join(timeout_seconds * 1000)
      answer
    end
  end
end
