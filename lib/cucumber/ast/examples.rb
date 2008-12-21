module Cucumber
  module Ast
    class Examples
      def initialize(scenario_outline, outline_table)
        @outline_table = outline_table
      end

      def accept(visitor)
        @outline_table.accept(visitor)
      end
    end
  end
end
