Feature: Progress output formatter

  Background:
    Given a file named "features/scenario_outline_with_undefined_steps.feature" with:
      """
      Feature:

        Scenario Outline:
          Given this step is undefined

        Examples:
          |foo|
          |bar|
      """

  Scenario: an scenario outline, one undefined step, one random example, expand flag on
    When I run `cucumber features/scenario_outline_with_undefined_steps.feature --format progress --expand `
    Then it should fail
    And the output should contain:
    """
    Undefined Scenarios:
    cucumber features/scenario_outline_with_undefined_steps.feature:8 # Scenario Outline:
    """	

Scenario: when using a profile the output should include 'Using the default profile...'
    And a file named "cucumber.yml" with:
    """
      default: -r features
    """
    When I run `cucumber --profile default --format progress`
    Then it should fail
    And the output should contain:
    """
    Using the default profile...
    """

