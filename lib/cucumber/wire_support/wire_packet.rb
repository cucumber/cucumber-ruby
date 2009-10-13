module Cucumber
  module WireSupport
    # Represents the packet of data sent over the wire as JSON data, containing
    # a message and a hash of arguments
    class WirePacket
      class ParseError < StandardError
        def initialize(key, raw)
          super "Could not find mandatory key '#{key}' in this packet: #{raw}"
        end
      end
      
      class << self
        def parse(raw)
          attributes = JSON.parse(raw.strip)
          message = parse_attribute(attributes, 'message', raw)
          params  = parse_attribute(attributes, 'params', raw)
          new(message, params)
        end
        
        def parse_attribute(attributes, key, raw)
          attributes.key?(key) or raise(ParseError.new(key, raw))
          attributes[key]
        end
      end
      
      attr_reader :message, :params
      
      def initialize(message, params)
        @message, @params = message, params
      end
      
      def to_json
        {
          'message' => @message,
          'params' => @params
        }.to_json
      end
      
      def raise_if_bad
        raise WireException.new(@params) if @message == 'fail' || @message == 'step_failed'
      end
    end
  end
end
