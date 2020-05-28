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
  execute_cucumber('features/ --format progress')
end

Then('the exit status should be {int}') do |exit_code|
  expect(command_line).to have_exited_with(exit_code)
end

Then('it should {status}') do |status|
  expect(command_line).to have_exited_with(status)
end

Then('it should {status} with:') do |status, output|
  expect(command_line).to have_exited_with(status)
  expect(command_line.all_output).to include_output(output)
end

Then('it should {status} with exactly:') do |status, output|
  expect(command_line).to have_exited_with(status)
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
