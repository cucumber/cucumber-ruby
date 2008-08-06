Feature: Addition
  As a math idiot 
  I want to be told the sum of two numbers
  So that I don't make silly mistakes

  Scenario: 50+70
    Given I have entered 50 into the calculator
    Given foo bar
    And I have entered 70 into the calculator
    When I add
    Then the result should be 12 on the screen
    And the result class should be Float

    | input_1 | input_2 | output | class  |
    | 20      | 30      | 50     | Fixnum |
    | 2       | 5       | 7      | Fixnum |
    | 20      | 40      | 80     | Number |
