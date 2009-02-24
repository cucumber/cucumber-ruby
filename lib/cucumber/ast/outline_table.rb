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
          if n == 0 || visitor.matches_filters?(@scenario_outline) || visitor.matches_filters?(row)
            visitor.visit_table_row(row)
          end
        end
        nil
      end

      def each_invocation(cells, &block)
        @scenario_outline.each_invocation(cells, &block)
      end

      class ExampleCells < Cells
        def accept(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped
              visitor.visit_table_cell(cell)
            end
          else
            @table.each_invocation(self) do |step_invocation|
              step_invocation.invoke(visitor.step_mother, visitor.options)
              @exception ||= step_invocation.exception
            end

            @cells.each do |cell|
              visitor.visit_table_cell(cell)
            end
            visitor.step_mother.scenario_visited(self)
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
