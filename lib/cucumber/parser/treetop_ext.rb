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
    class Filter
      def initialize(lines, options)
        @lines = lines
        @include_tags = options[:include_tags] || []
        @exclude_tags = options[:exclude_tags] || []
        @name_regexps = options[:name_regexps] || []
      end

      def accept?(syntax_node)
        at_line?(syntax_node) &&
        matches_tags?(syntax_node) &&
        matches_names?(syntax_node)
      end

      def accept_example?(syntax_node, outline)
        (at_line?(syntax_node) || outline_at_line?(outline)) && 
        (matches_names?(syntax_node) || outline_matches_names?(outline))
      end
      
      def at_line?(syntax_node)
        @lines.nil? || @lines.empty? || @lines.detect{|line| syntax_node.at_line?(line)}
      end

      def outline_at_line?(syntax_node)
         @lines.nil? || @lines.empty? || @lines.detect{|line| syntax_node.outline_at_line?(line)}
      end

      def matches_tags?(syntax_node)
        !excluded_by_tags?(syntax_node) &&
        included_by_tags?(syntax_node)
      end

      def included_by_tags?(syntax_node)
        @include_tags.empty? || syntax_node.has_tags?(@include_tags)
      end

      def excluded_by_tags?(syntax_node)
        @exclude_tags.any? && syntax_node.has_tags?(@exclude_tags)
      end
      
      def outline_matches_names?(syntax_node)
        @name_regexps.nil? || @name_regexps.empty? || @name_regexps.detect{|name_regexp| syntax_node.outline_matches_name?(name_regexp)}
      end
      
      def matches_names?(syntax_node)
        @name_regexps.nil? || @name_regexps.empty? || @name_regexps.detect{|name_regexp| syntax_node.matches_name?(name_regexp)}
      end
    end

    module TreetopExt      
      FILE_COLON_LINE_PATTERN = /^([\w\W]*?):([\d:]+)$/

      # Parses a file and returns a Cucumber::Ast
      def parse_file(file, options)
        _, path, lines = *FILE_COLON_LINE_PATTERN.match(file)
        if path
          lines = lines.split(':').map { |line| line.to_i }
        else
          path = file
        end
        filter = Filter.new(lines, options)

        loader = lambda { |io| parse_or_fail(io.read, filter, path) }
        feature = if path =~ /^http/
          require 'open-uri'
          open(path, &loader)
        else
          File.open(path, Cucumber.file_mode('r'), &loader) 
        end
        feature
      end

      def parse_or_fail(string, filter=nil, file=nil, line_offset=0)
        parse_tree = parse(string)
        if parse_tree.nil?
          raise Cucumber::Parser::SyntaxError.new(self, file, line_offset)
        else
          ast = parse_tree.build(filter) # may return nil if it doesn't match filter.
          ast.file = file unless ast.nil?
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
