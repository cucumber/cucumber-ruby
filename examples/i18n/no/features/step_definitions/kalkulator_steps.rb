Before do
  @calc = Kalkulator.new
end

Given(/at jeg har tastet inn (\d+)/) do |n|
  @calc.push n.to_i
end

Når('jeg summerer') do
  @result = @calc.add
end

Så(/skal resultatet være (\d*)/) do |result|
  expect(@result).to eq(result.to_i)
end
