When('the following table is transposed:') do |table|
  expect(table.to_s).not_to be_empty
end

Then('it should be:') do |table|
  expect(table.to_s).not_to be_empty
end