module Cucumber
  module Visitors
    class PrettyPrinter < Visitor
      def visit_story(story)
        super
      end

      def visit_header(header)
        puts header.text_value
        super
      end

      def visit_narrative(header)
        puts header.text_value
        super
      end

      def visit_scenario(scenario)
        puts scenario.text_value
        super
      end

      def visit_step(step)
        puts step.text_value
        super
      end
    end
  end
end