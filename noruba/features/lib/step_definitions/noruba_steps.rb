require 'securerandom'
require 'nokogiri'

Around do |scenario, block|
  begin
    original_cwd = Dir.pwd
    # We limit the length to avoid issues on Windows where sometimes the creation
    # of the temporary directory fails due to the length of the scenario name.
    scenario_name = scenario.name.downcase.gsub(/[^a-z0-9]+/, '-')[0..100]
    tmp_working_directory = File.join('tmp', "noruba-#{scenario_name}-#{SecureRandom.uuid}")

    FileUtils.rm_rf(tmp_working_directory)
    FileUtils.mkdir_p(tmp_working_directory)

    Dir.chdir(tmp_working_directory)

    block.call
  ensure
    command_line&.destroy_mocks

    Dir.chdir(original_cwd)
    FileUtils.rm_rf(tmp_working_directory) unless scenario.status == :failed
  end
end

Before('@global_state') do
  # Ok, this one is tricky but kinda make sense.
  # So, we need to share state between some sub-scenarios (the ones executed by
  # CucumberCommand). But we don't want those to leak between the "real" scenarios
  # (the ones ran by Cucumber itself).
  # This should reset data hopefully (and make clear why we do that)

  # rubocop:disable Style/GlobalVars
  $global_state = nil
  $global_cukes = 0
  $scenario_runs = 0
  # rubocop:enable Style/GlobalVars
end

After('@disable_fail_fast') do
  Cucumber.wants_to_quit = false
end

Given('a directory without standard Cucumber project directory structure') do
  # A new temp dir is created for each running scenario, so it will be empty
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

  @command_line2 = CucumberCommand.new
  @command_line2.execute(command_line.args.gsub(/random/, "random:#{previous_seed}"))
end

Then('the output of both commands should be the same') do
  expect(command_line.stdout).to be_similar_output_than(@command_line2.stdout)
end
