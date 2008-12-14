module Cucumber
  module Ast
    # Represents the root node of a parsed feature.
    class Feature
      attr_accessor :file
      attr_reader :comment
      attr_reader :scenarios
      
      def initialize(comment, scenarios)
        @comment = comment
        @scenarios = scenarios
      end
    end
  end
end