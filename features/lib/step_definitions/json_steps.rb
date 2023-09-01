# frozen_string_literal: true

Then('it should fail with JSON:') do |json|
  expect(command_line).to have_failed
  actual = normalise_json(JSON.parse(command_line.stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end

Then('it should pass with JSON:') do |json|
  expect(command_line).to have_succeded
  actual = normalise_json(JSON.parse(command_line.stdout))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end

Then('file {string} should contain JSON:') do |filename, json|
  actual = normalise_json(JSON.parse(File.read(filename)))
  expected = JSON.parse(json)

  expect(actual).to eq expected
end
