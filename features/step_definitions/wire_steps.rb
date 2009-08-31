Given /^a local wire server listening on port (\d+) reading step definitions from "([^\"]*)"$/ do |port, dir|
  in_current_dir do
    @wire_pid = fork do
      @server = Cucumber::WireSupport::WireServer.new(port.to_i, dir)
      @server.run
    end
  end
end

After('@wire') do
  Process.kill('KILL', @wire_pid)
end