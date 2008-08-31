require 'spec' # so we can call .should
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../src') # so the jar is found
require 'dotnet'
loadLibrary 'Cucumber.Demo'

Given /my name is (\w+)/ do |name|
  @hello = Hello.new # A .net object
  @name = name
end

When /I greet (.*)/ do |someone|
  @greeting = @hello.greet(someone, @name)
end

Then /he should hear (.*)\./ do |message|
  @greeting.should == message
end

Then /I should remember (\w+) as a friend/ do |name|
  @hello.isFriend(name).should == true
end

Then /I should get (\w+)'s phone number/ do |name|
  @hello.getPhoneNumber(name).should_not == nil
end
