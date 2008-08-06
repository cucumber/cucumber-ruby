Feature: Sell cucumbers
  As a cucumber farmer
  I want to sell cucumbers
  So that I buy meat

  Scenario: Sell a dozen
    Given there are 5 cucumbers
    When I sell 12 cucumbers
    Then I should owe 7 cucumbers
