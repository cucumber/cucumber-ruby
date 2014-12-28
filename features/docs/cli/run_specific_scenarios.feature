Feature: Run specific scenarios

  You can choose to run a specific scenario using the file:line format,
  or you can pass in a file with a list of scenarios using @-notation.

  Background:
    Given the standard step definitions

  Scenario: Two scenarios, run just one of them
    Given a file named "features/test.feature" with:
      """
      Feature: 
        Scenario:
          Given this step is undefined

        Scenario: Hit
          Given this step passes
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
          Given this step <something>

          Examples:
            | something    |
            | is undefined |
            | fails        |

        Scenario: Miss
          Given this step passes
      """
    When I run `cucumber features/test.feature:8 -f progress`
    Then it should fail with:
      """
      1 scenario (1 failed)
      """

  @spawn
  Scenario: Specify 2 line numbers where one is a tag
    Given a file named "features/test.feature" with:
      """
      Feature: Sample

        @two @three
        Scenario:
          Given this step passes

        @four
        Scenario:
          Given this step passes
      """
    When I run `cucumber -q features/test.feature:3:8`
    Then it should pass with:
      """
      2 scenarios (2 passed)
      2 steps (2 passed)
      """

  Scenario: Specify 2 line numbers using separate arguments
    Given a file named "features/test.feature" with:
      """
      Feature: Sample
        Scenario: One
          Given this step passes

        Scenario: Two
          Given this step passes
      """
    When I run `cucumber -q features/test.feature:3 features/test.feature:6`
    Then it should pass with:
      """
      2 scenarios (2 passed)
      2 steps (2 passed)
      """

  Scenario: Specify the line number of a row
    Given a file named "features/test.feature" with:
      """
      Feature: Sample
        Scenario: Passing
          Given this step is a table step
            | a | b |
            | c | d |

      """
    When I run `cucumber -q features/test.feature:4`
    Then it should pass with:
      """
      Feature: Sample

        Scenario: Passing
          Given this step is a table step
            | a | b |
            | c | d |

      1 scenario (1 passed)
      1 step (1 passed)

      """

  Scenario: Use @-notation to specify a file containing feature file list
    Given a file named "features/test.feature" with:
      """
      Feature: Sample
        Scenario: Passing
          Given this step passes
      """
    And a file named "list-of-features.txt" with:
      """
      features/test.feature:2
      """
    When I run `cucumber -q @list-of-features.txt`
    Then it should pass with:
      """
      Feature: Sample

        Scenario: Passing
          Given this step passes

      1 scenario (1 passed)
      1 step (1 passed)
      """
