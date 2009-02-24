module Cucumber
  module Ast
    class Features
      def initialize
        @features = []
      end

      def add_feature(feature)
        feature.features = self
        @features << feature
      end

      def accept(visitor)
        @features.each do |feature|
          visitor.visit_feature(feature) if feature.descend?(visitor)
        end
      end
    end
  end
end