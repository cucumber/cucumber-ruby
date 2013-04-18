Feature: Assertions
  In order to get started quickly
  As a new Cucumber user
  I want to use a familiar assertion library

  Background:
    Given a file named "features/assert.feature" with:
       """
       Feature: Assert
         Scenario: Passing
           Then it should pass
       """

    Given a file named "without_rspec.rb" with:
    """
    require 'rubygems' if RUBY_VERSION <= '1.8.7'
    require 'rspec/expectations'

    module RSpec
      remove_const :Matchers rescue nil
      remove_const :Expectations rescue nil
    end

    module Spec
      remove_const :Expectations rescue nil
    end
    """

  @spawn
  Scenario: Test::Unit
    Given a file named "features/step_definitions/assert_steps.rb" with:
      """
      require 'test/unit/assertions'
      World(::Test::Unit::Assertions)

      Then /^it should pass$/ do
        assert(2 + 2 == 4)
      end
      """
    When I run `cucumber`
    Then it should pass with exactly:
      """
      Feature: Assert

        Scenario: Passing     # features/assert.feature:2
          Then it should pass # features/step_definitions/assert_steps.rb:4

      1 scenario (1 passed)
      1 step (1 passed)
      0m0.012s

      """

  Scenario: RSpec
    Given a file named "features/step_definitions/assert_steps.rb" with:
      """
      Then /^it should pass$/ do
        (2 + 2).should == 4
      end
      """
    When I run `cucumber`
    Then it should pass with exactly:
      """
      Feature: Assert

        Scenario: Passing     # features/assert.feature:2
          Then it should pass # features/step_definitions/assert_steps.rb:1

      1 scenario (1 passed)
      1 step (1 passed)
      0m0.012s

      """
