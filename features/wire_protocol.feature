@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support Ruby
  I want a low-level protocol which Cucumber can use to run steps within my app
  
  Background:
    Given a standard Cucumber project directory structure
    And a file named "features/cucumber.feature" with:
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
  
      """
    And a file named "features/step_definitions/cucumber.wire" with:
      """
      host: localhost
      port: 98989
      """

  Scenario: Invoke a Step Definition which passes
    Given a file named "remote/stepdefs.rb" with:
      """
      Given /we're all wired/ do
      end
      """
    And a local wire server listening on port 98989 reading step definitions from "remote"
    When I run cucumber -q features
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
      Given /we're all wired/ do
        raise 'the wires are down'
      end
      """
    And a local wire server listening on port 98989 reading step definitions from "remote"
    When I run cucumber -q features
    Then STDERR should be empty
    And it should fail with
      """
      Feature: Over the wire

        Scenario: Wired
          Given we're all wired
            the wires are down (Cucumber::WireSupport::WireException)
            (eval):2:in `parse!'
            features/cucumber.feature:4:in `Given we're all wired'

      Failing Scenarios:
      cucumber features/cucumber.feature:3 # Scenario: Wired

      1 scenario (1 failed)
      1 step (1 failed)
      
      """
