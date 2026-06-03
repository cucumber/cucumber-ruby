# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib")
require 'calculator'

Before do
  @calc = Calculator.new
end

After do
end

بفرض(/كتابة (.+) في الآلة الحاسبة/) do |n|
  @calc.push n.to_i
end

متى(/يتم الضغط على (.+)/) do |op|
  @result = @calc.send op
end

اذاً(/يظهر (\d+) على الشاشة/) do |result|
  expect(@result).to eq(result)
end
