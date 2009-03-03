# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'cucumber/formatters/unicode'
require 'calculator'

Допустим /ввожу число (\d+)/ do |n|
  @calc.push n.to_i
end

Если /нажимаю "(.*)"/ do |op|
  @calc.send op
end

То /должен увидеть на экране число (\d+)/ do |result|
  @calc.result.should == result.to_f
end