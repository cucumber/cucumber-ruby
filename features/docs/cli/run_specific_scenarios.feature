Feature: Run specific scenarios

  You can choose to run a specific scenario using the file:line format

  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given(/pass/) {}
      Given(/fail/) { raise "Failed" }
      Given(/table/) { |t| }
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

  Scenario: Specify 2 line numbers where one is a tag
    Given a file named "features/test.feature" with:
      """
      Feature: Sample

        @two @three
        Scenario: Passing
          Given passing

        @four
        Scenario: Failing
          Given failing
      """
    When I run `cucumber -q features/test.feature:3:8`
    Then it should fail with:
      """
      Feature: Sample

        @two @three
        Scenario: Passing
          Given passing

        @four
        Scenario: Failing
          Given failing
            Failed (RuntimeError)
            ./features/step_definitions/steps.rb:2:in `/fail/'
            features/test.feature:9:in `Given failing'

      Failing Scenarios:
      cucumber features/test.feature:8

      2 scenarios (1 failed, 1 passed)
      2 steps (1 failed, 1 passed)
      """

  Scenario: Specify the line number of a row
    Given a file named "features/test.feature" with:
      """
      Feature: Sample
        Scenario: Passing
          Given a table
            | a | b |
            | c | d |

      """
    When I run `cucumber -q features/test.feature:4`
    Then it should pass with:
      """
      Feature: Sample

        Scenario: Passing
          Given a table
            | a | b |
            | c | d |

      1 scenario (1 passed)
      1 step (1 passed)

      """
