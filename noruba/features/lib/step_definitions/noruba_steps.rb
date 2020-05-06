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


Then('the {word} profile should be used') do |profile|
  expect(command_line.all_output).to include_output(profile)
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

Given('a scenario with a step that looks like this:') do |content|
  write_file(
    'features/my_feature.feature',
    feature(
      "feature #{ SecureRandom.uuid }",
      [scenario("scenario #{ SecureRandom.uuid }", content)]
    )
  )
end

Given('a scenario with a step that looks like this in japanese:') do |content|
  write_file(
    'features/my_feature.feature',
    feature(
      SecureRandom.uuid,
      [scenario("scenario #{ SecureRandom.uuid }", content, keyword: 'シナリオ')],
      keyword: '機能',
      language: 'ja'
    )
  )
end

Given('a scenario {string} that fails once, then passes') do |full_name|
  name = snake_case(full_name)
  write_file(
    "features/#{name}.feature",
    feature(
      "#{full_name} feature",
      [scenario(full_name, 'Given it fails once, then passes')]
    )
  )

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
  write_file(
    "features/#{name}.feature",
    feature(
      "#{full_name} feature",
      [scenario(full_name, 'Given it fails twice, then passes')]
    )
  )

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
  write_file(
    "features/#{name}.feature",
    feature(
      name,
      [scenario(name, 'Given it passes')]
    )
  )

  write_file "features/step_definitions/#{name}_steps.rb",
             <<-STEPS
  Given(/^it passes$/) { expect(true).to be true }
  STEPS
end

Given('a scenario {string} that fails') do |name|
  write_file(
    "features/#{name}.feature",
    feature(
      name,
      [scenario(name, 'Given it fails')]
    )
  )

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

Then('the file {string} should contain:') do |path, content|
  expect(File.read(path)).to include(content)
end

Then('output should be html with title {string}') do |title|
  document = Nokogiri::HTML.parse(command_line.stdout)
  expect(document.xpath('//title').text).to eq(title)
end

Then('output should be valid NDJSON') do
  command_line.stdout.split("\n").map do |line|
    expect { JSON.parse(line) }.not_to raise_exception
  end
end

Then('messages types should be:') do |expected_types|
  parsed_json = command_line.stdout.split("\n").map { |line| JSON.parse(line) }
  message_types = parsed_json.map(&:keys).flatten.compact

  expect(expected_types.split("\n").map(&:strip)).to contain_exactly(*message_types)
end

Then('the junit output file {string} should contain:') do |actual_file, text|
  actual = IO.read(File.expand_path('.') + '/' + actual_file)
  actual = remove_self_ref(replace_junit_time(actual))

  expect(actual).to be_similar_output_than(text)
end

Then('it should fail with JSON:') do |json|
  expect(command_line).to have_failed
  actual = normalise_json(JSON.parse(command_line.stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end

Then('it should pass with JSON:') do |json|
  expect(command_line).to have_succeded
  actual = normalise_json(JSON.parse(command_line.stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end

Then('I should see the CLI help') do
  expect(command_line.stdout).to include('Usage:')
end

Then('cucumber lists all the supported languages') do
  sample_languages = %w[Arabic български Pirate English 日本語]
  sample_languages.each do |language|
    expect(command_line.stdout.force_encoding('utf-8')).to include(language)
  end
end

Then('the output should contain NDJSON with key {string} and value {string}') do |key, value|
  expect(command_line.stdout).to match(/"#{key}": ?"#{value}"/)
end

When('I rerun the previous command with the same seed') do
  previous_seed = command_line.stdout.match(/with seed (\d+)/)[1]

  @command_line2 = CucumberCommand.new()
  @command_line2.execute(command_line.args.gsub(/random/, "random:#{previous_seed}"))
end

Then('the output of both commands should be the same') do
  expect(command_line.stdout).to be_similar_output_than(@command_line2.stdout)
end
