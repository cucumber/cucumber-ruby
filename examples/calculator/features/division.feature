Feature: Division
  As a math genius 
  I want to be told the division of two floats
  So that I don't make silly mistakes

  Scenario: Regular numbers
    Given I have entered 3 into the calculator
    And I have entered 2 into the calculator
    When I press divide
    Then the result should be 1.5 on the screen
    And the result class should be Float
    And it should rain on Friday