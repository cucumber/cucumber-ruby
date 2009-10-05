module Cucumber
  module WireSupport
    class RemoteSteps
      def initialize(config)
        @connection = Connection.new(config['host'], config['port'])
      end
      
      def step_matches(step_name, formatted_step_name)
        @connection.call_remote(:step_matches, 
          :step_name => step_name, :formatted_step_name => formatted_step_name)
      end
      
      class Connection
        def initialize(host, port)
          @host, @port = host, port
        end
        
        def call_remote(message, args = nil)
          timeout = 5
          packet = message.to_s
          packet << ":#{args.to_json}" if args

          begin
            send_data_to_socket(packet, timeout)
            response = fetch_data_from_socket(timeout)
            response.raise_if_bad
            raise_if_bad(response)
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
          log.debug("Received response: #{raw_response}")
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
end