require 'test/unit/assertions'

World(Test::Unit::Assertions)

Given(/^(\w+) = (\w+)$/) do |var, value|
  instance_variable_set("@#{var}", value)
end

Then(/^I can assert that (\w+) == (\w+)$/) do |var_a, var_b|
  a = instance_variable_get("@#{var_a}")
  b = instance_variable_get("@#{var_b}")
  assert_equal(a, b)
end
