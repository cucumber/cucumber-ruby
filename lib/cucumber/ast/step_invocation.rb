module Cucumber
  module Ast
    class StepInvocation
      attr_writer :step_collection, :background
      attr_reader :name, :matched_cells, :status
      attr_accessor :exception

      def initialize(step, name, multiline_arg, matched_cells)
        @step, @name, @multiline_arg, @matched_cells = step, name, multiline_arg, matched_cells
        status!(:skipped)
      end

      def background?
        @background
      end

      def skip_invoke!
        @skip_invoke = true
      end

      def accept(visitor)
        invoke(visitor.step_mother, visitor.options)
        @step.visit_step_details(visitor, @step_match, @multiline_arg, @status, @exception, @background)
      end

      def invoke(step_mother, options)
        find_step_match!(step_mother)
        unless @skip_invoke || options[:dry_run] || exception || @step_collection.exception
          @skip_invoke = true
          begin
            step_mother.current_world.__cucumber_current_step = self if step_mother.current_world # Nil in Pure Java
            @step_match.invoke(step_mother.current_world, @multiline_arg)
            status!(:passed)
          rescue Pending => e
            failed(e, false)
            status!(:pending)
          rescue Undefined => e
            failed(e, false)
            status!(:undefined)
          rescue Exception => e
            failed(e, false)
            status!(:failed)
          end
        end
      end

      def find_step_match!(step_mother)
        return if @step_match
        begin
          @step_match = step_mother.step_match(@name)
        rescue Undefined => e
          failed(e, true)
          status!(:undefined)
          @step_match = NoStepMatch.new(@step)
        rescue Ambiguous => e
          failed(e, false)
          status!(:failed)
          @step_match = NoStepMatch.new(@step)
        end
        step_mother.step_visited(self)
      end

      def failed(exception, clear_backtrace)
        @exception = exception
        @exception.set_backtrace([]) if clear_backtrace
        @exception.backtrace << @step.backtrace_line unless @step.backtrace_line.nil?
      end

      def status!(status)
        @status = status
        @multiline_arg.status = status if @multiline_arg
        @matched_cells.each do |cell|
          cell.status = status
        end
      end

      def previous
        @step_collection.previous_step(self)
      end

      def actual_keyword
        if [Cucumber.keyword_hash['and'], Cucumber.keyword_hash['but']].index(@step.keyword) && previous
          previous.actual_keyword
        else
          keyword
        end
      end

      def matches_lines?(lines)
        @step.matches_lines?(lines)
      end

      def text_length
        @step.text_length
      end

      def keyword
        @step.keyword
      end

      def file_colon_line
        @step.file_colon_line
      end

      def dom_id
        @step.dom_id
      end

      def backtrace_line
        @step.backtrace_line
      end

      def to_sexp
        [:step_invocation, @step.line, @step.keyword, @name, (@multiline_arg.nil? ? nil : @multiline_arg.to_sexp)].compact
      end
    end
  end
end