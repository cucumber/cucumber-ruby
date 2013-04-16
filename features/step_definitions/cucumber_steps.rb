Then 'it should pass' do
  assert_exit_status 0
end

Then /^it should (pass|fail) with JSON:$/ do |pass_fail, json|
  # Need to store it in a variable. With JRuby we can only do this once it seems :-/
  stdout = all_stdout

  # JRuby has weird traces sometimes (?)
  stdout = stdout.gsub(/ `\(root\)':in/, '')

  actual = JSON.parse(stdout)
  expected = JSON.parse(json)

  #make sure duration was captured (should be >= 0)
  #then set it to what is "expected" since duration is dynamic
  actual.each do |feature|
    feature['elements'].each do |scenario|
      scenario['steps'].each do |step|
        step['result']['duration'].should be >= 0
        step['result']['duration'] = 1
      end
    end
  end

  actual.should == expected
  assert_success(pass_fail == 'pass')
end

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
