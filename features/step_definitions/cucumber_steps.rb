Given /^I am in (.*)$/ do |example_dir_relative_path|
  @current_dir = examples_dir(example_dir_relative_path)
end

Given /^a standard Cucumber project directory structure$/ do
  @current_dir = working_dir
  in_current_dir do
    FileUtils.mkdir_p 'features/support'
    FileUtils.mkdir 'features/step_definitions'
  end
end

Given /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

Given /^the following profiles? (?:are|is) defined:$/ do |profiles|
  create_file('cucumber.yml', profiles)
end

When /^I run cucumber (.*)$/ do |cucumber_opts|
  run "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY} --no-color #{cucumber_opts}"
end

When /^I run rake (.*)$/ do |rake_opts|
  run "rake #{rake_opts}"
end

Then /^it should (fail|pass)$/ do |success|
  if success == 'fail'
    last_exit_status.should_not == 0
  else
    last_exit_status.should == 0
  end
end

Then /^it should (fail|pass) with$/ do |success, output|
  last_stdout.should == output
  Then("it should #{success}")
end

Then /^the output should contain$/ do |text|
  last_stdout.should include(text)
end

Then /^"(.*)" should contain$/ do |file, text|
  IO.read(file).should == text
end

Then /^"(.*)" should match$/ do |file, text|
  IO.read(file).should =~ Regexp.new(text)
end

Then /^STDERR should match$/ do |text|
  last_stderr.should =~ /#{text}/
end

Then /^"(.*)" should exist$/ do |file|
  File.exists?(file).should be_true
  FileUtils.rm(file)
end
