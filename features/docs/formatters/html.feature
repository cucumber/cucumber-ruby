Feature: html formatter

  Background:
    Given the standard step definitions
    And a file named "features/my_feature.feature" with:
      """
      Feature: Some feature

        Scenario Outline: a scenario
          Given a <status> step

        Examples:
          | status |
          | passed |
          | failed |
      """

  Scenario: output html to stdout
    When I run `cucumber features/my_feature.feature --format html`
    Then it should pass with:
      """
      <head>
      """
