Given /^there are (\d+) (\w+)$/ do |count, fruit|
  @eattingMachine = EattingMachine.new(fruit, count)
end

Given "the belly space is < 12 and > 6" do
end

When /^I eat (\d+) (\w+)$/ do |count, fruit|
  @eattingMachine.eat(count)
  @eattingMachine.belly_count = count.to_i
end

Then /^I should have (\d+) (\w+)$/ do |count, fruit|
  @eattingMachine.fruit_total.should == count.to_i
end

Then /^I should have (\d+) (\w+) in my belly$/ do |count, fruit|
  @eattingMachine.belly_count.should == count.to_i
end