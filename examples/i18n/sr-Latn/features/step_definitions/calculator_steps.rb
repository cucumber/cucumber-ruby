# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculator'

Before do
  @calc = Calculator.new
end

Zadato('Unesen {int} broj u kalkulator') do |int|
  @calc.push int
end

Kada('pritisnem {word}') do |op|
  @result = @calc.send op
end

Onda('bi trebalo da bude {float} prikazano na ekranu') do |float|
  expect(@result).to eq(float)
end
