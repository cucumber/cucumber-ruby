@spawn @wip-new-core
Feature: Assertions

  Assertions are how you tell Cucumber that a step has failed. The most basic
  way to do this is by raising an exception, but you can also use Ruby's built-in
  `Test::Unit` assertions library, or RSpec's `RSpec::Expectations` library.

  Background:
    Given a file named "features/assert.feature" with:
       """
       Feature: Assert
         Scenario: Passing
           Then it should pass
       """

  Scenario: Test::Unit
    Given a Gemfile with:
      """
      source "https://rubygems.org"
      gem "cucumber", path: "../.."
      core_path = File.expand_path("../../../../cucumber-ruby-core", __FILE__)
      if File.exist?(core_path)
        gem 'cucumber-core', :path => core_path
      else
        gem 'cucumber-core', :git => "git://github.com/cucumber/cucumber-ruby-core.git"
      end

      """
    And I run `bundle install --local --quiet`
    And a file named "features/step_definitions/steps.rb" with:
      """
      Then /^it should pass$/ do
        assert(2 + 2 == 4)
      end
      """
    When I run `bundle exec cucumber`
    Then it should pass

  Scenario: RSpec
    Given a Gemfile with:
      """
      source "https://rubygems.org"
      gem "cucumber", path: "../.."
      core_path = File.expand_path("../../../../cucumber-ruby-core", __FILE__)
      if File.exist?(core_path)
        gem 'cucumber-core', :path => core_path
      else
        gem 'cucumber-core', :git => "git://github.com/cucumber/cucumber-ruby-core.git"
      end

      gem "rspec"
      """
    And I run `bundle install --local --quiet`
    And a file named "features/step_definitions/steps.rb" with:
      """
      Then /^it should pass$/ do
        (2 + 2).should == 4
      end
      """
    When I run `bundle exec cucumber`
    Then it should pass
