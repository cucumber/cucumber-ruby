# frozen_string_literal: true
Given('the following profile(s) are/is defined:') do |profiles|
  write_file 'cucumber.yml', profiles
end

Then('the {word} profile should be used') do |profile|
  step 'the stdout should contain:', profile
end

Then('exactly these files should be loaded: {list}') do |files|
  expect(all_stdout.scan(/^  \* (.*\.rb)$/).flatten).to eq files
end

Then('exactly these features should be run: {list}') do |files|
  expect(all_stdout.scan(/^  \* (.*\.feature)$/).flatten).to eq files
end
