require 'rubygems'
require 'treetop'

grammar = IO.read(File.dirname(__FILE__) + '/story.treetop')
parser = Treetop::Compiler::MetagrammarParser.new
result = parser.parse(grammar)
ruby = result.compile
Object.class_eval(ruby)

module Stories
  class Runner
    def initialize
      @steps = {} # TODO: Use a default pending block?
    end
    
    def step(step_expression, &block)
      @steps[step_expression] = block
    end
    
    def parse(story) # TODO: Our extrenal API should be more like #execute and #register_story
      @parser = StoryParser.new
      tree = @parser.parse(story)
      raise @parser.failure_reason if tree.nil?
    end
  end
end