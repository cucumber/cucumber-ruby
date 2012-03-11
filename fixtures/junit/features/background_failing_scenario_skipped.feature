Feature: Background failing, scenario skipped

  Background: Background failing
    Given a failing scenario
  
  Scenario: Scenario should fail
    Given a passing scenario

  Scenario: Scenario should be skipped
    Given a passing scenario
    
