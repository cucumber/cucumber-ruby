# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculator'

Before do
  @calc = Calculator.new
end

Pokud('Zadám číslo {int} do kalkulačky') do |int|
  @calc.push int
end

Když('stisknu {word}') do |op|
  @result = @calc.send op
end

Pak('výsledek by měl být {float}') do |float|
  expect(@result).to eq(float)
end
