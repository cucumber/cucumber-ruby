require 'spec/expectations' # so we can call .should
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../src') # so the jar is found
require 'cucumber_demo' # puts the jar on the classpath
include_class 'cucumber.demo.Hello'

Given /my name is (\w+)/ do |name|
  @hello = Hello.new # A java object
  @name = name
end

When /I greet (.*)/ do |someone|
  @greeting = @hello.greet(someone, @name)
end

Then /he should hear (.*)\./ do |message|
  @greeting.should == message
end

Then /I should remember (\w+) as a friend/ do |name|
  @hello.friend?(name).should == true
end

Then /I should get (\w+)'s phone number/ do |name| #'
  @hello.getPhoneNumber(name).should_not == nil
end
