module FeatureSerializer
  def serialize_feature(cmd)
    feature_basename = File.basename(@scenario.feature.file)
    scenario_line = @scenario.line
    json_file = File.expand_path("json/#{feature_basename}/#{scenario_line}.json")
    dir = File.dirname(json_file)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    run(unescape("cucumber #{cmd} --format json --out #{json_file}"), false)
  end
end
World(FeatureSerializer)

When /^I run cucumber "([^"]*)"$/ do |cmd|
  #serialize_feature(cmd)
  run(unescape("cucumber #{cmd}"), false)
end

Then /^it should (pass|fail) with JSON:$/ do |pass_fail, json|
  JSON.pretty_generate(JSON.parse(@last_stdout)).should == JSON.pretty_generate(JSON.parse(json))
  assert_exiting_with(pass_fail == 'pass')
end
