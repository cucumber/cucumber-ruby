module Cucumber
  module Ast
    class Features
      def initialize(filter)
        @filter = filter
        @features = []
      end

      def add_feature(feature)
        feature.features = self
        @features << feature
      end

      def visit?(node, lines)
        @filter.matched?(node) &&
        (lines.empty? ? true : node.at_lines?(lines))
      end

      def accept(visitor)
        @features.each do |feature|
          visitor.visit_feature(feature) if visit?(feature, [])
        end
      end
    end
  end
end