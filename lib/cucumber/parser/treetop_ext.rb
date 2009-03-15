begin
  require 'treetop'
  require 'treetop/runtime'
  require 'treetop/ruby_extensions'
rescue LoadError
  require "rubygems"
  gem "treetop"
  require 'treetop'
  require 'treetop/runtime'
  require 'treetop/ruby_extensions'
end

module Cucumber
  module Parser
    module TreetopExt
      FILE_COLON_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/

      # Parses a file and returns a Cucumber::Ast
      def parse_file(file)
        _, path, lines = *FILE_COLON_LINE_PATTERN.match(file)
        if path
          lines = lines.split(':').map { |line| line.to_i }
        else
          path = file
          lines = []
        end

        loader = lambda { |io| parse_or_fail(io.read, path) }
        feature = if path =~ /^http/
          require 'open-uri'
          open(path, &loader)
        else
          File.open(path, Cucumber.file_mode('r'), &loader) 
        end
        feature.lines = lines
        feature
      end

      def parse_or_fail(s, file=nil, line_offset=0)
        parse_tree = parse(s)
        if parse_tree.nil?
          raise Cucumber::Parser::SyntaxError.new(self, file, line_offset)
        else
          ast = parse_tree.build
          ast.file = file
          ast
        end
      end
    end

    class SyntaxError < StandardError
      def initialize(parser, file, line_offset)
        tf = parser.terminal_failures
        expected = tf.size == 1 ? tf[0].expected_string.inspect : "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
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
    end
  end
end