module Cucumber
  module Ast
    class Scenario
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
    end
  end
end