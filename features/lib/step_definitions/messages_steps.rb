# frozen_string_literal: true

Then('output should be valid NDJSON') do
  all_stdout.split("\n").map do |line|
    expect { JSON.parse(line) }.not_to raise_exception
  end
end

Then('messages types should be:') do |expected_types|
  parsed_json = all_stdout.split("\n").map { |line| JSON.parse(line) }
  message_types = parsed_json.map(&:keys).flatten.compact

  expect(expected_types.split("\n").map(&:strip)).to contain_exactly(*message_types)
end

Then('output should be binary protobuf messages') do
  Cucumber::Messages::BinaryToMessageEnumerator.new(all_stdout) do |message|
    # puts message
  end
end
