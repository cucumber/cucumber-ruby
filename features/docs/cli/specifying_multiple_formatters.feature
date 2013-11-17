@spawn
Feature: Running multiple formatters

  When running cucumber, you are able to using multiple different
  formatters and redirect the output to text files.

  Scenario: Multiple formatters and outputs
    Given a file named "features/test.feature" with:
    """
    Feature: Lots of undefined

      Scenario: Implement me
        Given it snows in Sahara
        Given it's 40 degrees in Norway
        And it's 40 degrees in Norway
        When I stop procrastinating
        And there is world peace
    """
    When I run `cucumber --no-color --format progress --out progress.txt --format pretty --out pretty.txt --no-source --dry-run --no-snippets features/test.feature`
    Then the stderr should not contain anything
    Then the file "progress.txt" should contain:
      """
      UUUUU

      1 scenario (1 undefined)
      5 steps (5 undefined)

      """
    And the file "pretty.txt" should contain:
      """
      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
          Given it's 40 degrees in Norway
          And it's 40 degrees in Norway
          When I stop procrastinating
          And there is world peace

      1 scenario (1 undefined)
      5 steps (5 undefined)

      """

