Given /^a directory without standard Cucumber project directory structure$/ do
  in_current_dir do
    FileUtils.rm_rf 'features' if File.directory?('features')
  end
end

Given /^a scenario with a step that looks like this:$/ do |string|
  create_feature do
    create_scenario { string }
  end
end

Given(/^a scenario with a step that looks like this in japanese:$/) do |string|
  create_feature_ja do
    create_scenario_ja { string }
  end
end

Given /^a step definition that looks like this:$/ do |string|
  create_step_definition { string }
end

When /^I run the feature with the (\w+) formatter$/ do |formatter|
  features.length.should == 1
  run_feature features.first, formatter
end

module CucumberHelper
  def run_feature(filename = 'features/a_feature.feature', formatter = 'progress')
    run_simple "#{Cucumber::BINARY} #{filename} --format #{formatter}", false
  end
end

World(CucumberHelper)
