$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

Δεδομένου('ότι έχω εισάγει {int} στην αριθμομηχανή') do |int|
  @calc.push int
end

Δεδομένου('έχω εισάγει {int} στην αριθμομηχανή') do |int|
  @calc.push int
end

Όταν(/πατάω (\w+)/) do |op|
  @result = @calc.send op
end

Τότε(/το αποτέλεσμα στην οθόνη πρέπει να είναι (.*)/) do |result|
  expect(@result).to eq(result.to_f)
end
