require 'cucumber/step_match'
require 'cucumber/core_ext/string'
require 'cucumber/core_ext/proc'

module Cucumber
  # A Step Definition holds a Regexp and a Proc, and is created
  # by calling <tt>Given</tt>, <tt>When</tt> or <tt>Then</tt>
  # in the <tt>step_definitions</tt> ruby files - for example:
  #
  #   Given /I have (\d+) cucumbers in my belly/ do
  #     # some code here
  #   end
  #
  class RbStepDefinition
    include LanguageSupport::StepDefinitionMethods

    class MissingProc < StandardError
      def message
        "Step definitions must always have a proc"
      end
    end

    attr_reader :proc

    def initialize(rb_language, pattern, &proc)
      raise MissingProc if proc.nil?
      if String === pattern
        p = pattern.gsub(/\$\w+/, '(.*)') # Replace $var with (.*)
        pattern = Regexp.new("^#{p}$") 
      end
      @rb_language, @regexp, @proc = rb_language, pattern, proc
    end

    def regexp
      @regexp
    end

    def invoke(args)
      args = args.map{|arg| Ast::PyString === arg ? arg.to_s : arg}
      begin
        @rb_language.current_world.cucumber_instance_exec(true, regexp.inspect, *args, &@proc)
      rescue Cucumber::ArityMismatchError => e
        e.backtrace.unshift(self.backtrace_line)
        raise e
      end
    end

    def file_colon_line
      @proc.file_colon_line
    end
    
    def file
      @file ||= file_colon_line.split(':')[0]
    end
  end
end
