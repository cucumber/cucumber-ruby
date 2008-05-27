module Cucumber
  module Parser
    class StoryNode < Treetop::Runtime::SyntaxNode
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
    
    class StepNode < Treetop::Runtime::SyntaxNode
      class << self
        def new_id!
          @next_id ||= -1
          @next_id += 1
        end
      end

      attr_accessor :error

      def line
        input.line_of(interval.first)
      end

      def name
        sentence.text_value.strip
      end

      def keyword
        step_type.text_value.strip
      end

      def file
        parent.parent.file
      end
      
      def id
        @id ||= self.class.new_id!
      end

    end
  end
end