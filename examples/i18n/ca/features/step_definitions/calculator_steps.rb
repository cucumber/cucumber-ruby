$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculadora'

Before do
  @calc = Calculadora.new
end

Donat(/que he introduït (\d+) a la calculadora/) do |n|
  @calc.push n.to_i
end

Quan(/premo el (\w+)/) do |op|
  @result = @calc.send op
end

Aleshores(/el resultat ha de ser (\d+) a la pantalla/) do |result|
  expect(@result).to eq(result)
end
