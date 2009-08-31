@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support Ruby
  I want a low-level protocol which Cucumber can use to run steps within my app
  
  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/wired.feature" with:
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
  
      """
    And a file named "features/wired_table.feature" with:
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired on:
            |drug|
            |love|

      """
    And a file named "features/step_definitions/cucumber.wire" with:
      """
      host: localhost
      port: 98989
      """

  Scenario: Invoke a Step Definition which passes
    Given a file named "remote/stepdefs.rb" with:
      """
      Given /^we're all wired$/ do
      end
      """
    And a local wire server listening on port 98989 reading step definitions from "remote"
    When I run cucumber -q features/wired.feature
    Then STDERR should be empty
    And it should pass with
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
    
      1 scenario (1 passed)
      1 step (1 passed)
    
      """

  Scenario: Invoke a Step Definition which fails
    Given a file named "remote/stepdefs.rb" with:
      """
      Given /^we're all wired$/ do
        raise 'the wires are down'
      end
      """
    And a local wire server listening on port 98989 reading step definitions from "remote"
    When I run cucumber -q features/wired.feature
    Then STDERR should be empty
    And it should fail with
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
            the wires are down (Cucumber::WireSupport::WireException)
            remote/stepdefs.rb:2:in `parse!'
            features/wired.feature:4:in `Given we're all wired'

      Failing Scenarios:
      cucumber features/wired.feature:3 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 failed)
      
      """

  Scenario: Invoke a Step Definition with a table that fails on diff!
    Given a file named "remote/stepdefs.rb" with:
      """
      Given /^we're all wired on:$/ do |what|
        what.diff!([['drug'], ['life']])
        log.error "shouldn't get here"
      end
      """
    And a local wire server listening on port 98989 reading step definitions from "remote"
    When I run cucumber -q features/wired_table.feature
    Then STDERR should be empty
    And it should fail with
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired on:
            | drug |
            | love |
            | life |
            Tables were not identical (Cucumber::Ast::Table::Different)
            remote/stepdefs.rb:2:in `parse!'
            features/wired_table.feature:4:in `Given we're all wired on:'

      Failing Scenarios:
      cucumber features/wired_table.feature:3 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 failed)

      """