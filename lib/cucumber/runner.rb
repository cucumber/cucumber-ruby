require 'rubygems'
require 'treetop'
require 'erb'

module Cucumber
  class Runner
    # TODO: specify the language (to take from an embedded YAML file.
    def initialize(err=STDERR, out=STDOUT)
      @err, @out = err, out
      @steps = {}
      @additional_rules = []
    end
    
    # Registers a custom step, thereby extending the default grammar
    def step(step_expression, &block)
      @steps[step_expression] = block
    end
    
    # Compiles the story grammar - extended with custom steps
    def compile
      grammar_template = ERB.new(IO.read(File.dirname(__FILE__) + '/story.treetop.erb'))
      grammar = grammar_template.result(binding)
      parser = Treetop::Compiler::MetagrammarParser.new
      result = parser.parse(grammar)
      ruby = result.compile
#puts ruby
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
        verify_steps(tree)
        # TODO: Store the tree, text and path so we can descend the tree later
        # If a step fails, we'll add the story's location to the backtrace
      end
    ensure
      story.close if story.respond_to?(:close)
    end
    
    def verify_steps(tree)
      step_verifier = StepVerifier.new(self)
      tree.accept(step_verifier)
    end
    
    def verify_step(step)
      
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