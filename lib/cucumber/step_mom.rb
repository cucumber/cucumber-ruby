require 'cucumber/step_definition'

module Cucumber
  # This is the main interface for registering step definitions, which is done
  # from <tt>*_steps.rb</tt> files. This module is included right at the top-level
  # so #register_step_definition (and more interestingly - its aliases) are
  # available from the top-level.
  module StepMom

    class Pending < StandardError
    end

    class Multiple < StandardError
      # TODO: Give the user some hints about how to resolve ambiguity.
    end

    class Duplicate < StandardError
      def initialize(step_def_1, step_def_2)
      end
    end

    # Registers a new StepDefinition. This method is aliased
    # to <tt>Given</tt>, <tt>When</tt> and <tt>Then</tt>,
    # and you can create your own aliases simply by
    # adding the following to your <tt>support/env.rb</tt>:
    #
    #   # Given When Then in Norwegian
    #   %w{Gitt Når Så}.each do |adverb|
    #     alias_method adverb, :register_step_definition
    #   end
    #
    def register_step_definition(regexp, &proc)
      step_definition = StepDefinition.new(regexp, &proc)
      step_definitions.each do |already|
        raise Duplicate.new(already, step_definition) if already.match(regexp)
      end
      step_definitions << step_definition
    end

    %w{Given When Then}.each do |adverb|
      alias_method adverb, :register_step_definition
    end

    # Finds a StepDefinition that matches +step_name+ and
    # executes it in the context of +world+. Any number
    # of +inline_args+ can be passed, although in practice
    # there will be 0 or 1, since the parser only supports
    # 1 inline argument (Table or InlineString) per Step.
    def execute_step(step_name, world, *inline_args) #:nodoc
      step_definition = find_step_definition(step_name)
      step_definition.execute_in(world, step_name, *inline_args)
    end
    
    # Formats the matched arguments of a Step. This method
    # is usually called from visitors, which render output.
    #
    # The +format+ either be a String or a Proc.
    #
    # If it is a String it should be a format string according to
    # <tt>Kernel#sprinf</tt>, for example:
    #
    #   '<span class="param">%s</span></tt>'
    #
    # If it is a Proc, it should take one argument and return the formatted
    # argument, for example:
    #
    #   lambda { |param| "[#{param}]" }
    #
    def format_args(step_name, format)
      step_definition = find_step_definition(step_name)
      step_definition.format_args(step_name, format)
    end

    private

    def find_step_definition(step_name)
      found = step_definitions.select do |step_definition|
        step_definition.match(step_name)
      end
      raise Pending.new(step_name) if found.empty?
      raise Multiple.new(step_name) if found.size > 1
      found[0]
    end

    def step_definitions
      @step_definitions ||= []
    end
  end
end