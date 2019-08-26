Feature: Dots formatter

  The dots formatter is super simple. It just prints a single ANSI-coloured character
  for each step, then a summary at the bottom.

  The dots formatter lives in a [separate library](https://github.com/cucumber/cucumber/tree/master/dots-formatter), so we've just gone one example scenario
  here to check it all hangs together.

  Scenario:
    Given the standard step definitions
    And a file named "features/a_scenario.feature" with:
      """
      Feature:

        Scenario:
          Given this step passes
          Given this step is undefined
      """
    When I run `cucumber --format dots`
    Then it should pass
    And the output should contain:
    """
    .U
    """

