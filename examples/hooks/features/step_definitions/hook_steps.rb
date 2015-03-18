Given(/^the around hook has run$/) do
  expect($around_ran).to be_truthy
end

Then(/^the world should be a (.*)$/) do |clazz|
  expect($world_class.to_s).to eq clazz
end
