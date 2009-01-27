def flunker
  raise "FAIL"
end

Given /^passing$/ do |table|
end

Given /^failing$/ do |table|
  flunker
end

Given /^passing without a table$/ do
end

Given /^failing without a table$/ do
  flunker
end

Given /^a step definition that calls an undefined step$/ do
  Given 'this does not exist'
end

Given /^call step "(.*)"$/ do |step|
  Given step
end

Given /^'(.+)' cukes$/ do |cukes|
  @cukes = cukes
end

Then /^I should have '(.+)' cukes$/ do |cukes|
  @cukes.should == cukes
end

Given /^'(.+)' global cukes$/ do |cukes|
  $x ||= 0
  flunker if $x > 0
  $cukes = cukes
  $x += 1
end

Then /^I should have '(.+)' global cukes$/ do |cukes|
  $cukes.should == cukes
end