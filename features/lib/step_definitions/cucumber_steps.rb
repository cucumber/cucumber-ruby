require 'securerandom'
require 'nokogiri'

Given('a directory without standard Cucumber project directory structure') do
  FileUtils.cd('.') do
    FileUtils.rm_rf 'features' if File.directory?('features')
  end
end

Given('log only formatter is declared') do
  write_file('features/support/log_only_formatter.rb', [
    'class LogOnlyFormatter',
    '  attr_reader :io',
    '',
    '  def initialize(config)',
    '    @io = config.out_stream',
    '  end',
    '',
    '  def attach(src, media_type)',
    '    @io.puts src',
    '  end',
    'end'
  ].join("\n"))
end

Then('exactly these files should be loaded: {list}') do |files|
  expect(command_line.stdout.scan(/^  \* (.*\.rb)$/).flatten).to eq files
end

Then('exactly these features should be run: {list}') do |files|
  expect(command_line.stdout.scan(/^  \* (.*\.feature)$/).flatten).to eq files
end

Then('{string} should not be required') do |file_name|
  expect(command_line.stdout).not_to include("* #{file_name}")
end

Then('{string} should be required') do |file_name|
  expect(command_line.stdout).to include("* #{file_name}")
end

Then('it fails before running features with:') do |expected|
  expect(command_line.all_output).to start_with_output(expected)
  expect(command_line).to have_failed
end

Then('the file {string} should contain:') do |path, content|
  expect(File.read(path)).to include(content)
end

When('I rerun the previous command with the same seed') do
  previous_seed = command_line.stdout.match(/with seed (\d+)/)[1]

  execute_extra_cucumber(command_line.args.gsub(/random/, "random:#{previous_seed}"))
end

Then('the output of both commands should be the same') do
  expect(command_line.stdout).to be_similar_output_than(last_extra_command.stdout)
end
