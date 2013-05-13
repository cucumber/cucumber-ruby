Then /^it should (pass|fail) with JSON:$/ do |pass_fail, json|
  actual = normalise_json(MultiJson.load(all_stdout))
  expected = MultiJson.load(json)

  actual.should == expected
  assert_success(pass_fail == 'pass')
end
