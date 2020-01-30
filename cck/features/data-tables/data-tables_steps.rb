When('the following table is transposed:') do |table|
  @transposed = table.transpose
end

Then('it should be:') do |expected|
  @transposed.diff!(expected)
end
