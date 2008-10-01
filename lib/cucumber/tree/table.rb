module Cucumber
  module Tree
    class Table
      def initialize(rows)
        @rows = rows
      end
      
      def |(cell)
        @row ||= []
        if cell == self
          line = *caller[0].split(':')[1].to_i
          @row.instance_eval %{
            def line
              #{line}
            end
          }
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