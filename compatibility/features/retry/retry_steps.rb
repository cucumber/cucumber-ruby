# frozen_string_literal: true

Given('a step that always passes') do
  # no-op
end

second_time_pass = 0
Given('a step that passes the second time') do
  second_time_pass += 1
  raise 'Exception in step' if second_time_pass < 2
end

third_time_pass = 0
Given('a step that passes the third time') do
  third_time_pass += 1
  raise 'Exception in step' if third_time_pass < 3
end

Given('a step that always fails') do
  raise 'Exception in step'
end

Given('an ambiguous step') do
  # first one
end

Given('an ambiguous step') do
  # second one
end

Given('a pending step') do
  pending('')
end
