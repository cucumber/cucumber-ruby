require 'rubygems'
require 'treetop'
require 'erb'

module Stories
  class Runner
    def initialize(rule_factory)
      @rule_factory = rule_factory
      @steps = {} # TODO: Use a default pending block?
      @additional_rules = []
    end
    
    # Registers a custom step
    def step(step_expression, &block)
      @additional_rules << @rule_factory.rule_for(step_expression)
      @steps[step_expression] = block
    end
    
    # Compiles the story grammar - extended with custom steps
    def compile
      grammar_template = ERB.new(IO.read(File.dirname(__FILE__) + '/story.treetop.erb'))
      grammar = grammar_template.result(binding)
      parser = Treetop::Compiler::MetagrammarParser.new
      result = parser.parse(grammar)
      ruby = result.compile
      Object.class_eval(ruby)
    end
    
    def parse(story) # TODO: Our extrenal API should be more like #execute and #register_story
      @parser = StoryParser.new
      tree = @parser.parse(story)
      raise @parser.failure_reason if tree.nil?
    end
  end
end