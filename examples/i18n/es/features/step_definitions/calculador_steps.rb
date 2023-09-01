# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculador'

Before do
  @calc = Calculador.new
end

Dado(/que he introducido (\d+) en la calculadora/) do |n|
  @calc.push n.to_i
end

Cuando(/oprimo el (\w+)/) do |op|
  @result = @calc.send op
end

Entonces(/el resultado debe ser (.*) en la pantalla/) do |result|
  expect(@result).to eq(result.to_f)
end
