Feature: Run specific scenarios

  You can choose to run a specific scenario using the file:line format

  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given(/pass/) {}
      Given(/fail/) { raise "Failed" }
      """

  Scenario: Two scenarios, run just one of them
    Given a file named "features/test.feature" with:
      """
      Feature: 
        Scenario:
          Given this is undefined

        Scenario: Hit
          Given this passes
      """
    When I run `cucumber features/test.feature:5 -f progress`
    Then it should pass with:
      """
      1 scenario (1 passed)
      """

  Scenario: Single example from a scenario outline
    Given a file named "features/test.feature" with:
      """
      Feature:
        Scenario Outline:
          Given this <something>

          Examples:
            | something    |
            | is undefined |
            | fails        |

        Scenario: Miss
          Given this passes
      """
    When I run `cucumber features/test.feature:8 -f progress`
    Then it should fail with:
      """
      1 scenario (1 failed)
      """
