Feature: Run feature elements matching a name with --name/-n

  The `--name NAME` option runs only scenarios which match a certain
  name. The NAME can be a substring of the names of Features, Scenarios,
  Scenario Outlines or Example blocks.

  Background:
    Given a file named "features/first.feature" with:
      """
      Feature: first feature
        Scenario: foo first
          Given this step passes
        Scenario: bar first
          Given this step passes
      """
    Given a file named "features/second.feature" with:
      """
      Feature: second
        Scenario: foo second
          Given this step passes
        Scenario: bar second
          Given this step passes
      """
    Given a file named "features/outline.feature" with:
      """
      Feature: outline
        Scenario Outline: baz outline
          Given outline step <name>

          Examples: quux example
            | name |
            | a    |
            | b    |
      """
    And the standard step definitions

  Scenario: Matching Scenario names
    When I run `cucumber -q --name foo`
    Then it should pass with:
      """
      Feature: first feature

        Scenario: foo first
          Given this step passes

      Feature: second

        Scenario: foo second
          Given this step passes

      2 scenarios (2 passed)
      2 steps (2 passed)
      """

  Scenario: Matching Scenario Outline names
    When I run `cucumber -q --name baz`
    Then it should fail with:
      """
      Feature: outline

        Scenario Outline: baz outline
          Given outline step <name>

          Examples: quux example
            | name |
            | a    |
            | b    |

      Undefined Scenarios:
      cucumber features/outline.feature:7
      cucumber features/outline.feature:8

      2 scenarios (2 undefined)
      2 steps (2 undefined)
      """

