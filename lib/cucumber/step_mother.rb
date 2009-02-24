require 'cucumber/step_definition'
require 'cucumber/world'
require 'cucumber/core_ext/instance_exec'

module Cucumber
  class Undefined < StandardError
    attr_reader :step_name

    def initialize(step_name)
      super %{Undefined step: "#{step_name}"}
      @step_name = step_name
    end
  end

  # Raised when a StepDefinition's block invokes World#pending
  class Pending < StandardError
  end

  # Raised when a step matches 2 or more StepDefinition
  class Ambiguous < StandardError
    def initialize(step_name, step_definitions)
      message = "Ambiguous match of \"#{step_name}\":\n\n"
      message << step_definitions.map{|sd| sd.to_backtrace_line}.join("\n")
      message << "\n\n"
      super(message)
    end
  end

  # Raised when 2 or more StepDefinition have the same Regexp
  class Redundant < StandardError
    def initialize(step_def_1, step_def_2)
      message = "Multiple step definitions have the same Regexp:\n\n"
      message << step_def_1.to_backtrace_line << "\n"
      message << step_def_2.to_backtrace_line << "\n\n"
      super(message)
    end
  end

  # This is the main interface for registering step definitions, which is done
  # from <tt>*_steps.rb</tt> files. This module is included right at the top-level
  # so #register_step_definition (and more interestingly - its aliases) are
  # available from the top-level.
  module StepMother
    class << self
      def alias_adverb(adverb)
        alias_method adverb, :register_step_definition
      end
    end

    attr_writer :snippet_generator, :options

    def scenario_visited(scenario)
      scenarios << scenario unless scenarios.index(scenario)
    end
    
    def step_visited(step)
      steps << step unless steps.index(step)
    end
    
    def steps(status = nil)
      @steps ||= []
      if(status)
        @steps.select{|step| step.status == status}
      else
        @steps
      end
    end

    def scenarios
      @scenarios ||= []
    end

    # Registers a new StepDefinition. This method is aliased
    # to <tt>Given</tt>, <tt>When</tt> and <tt>Then</tt>.
    #
    # See Cucumber#alias_steps for details on how to
    # create your own aliases.
    #
    # The +&proc+ gets executed in the context of a <tt>world</tt>
    # object, which is defined by #World. A new <tt>world</tt>
    # object is created for each scenario and is shared across
    # step definitions within that scenario.
    def register_step_definition(regexp, &proc)
      step_definition = StepDefinition.new(regexp, &proc)
      step_definitions.each do |already|
        raise Redundant.new(already, step_definition) if already.match(regexp)
      end
      step_definitions << step_definition
      step_definition
    end

    # Registers a Before proc. You can call this method as many times as you
    # want (typically from ruby scripts under <tt>support</tt>).
    def Before(&proc)
      (@before_procs ||= []) << proc
    end

    def After(&proc)
      (@after_procs ||= []) << proc
    end

    # Registers a World proc. You can call this method as many times as you
    # want (typically from ruby scripts under <tt>support</tt>).
    def World(&proc)
      (@world_procs ||= []) << proc
    end

    def execute_scenario(scenario, &proc)
      new_world!
      begin
        (@before_procs ||= []).each do |proc|
          @current_world.cucumber_instance_exec(false, 'Before', scenario, &proc)
        end
        yield
      ensure
        (@after_procs ||= []).each do |proc|
          @current_world.cucumber_instance_exec(false, 'After', scenario, &proc)
        end
      end
    end

    # Creates a new world instance
    def new_world!
      @current_world = Object.new
      (@world_procs ||= []).each do |proc|
        @current_world = proc.call(@current_world)
      end

      @current_world.extend(World)
      @current_world.__cucumber_step_mother = self

      @current_world.extend(::Spec::Matchers) if defined?(::Spec::Matchers)
      @current_world
    end

    def current_world
      @current_world
    end

    def step_match(step_name)
      matches = step_definitions.map { |d| d.step_match(step_name) }.compact
      raise Undefined.new(step_name) if matches.empty?
      found = best_matches(step_name, matches) if matches.size > 1 && options[:guess]
      raise Ambiguous.new(step_name, matches) if matches.size > 1
      matches[0]
    end

    # Looks up the StepDefinition that matches +step_name+
    def step_definition(step_name) #:nodoc:
      found = step_definitions.select do |step_definition|
        step_definition.match(step_name)
      end
      raise Undefined.new(step_name) if found.empty?
      found = best_matches(step_name, found) if found.size > 1 && options[:guess]
      raise Ambiguous.new(step_name, found) if found.size > 1
      found[0]
    end

    def best_matches(step_name, step_definitions)
      top_group_score = step_definitions.map {|s| s.match(step_name).captures.length }.sort.last
      top_groups = step_definitions.select {|s| s.match(step_name).captures.length == top_group_score }
      if top_groups.size > 1
        shortest_capture_length = top_groups.map {|s| s.match(step_name).captures.inject(0) {|sum, c| sum + c.length } }.sort.first
        top_groups.select {|s| s.match(step_name).captures.inject(0) {|sum, c| sum + c.length } == shortest_capture_length }
      else
        top_groups
      end
    end
    
    def step_definitions
      @step_definitions ||= []
    end

    def snippet_text(step_keyword, step_name)
      @snippet_generator.snippet_text(step_keyword, step_name)
    end

    private

    def options
      @options || {}
    end
  end
end
