module Cucumber
  module Ast
    # Holds the names of tags parsed from a feature file:
    #
    #   @invoice @release_2
    #
    # This gets stored internally as <tt>["invoice", "release_2"]</tt>
    #
    class Tags #:nodoc:
      def self.strip_prefix(tag_name)
        tag_name =~ /^@(.*)/ ? $1 : tag_name
      end

      def initialize(line, tag_names)
        @line, @tag_names = line, tag_names
      end

      def accept(visitor)
        return if $cucumber_interrupted
        @tag_names.each do |tag_name|
          visitor.visit_tag_name(tag_name)
        end
      end

      def accept_hook?(hook)
        hook.tag_names.empty? || (hook.tag_names.map{|tag| Ast::Tags.strip_prefix(tag)} & @tag_names).any?
      end

      def count(tag)
        if @tag_names.respond_to?(:count)
          @tag_names.count(tag) # 1.9
        else
          @tag_names.select{|t| t == tag}.length  # 1.8
        end
      end

      def to_sexp
        @tag_names.map{|tag_name| [:tag, tag_name]}
      end
    end
  end
end
