def flunker
  raise "FAIL"
end

Given /^passing$/ do |table|
end

Given /^failing$/ do
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