module Cucumber
  class StepInvocation
    attr_writer :step_collection
    attr_reader :name, :matched_cells, :exception, :status

    def initialize(step, name, multiline_arg, matched_cells)
      @step, @name, @multiline_arg, @matched_cells = step, name, multiline_arg, matched_cells
      @status = :skipped
    end

    def accept(visitor)
      find_step_match!(visitor.step_mother, visitor.options[:strict])
      visitor.step_mother.step_accepted(self)

      unless @invoked || visitor.options[:dry_run] || exception || previous.exception
        invoke(visitor.step_mother)
        @invoked = true
      end
      @step.visit_step_details(visitor, @step_match, @multiline_arg, status, @exception)
    end

    def find_step_match!(step_mother, strict)
      return if @step_match
      begin
        @step_match = step_mother.step_match(@name)
      rescue Undefined => e
        @status = :undefined
        failed(e, true)
        @step_match = NoStepMatch.new(@step)
      rescue Ambiguous => e
        failed(e, false)
        @status = :failed
        @step_match = NoStepMatch.new(@step)
      end
      @step_match
    end

    def invoke(step_mother)
      begin
        @step.invoke(@step_match, step_mother.current_world)
        @status = :passed
      rescue Pending => e
        failed(e, false)
        @status = :pending
      rescue Exception => e
        failed(e, false)
        @status = :failed
      ensure
        step_mother.step_accepted(self)
      end
    end

    def failed(exception, clear_backtrace)
      @exception = exception
      @exception.set_backtrace([]) if clear_backtrace
      @exception.backtrace << @step.backtrace_line unless @step.backtrace_line.nil?

      @matched_cells.each do |cell|
        cell.status = status
      end
    end

    def previous
      @step_collection.previous_step(self)
    end

    def actual_keyword
      if [Cucumber.keyword_hash['and'], Cucumber.keyword_hash['but']].index(@keyword) && previous
        previous.actual_keyword
      else
        @step.keyword
      end
    end

    def at_lines?(lines)
      @step.at_lines?(lines)
    end

    def text_length
      @step.text_length
    end

    def to_sexp
      [:step_invocation, @step.line, @step.keyword, @name, (@multiline_arg.nil? ? nil : @multiline_arg.to_sexp)].compact
    end
  end
end