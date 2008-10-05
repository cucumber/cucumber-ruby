require 'spec'

Given "be_empty" do
  [1,2].should_not be_empty
end

Given "nested step is called" do
  Given "nested step"
end

Given "nested step" do
  @magic = 'mushroom'
end

Then "nested step should be executed" do
  @magic.should == 'mushroom'
end
