module Cucumber
  module FeatureElement
    attr_writer :feature

    def attach_steps(steps)
      steps.each {|step| step.feature_element = self}
    end

    def file_colon_line(line = @line)
      @feature.file_colon_line(line) if @feature
    end

    def text_length
      @keyword.jlength + @name.jlength
    end

    def at_lines?(lines)
      lines.empty? || lines.index(@line) || @steps.at_lines?(lines) || @tags.at_lines?(lines)
    end

    def backtrace_line(name = "#{@keyword} #{@name}", line = @line)
      @feature.backtrace_line(name, line) if @feature
    end

    def source_indent(text_length)
      max_line_length - text_length
    end

    def max_line_length
      @steps.max_line_length(self)
    end

    # TODO: Remove when we use StepCollection everywhere
    def previous_step(step)
      i = @steps.index(step) || -1
      @steps[i-1]
    end

    def tagged_with?(tag_names)
      @tags.among?(tag_names)
    end

    def undefined?
      @steps.empty?
    end
  end
end