require 'timeout'
require 'cucumber/wire_support/wire_protocol'

module Cucumber
  module WireSupport
    class Connection
      include WireProtocol
      
      attr_reader :default_timeout
      
      def initialize(config)
        @host, @port = config.host, config.port
        @default_timeout = config.timeout
      end
      
      def call_remote(request_handler, message, params)
        packet = WirePacket.new(message, params)

        begin
          send_data_to_socket(packet.to_json, default_timeout)
          response = fetch_data_from_socket(request_handler.timeout)
          response.handle_with(request_handler)
        rescue Timeout::Error
          raise "Timed out calling server with message #{message}"
        end
      end
      
      def exception(params)
        WireException.new(params, @host, @port)
      end

      private
      
      def send_data_to_socket(data, timeout)
        Timeout.timeout(timeout) { socket.puts(data) }
      end

      def fetch_data_from_socket(timeout)
        raw_response = Timeout.timeout(timeout) { socket.gets }
        WirePacket.parse(raw_response)
      end

      def socket
        @socket ||= TCPSocket.new(@host, @port)
      end
    end
  end
end