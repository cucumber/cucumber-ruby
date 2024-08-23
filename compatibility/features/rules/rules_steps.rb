# frozen_string_literal: true

Given('the customer has {int} cents') do |money|
  @money = money
end

Given('there are chocolate bars in stock') do
  @stock = ['Mars']
end

Given('there are no chocolate bars in stock') do
  @stock = []
end

When('the customer tries to buy a {int} cent chocolate bar') do |price|
  @chocolate = @stock.pop if @money >= price
end

Then('the sale should not happen') do
  expect(@chocolate).to be_nil
end

Then('the sale should happen') do
  expect(@chocolate).not_to be_nil
end
