require 'rubygems'
require 'treetop'
require 'erb'

module Stories
  class Runner
    def initialize(rule_factory, err=STDERR, out=STDOUT)
      @rule_factory, @err, @out = rule_factory, err, out
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
      @parser = StoryParser.new
    end
    
    # Adds a +story+ to be run. +story+ can be either an opened File object or a String
    def add(story)
      if story.respond_to?(:path) # It's a file
        path = story.path
        text = story.read
      else # It's just a String
        path = nil
        text = story
      end
      tree = @parser.parse(text)
      if tree.nil?
        @parser.failure_reason_with_path(@err, @out, path)
      else
        # TODO: Store the tree, text and path so we can descend the tree later
        # If a step fails, we'll add the story's location to the backtrace
      end
    ensure
      story.close if story.respond_to?(:close)
    end
  end
end

module Treetop
  module Runtime
    class CompiledParser
      def failure_reason_with_path(err, out, path)
        return nil unless (tf = terminal_failures) && tf.size > 0
	err.puts "Expected " +
	  (tf.size == 1 ?
	   tf[0].expected_string :
           "one of #{tf.map{|f| f.expected_string}.uniq*', '}"
	  ) + " after #{input[index...failure_index]}"
        out.puts "#{path}:#{failure_line}:#{failure_column}"
      end
    end
  end
end