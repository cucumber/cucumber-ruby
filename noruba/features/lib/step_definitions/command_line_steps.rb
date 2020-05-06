When('I run `cucumber{}`') do |args|
  execute_cucumber(args)
end

When('I run `bundle exec ruby {}`') do |filename|
  execute_ruby(filename)
end

When('I run `(bundle exec )rake {word}`') do |task|
  execute_rake(task)
end

When('I run the feature with the progress formatter') do
  execute_cucumber("features/ --format progress")
end

Then('the exit status should be {int}') do |status|
  expect(command_line.exit_status).to eq(status)
end

Then('it should fail') do
  expect(command_line).to have_failed
end

Then('it should fail with:') do |output|
  expect(command_line).to have_failed
  expect(command_line.all_output).to include_output(output)
end

Then('it should fail with exactly:') do |output|
  expect(command_line).to have_failed
  expect(command_line.all_output).to be_similar_output_than(output)
end

Then('it should pass') do
  expect(command_line).to have_succeded
end

Then('it should pass with:') do |output|
  expect(command_line).to have_succeded
  expect(command_line.all_output).to include_output(output)
end

Then('it should pass with exactly:') do |output|
  expect(command_line).to have_succeded
  expect(command_line.all_output).to be_similar_output_than(output)
end

Then('the output should contain:') do |output|
  expect(command_line.all_output).to include_output(output)
end

Then('the output should contain {string}') do |output|
  expect(command_line.all_output).to include_output(output)
end

Then('the output includes the message {string}') do |message|
  expect(command_line.all_output).to include(message)
end

Then('the output should not contain:') do |output|
  expect(command_line.all_output).not_to include_output(output)
end

Then('the output should not contain {string}') do |output|
  expect(command_line.all_output).not_to include_output(output)
end

Then('the stdout should contain exactly:') do |output|
  expect(command_line.stdout).to be_similar_output_than(output)
end

Then('the stderr should contain:') do |output|
  expect(command_line.stderr).to include_output(output)
end

Then('the stderr should not contain:') do |output|
  expect(command_line.stderr).not_to include_output(output)
end

Then('the stderr should not contain anything') do
  expect(command_line.stderr).to be_empty
end