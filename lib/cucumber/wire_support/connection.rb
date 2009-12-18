require 'timeout'
require 'cucumber/wire_support/wire_protocol'

module Cucumber
  module WireSupport
    class Connection
      include WireProtocol
      
      def initialize(config)
        @config = config
      end
      
      def call_remote(request_handler, message, params)
        packet = WirePacket.new(message, params)

        begin
          send_data_to_socket(packet.to_json)
          response = fetch_data_from_socket(@config.timeout(message))
          response.handle_with(request_handler)
        rescue Timeout::Error
          raise "Timed out calling server with message #{message}"
        end
      end
      
      def exception(params)
        WireException.new(params, @config.host, @config.port)
      end

      private
      
      def send_data_to_socket(data)
        Timeout.timeout(@config.timeout) { socket.puts(data) }
      end

      def fetch_data_from_socket(timeout)
        raw_response = Timeout.timeout(timeout) { socket.gets }
        WirePacket.parse(raw_response)
      end

      def socket
        @socket ||= TCPSocket.new(@config.host, @config.port)
      end
    end
  end
end