# frozen_string_literal: true

Before do
  @calc = Calculator.new
end

After do
end

Задати(/унесен број (\d+) у калкулатор/) do |n|
  @calc.push n.to_i
end

Када(/притиснем (\w+)/) do |op|
  @result = @calc.send op
end

Онда('би требало да буде {float} прикаѕано на екрану') do |result|
  expect(@result).to eq(result)
end
