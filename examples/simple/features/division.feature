Feature: Division
  As a math genius 
  I want to be told the division of two floats
  So that I don't make silly mistakes

  Scenario: 7/2
    Given I have entered 3 into the calculator
    And I have entered 2 into the calculator
    When I divide
    Then the result should be 2.5 on the screen
    And the result class should be Float

  Scenario: 3/0
    Given I have entered 3 into the calculator
    And I have entered 2 into the calculator
    When I divide
    Then the result should be NaN on the screen
