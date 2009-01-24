Feature: Trading
  In order to avoid lost trades
  Traders should be alerted about stocks

  Scenario: Status alert can be activated
    Given a stock of prices 0.5,1.0 and a threshold of 10.0
    When the stock is traded at 5.0
    Then the alert status should be OFF
    When the stock is traded at 11.0
    Then the alert status should be ON

  Scenario: Status alert is never activated
    Given a stock of prices 0.5,1.0 and a threshold of 15.0
    When the stock is traded at 5.0
    Then the alert status should be OFF
    When the stock is traded at 11.0
    Then the alert status should be OFF

  Scenario: Trader sells all stocks
    Given a trader of name Mauro
    Given a stock of prices 0.5,1.0 and a threshold of 1.5
    When the stock is traded at 2.0
    Then the trader sells all stocks
    And the trader gets a bonus