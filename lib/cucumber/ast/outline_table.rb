module Cucumber
  module Ast
    class OutlineTable < Table
      def initialize(raw, scenario_outline)
        super(raw)
        @scenario_outline = scenario_outline
        @cells_class = ExampleCells
        @cell_class = ArgCell
      end

      # Prepares the outline to be executed.
      # This happens when a row accepts a visitor
      def prepare_outline #:nodoc:
        @scenario_outline.prepare
      end

      def push_arg(cell_arg)
        @scenario_outline.push_arg(cell_arg)
      end

      class ExampleCells < Cells
        def accept(visitor)
          @table.prepare_outline
          super
        end
      end
      
      class ArgCell < Cell
        def accept(visitor)
          @table.push_arg(@value)
          visitor.visit_table_cell_value(@value, col_width)
        end
      end
    end
  end
end
