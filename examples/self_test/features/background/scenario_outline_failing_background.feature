Feature: Failing background with scenario outlines sample

  Background:
    Given failing without a table

  Scenario Outline: passing background
    Then I should have '<count>' cukes
    Examples:
      |count|
      | 10  |

  Scenario Outline: another passing background
    Then I should have '<count>' cukes
    Examples:
      |count|
      | 10  |
