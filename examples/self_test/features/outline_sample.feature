Feature: Outline Sample

  Scenario Outline: Test state
    Given <state> without a table
    Examples:
      |  state  |
      | missing |
      | passing |
      | failing |