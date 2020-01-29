Given('there are {int} cucumbers') do |count|
  expect(count).not_to be_nil
end

When('I eat {int} cucumbers') do |count|
  expect(count).not_to be_nil
end

Then('I should have {int} cucumbers') do |count|
  expect(count).not_to be_nil
end
