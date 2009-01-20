Feature: Outline Sample

  Scenario: I have no steps

  Scenario Outline: Test state
    Given <state> without a table
  Examples:
    |  state   |
    | missing |
    | passing|
| failing |