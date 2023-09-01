# frozen_string_literal: true

Given(/^I visit the calculator page$/) do
  visit '/add'
end

Given(/^I fill in '(.*)' for '(.*)'$/) do |value, field|
  fill_in(field, with: value)
end

When(/^I press '(.*)'$/) do |name|
  click_button(name)
end

Then(/^I should see '(.*)'$/) do |text|
  expect(body).to match(/#{text}/m)
end
