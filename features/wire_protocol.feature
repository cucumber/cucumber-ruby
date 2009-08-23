Feature: Wire Protocol
  In order to be allow Cucumber to touch my app in intimate places
  As a developer on platform which doesn't support ruby
  I want a low-level protocol which Cucumber can use to run steps within my app

  Scenario: Check for the existence of a step definition
    Given a standard Cucumber project directory structure
    And a file named "cucumber.wire" with:
    """
    localhost:98989
    """
    And a wire server listening on localhost:98989
    And the wire server is in a process that has defined the following step:
    """
    Given /I am here/ do
      pending
    end
    """
    When I run cucumber -q -f steps
    Then it should pass with
    """
    features/step_definitions/foo.rb
      /I am here/  # features/step_definitions/foo.rb:1

    1 step definition(s) in 1 source file(s).
    
    """
  
