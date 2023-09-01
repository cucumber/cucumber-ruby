# frozen_string_literal: true

Given('the following profile(s) is/are defined:') do |profiles|
  write_file('cucumber.yml', profiles)
end

Then('the {word} profile should be used') do |profile|
  expect(command_line.all_output).to include_output(profile)
end
