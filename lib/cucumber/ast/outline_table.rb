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
          if n == 0 || matches?(visitor, row)
            visitor.visit_table_row(row)
          end
        end
        nil
      end

      def descend?(visitor)
        cells_rows.detect{|cells_row| cells_row.descend?(visitor)}
      end
      
      def matches?(visitor, cells)
        @scenario_outline.matches_tags_and_name?(visitor) &&
        (visitor.matches_lines?(cells) || visitor.matches_lines?(@scenario_outline))
      end

      def invocations(cells)
        @scenario_outline.invocations(cells)
      end

      class ExampleCells < Cells
        def descend?(visitor)
          @table.matches?(visitor, self)
        end

        def accept(visitor)
          if header?
            @cells.each do |cell|
              cell.status = :skipped
              visitor.visit_table_cell(cell)
            end
          else
            @table.invocations(self).each do |step_invocation|
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
