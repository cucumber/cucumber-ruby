# encoding: utf-8

Before do
  @calc = Kalkulator.new
end

Gitt /at jeg har tastet inn (\d+)/ do |n|
  @calc.push n.to_i
end

Når 'jeg summerer' do
  @result = @calc.add
end

Så /skal resultatet være (\d*)/ do |result|
  @result.should == result.to_i
end
