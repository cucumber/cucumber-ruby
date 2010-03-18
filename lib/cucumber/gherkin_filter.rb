require 'cucumber/tag_expression'

module Cucumber
  # Filters the AST based on --tags, --name and file.feature:line arguments
  class GherkinFilter #:nodoc:
    def initialize(lines, options)
      @lines = lines
      @tag_expression = options[:tag_expression] || TagExpression.new
      @name_regexps = options[:name_regexps] || []
    end

    def good_line?(line)
      @lines.nil? || @lines.empty? || @lines.index(line)
    end

    # TODO: All of the code below should be removed when Treetop is dead

    def accept?(syntax_node)
      true
    end

    def accept_example?(syntax_node, outline)
      true
    end

    def at_line?(syntax_node)
      true
    end

    def outline_at_line?(syntax_node)
      true
    end

    def matches_tags?(syntax_node)
      true
    end

    def outline_matches_names?(syntax_node)
      true
    end
    
    def matches_names?(syntax_node)
      true
    end 
  end
end