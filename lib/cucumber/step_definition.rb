require 'cucumber/core_ext/string'

module Cucumber
  # A Step Definition holds a Regexp and a Proc, and is created
  # by calling <tt>Given</tt>, <tt>When</tt> or <tt>Then</tt>
  # in the <tt>step_definitions</tt> ruby files - for example:
  #
  #   Given /I have (\d+) cucumbers in my belly/ do
  #     # some code here
  #   end
  #
  class StepDefinition
    attr_reader :regexp

    def initialize(regexp, &proc)
      @regexp, @proc = regexp, proc
      @proc.extend(CoreExt::CallIn)
    end

    #:stopdoc:

    def match(step_name)
      case step_name
      when String then @regexp.match(step_name)
      when Regexp then @regexp == step_name
      end
    end

    def format_args(step_name, format)
      step_name.gzub(@regexp, format)
    end

    def execute_by_name(world, step_name, *inline_args)
      args = step_name.match(@regexp).captures + inline_args
      execute(world, *args)
    end

    def execute(world, *args)
      begin
        @proc.call_in(world, *args)
      rescue Exception => e
        method_line = "#{__FILE__}:#{__LINE__ - 2}:in `execute'"
        e.cucumber_strip_backtrace!(method_line, @regexp.to_s)
        raise e
      end
    end
  end
end
