module Cucumber
  module Ast
    class Argument
      
      def initialize(name, value)
        @name, @value = name, value
      end

      def replace_in(string)
        string.gsub("<#{@name}>", @value)
      end
      
    end
  end
end
