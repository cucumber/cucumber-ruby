module Cucumber
  module Ast
    # Holds the names of tags parsed from a feature file:
    #
    #   @invoice @release_2
    #
    # This gets stored internally as <tt>["invoice", "release_2"]</tt>
    #
    class Tags
      def initialize(line, tag_names)
        @line, @tag_names = line, tag_names
      end

      def among?(tag_names)
        no_tags, yes_tags = tag_names.partition{|tag| tag =~ /^~/}
        no_tags = no_tags.map{|tag| tag[1..-1]}

        # Strip @
        yes_tags = yes_tags.map{|tag| tag =~ /^@(.*)/ ? $1 : tag}
        no_tags = no_tags.map{|tag| tag =~ /^@(.*)/ ? $1 : tag}

        (yes_tags.empty? || (@tag_names & yes_tags).any?) && (no_tags.empty? || (@tag_names & no_tags).empty?)
      end

      def at_lines?(lines)
        lines.empty? || lines.index(@line)
      end

      def accept(visitor)
        @tag_names.each do |tag_name|
          visitor.visit_tag_name(tag_name)
        end
      end
      
      def to_sexp
        @tag_names.map{|tag_name| [:tag, tag_name]}
      end
    end
  end
end
