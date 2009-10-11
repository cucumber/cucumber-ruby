module Cucumber
  module WireSupport
    class WireStepDefinition
      def initialize(id, connection)
        @id = id
      end
      
      def invoke(*args)
        log.debug "WireStepDefinition id #{@id} invoked with args: #{args.inspect}"
        # raise WireException.new({'message' => 'The wires are down'})
      end
      
      private
      
      def log
        Logging::Logger[self]
      end
    end
  end
end