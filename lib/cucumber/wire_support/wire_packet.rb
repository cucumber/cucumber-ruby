module Cucumber
  module WireSupport
    # Represents the packet of data sent over the wire as JSON data, containing
    # a message and a hash of arguments
    class WirePacket
      class << self
        def parse(raw)
          attributes = JSON.parse(raw.strip)
          message = attributes.keys.first
          args = attributes[message]
          new(message, args)
        end
      end
      
      attr_reader :message, :args
      
      def initialize(message, args)
        @message, @args = message, args
      end
      
      def to_json
        {
          @message => @args
        }.to_json
      end
      
      def raise_if_bad
        raise WireException.new(@args) if @message == 'fail' || @message == 'step_failed'
      end
    end
  end
end
