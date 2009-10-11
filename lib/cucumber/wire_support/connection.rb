require 'cucumber/wire_support/wire_protocol'

module Cucumber
  module WireSupport
    class Connection
      include WireProtocol
      
      def initialize(config)
        @host, @port = config['host'], config['port']
      end
      
      private

      def call_remote(message, args = nil)
        timeout = 5
        packet = WirePacket.new(message, args)

        begin
          send_data_to_socket(packet.to_json, timeout)
          response = fetch_data_from_socket(timeout)
          response.raise_if_bad
          response
        rescue Timeout::Error
          raise "Timed out calling server with message #{message}"
        end
      end
      
      def send_data_to_socket(data, timeout)
        log.debug("Calling server with message #{data}")
        Timeout.timeout(timeout) { socket.puts(data) }
        log.debug("Message sent")
      end

      def fetch_data_from_socket(timeout)
        log.debug("Waiting #{timeout} secs for response...")
        raw_response = Timeout.timeout(timeout) { socket.gets }
        log.debug("Received response: #{raw_response.inspect}")
        WirePacket.parse(raw_response)
      end

      def socket
        log.debug("opening socket to #{@host}:#{@port}") unless @socket
        @socket ||= TCPSocket.new(@host, @port)
      end

      def log
        Logging::Logger[self]
      end
    end
  end
end