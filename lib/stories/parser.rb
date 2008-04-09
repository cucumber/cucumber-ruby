require 'rubygems'
require 'treetop'

grammar = IO.read(File.dirname(__FILE__) + '/story.treetop')
parser = Treetop::Compiler::MetagrammarParser.new
result = parser.parse(grammar)
ruby = result.compile
Object.class_eval(ruby)

module Stories
  class Parser
    
  end
end