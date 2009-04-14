module Cucumber
  module Ast
    # Holds the names of tags parsed from a feature file:
    #
    #   @invoice @release_2
    #
    # This gets stored internally as <tt>["invoice", "release_2"]</tt>
    #
    class Tags
      def self.strip_prefix(tag_name)
        tag_name =~ /^@(.*)/ ? $1 : tag_name
      end
    
      def initialize(line, tag_names)
        @line, @tag_names = line, tag_names
      end

      def accept(visitor)
        @tag_names.each do |tag_name|
          visitor.visit_tag_name(tag_name)
        end
      end

      def accept_hook?(hook)
        hook.matches_tag_names?(@tag_names)
      end

      def to_sexp
        @tag_names.map{|tag_name| [:tag, tag_name]}
      end
    end
  end
end
