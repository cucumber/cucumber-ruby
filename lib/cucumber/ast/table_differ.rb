require 'diff/lcs'

module Cucumber
  module Ast
    class TableDiffer
      class Anything
        class << self
          def ==(o)
            true
          end
        end
      end

      def diff(t1, t2)
      end
      
      def normalize(t1, t2, empty_value=nil)
        t1_cols = t1.transpose
        t2_cols = t2.transpose
        column_count_diff = t2_cols.length - t1_cols.length

        return [t1, t2] if column_count_diff == 0

        narrow_table, narrow_table_cols = column_count_diff > 0 ? [t1, t1_cols] : [t2, t2_cols]

        narrow_table_empty_row = Array.new(column_count_diff.abs, empty_value)
        narrow_table_empty_rows = narrow_table.map do
          narrow_table_empty_row
        end
        narrow_table_cols += narrow_table_empty_rows.transpose

        column_count_diff > 0 ? [narrow_table_cols.transpose, t2] : [t1, narrow_table_cols.transpose]
      end
    end
  end
end
