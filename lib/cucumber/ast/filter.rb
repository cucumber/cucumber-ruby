module Cucumber
  module Ast
    class Filter
      def initialize(options)
        @options = options
      end
      
      def matched?(node)
        matched_by_tags?(node) &&
        matched_by_scenario_names?(node)
      end
      
      def matched_by_tags?(node)
        @options[:tags].empty? || node.tagged_with?(@options[:tags])
      end

      def matched_by_scenario_names?(node)
        @options[:scenario_names].empty? || node.matches_scenario_names?(@options[:scenario_names])
      end
    end
  end
end