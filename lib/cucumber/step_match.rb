require 'cucumber/multiline_argument'

module Cucumber
  class StepMatch #:nodoc:
    attr_reader :step_definition, :step_arguments

    # Creates a new StepMatch. The +name_to_report+ argument is what's
    # reported, unless it's is, in which case +name_to_report+ is used instead.
    #
    def initialize(step_definition, name_to_match, name_to_report, step_arguments)
      raise "name_to_match can't be nil" if name_to_match.nil?
      raise "step_arguments can't be nil (but it can be an empty array)" if step_arguments.nil?
      @step_definition, @name_to_match, @name_to_report, @step_arguments = step_definition, name_to_match, name_to_report, step_arguments
    end

    def args
      @step_arguments.map{|g| g.val }
    end

    def name
      @name_to_report
    end

    def activate(test_step)
      test_step.with_action(@step_definition.file_colon_line) do
        invoke(MultilineArgument.from_core(test_step.source.last.multiline_arg))
      end
    end

    def invoke(multiline_arg)
      all_args = deep_clone_args
      multiline_arg.append_to(all_args)
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
      @name_to_report || replace_arguments(@name_to_match, @step_arguments, format, &proc)
    end

    def file_colon_line
      @step_definition.file_colon_line
    end

    def backtrace_line
      "#{file_colon_line}:in `#{@step_definition.regexp_source}'"
    end

    def text_length
      @step_definition.regexp_source.unpack('U*').length
    end

    def replace_arguments(string, step_arguments, format, &proc)
      s = string.dup
      offset = past_offset = 0
      step_arguments.each do |step_argument|
        next if step_argument.offset.nil? || step_argument.offset < past_offset

        replacement = if block_given?
          proc.call(step_argument.val)
        elsif Proc === format
          format.call(step_argument.val)
        else
          format % step_argument.val
        end

        s[step_argument.offset + offset, step_argument.val.length] = replacement
        offset += replacement.unpack('U*').length - step_argument.val.unpack('U*').length
        past_offset = step_argument.offset + step_argument.val.length
      end
      s
    end

    def inspect #:nodoc:
      sprintf("#<%s:0x%x>", self.class, self.object_id)
    end

    private
    def deep_clone_args
      Marshal.load( Marshal.dump( args ) )
    end
  end

  class SkippingStepMatch
    def activate(test_step)
      return test_step.with_action { raise Core::Test::Result::Skipped.new }
    end
  end

  class NoStepMatch #:nodoc:
    attr_reader :step_definition, :name

    def initialize(step, name)
      @step = step
      @name = name
    end

    def format_args(*args)
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

    def step_arguments
      []
    end

    def activate(test_step)
      # noop
      return test_step
    end
  end
end
