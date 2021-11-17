$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Se('mi entajpas {int} en la kalkulilon') do |int|
  @calc.push int
end

Donitaĵo('mi premas/premis {word}') do |op|
  @result = @calc.send op
end

Do('la rezulto estu {float}') do |float|
  expect(@result).to eq(float)
end
