require 'cucumber/rspec/doubles'
require 'cucumber/cli/main'

NORUBA = File.join('tmp', 'noruba')

Before do
  FileUtils.rm_rf(NORUBA)
  FileUtils.mkdir_p(NORUBA)

  @stdout = StringIO.new
  @stderr = StringIO.new
  @kernel = double()
  allow(@kernel).to receive(:exit)
end

Given('a directory without standard Cucumber project directory structure') do
end

Given('a file named {string} with:') do |name, content|
  full_path = File.join(NORUBA, name)
  FileUtils.mkdir_p(File.dirname(full_path))
  File.open(full_path, 'w') { |file| file.write(content) }
end

When('I run `cucumber`') do
  Cucumber::Cli::Main.new(
    [],
    nil,
    @stdout,
    @stderr,
    @kernel
  ).execute!
end

Then('the exit status should be {int}') do |status|
  expect(@kernel).to have_received(:exit).once.with(status)
end

Then('it should fail with:') do |output|
  expect(@kernel).not_to have_received(:exit).with(0)
  expect(@stderr.string).to include(output)
end

Then('the output should not contain:') do |output|
  expect(@stdout.string).not_to include(output)
end