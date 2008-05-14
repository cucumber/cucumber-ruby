module Cucumber
  module Parser
    class StoryNode
      def self.parse(file, parser)
        story = parser.parse(IO.read(file))
        if story.nil?
          raise parser.compile_error(file)
        end
        story.file = file
        story
      end
      
      attr_accessor :file

      def accept(visitor)
        visitor.visit_header(header)
        visitor.visit_narrative(narrative)
        scenario_nodes.elements.each do |scenario_node|
          visitor.visit_scenario(scenario_node)
        end
      end
    end
  end
end