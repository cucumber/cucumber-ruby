$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

ops = {
  जोड़: 'add',
  भाग: 'divide'
}

ParameterType(
  name: 'op',
  regexp: /#{ops.keys.join('|')}/,
  transformer: ->(s) { ops[s.to_sym] }
)

अगर('मैं गणक में {int} डालता हूँ') do |int|
  @calc.push int
end

जब('मैं {op} दबाता हूँ') do |op|
  @result = @calc.send op
end

अगर('परिणाम {float} परदे पर प्रदशित होना चाहिए') do |float|
  expect(@result).to eq(float)
end
