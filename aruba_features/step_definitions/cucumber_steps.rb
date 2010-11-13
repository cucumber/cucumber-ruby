When /^I run cucumber "([^"]*)"$/ do |cmd|
  run_simple(unescape("cucumber #{cmd}"), false)
end

Then /^it should (pass|fail) with JSON:$/ do |pass_fail, json|
  JSON.pretty_generate(JSON.parse(all_stdout)).should == JSON.pretty_generate(JSON.parse(json))
  assert_exiting_with(pass_fail == 'pass')
end
