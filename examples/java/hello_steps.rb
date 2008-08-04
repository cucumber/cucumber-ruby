require 'spec' # so we can call .should
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/src') # so the jar is found
require 'cucumber_demo' # puts the jar on the classpath
include_class 'cucumber.demo.Hello'

Given /my name is (\w+)/ do |name|
  @name = name
end

When /I greet (.*)/ do |someone|
  @greeting = Hello.new.greet(someone, @name)
end

Then /he should hear (.*)\./ do |message|
  @greeting.should == message
end
