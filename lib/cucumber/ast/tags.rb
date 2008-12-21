module Cucumber
  module Ast
    # Holds the names of tags parsed from a feature file:
    #
    #   @invoice @release_2
    #
    # This gets stored internally as <tt>["invoice", "release_2"]</tt>
    #
    class Tags
      def initialize(tag_names)
        @tag_names = tag_names
      end

      def accept(visitor)
        @tag_names.each do |tag_name|
          visitor.visit_tag_name(tag_name)
        end
      end
    end
  end
end
