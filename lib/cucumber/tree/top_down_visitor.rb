module Cucumber
  module Tree
    class TopDownVisitor
      def visit_stories(stories)
        stories.accept(self)
      end

      def visit_story(story)
        story.accept(self)
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