require 'rubygems'
require 'treetop'
require 'erb'

module Cucumber
  class Runner
    # TODO: specify the language (to take from an embedded YAML file.
    def initialize(err=STDERR, out=STDOUT)
      @err, @out = err, out
      compile
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
    
    def load(file)
      add File.open(file)
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
        stories << [tree, text, path]
      end
    ensure
      story.close if story.respond_to?(:close)
    end

    def stories
      @stories ||= []
    end
    
    def accept(visitor)
      stories.each do |story|
        story[0].accept(visitor)
      end
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