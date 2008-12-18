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

    def execute_in(world, step_name, *inline_args)
      args = step_name.match(@regexp).captures
      @proc.call_in(world, *(args + inline_args))
    end

    def strip_backtrace!(error, line)
      error.cucumber_strip_backtrace!(line, regexp.to_s)
    end
  end
end
