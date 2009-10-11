module Cucumber
  module WireSupport
    class WireStepDefinition
      def initialize(id, connection)
        @id, @connection = id, connection
      end
      
      def invoke(args)
        log.debug "WireStepDefinition id #{@id} invoked with args: #{args.inspect}"
        @connection.invoke(@id, args)
      end
      
      private
      
      def log
        Logging::Logger[self]
      end
    end
  end
end