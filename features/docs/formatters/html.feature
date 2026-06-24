Feature: html formatter

  Background:
    Given the standard step definitions
    And a file named "features/my_feature.feature" with:
      """
      Feature: Some feature

        Scenario Outline: a scenario
          Given this step <status>

        Examples:
          | status |
          | passes |
          | fails  |
      """

  Scenario: output html to stdout
    When I run `cucumber features/my_feature.feature --format html`
    Then it should fail
    And output should be html with title "Cucumber"
