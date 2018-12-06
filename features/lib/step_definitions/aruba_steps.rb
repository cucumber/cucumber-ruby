# frozen_string_literal: true

Then(/^it should (pass|fail)$/) do |result|
  if result == 'pass'
    expect(last_command_started).to be_successfully_executed
  else
    expect(last_command_started).not_to be_successfully_executed
  end
end

Then('{string} should not be required') do |file_name|
  expect(all_stdout).not_to include("* #{file_name}")
end

Then('{string} should be required') do |file_name|
  expect(all_stdout).to include("* #{file_name}")
end

Then('it fails before running features with:') do |expected|
  assert_matching_output("\\A#{expected}", all_stdout)
  step 'it should fail'
end

Then('the output includes the message {string}') do |message|
  expect(all_stdout).to include(message)
end
