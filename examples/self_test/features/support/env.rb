require 'spec/expectations'
$KCODE = 'u' unless Cucumber::RUBY_1_9

Before('@not_used') do
  raise "Should never run"
end

After('@not_used') do
  raise "Should never run"
end

Before('@background_tagged_before_on_outline') do
  @cukes = '888'
end

After('@background_tagged_before_on_outline') do
  @cukes.should == '888'
end

Transform /^'\d+' to an Integer$/ do |step_arg|
  /'(\d+)' to an Integer/.match(step_arg)[0].to_i
end

Transform(/^('\w+') to a Symbol$/) {|str| str.to_sym }
