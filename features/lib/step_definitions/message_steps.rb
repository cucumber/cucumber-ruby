# frozen_string_literal: true

Then('messages types should be:') do |expected_types|
  parsed_json = command_line.stdout.split("\n").map { |line| JSON.parse(line) }
  message_types = parsed_json.map(&:keys).flatten.compact

  expect(expected_types.split("\n").map(&:strip)).to contain_exactly(*message_types)
end

Then('output should be valid NDJSON') do
  expect { command_line.stdout(format: :messages) }.not_to raise_error
end

Then('the output should contain NDJSON with key {string}') do |key|
  expect(command_line.stdout(format: :messages)).to include(have_key(key))
end

Then('the output should contain NDJSON with key {string} and value {string}') do |key, value|
  expect(command_line.stdout).to match(/"#{key}": ?"#{value}"/)
end

Then('the output should contain NDJSON {string} message with key {string} and value {string}') do |message_name, key, value|
  message_contents = command_line.stdout(format: :messages).detect { |msg| msg.keys == [message_name] }[message_name]

  expect(message_contents).to include(key => value)
end
