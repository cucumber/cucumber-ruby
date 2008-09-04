Feature: Division
  In order to avoid silly mistakes
  As a math idiot 
  I want to be told the division of two numbers

  Scenario: Regular numbers
    Given I have entered 3 into the calculator
    And I have entered 2 into the calculator
    When I press divide
    Then the result should be 1.5 on the screen
    And the result class should be Float
