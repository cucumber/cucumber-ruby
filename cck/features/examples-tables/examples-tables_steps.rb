Given('there are {int} cucumbers') do |initial_count|
  @count = initial_count
end

When('I eat {int} cucumbers') do |eat_count|
  @count -= eat_count
end

Then('I should have {int} cucumbers') do |expected_count|
  expect(@count).to eq(expected_count)
end
