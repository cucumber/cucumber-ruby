# frozen_string_literal: true

ICANHAZ(/^IN TEH BEGINNIN (\d+) CUCUMBRZ$/) do |n|
  @basket = Basket.new(n.to_i)
end

WEN(/^I EAT (\d+) CUCUMBRZ$/) do |n|
  @belly = Belly.new
  @belly.eat(@basket.take(n.to_i))
end

DEN(/^I HAS (\d+) CUCUMBERZ IN MAH BELLY$/) do |n|
  expect(@belly.cukes).to eq(n.to_i)
end

DEN(/^IN TEH END (\d+) CUCUMBRZ KTHXBAI$/) do |n|
  expect(@basket.cukes).to eq(n.to_i)
end
