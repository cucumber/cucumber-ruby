Given 'there are $n cucumbers' do |n|
  Cucumber.initial = n.to_i
end

When 'I sell $n cucumbers' do |n|
  Cucumber.sold = n.to_i
end

Then 'there should be $n cucumbers left' do |n|
  Cucumber.left.should == n.to_i
end
