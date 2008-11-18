require 'spec'
require 'dotnet'

Given /I have an empty set/ do
  @set = System.Collections.ArrayList.new  
end

When /I add (\w+)/ do |s|
  @set.add(s)
end

Then /the contents should be (.*)/ do |s|
  @set.to_a.join(" ").should == s
end
