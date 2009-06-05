require 'tempfile'

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

Given /^the (.*) directory is empty$/ do |directory|
  in_current_dir do
    FileUtils.remove_dir(directory) rescue nil
    FileUtils.mkdir 'tmp'
  end
end

Given /^a file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, '')
end

Given /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

Given /^the following profiles? (?:are|is) defined:$/ do |profiles|
  create_file('cucumber.yml', profiles)
end

Given /^I am running "([^\"]*)" in the background$/ do |command|
  run_in_background command
end

Given /^I am not running (?:.*) in the background$/ do
  # no-op
end


When /^I run cucumber (.*)$/ do |cucumber_opts|
  run "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY} --no-color #{cucumber_opts}"
end

When /^I run rake (.*)$/ do |rake_opts|
  run "rake #{rake_opts} --trace"
end

Then /^it should (fail|pass)$/ do |success|
  if success == 'fail'
    last_exit_status.should_not == 0
  else
    if last_exit_status != 0
      raise "Failed with exit status #{last_exit_status}\nSTDOUT:\n#{last_stdout}\nSTDERR:\n#{last_stderr}"
    end
  end
end

Then /^it should (fail|pass) with$/ do |success, output|
  last_stdout.should == output
  Then("it should #{success}")
end

Then /^the output should contain$/ do |text|
  last_stdout.should include(text)
end

Then /^the output should not contain$/ do |text|
  last_stdout.should_not include(text)
end

Then /^the output should be$/ do |text|
  last_stdout.should == text
end

Then /^"(.*)" should contain XML$/ do |file, xml|
  t = Tempfile.new('cucumber-junit')
  t.write(xml)
  t.flush
  t.close
  cmd = "diffxml #{t.path} #{file}"
  diff = `#{cmd}`
  if diff =~ /<delta>/m
    raise diff + "\nXML WAS:\n" + IO.read(file)
  end
end

Then /^"(.*)" should contain$/ do |file, text|
  strip_duration(IO.read(file)).should == text
end

Then /^"(.*)" should match$/ do |file, text|
  IO.read(file).should =~ Regexp.new(text)
end

Then /^"([^\"]*)" should have the same contents as "([^\"]*)"$/ do |actual_file, expected_file|
  actual = IO.read(actual_file)
  actual = replace_duration(actual, '0m30.005s')
  # Comment out to replace expected file. Use with care! Remember to update duration afterwards.
  # File.open(expected_file, "w") {|io| io.write(actual)}
  actual.should == IO.read(expected_file)
end

Then /^STDERR should match$/ do |text|
  last_stderr.should =~ /#{text}/
end

Then /^STDERR should not match$/ do |text|
  last_stderr.should_not =~ /#{text}/
end

Then /^STDERR should be empty$/ do
  last_stderr.should == ""
end

Then /^"(.*)" should exist$/ do |file|
  File.exists?(file).should be_true
  FileUtils.rm(file)
end

Then /^"([^\"]*)" should not be required$/ do |file_name|
  last_stdout.should_not include("* #{file_name}")
end

Then /^"([^\"]*)" should be required$/ do |file_name|
  last_stdout.should include("* #{file_name}")
end

