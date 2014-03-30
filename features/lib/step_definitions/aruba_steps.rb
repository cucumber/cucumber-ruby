Given('a Gemfile with:') do |content|
  path = File.expand_path(current_dir + "/Gemfile")
  write_file path, content
  set_env "BUNDLE_GEMFILE", path
end

Then('it should pass') do
  assert_exit_status 0
end

Then(/^"([^"]*)" should not be required$/) do |file_name|
  all_output.should_not include("* #{file_name}")
end

Then(/^"([^"]*)" should be required$/) do |file_name|
  all_output.should include("* #{file_name}")
end

Then /^it fails before running features with:$/ do |expected|
  assert_matching_output("\\A#{expected}", all_output)
  assert_success(false)
end

When(/^I run `(.*)` (\d+) times$/) do |cmd, num|
  @exit_statuses = []
  num.to_i.times do
    run(cmd)
    @exit_statuses << last_exit_status
  end
end

Then(/^it should fail at least once$/) do
  failure_count = @exit_statuses.count { |exit_status| exit_status > 0 }
  expect( failure_count ).to be > 0
end
