module Cucumber
  module WireSupport
    class Configuration
      attr_reader :host, :port
      
      def initialize(wire_file)
        params = YAML.load_file(wire_file)
        @host = params['host']
        @port = params['port']
        @timeout = 3
      end
      
      def timeout(message = nil)
        return @timeout
      end
    end
  end
end