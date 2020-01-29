When('the string {string} is attached as {string}') do |string, string2|
  expect(1).to eq(1)
end

When('an array with {int} bytes are attached as {string}') do |int, string|
# When('an array with {float} bytes are attached as {string}') do |float, string|
  expect(1).to eq(1)
end

When('a stream with {int} bytes are attached as {string}') do |int, string|
# When('a stream with {float} bytes are attached as {string}') do |float, string|
  expect(1).to eq(1)
end

When('the following table is transposed:') do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  expect(1).to eq(1)
end

Then('it should be:') do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  expect(1).to eq(1)
end

Given('there are {int} cucumbers') do |int|
# Given('there are {float} cucumbers') do |float|
  expect(1).to eq(1)
end

When('I eat {int} cucumbers') do |int|
# When('I eat {float} cucumbers') do |float|
  expect(1).to eq(1)
end

Then('I should have {int} cucumbers') do |int|
# Then('I should have {float} cucumbers') do |float|
  expect(1).to eq(1)
end

When('I eat banana cucumbers') do
  expect(1).to eq(1)
end

Then('I should have apple cucumbers') do
  expect(1).to eq(1)
end

When('a step passes') do
  expect(1).to eq(1)
end

When('a step throws an exception') do
  expect(1).to eq(1)
end

Given('LHR-CDG has been delayed {int} minutes') do |int|
# Given('LHR-CDG has been delayed {float} minutes') do |float|
  expect(1).to eq(1)
end

Given('there are {int} {float} coins inside') do |int, float|
# Given('there are {float} {float} coins inside') do |float, float2|
  expect(1).to eq(1)
end

When('the customer tries to buy a {float} chocolate with a {int} coin') do |float, int|
# When('the customer tries to buy a {float} chocolate with a {float} coin') do |float, float2|
  expect(1).to eq(1)
end

Then('the sale should not happen') do
  expect(1).to eq(1)
end

Given('there are {int} chocolates inside') do |int|
# Given('there are {float} chocolates inside') do |float|
  expect(1).to eq(1)
end

Then('the customer's change should be {int} {float} coin') do |int, float|
# Then('the customer's change should be {float} {float} coin') do |float, float2|
  expect(1).to eq(1)
end

Given('there are no chocolates inside') do
  expect(1).to eq(1)
end