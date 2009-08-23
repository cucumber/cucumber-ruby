require 'eventmachine'
require 'socket'
require 'timeout'

module FakeWireServer
  def post_init
    # puts "-- someone connected to the wire server"
  end

  def receive_data data
    if data == 'get_steps'
      send_data '/I am here/'
      return
    end
    close_connection if data =~ /quit/i
    puts ">>>you sent: #{data}"
  end

  def unbind
    # puts "-- someone disconnected from the wire server!"
  end
  
  def close_connection
    super
    EM.stop
  end
end

module WireClient
  def receive_data(data)
    puts "Client received>> #{data}"
  end
end

Given /^the wire server is in a process that has defined the following step:$/ do |string|
  in_current_dir do
    File.open("./features/step_definitions/foo.rb", "w") do |file|
      file.puts string
    end
  end
end

Given /^a wire server listening on localhost:98989$/ do
  @pid = fork do
    EventMachine::run {
      EventMachine::start_server "127.0.0.1", 98989, FakeWireServer
    }
  end
  at_exit do
    Process.kill('KILL', @pid)
  end

  Thread.abort_on_exception = true
  Thread.new do
    EM.run do
      @wire_client = EM.connect '127.0.0.1', 98989, WireClient
    end
  end
  sleep 5
  @wire_client.send_data 'get_steps'
  sleep 5
end

After do
  EM.stop
  Process.kill('KILL', @pid)
end