module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
        create_step_invocations_for_example_rows!(scenario_outline)
      end

      def accept(visitor)
        cells_rows.each_with_index do |row, n|
          visitor.visit_table_row(row)
        end
        nil
      end

      def accept_hook?(hook)
        @scenario_outline.accept_hook?(hook)
      end

      def skip_invoke!
        example_rows.each do |cells|
          cells.skip_invoke!
        end
      end

      def create_step_invocations_for_example_rows!(scenario_outline)
        example_rows.each do |cells|
          cells.create_step_invocations!(scenario_outline)
        end
      end
      
      def example_rows
        cells_rows[1..-1]
      end

      class ExampleCells < Cells
        def create_step_invocations!(scenario_outline)
          @step_invocations = scenario_outline.step_invocations(self)
        end
        
        def skip_invoke!
          @step_invocations.each do |step_invocation|
            step_invocation.skip_invoke!
          end
        end

        def accept(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped_param
              visitor.visit_table_cell(cell)
            end
          else
            visitor.step_mother.before_and_after(self) do
              @step_invocations.each do |step_invocation|
                step_invocation.invoke(visitor.step_mother, visitor.options)
                @exception ||= step_invocation.exception
              end

              @cells.each do |cell|
                visitor.visit_table_cell(cell)
              end
            end
          end
        end

        def accept_hook?(hook)
          @table.accept_hook?(hook)
        end

        private

        def header?
          index == 0
        end
      end
    end
  end
end
