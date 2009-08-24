require 'eventmachine'
require 'socket'
require 'timeout'
require 'json'

module FakeWireServer
  def receive_data data
    case data 
    when /^list_step_definitions/
      send_data [{'id' => '1', 'regexp' => 'wired'}].to_json
    when /^invoke:(.*)/
      invocation = JSON.parse($1)
      # invocation is a Hash with id and args. TODO: encode Table too....
      send_data "OK"
    end
  end
  
  def send_data(data)
    super(data + "\n")
  end
end

Given /^the wire server is in a process that has defined the following step:$/ do |string|
  # in_current_dir do
  #   File.open("./features/step_definitions/foo.rb", "w") do |file|
  #     file.puts string
  #   end
  # end
end

Given /^a wire server listening on localhost:98989$/ do
  @pid = fork do
    EventMachine::run {
      EventMachine::start_server "127.0.0.1", 98989, FakeWireServer
    }
  end
end

After('@wire') do
  Process.kill('KILL', @pid)
end