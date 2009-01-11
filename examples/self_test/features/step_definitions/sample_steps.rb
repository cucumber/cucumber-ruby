Given /^passing$/ do |table|
end

Given /^failing$/ do |table|
  raise "FAIL"
end

Given /^passing without a table$/ do
end

Given /^failing without a table$/ do
  raise "FAIL"
end