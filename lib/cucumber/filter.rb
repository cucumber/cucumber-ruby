require 'cucumber/tag_expression'

module Cucumber
  # Filters the AST based on --tags and --name
  class Filter #:nodoc:
    def initialize(lines, options)
      @lines = lines
      @tag_expression = options[:tag_expression] || TagExpression.new
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
      syntax_node.matches_tags?(@tag_expression)
    end

    def outline_matches_names?(syntax_node)
      @name_regexps.nil? || @name_regexps.empty? || @name_regexps.detect{|name_regexp| syntax_node.outline_matches_name?(name_regexp)}
    end
    
    def matches_names?(syntax_node)
      @name_regexps.nil? || @name_regexps.empty? || @name_regexps.detect{|name_regexp| syntax_node.matches_name?(name_regexp)}
    end
  end
end
