require 'cucumber/step_definition'
require 'cucumber/core_ext/instance_exec'

module Cucumber
  class Undefined < StandardError
    attr_reader :step_name

    def initialize(step_name)
      super %{Undefined step: "#{step_name}"}
      @step_name = step_name
    end
    Cucumber::EXCEPTION_STATUS[self] = :undefined
  end

  class Pending < StandardError
    Cucumber::EXCEPTION_STATUS[self] = :pending
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
    attr_writer :snippet_generator
    attr_writer :options
    
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

    def world(scenario, prior_world = nil, &proc)
      world = prior_world || new_world
      begin
        (@before_procs ||= []).each do |proc|
          world.cucumber_instance_exec(false, 'Before', scenario, &proc)
        end
        yield world
      ensure
        (@after_procs ||= []).each do |proc|
          world.cucumber_instance_exec(false, 'After', scenario, &proc)
        end
      end
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

    # Creates a new world instance
    def new_world #:nodoc:
      world = Object.new
      (@world_procs ||= []).each do |proc|
        world = proc.call(world)
      end

      world.extend(WorldMethods)
      world.__cucumber_step_mother = self

      world.extend(::Spec::Matchers) if defined?(::Spec::Matchers)
      world
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
    
    def print_step_definitions(out)
      step_definitions.each do |step_definition|
        indent = max_step_definition_length - step_definition.text_length
        out.puts(step_definition.to_s(indent))
      end
    end

    private

    def max_step_definition_length
      @max_step_definition_length ||= step_definitions.map{|step_definition| step_definition.text_length}.max
    end

    def options
      @options || {}
    end

    module WorldMethods #:nodoc:
      attr_writer :__cucumber_step_mother, :__cucumber_current_step

      # Call a step from within a step definition
      def __cucumber_invoke(name, *multiline_arguments)
        begin
          # TODO: Very similar to code in Step. Refactor. Get back StepInvocation?
          # Make more similar to JBehave?
          step_definition = @__cucumber_step_mother.step_definition(name)
          matched_args = step_definition.matched_args(name)
          args = (matched_args + multiline_arguments)
          step_definition.execute(name, self, *args)
        rescue Exception => e
          @__cucumber_current_step.exception = e
          raise e
        end
      end
      
      def table(text, file=nil, line=0)
        @table_parser ||= Parser::TableParser.new
        @table_parser.parse_or_fail(text.strip, file, line)
      end

      def pending(message = "TODO")
        if block_given?
          begin
            yield
          rescue Exception => e
            raise Pending.new(message)
          end
          raise Pending.new("Expected pending '#{message}' to fail. No Error was raised. No longer pending?")
        else
          raise Pending.new(message)
        end
      end
    end
  end
end
