When(/^I run the feature with the event stream output$/) do
  run_simple "#{Cucumber::BINARY} --format events", false
end

Then(/^test run should have started$/) do
  events = all_stdout.lines.map { |line| JSON.parse(line) }
  expect(events[0]['event']).to eq 'TestRunStarted'
end
