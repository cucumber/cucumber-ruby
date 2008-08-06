module Cucumber
  module Tree
    class Features
      def initialize
        @features = []
      end
      
      def length
        @features.length
      end

      def <<(feature)
        @features << feature
      end

      def accept(visitor)
        @features.each{|feature| visitor.visit_feature(feature)}
      end
    end
  end
end