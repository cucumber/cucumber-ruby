module Cucumber
  # Filters the AST based on --tags and --name
  class Filter #:nodoc:
    def initialize(lines, options)
      @lines = lines

      @include_tags = options[:include_tags] ? options[:include_tags].keys : []
      @exclude_tags = options[:exclude_tags] ? options[:exclude_tags].keys : []
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
      @include_tags.empty? || syntax_node.has_all_tags?(@include_tags)
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
end
