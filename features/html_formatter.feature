Feature: HTML output formatter

  Background:
    Given a file named "features/scenario_outline_with_undefined_steps.feature" with:
      """
      Feature:

        Scenario Outline:
          Given an undefined step
        
        Examples:
          |foo|
          |bar|
      """

  Scenario: an scenario outline, one undefined step, one random example, expand flag on
    When I run cucumber "features/scenario_outline_with_undefined_steps.feature --format html --expand "
    Then it should pass

