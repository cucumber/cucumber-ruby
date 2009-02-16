module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
      end

      def accept(visitor)
        cells_rows.each_with_index do |row, n|
          should_visit = n == 0 || 
            row.at_lines?(visitor.current_feature_lines) ||
            @scenario_outline.at_header_or_step_lines?(visitor.current_feature_lines)

          if should_visit
            visitor.visit_table_row(row)
          end
        end
        nil
      end

      def step_invocations(cells)
        @scenario_outline.step_invocations(cells)
      end

      class ExampleCells < Cells
        def accept(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped
              visitor.visit_table_cell(cell)
            end
          else
            visitor.step_mother.execute_scenario(self) do
              step_invocations.each_step do |step_invocation|
                step_invocation.invoke(visitor.step_mother)
                @exception ||= step_invocation.exception
              end
            end

            @cells.each do |cell|
              visitor.visit_table_cell(cell)
            end
          end
        end

        private

        def step_invocations
          @step_invocations ||= @table.step_invocations(self)
        end

        def header?
          index == 0
        end
      end
    end
  end
end
