module Cucumber
  module Ast
    class Features
      def initialize
        @features = []
      end
      
      def add_feature(feature)
        @features << feature
      end
      
      def accept(visitor)
        @features.each do |feature|
          visitor.visit_feature(feature)
        end
      end
    end
  end
end