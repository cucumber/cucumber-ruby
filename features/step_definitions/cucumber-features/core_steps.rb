CUCUMBER = File.dirname(__FILE__) + '/../../../bin/cucumber'

Given /^a scenario "([^"]*)" with:$/ do |scenario_name, steps|
  write_file("features/a_feature.feature", <<-EOF)
Feature: A feature
  Scenario: #{scenario_name}
#{steps.gsub(/^/, '    ')}
EOF
end

When /^Cucumber executes "([^"]*)" with these step mappings:$/ do |scenario_name, mappings|
  mapping_code = mappings.raw.map do |pattern, result|
    "Given /#{pattern}/ do\nend\n"
  end.join("\n")
  write_file("features/step_definitions/some_stepdefs.rb", mapping_code)

  run_simple "#{CUCUMBER} features/a_feature.feature --name '#{scenario_name}'"
end

Then /^the scenario passes$/ do
  assert_exiting_with 0
end