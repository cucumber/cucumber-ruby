module Cucumber
  module WireSupport
    class Configuration
      attr_reader :host, :port
      
      def initialize(wire_file)
        params = YAML.load_file(wire_file)
        @host = params['host']
        @port = params['port']
        @timeouts = params['timeout'] || {}
      end
      
      def timeout(message = nil)
        return @timeouts[message.to_s] || 3
      end
    end
  end
end