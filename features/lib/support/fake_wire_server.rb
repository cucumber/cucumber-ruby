# frozen_string_literal: true
require 'multi_json'
require 'socket'

class FakeWireServer
  def initialize(port, protocol_table)
    @port, @protocol_table = port, protocol_table
    @delays = {}
  end

  def run(io)
    @server = TCPServer.open(@port)
    loop { handle_connections(io) }
  end

  def delay_response(message, delay)
    @delays[message] = delay
  end

  private

  def handle_connections(io)
    Thread.start(@server.accept) { |socket| open_session_on socket, io }
  end

  def open_session_on(socket, io)
    begin
      on_message = lambda { |message| io.puts message }
      SocketSession.new(socket, @protocol_table, @delays, on_message).start
    rescue Exception => e
      raise e
    ensure
      socket.close
    end
  end

  class SocketSession
    def initialize(socket, protocol, delays, on_message)
      @socket = socket
      @protocol = protocol
      @delays = delays
      @on_message = on_message
    end

    def start
      message = @socket.gets

      while message
        handle(message)
        message = @socket.gets
      end
    end

    private

    def handle(data)
      protocol_entry = response_to(data.strip)

      if protocol_entry
        sleep delay(data)
        @on_message.call(MultiJson.load(protocol_entry['request'])[0])
        send_response(protocol_entry['response'])
      else
        serialized_exception = { :message => "Not understood: #{data}", :backtrace => [] }
        send_response(['fail', serialized_exception ].to_json)
      end
    rescue => e
      response = [
                    'fail',
                    {
                      :message => e.message,
                      :backtrace => e.backtrace,
                      :exception => e.class
                    }
                  ].to_json
      send_response(response)
    end

    def response_to(data)
      @protocol.detect do |entry|
        MultiJson.load(entry['request']) == MultiJson.load(data)
      end
    end

    def send_response(response)
      @socket.puts response + "\n"
    end

    def delay(data)
      message = MultiJson.load(data.strip)[0]
      @delays[message.to_sym] || 0
    end
  end
end
