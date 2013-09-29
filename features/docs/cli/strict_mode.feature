Feature: Strict mode

  Using the `--strict` flag will cause cucumber to fail unless all the
  step definitions have been defined.

  Background:
    Given a file named "features/missing.feature" with:
    """
    Feature: Missing
      Scenario: Missing
        Given a step
    """

  Scenario: Fail with --strict
    When I run `cucumber -q features/missing.feature --strict`
    Then it should fail with:
      """
      Feature: Missing

        Scenario: Missing
          Given a step
            Undefined step: "a step" (Cucumber::Undefined)
            features/missing.feature:3:in `Given a step'

      1 scenario (1 undefined)
      1 step (1 undefined)
      """

  Scenario: Succeed with --strict
    Given a file named "features/step_definitions/steps.rb" with:
    """
      Given(/^a step$/) { }
    """
    When I run `cucumber -q features/missing.feature --strict`
    Then it should pass with:
    """
    Feature: Missing

      Scenario: Missing
        Given a step

    1 scenario (1 passed)
    1 step (1 passed)
    """
