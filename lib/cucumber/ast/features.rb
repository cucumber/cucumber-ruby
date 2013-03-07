module Cucumber
  module Ast
    class Features #:nodoc:
      include Enumerable

      attr_reader :duration

      def initialize
        @features = []
      end

      def [](index)
        @features[index]
      end

      def each(&proc)
        @features.each(&proc)
      end

      def add_feature(feature)
        @features << feature
      end

      def accept(visitor)
        return if Cucumber.wants_to_quit
        start = Time.now
        self.each do |feature|
          visitor.visit_feature(feature)
        end
        @duration = Time.now - start
      end

      def step_count
        @features.inject(0) { |total, feature| total += feature.step_count }
      end
    end
  end
end
