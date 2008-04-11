Given 'there are $n stories' do |n|
  Stories.initial = n.to_i
end

When 'I sell $n stories' do |n|
  Stories.sold = n.to_i
end

Then 'there should be $n stories left' do |n|
  Stories.left.should == n.to_i
end
