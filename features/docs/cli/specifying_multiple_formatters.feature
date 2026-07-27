Feature: Running multiple formatters

  When running cucumber, you are able to using multiple different
  formatters and redirect the output to text files.
  Two formatters cannot both print to the same file (or to STDOUT)

  Background:
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

  Scenario: Multiple formatters and outputs
    When I run `cucumber --no-color --format progress --out progress.txt --format pretty --out pretty.txt --no-source --dry-run --no-snippets features/test.feature --publish-quiet`
    Then the stderr should not contain anything
    Then the file "progress.txt" should contain:
      """
      UUUUU

      Undefined Scenarios:
      cucumber features/test.feature:3

      1 scenario (1 undefined)
      5 steps (5 undefined)

      """
    And the file "pretty.txt" should contain:
      """
      Feature: Lots of undefined

        Scenario: Implement me
          Given it snows in Sahara
            Undefined step: "it snows in Sahara" (Cucumber::Core::Test::Result::Undefined)
            features/test.feature:4:in `it snows in Sahara'
          Given it's 40 degrees in Norway
            Undefined step: "it's 40 degrees in Norway" (Cucumber::Core::Test::Result::Undefined)
            features/test.feature:5:in `it's 40 degrees in Norway'
          And it's 40 degrees in Norway
            Undefined step: "it's 40 degrees in Norway" (Cucumber::Core::Test::Result::Undefined)
            features/test.feature:6:in `it's 40 degrees in Norway'
          When I stop procrastinating
            Undefined step: "I stop procrastinating" (Cucumber::Core::Test::Result::Undefined)
            features/test.feature:7:in `I stop procrastinating'
          And there is world peace
            Undefined step: "there is world peace" (Cucumber::Core::Test::Result::Undefined)
            features/test.feature:8:in `there is world peace'

      Undefined Scenarios:
      cucumber features/test.feature:3

      1 scenario (1 undefined)
      5 steps (5 undefined)

      """

  Scenario: Two formatters to stdout
    When I run `cucumber -f progress -f pretty features/test.feature`
    Then it should fail with:
      """
      All but one formatter must use --out, only one can print to each stream (or STDOUT) (RuntimeError)
      """

  Scenario: Two formatters to stdout when using a profile
    Given the following profiles are defined:
      """
      default: -q
      """
    When I run `cucumber -f progress -f pretty features/test.feature`
    Then it should fail with:
      """
      All but one formatter must use --out, only one can print to each stream (or STDOUT) (RuntimeError)
      """
