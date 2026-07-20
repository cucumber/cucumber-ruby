# frozen_string_literal: true

Given('потім/я ввожу число {int}') do |number|
  calc.push number
end

Given('я натискаю {string}') do |number|
  calc.send number
end

Given('результатом повинно бути число {float}') do |number|
  expect(calc.result).to eq(number)
end

Given('я додав {int} і {int}') do |number1, number2|
  calc.push number1
  calc.push number2
  calc.send '+'
end
