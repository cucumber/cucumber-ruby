module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
      end

      def accept(visitor, status)
        cells_rows.each_with_index do |row, n|
          should_visit = n == 0 || 
            row.at_lines?(visitor.current_feature_lines) ||
            @scenario_outline.at_header_or_step_lines?(visitor.current_feature_lines)

          if should_visit
            visitor.visit_table_row(row, status)
          end
        end
        nil
      end

      def execute_row(cells, visitor, &proc)
        @scenario_outline.execute_row(cells, visitor, &proc)
      end

      class ExampleCells < Cells
        def accept(visitor, status)
          if header?
            @cells.each do |cell|
              visitor.visit_table_cell(cell, :thead)
            end
            nil
          else
            exception = @table.execute_row(self, visitor) do |cell, status|
              visitor.visit_table_cell(cell, status)
            end
          end
        end

        private

        def header?
          index == 0
        end
      end
    end
  end
end
