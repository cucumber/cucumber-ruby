module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
      end

      def execute_row(cells)
        @scenario_outline.execute_row(cells)
      end

      class ExampleCells < Cells
        def accept(visitor, status)
          @table.execute_row(self.to_hash) unless header?
          visit_cells(visitor, :passed)
        rescue StepMom::Pending
          visit_cells(visitor, :pending)
        rescue Exception => error
          puts error.message
          puts error.backtrace
          visit_cells(visitor, :failed)
        end

        private

        def header?
          index == 0
        end

        def visit_cells(visitor, status)
          each do |cell|
            visitor.visit_table_cell(cell, status)
          end
        end
      end
    end
  end
end
