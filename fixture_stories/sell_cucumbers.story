Story: Sell cucumbers
  As a cucumber farmer 
  I want to sell cucumbers 
  So that I buy meat

  Scenario: Sell none
    Given there are 5 cucumber
    When I sell 0 cucumbers
    Then I should have 5 cucumbers

  Scenario: Sell a dozen
    Given there are 5 cucumber
    When I sell 12 cucumbers
    Then I should owe 7 cucumbers

  Scenario: Sell a couple
    Given there are 5 cucumber
    When I sell 2 cucumbers
    Then I should have 3 cucumbers
