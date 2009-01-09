require 'spec/expectations'
include_class 'java.util.TreeSet'

Given /I have an empty set/ do
  @set = TreeSet.new  
end

When /I add (\w+)/ do |s|
  @set.add(s)
end

Then /the contents should be (.*)/ do |s|
  @set.to_a.join(" ").should == s
end
