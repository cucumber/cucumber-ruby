# frozen_string_literal: true

Then(/^it should (pass|fail) with JSON:$/) do |pass_fail, json|
  actual = normalise_json(MultiJson.load(all_stdout))
  expected = MultiJson.load(json)

  expect(actual).to eq expected
  step "it should #{pass_fail}"
end
