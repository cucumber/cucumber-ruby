module Cucumber
  module WireSupport
    class WireStepDefinition
      def initialize(id, connection)
        @id, @connection = id, connection
      end
      
      def invoke(args)
        @connection.invoke(@id, args)
      end
    end
  end
end