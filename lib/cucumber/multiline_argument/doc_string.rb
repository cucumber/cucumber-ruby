module Cucumber
  module MultilineArgument
    class DocString < SimpleDelegator
      def append_to(array)
        array << self
      end
    end
  end
end

