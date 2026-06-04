# frozen_string_literal: true

Given('{int} сонини киритсам') do |number|
  calc.push number
end

Given('ундан сунг {int} сонини киритсам') do |number|
  calc.push number
end

Given('ман {int} сонини киритсам') do |number|
  calc.push number
end

When('{word} боссам') do |operation|
  calc.send operation
end

When('{int} ва {int} сонини кушсам') do |number1, number2|
  calc.push number1
  calc.push number2
  calc.send '+'
end

Then('жавоб {int} сони булиши керак') do |answer|
  expect(calc.result).to eq(answer)
end
