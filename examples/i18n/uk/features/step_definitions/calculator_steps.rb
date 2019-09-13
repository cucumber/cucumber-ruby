Припустимо('потім/я ввожу число {int}') do |число|
  calc.push число
end

Якщо('я натискаю {string}') do |операція|
  calc.send операція
end

То('результатом повинно бути число {float}') do |результат|
  expect(calc.result).to eq(результат)
end

Припустимо('я додав {int} і {int}') do |число1, число2|
  calc.push число1
  calc.push число2
  calc.send '+'
end
