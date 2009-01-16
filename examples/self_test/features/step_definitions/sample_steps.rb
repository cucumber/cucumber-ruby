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