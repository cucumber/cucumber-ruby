require 'spec'

World do
  Object.new
end

Given "be_empty" do
  [1,2].should_not be_empty
end

Given "nested step is called" do
  Given "nested step"
end

Given "nested step" do
  @magic = 'mushroom'
end

Then "nested step should be executed" do
  @magic.should == 'mushroom'
end

Given /^the following table$/ do |table|
  @table = table
end

Then /^I should be (\w+) in (\w+)$/ do |key, value|
  hash = @table.hashes[0]
  hash[key].should == value
end

Then /^I shoule see a multiline string like$/ do |s|
  s.should == %{A string
that spans
several lines}
end
