When(/^I run the following Ruby code:$/) do |code|
  write_file('tmp.rb', code)
  run_simple %{ruby tmp.rb}
end
