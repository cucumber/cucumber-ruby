module Cucumber
  class StepInvocation
    attr_writer :step_collection
    attr_reader :name, :matched_cells, :exception

    def initialize(step, name, multiline_arg, matched_cells)
      @step, @name, @multiline_arg, @matched_cells = step, name, multiline_arg, matched_cells
    end

    def accept(visitor)
      unless @invoked || visitor.options[:dry_run] || previous.exception
        invoke(visitor.step_mother)
        @invoked = true
        visitor.step_mother.step_executed(self)
      end
      @step.visit_step_details(visitor, @step_match, @multiline_arg, status, @exception)
    end

    def invoke(step_mother)
      begin
        @step_match = step_mother.step_match(@name)
        begin
          @step.invoke(@step_match, step_mother.current_world)
        rescue Pending => exception
          failed(exception, false)
        rescue Exception => exception
          failed(exception, false)
        end
      rescue Undefined => exception
        @step_match = StepMatch.new(nil, @name, [])
        failed(exception, true)
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

    def status
      Cucumber::EXCEPTION_STATUS[@exception.class]
    end

    def previous
      @step_collection.previous_step(self)
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