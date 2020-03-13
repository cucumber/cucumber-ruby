# frozen_string_literal: true

require 'nokogiri'

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
  expect(all_output).to match(/\A#{expected}/)
  step 'it should fail'
end

Then('the output includes the message {string}') do |message|
  expect(all_stdout).to include(message)
end

Then('the output should contain (ND)JSON with key {string} and value {string}') do |key, value|
  expect(all_stdout).to match(/"#{key}": ?"#{value}"/)
end

Then('output should be html with title {string}') do |title|
  document = Nokogiri::HTML.parse(all_stdout)
  expect(document.xpath("//title").text).to eq(title)
end