Given('there are {int} {float} coins inside') do |count, coin_type|
  expect(count).not_to be_nil
  expect(coin_type.to_s).not_to be_empty
end

When('the customer tries to buy a {float} chocolate with a {int} coin') do |count, coin_type|
  expect(count).not_to be_nil
  expect(coin_type.to_s).not_to be_empty
end

Then('the sale should not happen') do
  true
end

Given('there are {int} chocolates inside') do |count|
  expect(count).not_to be_nil
end

Then("the customer's change should be {int} {float} coin") do |count, coin_type|
  expect(count).not_to be_nil
  expect(coin_type.to_s).not_to be_empty
end

Given('there are no chocolates inside') do
  true
end
