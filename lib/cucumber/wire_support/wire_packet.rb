module Cucumber
  module WireSupport
    class WirePacket
      class << self
        PACKET_PATTERN = /^([^:]+):(.*)$/
        
        def parse(raw)
          _, message, raw_args = *PACKET_PATTERN.match(raw)
          new message, JSON.parse(raw_args)
        end
      end
      
      attr_reader :message, :args
      
      def initialize(message, args)
        @message, @args = message, args
      end
      
      def raise_if_bad
        raise WireException.new(@args) if @message == 'FAIL'
      end
    end
  end
end
