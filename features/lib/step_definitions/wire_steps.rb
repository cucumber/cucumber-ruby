Given /^there is a wire server (running |)on port (\d+) which understands the following protocol:$/ do |running, port, table|
  table.map_column!('response') {|cell| cell.gsub(/\n/, '\n')}
  protocol = table.hashes
  @server = FakeWireServer.new(port.to_i, protocol)
  start_wire_server if running.strip == "running"
end

Given /^the wire server takes (.*) seconds to respond to the invoke message$/ do |timeout|
  @server.delay_response(:invoke, timeout.to_f)
  start_wire_server
end

Given /^I have environment variable (\w+) set to "([^"]*)"$/ do |variable, value|
  set_env_var(variable, value)
end

module WireHelper
  def start_wire_server
    @wire_pid = fork do
      at_exit { stop_wire_server }
      @server.run
    end
  end

  def stop_wire_server
    return unless @wire_pid
    Process.kill('KILL', @wire_pid)
    Process.wait
  end
end

Before('@wire') do
  extend(WireHelper)
end

After('@wire') do
  stop_wire_server
end

module CucumberHelper
  def set_env_var(variable, value)
    @original_env_vars ||= {}
    @original_env_vars[variable] = ENV[variable]
    ENV[variable]  = value
  end
end

World(CucumberHelper)
