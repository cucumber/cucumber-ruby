# frozen_string_literal: true

Then('messages types should be:') do |expected_types|
  message_types = command_line.stdout(format: :messages).map(&:keys).flatten.compact

  expect(expected_types.split("\n")).to eq(message_types)
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

Then('the output should contain NDJSON {string} message with key {string} and an encoded value') do |message_name, key|
  message_contents = command_line.stdout(format: :messages).detect { |msg| msg.keys == [message_name] }[message_name]

  expect(message_contents[key].length).to be > 50
end

Then('the output should contain NDJSON {string} message with key {string} and value {string}') do |message_name, key, value|
  message_contents = command_line.stdout(format: :messages).detect { |msg| msg.keys == [message_name] }[message_name]

  expect(message_contents).to include(key => value)
end

Then('the output should contain NDJSON {string} message with key {string} and boolean value {word}') do |message_name, key, value|
  boolean = value == 'true'
  message_contents = command_line.stdout(format: :messages).detect { |msg| msg.keys == [message_name] }[message_name]

  expect(message_contents).to include(key => boolean)
end

Then('the messages report these attempts of the scenarios:') do |expected_attempts|
  scenario_names = {}
  pickle_ids = {}
  attempts = []

  command_line.stdout(format: :lines).each do |line|
    case JSON.parse(line, symbolize_names: true)
    in { pickle: { id:, name: } }
      scenario_names[id] = name
    in { testCase: { id:, pickleId: pickle_id } }
      pickle_ids[id] = pickle_id
    in { testCaseStarted: { id:, testCaseId: test_case_id, attempt: } }
      attempts << { 'id' => id, 'scenario' => scenario_names.fetch(pickle_ids.fetch(test_case_id)), 'attempt' => attempt.to_s }
    in { testCaseFinished: { testCaseStartedId: started_id, willBeRetried: will_be_retried } }
      expect(started_id).to eq(attempts.last['id'])
      attempts.last['willBeRetried'] = will_be_retried.to_s
    else
      nil
    end
  end

  expect(attempts.map { |attempt| attempt.except('id') }).to eq(expected_attempts.hashes)
end
