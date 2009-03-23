module Cucumber
  module Ast
    class Features
      include Enumerable

      def initialize
        @features = []
      end

      def each(&proc)
        @features.each(&proc)
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