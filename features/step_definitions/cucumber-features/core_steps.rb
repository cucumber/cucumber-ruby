require 'erb'
CUCUMBER = File.dirname(__FILE__) + '/../../../bin/cucumber'

World(Module.new do
  def step_file(pattern)
    pattern.gsub(/ /, '_') + '.step'
  end
end)

Given /^a scenario "([^"]*)" with:$/ do |scenario_name, steps|
  write_file("features/a_feature.feature", <<-EOF)
Feature: A feature
  Scenario: #{scenario_name}
#{steps.gsub(/^/, '    ')}
EOF
end

When /^Cucumber executes "([^"]*)" with these step mappings:$/ do |scenario_name, mappings|
  mapping_code = mappings.raw.map do |pattern, result|
    erb = ERB.new(<<-EOF, nil, '-')
Given /<%= pattern -%>/ do
<% if result == 'passing' -%>
  File.open("<%= step_file(pattern) %>", "w")
<% elsif result == 'pending' -%>
  File.open("<%= step_file(pattern) %>", "w")
  pending
<% else -%>
  File.open("<%= step_file(pattern) %>", "w")
  raise "bang!"
<% end -%>
end
    EOF
    erb.result(binding)
  end.join("\n")
  write_file("features/step_definitions/some_stepdefs.rb", mapping_code)

  run_simple "#{CUCUMBER} features/a_feature.feature --name '#{scenario_name}'", false
end

Then /^the scenario passes$/ do
  assert_partial_output("1 scenario (1 passed)", all_stdout)
  assert_exiting_with true
end

Then /^the scenario fails$/ do
  assert_partial_output("1 scenario (1 failed)", all_stdout)
  assert_exiting_with false
end

Then /^the scenario is pending$/ do
  assert_partial_output("1 scenario (1 pending)", all_stdout)
  assert_exiting_with true
end

Then /^the step "([^"]*)" is skipped$/ do |pattern|
  if File.exist?(File.join(current_dir, step_file(pattern)))
    raise "#{pattern} was not skipped"
  end
end
