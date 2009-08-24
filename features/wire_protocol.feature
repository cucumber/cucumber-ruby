@wire
Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support ruby
  I want a low-level protocol which Cucumber can use to run steps within my app

  Scenario: Check for the existence of a step definition
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
    And a wire server listening on localhost:98989
    And the wire server is in a process that has defined the following step:
    """
    Given /wired/ do
    end
    """
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
