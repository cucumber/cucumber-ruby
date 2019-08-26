Before do
  @calc = Calculator.new
end

After do
end

前提('{int} を入力') do |int|
  @calc.push int
end

もし(/(\w+) を押した/) do |op|
  @result = @calc.send op
end

ならば(/(.*) を表示/) do |result|
  expect(@result).to eq(result.to_f)
end
