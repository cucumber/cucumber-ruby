# frozen_string_literal: true

Then('I should see the CLI help') do
  expect(all_stdout).to include('Usage:')
end
