Given /a passing scenario/ do
  #does nothing
end

Given /a failing scenario/ do
  fail
end

Given /a pending step/ do
  pending
end

Given /^I add (\d+) and (\d+)$/ do |a,b|
  @result = a.to_i + b.to_i
end

Then /^I the result should be (\d+)$/ do |c|
  @result.should == c.to_i
end

Then /^I should see/ do |string|

end

