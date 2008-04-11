Given 'there are $n cucumber' do |n|
  Cucumber.initial = n.to_i
end

When 'I sell $n cucumber' do |n|
  Cucumber.sold = n.to_i
end

Then 'there should be $n cucumber left' do |n|
  Cucumber.left.should == n.to_i
end
