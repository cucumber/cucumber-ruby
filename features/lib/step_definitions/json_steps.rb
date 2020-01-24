# frozen_string_literal: true

Then(/^it should (pass|fail) with JSON:$/) do |pass_fail, json|
  actual = normalise_json(MultiJson.load(all_stdout))
  expected = MultiJson.load(json)

  expect(actual).to eq expected
  step "it should #{pass_fail}"
end

Then('output should be valid NDJSON') do
  all_stdout.split("\n").map do |line|
    expect { JSON.parse(line) }.not_to raise_exception
  end
end

Then('messages types should be:') do |expected_types|
  parsed_json = all_stdout.split("\n").map { |line| JSON.parse(line) }
  message_types = parsed_json.map(&:keys).flatten.compact

  expect(expected_types.split("\n").map(&:strip)).to eq(message_types)
end
