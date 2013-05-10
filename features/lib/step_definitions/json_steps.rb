Then /^it should (pass|fail) with JSON:$/ do |pass_fail, json|
  warn("This step has a confusing name. Needs to explain that it's testing JSON Gherkin output")
  # Need to store it in a variable. With JRuby we can only do this once it seems :-/
  stdout = all_stdout

  # JRuby has weird traces sometimes (?)
  stdout = stdout.gsub(/ `\(root\)':in/, '')

  actual = JSON.parse(stdout)
  expected = JSON.parse(json)

  #make sure duration was captured (should be >= 0)
  #then set it to what is "expected" since duration is dynamic
  actual.each do |feature|
    feature['elements'].each do |scenario|
      scenario['steps'].each do |step|
        step['result']['duration'].should be >= 0
        step['result']['duration'] = 1
      end
    end
  end

  actual.should == expected
  assert_success(pass_fail == 'pass')
end

Then /^the output should contain the following JSON:$/ do |json_string|
  MultiJson.load(all_stdout).should == MultiJson.load(json_string)
end
