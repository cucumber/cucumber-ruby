module Cucumber
  module Ast
    # Holds the data of a table parsed from a feature file.
    # Consider the following table:
    #
    #   |a|b|
    #   |c|d|
    #
    # This gets parsed into a Table holding the values <tt>[['a', 'b'], ['c', 'd']]</tt>
    #
    class Table
      # The raw data of this table, as a 2-dimensional array.
      attr_reader :raw
      
      def initialize(raw)
        # Verify that it's square
        raw.transpose
        @raw = raw
      end
    end
  end
end