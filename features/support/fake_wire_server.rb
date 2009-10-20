require 'socket'
require 'timeout'
require 'json'
require 'logging'
require 'pathname'

module Cucumber
  module WireSupport
    class SocketSession
      def initialize(socket, protocol)
        @socket = socket
        @protocol = protocol
      end

      def start
        while message = @socket.gets
          log.debug "Got message: #{message.strip}"
          handle(message)
        end
      end

      private
      
      def response_to(data)
        @protocol.detect do |entry| 
          log.debug "#{entry['request']}"
          log.debug "#{data}"
          result = JSON.parse(entry['request']) == JSON.parse(data)
          result
        end
      end

      def handle(data)
        if protocol_entry = response_to(data.strip)
          send_response(protocol_entry['response'])
        else
          serialized_exception = { :message => "Not understood: #{data}", :backtrace => [] }
          send_response(['fail', serialized_exception ].to_json)
        end
      end

      def send_response(response)
        log.debug "Sending response: #{response}"
        @socket.puts response + "\n"
      end

      def step_definitions
        @step_definitions ||= @parser.parse!.step_defs
      end

      def wrap(args)
        args.map{|arg| Array === arg ? Table.new(self, arg) : arg}
      end

      def log
        Logging::Logger[self]
      end
    end

    class FakeWireServer
      def initialize(port, protocol_table)
        @port, @protocol_table = port, protocol_table
      end

      def run
        log.debug "Opening server on port #{@port}"
        @server = TCPServer.open(@port)
        loop { handle_connections }
      end

      private

      def handle_connections
        log.debug "Ready & waiting for new connection"
        Thread.start(@server.accept) { |socket| open_session_on socket }
      end

      def open_session_on(socket)
        begin
          SocketSession.new(socket, @protocol_table).start
          log.debug "Closing connection"
        rescue Exception => e
          log.error e
          raise e
        ensure
          socket.close
        end
      end

      def log
        Logging::Logger[self]
      end

    end
  end
end

logfile = File.expand_path(File.dirname(__FILE__) + '/../../cucumber.log')
Logging::Logger[Cucumber::WireSupport].add_appenders(
  Logging::Appenders::File.new(logfile)
)
Logging::Logger[Cucumber::WireSupport].level = :debug
