When /^I run cucumber (.*)$/ do |cmd|
  dir = File.expand_path(File.dirname(__FILE__) + '/../../examples/self_test')
  Dir.chdir(dir) do
    @full_cmd = "#{Cucumber::RUBY_BINARY} #{Cucumber::BINARY} #{cmd}"
    @out = `#{@full_cmd}`
  end
end

Then /^the output should be$/ do |output|
  @out.should == output
end
