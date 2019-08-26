Допустим('я ввожу число {int}') do |число|
  calc.push число
end

Допустим('затем ввожу число {int}') do |число|
  calc.push число
end

Если('нажимаю {string}') do |операция|
  calc.send операция
end

Если('я нажимаю {string}') do |операция|
  calc.send операция
end

То('результатом должно быть число {float}') do |результат|
  calc.result.should == результат
end

Допустим('я сложил {int} и {int}') do |слагаемое1, слагаемое2|
  calc.push слагаемое1
  calc.push слагаемое2
  calc.send '+'
end
