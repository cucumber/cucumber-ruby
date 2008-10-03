require 'spec'

class Calculadora
  def push(n)
    @args ||= []
    @args << n
  end
  
  def soma
    @args.inject(0) {|n,sum| sum+n}
  end
end

Before do
  @calc = Calculadora.new
end

After do
end

Given /que eu digitei (\d+) na calculadora/ do |n|
  @calc.push n.to_i
end

When 'eu aperto o botão de soma' do
  @result = @calc.soma
end

Then /o resultado na calculadora deve ser (\d*)/ do |result|
  @result.should == result.to_i
end
