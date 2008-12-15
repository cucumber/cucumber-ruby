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

      def format(io, indent=0)
        tags = @tag_names.map do |tag_name|
          (" " * indent) + "@#{tag_name}"
        end.join(" ")
        io.write(tags)
        io.write("\n")
      end
    end
  end
end