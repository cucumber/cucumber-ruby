require 'spec'

class Kalkulaator
  def push(n)
    @args ||= []
    @args << n
  end
  
  def liida
    @args.inject(0) {|n,sum| sum+n}
  end
end

Before do
  @calc = Kalkulaator.new
end

After do
end

Given /olen sisestanud kalkulaatorisse numbri (\d+)/ do |n|
  @calc.push n.to_i
end

When /ma vajutan (.*)/ do |op|
  @result = @calc.send op
end

Then /vastuseks peab ekraanil kuvatama (\d*)/ do |result|
  @result.should == result.to_i
end

Then /vastuseklass peab olema tüüpi (\w*)/ do |class_name|
  @result.class.name.should == class_name
end