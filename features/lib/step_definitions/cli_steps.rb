Then(/^I should see the CLI help$/) do
  expect(all_output).to include("Usage:")
end
