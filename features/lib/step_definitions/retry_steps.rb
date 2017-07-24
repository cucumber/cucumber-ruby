# frozen_string_literal: true
Given('a scenario {string} that fails once, then passes') do |full_name|
  name = snake_case(full_name)
  write_file "features/#{name}.feature",
  <<-FEATURE
  Feature: #{full_name} feature
    Scenario: #{full_name}
      Given it fails once, then passes
  FEATURE

  write_file "features/step_definitions/#{name}_steps.rb",
  <<-STEPS
  Given(/^it fails once, then passes$/) do
    $#{name} += 1
    expect($#{name}).to be > 1
  end
  STEPS

  write_file "features/support/#{name}_init.rb",
  <<-INIT
  $#{name} = 0
  INIT
end

Given('a scenario {string} that fails twice, then passes') do |full_name|
  name = snake_case(full_name)
  write_file "features/#{name}.feature",
  <<-FEATURE
  Feature: #{full_name} feature
    Scenario: #{full_name}
      Given it fails twice, then passes
  FEATURE

  write_file "features/step_definitions/#{name}_steps.rb",
  <<-STEPS
  Given(/^it fails twice, then passes$/) do
    $#{name} ||= 0
    $#{name} += 1
    expect($#{name}).to be > 2
  end
  STEPS

  write_file "features/support/#{name}_init.rb",
  <<-INIT
  $#{name} = 0
  INIT
end

module SnakeCase
  def snake_case(name)
    name.downcase.gsub(/\W/, '_')
  end
end

World(SnakeCase)
