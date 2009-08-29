Given /^a local wire server listening on port (\d+) reading step definitions from "([^\"]*)"$/ do |port, dir|
  dir = in_current_dir { File.expand_path(dir) }
  @wire_pid = fork do
    @server = Cucumber::WireSupport::WireServer.new(port.to_i, dir)
    @server.run
  end
end

After('@wire') do
  Process.kill('KILL', @wire_pid)
end