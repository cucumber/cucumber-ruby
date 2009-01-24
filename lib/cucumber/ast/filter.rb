module Cucumber
  module Ast
    class Filter
      def initialize(options)
        @options = options
      end
      
      def matched?(node)
        matched_by_tags?(node)
      end
      
      def matched_by_tags?(node)
        @options[:tags].empty? || node.tagged_with?(@options[:tags])
      end
    end
  end
end