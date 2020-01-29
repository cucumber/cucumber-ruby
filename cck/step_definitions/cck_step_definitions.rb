When('the string {string} is attached as {string}') do |message, media_type|
  expect(message).not_to be_empty
  expect(media_type).not_to be_empty
end

When('an array with {int} bytes are attached as {string}') do |count, media_type|
  expect(count).not_to be_zero
  expect(media_type).not_to be_empty
end

When('a stream with {int} bytes are attached as {string}') do |count, media_type|
  expect(count).not_to be_zero
  expect(media_type).not_to be_empty
end

When('the following table is transposed:') do |table|
  expect(table).not_to be_empty
end

Then('it should be:') do |table|
  expect(table).not_to be_empty
end

Given('there are {int} cucumbers') do |count|
  expect(count).not_to be_zero
end

When('I eat {int} cucumbers') do |count|
  expect(count).not_to be_zero
end

Then('I should have {int} cucumbers') do |count|
  expect(count).not_to be_zero
end

When('a step passes') do
  true
end

When('a step throws an exception') do
  raise StandardError, 'An exception is raised here'
end

Given('LHR-CDG has been delayed {int} minutes') do |count|
  expect(count).not_to be_zero
end

Given('there are {int} {float} coins inside') do |count, coin_type|
  expect(count).not_to be_zero
  expect(coin_type.to_s).not_to be_empty
end

When('the customer tries to buy a {float} chocolate with a {int} coin') do |count, coin_type|
  expect(count).not_to be_zero
  expect(coin_type.to_s).not_to be_empty
end

Then('the sale should not happen') do
  true
end

Given('there are {int} chocolates inside') do |count|
  expect(count).not_to be_zero
end

Then("the customer's change should be {int} {float} coin") do |count, coin_type|
  expect(count).not_to be_zero
  expect(coin_type.to_s).not_to be_empty
end

Given('there are no chocolates inside') do
  true
end
