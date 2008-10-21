module Cucumber
  module Model
    class Table
      attr_accessor :raw
      
      # Creates a new table. The +raw+ argument should be an array
      # of arrays
      def initialize(raw)
        @raw = raw
      end
      
      # Turn the table into an array of Hash where each Hash
      # has keys corresponding to the table header (first line)
      # and the values are the individual row cells.
      def hashes
        header = @raw[0]
        @raw[1..-1].map do |row|
          h = {}
          row.each_with_index do |v,n|
            key = header[n]
            h[key] = v
          end
          h
        end
      end
    end
  end
end
