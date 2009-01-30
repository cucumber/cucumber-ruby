Feature: Failing background sample
  
  Background:
    Given failing without a table
    
  Scenario: failing background
    Then I should have '10' cukes
    
  Scenario: another failing background
    Then I should have '10' cukes