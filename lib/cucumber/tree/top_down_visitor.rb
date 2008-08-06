module Cucumber
  module Tree
    class TopDownVisitor
      def visit_features(features)
        features.accept(self)
      end

      def visit_feature(feature)
        feature.accept(self)
      end

      def visit_header(header)
      end

      def visit_scenario(scenario)
        scenario.accept(self)
      end

      def visit_step(step)
      end
    end
  end
end