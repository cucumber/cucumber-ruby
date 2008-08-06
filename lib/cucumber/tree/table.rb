module Cucumber
  module Tree
    class Table
      def initialize(rows)
        @rows = rows
      end
      
      def |(cell)
        @row ||= []
        if cell == self
          @rows << @row
          @row = nil
        else
          @row << cell.to_s
        end
        self
      end
    end
  end
end