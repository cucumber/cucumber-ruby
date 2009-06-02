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

  # Raised when a step matches 2 or more StepDefinition
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

  class NilWorld < StandardError
    def initialize
      super("World procs should never return nil")
    end
  end

  class MultipleWorld < StandardError
    def initialize(first_proc, second_proc)
      message = "You can only pass a proc to #World once, but it's happening\n"
      message << "in 2 places:\n\n"
      message << first_proc.backtrace_line('World') << "\n"
      message << second_proc.backtrace_line('World') << "\n\n"
      message << "Use Ruby modules instead to extend your worlds. See the Cucumber::StepMother#World RDoc\n"
      message << "or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.\n\n"
      super(message)
    end
  end

  # This is the main interface for registering step definitions, which is done
  # from <tt>*_steps.rb</tt> files. This module is included right at the top-level
  # so #register_step_definition (and more interestingly - its aliases) are
  # available from the top-level.
  module StepMother
    class Hook
      def initialize(tag_names, proc)
        @tag_names = tag_names.map{|tag| Ast::Tags.strip_prefix(tag)}
        @proc = proc
      end

      def matches_tag_names?(tag_names)
        @tag_names.empty? || (@tag_names & tag_names).any?
      end

      def execute_in(world, scenario, location, exception_fails_scenario = true)
        begin
          world.cucumber_instance_exec(false, location, scenario, &@proc)
        rescue Exception => exception
          if exception_fails_scenario
            scenario.fail!(exception)
          else
            raise
          end
        end
      end
    end

    class << self
      def alias_adverb(adverb)
        adverb = adverb.gsub(/\s/, '')
        alias_method adverb, :register_step_definition
      end
    end

    attr_writer :snippet_generator, :options, :visitor

    def options
      @options ||= {}
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

    def scenarios(status = nil)
      @scenarios ||= []
      if(status)
        @scenarios.select{|scenario| scenario.status == status}
      else
        @scenarios
      end
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
    def Before(*tag_names, &proc)
      register_hook(:before, tag_names, proc)
    end

    def After(*tag_names, &proc)
      register_hook(:after, tag_names, proc)
    end

    def AfterStep(*tag_names, &proc)
      register_hook(:after_step, tag_names, proc)
    end

    def register_hook(phase, tags, proc)
      hook = Hook.new(tags, proc)
      hooks[phase] << hook
      hook
    end

    def hooks
      @hooks ||= Hash.new {|hash, phase| hash[phase] = []}
    end

    def hooks_for(phase, scenario)
      hooks[phase].select{|hook| scenario.accept_hook?(hook)}
    end

    # Registers any number of +world_modules+ (Ruby Modules) and/or a Proc.
    # The +proc+ will be executed once before each scenario to create an
    # Object that the scenario's steps will run within. Any +world_modules+
    # will be mixed into this Object (via Object#extend).
    #
    # This method is typically called from one or more Ruby scripts under 
    # <tt>features/support</tt>. You can call this method as many times as you 
    # like (to register more modules), but if you try to register more than 
    # one Proc you will get an error.
    #
    # Cucumber will not yield anything to the +proc+ (like it used to do before v0.3).
    #
    # In earlier versions of Cucumber (before 0.3) you could not register
    # any +world_modules+. Instead you would register several Proc objects (by 
    # calling the method several times). The result of each +proc+ would be yielded 
    # to the next +proc+. Example:
    #
    #   World do |world| # NOT SUPPORTED FROM 0.3
    #     MyClass.new
    #   end
    #
    #   World do |world| # NOT SUPPORTED FROM 0.3
    #     world.extend(MyModule)
    #   end
    #
    # From Cucumber 0.3 the recommended way to do this is:
    #
    #    World do
    #      MyClass.new
    #    end
    #
    #    World(MyModule)
    #
    def World(*world_modules, &proc)
      if(proc)
        raise MultipleWorld.new(@world_proc, proc) if @world_proc
        @world_proc = proc
      end
      @world_modules ||= []
      @world_modules += world_modules
    end

    def current_world
      @current_world
    end

    def step_match(step_name, formatted_step_name=nil)
      matches = step_definitions.map { |d| d.step_match(step_name, formatted_step_name) }.compact
      raise Undefined.new(step_name) if matches.empty?
      matches = best_matches(step_name, matches) if matches.size > 1 && options[:guess]
      raise Ambiguous.new(step_name, matches, options[:guess]) if matches.size > 1
      matches[0]
    end

    def best_matches(step_name, step_matches)
      max_arg_length = step_matches.map {|step_match| step_match.args.length }.max
      top_groups     = step_matches.select {|step_match| step_match.args.length == max_arg_length }

      if top_groups.length > 1
        shortest_capture_length = top_groups.map {|step_match| step_match.args.inject(0) {|sum, c| sum + c.length } }.min
        top_groups.select {|step_match| step_match.args.inject(0) {|sum, c| sum + c.length } == shortest_capture_length }
      else
        top_groups
      end
    end
    
    def clear!
      step_definitions.clear
      hooks.clear
      steps.clear
      scenarios.clear
    end

    def step_definitions
      @step_definitions ||= []
    end

    def snippet_text(step_keyword, step_name, multiline_arg_class)
      @snippet_generator.snippet_text(step_keyword, step_name, multiline_arg_class)
    end

    def before_and_after(scenario, skip=false)
      before(scenario) unless skip
      @current_scenario = scenario
      yield scenario
      @current_scenario = nil
      after(scenario) unless skip
      scenario_visited(scenario)
    end
    
    def before(scenario)
      unless current_world
        new_world!
        execute_before(scenario)
      end
    end
    
    def after(scenario)
      execute_after(scenario)
      nil_world!
    end
    
    def after_step
      execute_after_step(@current_scenario)
    end
    
    private

    def max_step_definition_length
      @max_step_definition_length ||= step_definitions.map{|step_definition| step_definition.text_length}.max
    end

    # Creates a new world instance
    def new_world!
      return if options[:dry_run]
      create_world!
      extend_world
      connect_world
      @current_world
    end

    def create_world!
      if(@world_proc)
        @current_world = @world_proc.call
        check_nil(@current_world, @world_proc)
      else
        @current_world = Object.new
      end
    end

    def extend_world
      @current_world.extend(World)
      @current_world.extend(::Spec::Matchers) if defined?(::Spec::Matchers)
      (@world_modules || []).each do |mod|
        @current_world.extend(mod)
      end
    end

    def connect_world
      @current_world.__cucumber_step_mother = self
      @current_world.__cucumber_visitor = @visitor
    end

    def check_nil(o, proc)
      if o.nil?
        begin
          raise NilWorld.new
        rescue NilWorld => e
          e.backtrace.clear
          e.backtrace.push(proc.backtrace_line("World"))
          raise e
        end
      else
        o
      end
    end

    def nil_world!
      @current_world = nil
    end

    def execute_before(scenario)
      return if options[:dry_run]
      hooks_for(:before, scenario).each do |hook|
        hook.execute_in(@current_world, scenario, 'Before')
      end
    end

    def execute_after(scenario)
      return if options[:dry_run]
      hooks_for(:after, scenario).each do |hook|
        hook.execute_in(@current_world, scenario, 'After')
      end
    end

    def execute_after_step(scenario)
      return if options[:dry_run]
      hooks_for(:after_step, scenario).each do |hook|
        hook.execute_in(@current_world, scenario, 'AfterStep', false)
      end
    end

    def scenario_visited(scenario)
      scenarios << scenario unless scenarios.index(scenario)
    end
  end
end
