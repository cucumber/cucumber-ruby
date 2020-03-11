# frozen_string_literal: true

Then(/^it should (pass|fail) with JSON:$/) do |pass_fail, json|
  actual = normalise_json(JSON.parse(all_stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
  step "it should #{pass_fail}"
end
