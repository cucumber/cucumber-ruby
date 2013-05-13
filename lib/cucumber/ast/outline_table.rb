module Cucumber
  module Ast
    class OutlineTable < Table #:nodoc:
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleRow
        example_rows.each do |cells|
          cells.create_step_invocations!(scenario_outline)
        end
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        visitor.visit_outline_table(self) do
          cells_rows.each do |row|
            row.accept(visitor)
          end
        end
        nil
      end

      def accept_hook?(hook)
        @scenario_outline.accept_hook?(hook)
      end

      def source_tags
        @scenario_outline.source_tags
      end

      def source_tag_names
        source_tags.map { |tag| tag.name }
      end

      def skip_invoke!
        example_rows.each do |cells|
          cells.skip_invoke!
        end
      end

      def example_rows
        cells_rows[1..-1]
      end

      def visit_scenario_name(visitor, row)
        @scenario_outline.visit_scenario_name(visitor, row)
      end

      def language
        @scenario_outline.language
      end

      class ExampleRow < Cells #:nodoc:
        class InvalidForHeaderRowError < NoMethodError
          def initialize(*args)
            super 'This is a header row and cannot pass or fail'
          end
        end

        attr_reader :scenario_outline # https://rspec.lighthouseapp.com/projects/16211/tickets/342

        def initialize(table, cells)
          super
          @scenario_exception = nil
        end

        def source_tag_names
          source_tags.map { |tag| tag.name }
        end

        def source_tags
          @table.source_tags
        end

        def create_step_invocations!(scenario_outline)
          @scenario_outline = scenario_outline
          @step_invocations = scenario_outline.step_invocations(self)
        end

        def skip_invoke!
          @step_invocations.each do |step_invocation|
            step_invocation.skip_invoke!
          end
        end

        def accept(visitor)
          return if Cucumber.wants_to_quit
          if visitor.configuration.expand? 
            accept_expand(visitor) 
          else
            visitor.visit_table_row(self) do
              accept_plain(visitor)
            end
          end
        end

        def accept_plain(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped_param
              cell.accept(visitor)
            end
          else
            visitor.runtime.with_hooks(self) do
              @step_invocations.each do |step_invocation|
                step_invocation.invoke(visitor.runtime, visitor.configuration)
                @exception ||= step_invocation.reported_exception
              end

              @cells.each do |cell|
                cell.accept(visitor)
              end

              visitor.visit_exception(@scenario_exception, :failed) if @scenario_exception
            end
          end
        end

        def accept_expand(visitor)
          return if header?
          visitor.runtime.with_hooks(self) do
            @table.visit_scenario_name(visitor, self)
            @step_invocations.each do |step_invocation|
              step_invocation.accept(visitor)
              @exception ||= step_invocation.reported_exception
            end
          end
        end

        def accept_hook?(hook)
          @table.accept_hook?(hook)
        end

        def exception
          @exception || @scenario_exception
        end

        def fail!(exception)
          @scenario_exception = exception
        end

        # Returns true if one or more steps failed
        def failed?
          raise InvalidForHeaderRowError if header?
          @step_invocations.failed? || !!@scenario_exception
        end

        # Returns true if all steps passed
        def passed?
          !failed?
        end

        # Returns the status
        def status
          return :failed if @scenario_exception
          @step_invocations.status
        end

        def backtrace_line
          @scenario_outline.backtrace_line(name, line)
        end

        def name
          "| #{@cells.collect{|c| c.value }.join(' | ')} |"
        end

        def language
          @table.language
        end

        private

        def header?
          index == 0
        end
      end
    end
  end
end
