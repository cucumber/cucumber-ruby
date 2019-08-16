$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculator'

Before do
  @calc = Calculator.new
end

ParameterType(
  name: 'op',
  regexp: /按相加按/,
  transformer: ->(_s) { 'add' }
)

假如('我已经在计算器里输入{int}') do |n|
  @calc.push n
end

当('我{op}钮') do |op|
  @result = @calc.send op
end

那么('我应该在屏幕上看到的结果是{float}') do |result|
  expect(@result).to eq(result)
end
