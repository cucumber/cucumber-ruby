Given(/^the around hook has run$/) do
  $around_ran.should be_true
end

Then(/^the world should be a (.*)$/) do |clazz|
  $world_class.to_s.should eq clazz
end
