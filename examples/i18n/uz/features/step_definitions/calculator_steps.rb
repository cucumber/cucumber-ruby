Агар('{int} сонини киритсам') do |сон|
  calc.push сон
end

Агар('ундан сунг {int} сонини киритсам') do |сон|
  calc.push сон
end

Агар('ман {int} сонини киритсам') do |сон|
  calc.push сон
end

Агар('{word} боссам') do |операция|
  calc.send операция
end

Агар('{int} ва {int} сонини кушсам') do |сон1, сон2|
  calc.push сон1.to_i
  calc.push сон2.to_i
  calc.send '+'
end

Унда('жавоб {int} сони булиши керак') do |жавоб|
  expect(calc.result).to eq(жавоб)
end
