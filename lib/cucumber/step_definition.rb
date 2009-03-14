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
  class StepDefinition
    def self.snippet_text(step_keyword, step_name)
      escaped = Regexp.escape(step_name).gsub('\ ', ' ').gsub('/', '\/')
      "#{step_keyword} /^#{escaped}$/ do\n  pending\nend"
    end

    class MissingProc < StandardError
      def message
        "Step definitions must always have a proc"
      end
    end

    attr_reader :regexp

    def initialize(pattern, &proc)
      raise MissingProc if proc.nil?
      if String === pattern
        p = pattern.gsub(/\$\w+/, '(.*)')
        pattern = Regexp.new("^#{p}$") 
      end
      @regexp, @proc = pattern, proc
    end

    #:stopdoc:

    def match(step_name)
      case step_name
      when String then @regexp.match(step_name)
      when Regexp then @regexp == step_name
      end
    end

    # Formats the matched arguments of the associated Step. This method
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
      step_name.gzub(@regexp, format)
    end

    def matched_args(step_name)
      step_name.match(@regexp).captures
    end

    def execute(step_name, world, *args)
      args = args.map{|arg| Ast::PyString === arg ? arg.to_s : arg}
      begin
        world.cucumber_instance_exec(true, @regexp.inspect, *args, &@proc)
      rescue Cucumber::ArityMismatchError => e
        e.backtrace.unshift(self.to_backtrace_line)
        raise e
      end
    end

    def to_backtrace_line
      "#{file_colon_line}:in `#{@regexp.inspect}'"
    end

    def file_colon_line
      @proc.file_colon_line
    end

    def text_length
      @regexp.inspect.jlength
    end

    def to_s(indent = 0)
      @regexp.inspect + (' # ').indent(indent) + file_colon_line
    end
  end
end
