Story: Sell cucumber
  As a cucumber artist 
  I want to sell cucumber 
  So that I can make the world a better place

  Scenario: Sell a couple
    Given there are 5 cucumber
    When I sell 2 cucumber
    Then there should be 3 cucumber left

  Scenario: Sell a dozen
    Given there are 5 cucumber
    When I sell 12 cucumbers
    Then I should owe 7 cucumbers
