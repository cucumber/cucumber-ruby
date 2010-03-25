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
require 'cucumber/parser/gherkin_builder'
require 'gherkin/tools/filter_listener'

module Cucumber
  module Parser
    # Raised if Cucumber fails to parse a feature file
    class SyntaxError < StandardError
      def initialize(parser, file, line_offset)
        tf = parser.terminal_failures
        expected = tf.size == 1 ? tf[0].expected_string.inspect : "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        line = parser.failure_line + line_offset
        message = "#{file}:#{line}:#{parser.failure_column}: Parse error, expected #{expected}."
        super(message)
      end
    end
    
    module TreetopExt #:nodoc:
      def parse_or_fail(source, file, lines, name_regexen, tag_expression, line_offset)
        parse_tree = parse(source)
        if parse_tree.nil?
          raise Cucumber::Parser::SyntaxError.new(self, file, line_offset)
        else
          builder = Cucumber::Parser::GherkinBuilder.new
          filter = Gherkin::Tools::FilterListener.new(builder, lines, name_regexen, tag_expression)
          parse_tree.emit(filter)
          filter.eof
          ast = builder.ast
          ast.file = file unless ast.nil?
          ast
        end
      end
    end
  end
end

module Treetop #:nodoc:
  module Runtime #:nodoc:
    class SyntaxNode #:nodoc:
      def line
        input.line_of(interval.first)
      end
    end

    class CompiledParser #:nodoc:
      public :prepare_to_parse
      include Cucumber::Parser::TreetopExt
    end
  end
end
