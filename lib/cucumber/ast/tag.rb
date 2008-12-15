module Cucumber
  module Ast
    # Holds the data of a tag parsed from a feature file:
    #
    #   @invoice
    #
    # This gets parsed into a Tag with name <tt>"invoice"</tt>
    #
    class Tag
      # The name this tag
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
    end
  end
end