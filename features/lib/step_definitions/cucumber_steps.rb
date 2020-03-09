# frozen_string_literal: true

Given('a directory without standard Cucumber project directory structure') do
  cd('.') do
    FileUtils.rm_rf 'features' if File.directory?('features')
  end
end

Given('a scenario with a step that looks like this:') do |string|
  create_feature do
    create_scenario { string }
  end
end

Given('a scenario with a step that looks like this in japanese:') do |string|
  create_feature_ja do
    create_scenario_ja { string }
  end
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

Given('a step definition that looks like this:') do |string|
  create_step_definition { string }
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

When(/^I run the feature with the (\w+) formatter$/) do |formatter|
  expect(features.length).to eq 1
  run_feature features.first, formatter
end

When(/^I rerun the previous command with the same seed$/) do
  previous_seed = last_command_started.output.match(/with seed (\d+)/)[1]
  second_command = all_commands.last.commandline.gsub(/random/, "random:#{previous_seed}")

  step "I run `#{second_command}`"
end

Then(/the output of both commands should be the same/) do
  first_output = all_commands.first.output.gsub(/\d+m\d+\.\d+s/, '')
  last_output = all_commands.last.output.gsub(/\d+m\d+\.\d+s/, '')

  expect(first_output).to eq(last_output)
end

module CucumberHelper
  def run_feature(filename = 'features/a_feature.feature', formatter = 'progress')
    run_command(sanitize_text("#{Cucumber::BINARY} #{filename} --format #{formatter}"))
  end
end

World(CucumberHelper)
