When /^I run cucumber "(.+)"$/ do |cmd|
  run_simple(unescape("cucumber #{cmd}"), false)
end

Then /^it should (pass|fail) with JSON:$/ do |pass_fail, json|
  # Need to store it in a variable. With JRuby we can only do this once it seems :-/
  stdout = all_stdout
  
  # JRuby has weird traces sometimes (?)
  stdout = stdout.gsub(/ `\(root\)':in/, '') 

  actual = JSON.parse(stdout)
  expected = JSON.parse(json)
  
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

Given /^a step definition that looks like this:$/ do |string|
  create_step_definition { string }
end

When /^I run the feature with the (\w+) formatter$/ do |formatter|
  features.length.should == 1
  run_feature features.first, formatter
end
