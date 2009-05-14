require 'spec/expectations' # so we can call .should
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
