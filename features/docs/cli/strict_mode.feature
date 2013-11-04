Feature: Strict mode

  Using the `--strict` flag will cause cucumber to fail unless all the
  step definitions have been defined.

  Background:
    Given a file named "features/missing.feature" with:
    """
    Feature: Missing
      Scenario: Missing
        Given this step passes
    """

  @wip-new-core
  Scenario: Fail with --strict
    When I run `cucumber -q features/missing.feature --strict`
    Then it should fail with:
      """
      Feature: Missing

        Scenario: Missing
          Given this step passes
            Undefined step: "this step passes" (Cucumber::Undefined)
            features/missing.feature:3:in `Given this step passes'

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

  Scenario: Succeed with --strict
    Given the standard step definitions
    When I run `cucumber -q features/missing.feature --strict`
    Then it should pass with:
    """
    Feature: Missing

      Scenario: Missing
        Given this step passes

    1 scenario (1 passed)
    1 step (1 passed)
    """
