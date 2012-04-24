Feature: Run specific scenarios

  You can choose to run a specific scenario using the file:line format

  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given(/pass/) {}
      """

  Scenario: Two scenarios, run just one of them
    Given a file named "features/test.feature" with:
      """
      Feature: Test
        Scenario: Miss
          Given this is undefined

        Scenario: Hit
          Given this passes
      """
    When I run `cucumber features/test.feature:5 -f progress`
    Then it should pass with:
      """
      1 scenario (1 passed)
      """

