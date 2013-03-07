module Cucumber
  module Ast

    class Location
      def initialize(file, line)
        @file = file || raise(ArgumentError, "file is mandatory")
        @line = line || raise(ArgumentError, "line is mandatory")
      end

      def to_s
        "#{file}:#{line}"
      end

      private

      attr_reader :file, :line
    end

    module HasLocation
      def file_colon_line
        Location.new(file, line).to_s
      end
    end
  end
end
