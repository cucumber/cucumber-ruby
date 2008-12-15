module Cucumber
  module Ast
    # Holds the names of tags parsed from a feature file:
    #
    #   @invoice @release_2
    #
    # This gets stored internally as <tt>["invoice", "release_2"]</tt>
    #
    class Tags
      attr_reader :tag_names
      
      def initialize(tag_names)
        @tag_names = tag_names
      end
    end
  end
end