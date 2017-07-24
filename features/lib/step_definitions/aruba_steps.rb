# frozen_string_literal: true
Then(/^it should (pass|fail)$/) do |result|
  assert_success result == 'pass'
end

Then('{string} should not be required') do |file_name|
  expect(all_output).not_to include("* #{file_name}")
end

Then('{string} should be required') do |file_name|
  expect(all_output).to include("* #{file_name}")
end

Then('it fails before running features with:') do |expected|
  assert_matching_output("\\A#{expected}", all_output)
  assert_success(false)
end

Then('the output includes the message {string}') do |message|
  expect(all_output).to include(message)
end
