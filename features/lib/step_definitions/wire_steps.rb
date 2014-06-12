Given /^there is a wire server (running |)on port (\d+) which understands the following protocol:$/ do |running, port, table|
  protocol = table.hashes.map do |table_hash|
    table_hash['response'] = table_hash['response'].gsub(/\n/, '\n')
    table_hash
  end

  @server = FakeWireServer.new(port.to_i, protocol)
  start_wire_server if running.strip == "running"
end

Given /^the wire server takes (.*) seconds to respond to the invoke message$/ do |timeout|
  @server.delay_response(:invoke, timeout.to_f)
  start_wire_server
end

Given /^I have environment variable (\w+) set to "([^"]*)"$/ do |variable, value|
  set_env(variable, value)
end

module WireHelper
  def start_wire_server
    @wire_pid = fork { @server.run }
    at_exit { stop_wire_server }
  end

  def stop_wire_server
    return unless @wire_pid
    Process.kill('KILL', @wire_pid)
    Process.wait(@wire_pid)
  end
end

Before('@wire') do
  extend(WireHelper)
end

After('@wire') do
  stop_wire_server
end
