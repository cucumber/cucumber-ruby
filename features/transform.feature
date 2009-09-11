Feature: transform
  In order to maintain modularity within step definitions
  As a step definition editor
  I want to register a regex to capture and tranform step definition arguments.

  Scenario: run a specific scenario with a registered transform
    When I run cucumber -q features/transform_sample.feature --require features
    Then it should pass with
    """
    Feature: Step argument transformations
    
      Scenario: transform with matches
        Then I should transform '10' to an Integer

      Scenario: transform without matches
        Then I should not transform '10' to an Integer

    2 scenarios (2 passed)
    2 steps (2 passed)
    
    """
