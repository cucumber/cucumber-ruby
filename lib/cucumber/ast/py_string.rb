module Cucumber
  module Ast
    class PyString
      def initialize(string)
        @string = string
      end

      def to_s
        @string.split("\n", -1).map{|line| line.lstrip}.join("\n")
      end

      def accept(visitor, status)
        visitor.visit_py_string(to_s, status)
      end
    end
  end
end
