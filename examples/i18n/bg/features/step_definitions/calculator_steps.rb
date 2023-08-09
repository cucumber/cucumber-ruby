# frozen_string_literal: true

Дадено('е че съм въвел {int}') do |int|
  calc.push int
end

Дадено('съм въвел {int}') do |int|
  calc.push int
end

Дадено('е че съм събрал {int} и {int}') do |int1, int2|
  calc.push int1
  calc.push int2
  calc.send '+'
end

Когато('въведа {int}') do |int|
  calc.push int
end

Когато('натисна {string}') do |op|
  calc.send op
end

То('резултата трябва да е равен на {int}') do |int|
  expect(calc.result).to eq(int)
end
