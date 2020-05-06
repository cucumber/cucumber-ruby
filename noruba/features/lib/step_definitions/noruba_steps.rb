require 'securerandom'
require 'nokogiri'

require 'cucumber/rspec/doubles'
require 'cucumber/cli/main'

require_relative './output'
require_relative './command_line'
require_relative './filesystem'

NORUBA_PATH = 'noruba/features/lib'

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
    @command_line&.destroy_mocks

    Dir.chdir(original_cwd)
    if scenario.status != :failed
      FileUtils.rm_rf(tmp_working_directory)
    end
  end
end


Before('@global_state') do
  # Ok, this one is tricky but kinda make sense.
  # So, we need to share state between some sub-scenarios (the ones executed by
  # CucumberCommand). But we don't want those to leak between the "real" scenarios
  # (the ones ran by Cucumber itself).
  # This should reset data hopefully (and make clear why we do that)

  $global_state = nil
  $global_cukes = 0
  $scenario_runs = 0
end


After('@disable_fail_fast') do
  Cucumber.wants_to_quit = false
end

Given('a directory named {string}') do |path|
  FileUtils.mkdir_p(path)
end

Given('a directory without standard Cucumber project directory structure') do
  # A new temp dir is created for each running scenario, so it will be empty
end

Given('the standard step definitions') do
  write_file 'features/step_definitions/steps.rb',
             <<-STEPS
  Given(/^this step passes$/)          { }
  Given(/^this step raises an error$/) { raise 'error' }
  Given(/^this step is pending$/)      { pending }
  Given(/^this step fails$/)           { fail }
  Given(/^this step is a table step$/) {|t| }
  STEPS
end

Given('a file named {string} with:') do |path, content|
  write_file(path, content)
end

Given('an empty file named {string}') do |path|
  write_file(path, '')
end

Given('the following profiles are defined:') do |profiles|
  write_file('cucumber.yml', profiles)
end

Given('the following profile is defined:') do |profile|
  write_file('cucumber.yml', profile)
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

When('I run `cucumber{}`') do |args|
  @command_line = CucumberCommand.new()
  @command_line.execute(args)
end

When('I run `bundle exec ruby {}`') do |filename|
  @command_line = RubyCommand.new()

  @command_line.execute("#{Dir.pwd}/#{filename}")
end

When('I run `(bundle exec )rake {word}`') do |task|
  @command_line = RakeCommand.new()
  @command_line.execute(task)
end

When('I run the feature with the progress formatter') do
  @command_line = CucumberCommand.new()
  @command_line.execute("features/ --format progress")
end

Then('the exit status should be {int}') do |status|
  expect(@command_line.exit_status).to eq(status)
end

Then('it should fail') do
  expect(@command_line.exit_status).not_to eq(0)
end

Then('it should fail with:') do |output|
  #expect(@command_line.exit_status).not_to eq(0)
  output_include(@command_line.all_output, output)
end

Then('it should fail with exactly:') do |output|
  #expect(@command_line.exit_status).not_to eq(0)
  output_equals(@command_line.all_output, output)
end

Then('it should pass') do
  expect(@command_line.exit_status).to eq(0)
end

Then('it should pass with:') do |output|
  #expect(@command_line.exit_status).to eq(0)
  output_include(@command_line.all_output, output)
end

Then('it should pass with exactly:') do |output|
  output_equals(@command_line.all_output, output)
end

Then('the output should contain:') do |output|
  output_include(@command_line.all_output, output)
end

Then('the output should contain {string}') do |output|
  output_include(@command_line.all_output, output)
end

Then('the output includes the message {string}') do |message|
  expect(@command_line.all_output).to include(message)
end

Then('the output should not contain:') do |output|
  output_include_not(@command_line.all_output, output)
end

Then('the output should not contain {string}') do |output|
  output_include_not(@command_line.all_output, output)
end

Then('the stdout should contain exactly:') do |output|
  output_equals(@command_line.stdout, output)
end

Then('the stderr should contain:') do |output|
  output_include(@command_line.stderr, output)
end

Then('the stderr should not contain:') do |output|
  output_include_not(@command_line.stderr, output)
end

Then('the stderr should not contain anything') do
  expect(@command_line.stderr).to be_empty
end

Then('the {word} profile should be used') do |profile|
  output_include(@command_line.all_output, profile)
end

Then('exactly these files should be loaded: {list}') do |files|
  expect(@command_line.stdout.scan(/^  \* (.*\.rb)$/).flatten).to eq files
end

Then('exactly these features should be run: {list}') do |files|
  expect(@command_line.stdout.scan(/^  \* (.*\.feature)$/).flatten).to eq files
end

Then('{string} should not be required') do |file_name|
  expect(@command_line.stdout).not_to include("* #{file_name}")
end

Then('{string} should be required') do |file_name|
  expect(@command_line.stdout).to include("* #{file_name}")
end

Then('it fails before running features with:') do |expected|
  output_starts_with(@command_line.all_output, expected)
  expect(@command_line.exit_status).not_to eq(0)
end

Given('a scenario with a step that looks like this:') do |content|
  write_file(
    'features/my_feature.feature',
     <<-FEATURE
Feature: feature #{ SecureRandom.uuid }

  Scenario: scenario #{ SecureRandom.uuid }
  #{content}
FEATURE
  )
end

Given('a scenario with a step that looks like this in japanese:') do |content|
  write_file(
    'features/my_feature.feature',
     <<-FEATURE
# language: ja
機能: #{ SecureRandom.uuid }

シナリオ: scenario #{ SecureRandom.uuid }
#{content}
FEATURE
  )
end

Given('a scenario {string} that fails once, then passes') do |full_name|
  name = snake_case(full_name)
  write_file "features/#{name}.feature",
             <<-FEATURE
  Feature: #{full_name} feature
    Scenario: #{full_name}
      Given it fails once, then passes
  FEATURE

  write_file "features/step_definitions/#{name}_steps.rb",
             <<-STEPS
  Given(/^it fails once, then passes$/) do
    $#{name} += 1
    expect($#{name}).to be > 1
  end
  STEPS

  write_file "features/support/#{name}_init.rb",
             <<-INIT
  $#{name} = 0
  INIT
end

Given('a scenario {string} that fails twice, then passes') do |full_name|
  name = snake_case(full_name)
  write_file "features/#{name}.feature",
             <<-FEATURE
  Feature: #{full_name} feature
    Scenario: #{full_name}
      Given it fails twice, then passes
  FEATURE

  write_file "features/step_definitions/#{name}_steps.rb",
             <<-STEPS
  Given(/^it fails twice, then passes$/) do
    $#{name} ||= 0
    $#{name} += 1
    expect($#{name}).to be > 2
  end
  STEPS

  write_file "features/support/#{name}_init.rb",
             <<-INIT
  $#{name} = 0
  INIT
end

Given('a scenario {string} that passes') do |name|
  write_file "features/#{name}.feature",
             <<-FEATURE
  Feature: #{name}
    Scenario: #{name}
      Given it passes
  FEATURE

  write_file "features/step_definitions/#{name}_steps.rb",
             <<-STEPS
  Given(/^it passes$/) { expect(true).to be true }
  STEPS
end

Given('a scenario {string} that fails') do |name|
  write_file "features/#{name}.feature",
             <<-FEATURE
  Feature: #{name}
    Scenario: #{name}
      Given it fails
  FEATURE

  write_file "features/step_definitions/#{name}_steps.rb",
             <<-STEPS
  Given(/^it fails$/) { expect(false).to be true }
  STEPS
end

def snake_case(name)
  name.downcase.gsub(/\W/, '_')
end

Given('a step definition that looks like this:') do |content|
  write_file("features/step_definitions/steps#{ SecureRandom.uuid }.rb", content)
end

Then('a file named {string} should exist') do |path|
  expect(File.file?(path)).to be true
end

Then('the file {string} should contain:') do |path, content|
  expect(File.read(path)).to include(content)
end

Then('output should be html with title {string}') do |title|
  document = Nokogiri::HTML.parse(@command_line.stdout)
  expect(document.xpath('//title').text).to eq(title)
end

Then('output should be valid NDJSON') do
  @command_line.stdout.split("\n").map do |line|
    expect { JSON.parse(line) }.not_to raise_exception
  end
end

Then('messages types should be:') do |expected_types|
  parsed_json = @command_line.stdout.split("\n").map { |line| JSON.parse(line) }
  message_types = parsed_json.map(&:keys).flatten.compact

  expect(expected_types.split("\n").map(&:strip)).to contain_exactly(*message_types)
end

Then('the junit output file {string} should contain:') do |actual_file, text|
  actual = IO.read(File.expand_path('.') + '/' + actual_file)
  actual = remove_self_ref(replace_junit_time(actual))

  output_equals(actual, text)
end

def replace_junit_time(time)
  time.gsub(/\d+\.\d\d+/m, '0.05')
end

Then('it should fail with JSON:') do |json|
  #expect(@command_line.exit_status).not_to eq(0)
  actual = normalise_json(JSON.parse(@command_line.stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end

Then('it should pass with JSON:') do |json|
  #expect(@command_line.exit_status).to eq(0)
  actual = normalise_json(JSON.parse(@command_line.stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end

def normalise_json(json)
  # make sure duration was captured (should be >= 0)
  # then set it to what is "expected" since duration is dynamic
  json.each do |feature|
    elements = feature.fetch('elements') { [] }
    elements.each do |scenario|
      scenario['steps'].each do |_step|
        %w[steps before after].each do |type|
          next unless scenario[type]
          scenario[type].each do |step_or_hook|
            normalise_json_step_or_hook(step_or_hook)
            next unless step_or_hook['after']
            step_or_hook['after'].each do |hook|
              normalise_json_step_or_hook(hook)
            end
          end
        end
      end
    end
  end
end

def normalise_json_step_or_hook(step_or_hook)
  if step_or_hook['result']['error_message']
    step_or_hook['result']['error_message'] = step_or_hook['result']['error_message']
      .split("\n")
      .reject { |line| line.include?(NORUBA_PATH)}
      .join("\n")
  end

  return unless step_or_hook['result'] && step_or_hook['result']['duration']
  expect(step_or_hook['result']['duration']).to be >= 0
  step_or_hook['result']['duration'] = 1
end

Then('I should see the CLI help') do
  expect(@command_line.stdout).to include('Usage:')
end

Then('cucumber lists all the supported languages') do
  sample_languages = %w[Arabic български Pirate English 日本語]
  sample_languages.each do |language|
    expect(@command_line.stdout.force_encoding('utf-8')).to include(language)
  end
end

Then('the output should contain NDJSON with key {string} and value {string}') do |key, value|
  expect(@command_line.stdout).to match(/"#{key}": ?"#{value}"/)
end

When('I rerun the previous command with the same seed') do
  previous_seed = @command_line.stdout.match(/with seed (\d+)/)[1]

  @command_line2 = CucumberCommand.new()
  @command_line2.execute(@command_line.args.gsub(/random/, "random:#{previous_seed}"))
end

Then('the output of both commands should be the same') do
  output_equals(@command_line.stdout, @command_line2.stdout)
end
