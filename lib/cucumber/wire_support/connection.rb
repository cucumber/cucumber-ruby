require 'cucumber/step_argument'

module Cucumber
  module WireSupport
    class Connection
      def initialize(config)
        @host, @port = config['host'], config['port']
      end
      
      def step_matches(step_name, formatted_step_name)
        raw_response = call_remote(:step_matches, 
          :step_name           => step_name)
          
        raw_response.args.map do |raw_step_match|
          step_definition = WireStepDefinition.new(raw_step_match['id'], self)
          args = raw_step_match['args'].map do |raw_arg|
            StepArgument.new(raw_arg['val'], raw_arg['pos'])
          end
          StepMatch.new(step_definition, step_name, formatted_step_name, args)
        end
      end
      
      def invoke(step_definition_id, args)
        raw_response = call_remote(:invoke, 
          :id   => step_definition_id, 
          :args => args)
        
        return if raw_response.message == 'success'
        raise WireException.new(raw_response.args)
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