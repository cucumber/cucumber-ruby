Feature: Data Tables
  Data Tables can be placed underneath a step and will be passed as the last
  argument to the step definition.

  They can be used to represent richer data structures, and can be transformed to other data-types.

  Scenario: transposed table
    When the following table is transposed:
      | a | b |
      | 1 | 2 |
    Then it should be:
      | a | 1 |
      | b | 2 |
