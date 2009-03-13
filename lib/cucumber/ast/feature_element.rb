module Cucumber
  module FeatureElement
    def attach_steps(steps)
      steps.each {|step| step.feature_element = self}
    end

    def file_colon_line(line = @line)
      @feature.file_colon_line(line) if @feature
    end

    def text_length
      @keyword.jlength + @name.jlength
    end

    def matches_lines?(lines)
      lines.index(@line) || @steps.matches_lines?(lines) || @tags.matches_lines?(lines)
    end

    def has_tags?(tags)
      @tags.has_tags?(tags) || @feature.has_tags?(tags)
    end

    def matches_scenario_names?(scenario_names)
      scenario_names.detect{|name| name == @name}
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
    
  end
end