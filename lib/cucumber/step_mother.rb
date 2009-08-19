require 'cucumber/constantize'
require 'cucumber/core_ext/instance_exec'
require 'cucumber/parser/natural_language'
require 'cucumber/language_support/hook_methods'
require 'cucumber/language_support/language_methods'
require 'cucumber/language_support/step_definition_methods'

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

  # Raised when 2 or more StepDefinition have the same Regexp
  class Redundant < StandardError
    def initialize(step_def_1, step_def_2)
      message = "Multiple step definitions have the same Regexp:\n\n"
      message << step_def_1.backtrace_line << "\n"
      message << step_def_2.backtrace_line << "\n\n"
      super(message)
    end
  end

  # This is the meaty part of Cucumber that ties everything together.
  class StepMother
    include Constantize
    
    attr_writer :options, :visitor

    def initialize
      @programming_languages = []
      @language_map = {}
      load_natural_language('en')
    end

    # Loads and registers programming language implementation.
    # Instances are cached, so calling with the same argument
    # twice will return the same instance.
    #
    def load_programming_language(ext)
      return @language_map[ext] if @language_map[ext]
      programming_language_class = constantize("Cucumber::#{ext.capitalize}Support::#{ext.capitalize}Language")
      programming_language = programming_language_class.new(self)
      programming_language.alias_adverbs(@adverbs || [])
      @programming_languages << programming_language
      @language_map[ext] = programming_language
      programming_language
    end

    # Loads a natural language. This has the effect of aliasing 
    # Step Definition keywords for all of the registered programming 
    # languages (if they support aliasing). See #load_programming_language
    #
    def load_natural_language(lang)
      Parser::NaturalLanguage.get(self, lang)
    end

    # Registers a StepDefinition. This can be a Ruby StepDefintion,
    # or any other kind of object that implements the StepDefintion
    # contract (API).
    def register_step_definition(step_definition)
      step_definitions.each do |already|
        raise Redundant.new(already, step_definition) if already.same_regexp?(step_definition.regexp)
      end
      step_definitions << step_definition
      step_definition
    end

    # Returns the options passed on the command line.
    def options
      @options ||= {}
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

    def announce(msg) #:nodoc:
      @visitor.announce(msg)
    end

    def scenarios(status = nil) #:nodoc:
      @scenarios ||= []
      if(status)
        @scenarios.select{|scenario| scenario.status == status}
      else
        @scenarios
      end
    end

    def register_hook(phase, hook) #:nodoc:
      hooks[phase.to_sym] << hook
      hook
    end

    def hooks #:nodoc:
      @hooks ||= Hash.new {|hash, phase| hash[phase] = []}
    end

    def hooks_for(phase, scenario) #:nodoc:
      hooks[phase.to_sym].select{|hook| scenario.accept_hook?(hook)}
    end

    def step_match(step_name, formatted_step_name=nil) #:nodoc:
      matches = step_definitions.map { |d| d.step_match(step_name, formatted_step_name) }.compact
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
        shortest_capture_length = top_groups.map {|step_match| step_match.args.inject(0) {|sum, c| sum + c.length } }.min
        top_groups.select {|step_match| step_match.args.inject(0) {|sum, c| sum + c.length } == shortest_capture_length }
      else
        top_groups
      end
    end
    
    def clear! #:nodoc:
      step_definitions.clear
      hooks.clear
      steps.clear
      scenarios.clear
    end

    def step_definitions #:nodoc:
      @step_definitions ||= []
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
      @programming_languages.map do |programming_language|
        programming_language.snippet_text(step_keyword, step_name, multiline_arg_class)
      end.join("\n")
    end

    def before_and_after(scenario, skip_hooks=false) #:nodoc:
      before(scenario) unless skip_hooks
      yield scenario
      after(scenario) unless skip_hooks
      scenario_visited(scenario)
    end

    def register_adverbs(adverbs) #:nodoc:
      @adverbs ||= []
      @adverbs += adverbs
      @adverbs.uniq!
      @programming_languages.each do |programming_language|
        programming_language.alias_adverbs(@adverbs)
      end
    end

    def begin_scenario #:nodoc:
      return if options[:dry_run]
      @programming_languages.each do |programming_language|
        programming_language.begin_scenario
      end
    end

    def end_scenario #:nodoc:
      return if options[:dry_run]
      @programming_languages.each do |programming_language|
        programming_language.end_scenario
      end
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
    
    private

    def max_step_definition_length #:nodoc:
      @max_step_definition_length ||= step_definitions.map{|step_definition| step_definition.text_length}.max
    end

    def scenario_visited(scenario) #:nodoc:
      scenarios << scenario unless scenarios.index(scenario)
    end
  end
end
