require 'socket'
require 'timeout'
require 'json'
require 'logging'
require 'pathname'

module Cucumber
  module WireSupport
    class StepDefinition
      def initialize(regexp, &block)
        @regexp, @block = regexp, block
      end
      
      def id
        @regexp.to_s
      end
      
      def invoke(args)
        @block.call(*args)
      end

      def groups(step_name)
        []
      end

      def to_json(*args)
        { :id => id, :regexp => @regexp }.to_json(*args)
      end
    end

    # Raised when Table#diff! is called with a different table.
    class DiffKo < StandardError
    end

    class Table
      def initialize(session, raw)
        @session, @raw = session, raw
      end

      def diff!(other)
        @session.diff!(other)
      end
    end

    class StepDefinitionParser
      attr_reader :step_defs

      def initialize(dir)
        @step_defs = {}
        @dir = Pathname.new(dir)
      end

      def parse!
        @dir.children.each do |file|
          eval(file.read, binding, file.to_s, 1) unless file.directory?
        end
        self
      end

      def Given(regexp, &block)
        step_def = StepDefinition.new(regexp, &block)
        @step_defs[step_def.id] = step_def
      end

      def log
        Logging::Logger[self]
      end
    end

    class SocketSession
      def initialize(socket, dir)
        @socket = socket
        @parser = StepDefinitionParser.new(dir)
      end

      def start
        while message = @socket.gets
          log.debug "Got message: #{message.strip}"
          handle(message)
        end
      end

      def diff!(table)
        send_response("DIFF:" +  JSON.unparse(table))
        diffresult = @socket.gets
        case(diffresult)
          when /^DIFFOK/
          when /^DIFFKO/
            raise DiffKo
        end
      end

      private

      def handle(data)
        case data
        when /^LIST_STEP_DEFINITIONS/
          send_response JSON.unparse(step_definitions.values)
        when /^INVOKE:(.*)/
          invocation_instruction = JSON.parse($1)
          send_response invoke_step_definition(invocation_instruction)
        when /^GROUPS_FOR_STEP_NAME:(.*)/
          hash = JSON.parse($1)
          step_def = step_definitions[hash['id']]
          step_name = hash['step_name']
          groups = step_def.groups(step_name)
          send_response("GROUPS:#{groups.to_json}")
        else
          serialized_exception = { :message => "Not understood: #{data}", :backtrace => [] }
          send_response "FAIL:#{serialized_exception.to_json}"
        end
      end
      
      def invoke_step_definition(instructions)
        begin
          unless step_def = step_definitions[instructions['id']]
            raise "Unable to find a step definition with id '#{instructions['id']}' amongst #{step_definitions.keys.join(',')}"
          end
          
          raw_args = instructions['args']
          args = wrap(raw_args)
          step_def.invoke(args)
          'OK'
        rescue Exception => exception
          clean_backtrace = exception.backtrace.reject do |l| 
            l =~ /bin\/cucumber|lib\/cucumber|wire_server|instance_exec|wire_steps|support\/env.rb/
          end
          serialized_exception = { :message => exception.message, :backtrace => clean_backtrace }
          "FAIL:#{serialized_exception.to_json}"
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

    class WireServer
      def initialize(port, dir)
        @port, @dir = port, dir
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
          SocketSession.new(socket, @dir).start
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

Logging::Logger[Cucumber::WireSupport].add_appenders(
  Logging::Appenders::File.new('cucumber.log')
)
Logging::Logger[Cucumber::WireSupport].level = :debug
