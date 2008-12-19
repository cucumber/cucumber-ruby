module Cucumber
  module Ast
    class Examples
      def initialize(scenario_outline, matrix)
        @outline_table = OutlineTable.new(matrix, scenario_outline)
      end

      def accept(visitor)
        @outline_table.accept(visitor)
      end
    end
  end
end
