require 'delegate'
module Cucumber
  module MultilineArgument
    def self.from(core_multiline_arg)
      Builder.new(core_multiline_arg).result
    end

    class Builder
      def initialize(multiline_arg)
        multiline_arg.describe_to self
      end

      def doc_string(string, *args)
        @result = DocString.new(string)
      end

      def data_table(table, *args)
        @result = DataTable.new(table)
      end

      def result
        @result || None.new
      end
    end

    class DocString < SimpleDelegator
      def append_to(array)
        array << self
      end
    end

    class DataTable < SimpleDelegator
      def append_to(array)
        array << self
      end

      def to_json(options)
        raw.to_json(options)
      end

      def diff!(other_table)
        other_table = ensure_table(other_table)
        other_table_cell_matrix = other_table.cell_matrix

        ensure_green!

        require_diff_lcs
        cell_matrix.extend(Diff::LCS)

        changes = cell_matrix.diff(other_table_cell_matrix).flatten

        return if changes.empty?

        inserted = 0
        missing  = 0

        changes.each do |change|
          if(change.action == '-')
            missing_row_pos = change.position + inserted
            cell_matrix[missing_row_pos].each{|cell| cell.status = :undefined}

            missing += 1
          else # '+'
            inserted_row = change.element
            inserted_row.each{|cell| cell.status = :comment}

            insert_row_pos = change.position + missing
            cell_matrix.insert(insert_row_pos, inserted_row)

            inserted += 1
          end
        end

        raise Different.new(self)
      end

      def ensure_green! #:nodoc:
        each_cell{|cell| cell.status = :passed}
      end

      private

      def ensure_table(table_or_array) #:nodoc:
        return table_or_array if DataTable === table_or_array
        DataTable.new(table_or_array)
      end

      def require_diff_lcs #:nodoc:
        begin
          require 'diff/lcs'
        rescue LoadError => e
          e.message << "\n Please gem install diff-lcs\n"
          raise e
        end
      end

      class Different < StandardError
        attr_reader :table
        def initialize(table)
          @table = table
          super("Tables were not identical")
        end
      end
    end

    class None
      def append_to(array)
      end

      def describe_to(visitor)
      end
    end
  end
end

