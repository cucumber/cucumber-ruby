# frozen_string_literal: true

Given('there are {int} cucumbers') do |initial_count|
  @count = initial_count
end

Given('there are {int} friends') do |initial_friends|
  @friends = initial_friends
end

When('I eat {int} cucumbers') do |eat_count|
  @count -= eat_count
end

Then('I should have {int} cucumbers') do |expected_count|
  expect(@count).to eq(expected_count)
end

Then('each person can eat {int} cucumbers') do |expected_share|
  share = (@count / (1 + @friends)).floor

  expect(share).to eq(expected_share)
end
