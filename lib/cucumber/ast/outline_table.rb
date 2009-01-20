module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
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
