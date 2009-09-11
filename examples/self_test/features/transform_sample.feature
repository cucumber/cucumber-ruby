Feature: Step argument transformations

  Scenario: transform with matches
    Then I should transform '10' to an Integer

  Scenario: transform without matches
    Then I should not transform '10' to an Integer
