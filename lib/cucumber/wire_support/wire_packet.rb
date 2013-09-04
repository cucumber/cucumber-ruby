require 'multi_json'

module Cucumber
  module WireSupport
    # Represents the packet of data sent over the wire as JSON data, containing
    # a message and a hash of arguments
    class WirePacket
      class << self
        def parse(raw)
          attributes = MultiJson.load(raw.strip)
          message = attributes[0]
          params  = attributes[1]
          new(message, params)
        end
      end

      attr_reader :message, :params

      def initialize(message, params = nil)
        @message, @params = message, params
      end

      def to_json
        packet = [@message]
        packet << @params if @params
        MultiJson.dump(packet)
      end

      def handle_with(handler)
        handler.send("handle_#{@message}", @params)
      end
    end
  end
end
