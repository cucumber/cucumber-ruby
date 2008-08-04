require 'cucumber/core_ext/string'
require 'cucumber/tree'

module Cucumber
  module Parser
    class SyntaxError < StandardError
    end
    
    class StoryNode < Treetop::Runtime::SyntaxNode
      include Tree::Story
      attr_accessor :file
    
      def self.parse(file, parser)
        story = parser.parse(IO.read(file))
        if story.nil?
          raise SyntaxError.new(parser.compile_error(file))
        end
        story.file = file
        story
      end
    
    protected
    
      def header
        header_node.sentence_line.text_value
      end

      def narrative
        narrative_node.text_value
      end

      def scenarios
        scenario_nodes.elements
      end      
    end
    
    class HeaderNode < Treetop::Runtime::SyntaxNode
      def name
        sentence_line.text_value.strip
      end
    end
    
    class NarrativeNode < Treetop::Runtime::SyntaxNode
      def narrative
        text_value
      end
    end
    
    class ScenarioNode < Treetop::Runtime::SyntaxNode
      include Tree::Scenario

      def name
        sentence.text_value.strip
      end

      def file
        parent.parent.file
      end
      
    protected

      def steps
        step_nodes.elements
      end

      def line
        input.line_of(interval.first)
      end
    end
    
    class StepNode < Treetop::Runtime::SyntaxNode
      include Tree::Step

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
    end
  end
end