require 'treetop'
require 'treetop/runtime'
require 'treetop/ruby_extensions'

module Cucumber
  module Parser
    module TreetopExt
      FILE_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/

      # Parses a file and returns a Cucumber::Ast
      def parse_file(file)
        _, path, lines = *FILE_LINE_PATTERN.match(file)
        if path
          lines = lines.split(':').map { |line| line.to_i }
        else
          path = file
          lines = []
        end

        feature = File.open(path, Cucumber.file_mode('r')) do |io|
          parse_or_fail(io.read, path)
        end
        feature.lines = lines
        feature
      end
    end

    class SyntaxError < StandardError
      def initialize(parser, file, line_offset)
        tf = parser.terminal_failures
        expected = tf.size == 1 ? tf[0].expected_string.inspect : "one of #{tf.map{|f| f.expected_string}.uniq*', '}"
        line = parser.failure_line + line_offset
        message = "#{file}:#{line}:#{parser.failure_column}: Parse error, expected #{expected}."
        super(message)
      end
    end
  end
end

module Treetop
  module Runtime
    class SyntaxNode
      def line
        input.line_of(interval.first)
      end
    end
    
    class CompiledParser
      include Cucumber::Parser::TreetopExt
      
      def parse_or_fail(s, file=nil, line=0)
        parse_tree = parse(s)
        if parse_tree.nil?
          raise Cucumber::Parser::SyntaxError.new(self, file, line)
        else
          ast = parse_tree.build
          ast.file = file
          ast
        end
      end
    end
  end
end