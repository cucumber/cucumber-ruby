module Cucumber
  class StepMatch #:nodoc:
    attr_reader :step_definition

    def initialize(step_definition, step_name, formatted_step_name, groups)
      @step_definition, @step_name, @formatted_step_name, @groups = step_definition, step_name, formatted_step_name, groups
    end

    def args
      @groups.map{|g| g.val}
    end

    def name
      @formatted_step_name
    end

    def invoke(multiline_arg)
      all_args = args
      all_args << multiline_arg if multiline_arg
      @step_definition.invoke(all_args)
    end

    # Formats the matched arguments of the associated Step. This method
    # is usually called from visitors, which render output.
    #
    # The +format+ can either be a String or a Proc.
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
    def format_args(format = lambda{|a| a}, &proc)
      @formatted_step_name || gzub(@step_name, @groups, format, &proc)
    end
    
    def file_colon_line
      @step_definition.file_colon_line
    end

    def backtrace_line
      @step_definition.backtrace_line
    end

    def text_length
      @step_definition.text_length
    end

    # +groups+ is an array of 2-element arrays, where
    # the 1st element is the value of a regexp match group,
    # and the 2nd element is its start index.
    def gzub(string, groups, format=nil, &proc)
      s = string.dup
      offset = 0
      groups.each do |group|
        replacement = if block_given?
          proc.call(group.val)
        elsif Proc === format
          format.call(group.val)
        else
          format % group.val
        end

        s[group.start + offset, group.val.length] = replacement
        offset += replacement.length - group.val.length
      end
      s
    end
  end
  
  class NoStepMatch #:nodoc:
    attr_reader :step_definition, :name

    def initialize(step, name)
      @step = step
      @name = name
    end
    
    def format_args(format)
      @name
    end

    def file_colon_line
      raise "No file:line for #{@step}" unless @step.file_colon_line
      @step.file_colon_line
    end

    def backtrace_line
      @step.backtrace_line
    end

    def text_length
      @step.text_length
    end
  end
end
