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
