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

      # Takes as input two matrices +t1+ and +t2+ and returns two new matrices 
      # <tt>t1_t</tt>, <tt>t2_t</tt>. <tt>t1_t</tt> and <tt>t2_t</tt> will have the
      # same number of columns, and for each column that does not exist in the other
      # matrix, an empty column with values +empty_value+ is added. 
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

      # Returns two matrices, <tt>t2_sorted</tt> and <tt>t2_surplus</tt> so that <tt>t2_sorted</tt>
      # has the same columns (or a subset of) the columns in +t1+ (sorted), using the first row in +t1+ as
      # column identifier. <tt>t2_surplus</tt> has the columns that were not in +t1+, alphabetically 
      # sorted by header value.
      def sort(t1, t2)
        t2_cols = t2.transpose
        
        t1_headers = t1[0]

        t2_cols, t2_surplus_cols = t2_cols.partition do |col|
          t1_headers.index(col[0])
        end

        t2_cols.sort! do |col_a, col_b|
          t1_headers.index(col_a[0]) <=> t1_headers.index(col_b[0])
        end

        t2_surplus_cols.sort! do |col_a, col_b|
          col_a[0] <=> col_b[0]
        end

        [t2_cols.transpose, t2_surplus_cols.transpose]
      end
    end
  end
end
