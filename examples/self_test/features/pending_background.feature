Feature: Pending background sample

  Background:
    Given pending

  Scenario: passing background
    Then I should have '10' cukes
    
  Scenario: another passing background
    Then I should have '10' cukes