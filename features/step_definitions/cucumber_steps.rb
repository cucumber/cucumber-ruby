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

When /^I run cucumber (.*)$/ do |cmd|
  in_current_dir do
    @full_cmd = "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY} --no-color #{cmd}"
    @out = `#{@full_cmd}`
    @status = $?.exitstatus
  end
end

When /^I run rake (.*)$/ do |args|
  in_current_dir do
    @full_cmd = "rake #{args}"
    @out = `#{@full_cmd}`
    @status = $?.exitstatus
  end
end

Then /^it should (fail|pass) with$/ do |success, output|
  @out.should == output
  if success == 'fail'
    @status.should_not == 0
  else
    @status.should == 0
  end
end

Then /^the output should contain$/ do |text|
  @out.should include(text)
end

Then /^"(.*)" should contain$/ do |file, text|
  IO.read(file).should == text
end

Then /^"(.*)" should match$/ do |file, text|
  IO.read(file).should =~ Regexp.new(text)
end
