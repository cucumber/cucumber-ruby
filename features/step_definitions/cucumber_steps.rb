Given /^I am in (.*)$/ do |dir|
  @dir = dir
end

When /^I run cucumber (.*)$/ do |cmd|
  @dir ||= 'self_test'
  full_dir ||= File.expand_path(File.dirname(__FILE__) + "/../../examples/#{@dir}")
  Dir.chdir(full_dir) do
    @full_cmd = "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY} --no-color #{cmd}"
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

Then /^(.*) should contain$/ do |file, text|
  IO.read(file).should == text
end

Then /^(.*) should match$/ do |file, text|
  IO.read(file).should =~ Regexp.new(text)
end
