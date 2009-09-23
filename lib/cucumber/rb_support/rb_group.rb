module Cucumber
  module RbSupport
    class RbGroup
      attr_reader :val, :start
      
      def initialize(val, start)
        @val, @start = val, start
      end
    end
  end
end