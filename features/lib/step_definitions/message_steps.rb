Then('messages types should be:') do |expected_types|
  parsed_json = command_line.stdout.split("\n").map { |line| JSON.parse(line) }
  message_types = parsed_json.map(&:keys).flatten.compact

  expect(expected_types.split("\n").map(&:strip)).to contain_exactly(*message_types)
end

Then('output should be valid NDJSON') do
  command_line.stdout.split("\n").map do |line|
    expect { JSON.parse(line) }.not_to raise_exception
  end
end

Then('the output should contain NDJSON with key {string}') do |key|
  expect(command_line.stdout).to match(/"#{key}":/)
end

Then('the output should contain NDJSON with key {string} and value {string}') do |key, value|
  expect(command_line.stdout).to match(/"#{key}": ?"#{value}"/)
end
