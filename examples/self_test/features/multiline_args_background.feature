Feature: Passing background with multiline args

  Background:
    Given passing
      |a|b|
      |c|d|
    And passing
    """
      I'm a cucumber and I'm okay. 
      I sleep all night and I test all day
    """

  Scenario: passing background
    Then passing without a table
    
  Scenario: another passing background
    Then passing without a table