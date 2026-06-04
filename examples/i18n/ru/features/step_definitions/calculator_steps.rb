# frozen_string_literal: true

Given('я ввожу число {int}') do |number|
  calc.push number
end

Given('затем ввожу число {int}') do |number|
  calc.push number
end

When('нажимаю {string}') do |operation|
  calc.send operation
end

When('я нажимаю {string}') do |operation|
  calc.send operation
end

Then('результатом должно быть число {float}') do |answer|
  expect(calc.result).to eq(answer)
end

When('я сложил {int} и {int}') do |number1, number2|
  calc.push number1
  calc.push number2
  calc.send '+'
end
