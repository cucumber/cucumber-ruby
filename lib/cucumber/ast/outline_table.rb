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
        def accept(visitor)
          unless header?
            @table.execute_row(self.to_hash)
          end
          super
        end

        def header?
          index == 0
        end
      end
    end
  end
end
