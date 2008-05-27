Story: Addition
  As a math idiot 
  I want to be told the sum of two numbers
  So that I don't make silly mistakes

  Scenario: 5+7
    Given I have entered 5
    And I have entered 7
    When I add
    Then the result should be 12
