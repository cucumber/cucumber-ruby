require 'cucumber/constantize'
require 'cucumber/core_ext/instance_exec'
require 'cucumber/language_support/language_methods'
require 'cucumber/formatter/duration'
require 'cucumber/cli/options'
require 'cucumber/errors'
require 'cucumber/support_code'
require 'gherkin/rubify'
require 'timeout'

module Cucumber
  
  # This is the meaty part of Cucumber that ties everything together.
  class StepMother
    class FeaturesLoader
      include Formatter::Duration

      def initialize(feature_files, filters, tag_expression)
        @feature_files, @filters, @tag_expression = feature_files, filters, tag_expression
      end
      
      def features
        load unless @features
        @features
      end
      
    private
    
      def load
        features = Ast::Features.new

        tag_counts = {}
        start = Time.new
        log.debug("Features:\n")
        @feature_files.each do |f|
          feature_file = FeatureFile.new(f)
          feature = feature_file.parse(@filters, tag_counts)
          if feature
            features.add_feature(feature)
            log.debug("  * #{f}\n")
          end
        end
        duration = Time.now - start
        log.debug("Parsing feature files took #{format_duration(duration)}\n\n")

        check_tag_limits(tag_counts)

        @features = features
      end

      def check_tag_limits(tag_counts)
        error_messages = []
        @tag_expression.limits.each do |tag_name, tag_limit|
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
      
      def log
        Cucumber.logger
      end
    end
    include Formatter::Duration
    attr_writer :visitor

    def initialize(configuration = nil)
      @current_scenario = nil
      @configuration = configuration
      @options = configuration.options
    end
    
    def options=(options)
      warn("Setting StepMother#options is deprecated, and has been ignored. Please pass options into the constructor instead: #{caller[0]}")
    end
    
    # Returns the options passed on the command line.
    def options
      # warn("accessing options is deprecated: #{caller[0]}")
      @options
    end
    
    def load_plain_text_features(feature_files)
      FeaturesLoader.new(feature_files, @configuration.filters, @configuration.tag_expression).features
    end

    def load_code_files(step_def_files)
      support_code.load_files!(step_def_files)
    end

    # Loads and registers programming language implementation.
    # Instances are cached, so calling with the same argument
    # twice will return the same instance.
    #
    def load_programming_language(ext)
      support_code.load_programming_language!(ext)
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

    def invoke(step_name, multiline_argument)
      support_code.invoke(step_name, multiline_argument)
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
      include Gherkin::Rubify

      def initialize(step_mother)
        @step_mother = step_mother
      end

      def uri(uri)
      end

      def step(step)
        cucumber_multiline_arg = case(rubify(step.multiline_arg))
        when Gherkin::Formatter::Model::PyString
          step.multiline_arg.value
        when Array
          Ast::Table.new(step.multiline_arg.map{|row| row.cells})
        else
          nil
        end
        @step_mother.invoke(step.name, cucumber_multiline_arg) 
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
      support_code.step_match(step_name, name_to_report)
    end

    def unmatched_step_definitions
      support_code.unmatched_step_definitions
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      support_code.snippet_text(step_keyword, step_name, multiline_arg_class)
    end

    def with_hooks(scenario, skip_hooks=false)
      around(scenario, skip_hooks) do
        before_and_after(scenario, skip_hooks) do
          yield scenario
        end
      end
    end

    def around(scenario, skip_hooks=false, &block) #:nodoc:
      if skip_hooks
        yield
        return
      end
      
      support_code.around(scenario, block)
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      scenario_visited(scenario)
    end

    def before(scenario) #:nodoc:
      return if @configuration.dry_run? || @current_scenario
      @current_scenario = scenario
      support_code.fire_hook(:before, scenario)
    end
    
    def after(scenario) #:nodoc:
      @current_scenario = nil
      return if @configuration.dry_run?
      support_code.fire_hook(:after, scenario)
    end
    
    def after_step #:nodoc:
      return if @configuration.dry_run?
      support_code.fire_hook(:execute_after_step, @current_scenario)
    end
    
    def after_configuration(configuration) #:nodoc
      support_code.fire_hook(:after_configuration, configuration)
    end
    
    def unknown_programming_language?
      support_code.unknown_programming_language?
    end

  private
  
    def support_code
      @support_code ||= SupportCode.new(self)
    end

    def scenario_visited(scenario) #:nodoc:
      scenarios << scenario unless scenarios.index(scenario)
    end

    def log
      Cucumber.logger
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
