Feature: Dry Run

  Dry run gives you a way to quickly scan your features without actually running them.

  - Invokes formatters without executing the steps.
  - This also omits the loading of your support/env.rb file if it exists.

  Scenario: With a failing step
    Given a file named "features/test.feature" with:
      """
      Feature: test
        Scenario:
          Given this step fails
      """
    And the standard step definitions
    When I run `cucumber --dry-run --publish-quiet`
    Then it should pass with exactly:
      """
      Feature: test

        Scenario:               # features/test.feature:2
          Given this step fails # features/step_definitions/steps.rb:4

      1 scenario (1 skipped)
      1 step (1 skipped)

      """

  Scenario: With message formatter
    Given a file named "features/test.feature" with:
      """
      Feature: test
        Scenario:
          Given this step passes
      """
    And the standard step definitions
    When I run `cucumber --dry-run --publish-quiet --format message`
    Then it should pass
    And output should be valid NDJSON
    And the output should contain NDJSON with key "status" and value "SKIPPED"

  Scenario: In strict mode
    Given a file named "features/test.feature" with:
      """
      Feature: test
        Scenario:
          Given this step fails
      """
    And the standard step definitions
    When I run `cucumber --dry-run --strict --publish-quiet`
    Then it should pass with exactly:
      """
      Feature: test

        Scenario:               # features/test.feature:2
          Given this step fails # features/step_definitions/steps.rb:4

      1 scenario (1 skipped)
      1 step (1 skipped)

      """

  Scenario: In strict mode with an undefined step
    Given a file named "features/test.feature" with:
      """
      Feature: test
        Scenario:
          Given this step is undefined
      """
    When I run `cucumber --dry-run --strict`
    Then it should fail with:
      """
      Feature: test

        Scenario:                      # features/test.feature:2
          Given this step is undefined # features/test.feature:3
            Undefined step: "this step is undefined" (Cucumber::Core::Test::Result::Undefined)
            features/test.feature:3:in `this step is undefined'

      Undefined Scenarios:
      cucumber features/test.feature:2 # Scenario:

      1 scenario (1 undefined)
      1 step (1 undefined)

      """

  Scenario: With BeforeAll and AfterAll hooks
    Given a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
      """
    And the standard step definitions
    And a file named "features/step_definitions/support.rb" with:
      """
      BeforeAll do
        raise "BeforeAll hook error has been raised"
      end

      AfterAll do
        raise "AfterAll hook error has been raised"
      end
      """
    When I run `cucumber features/test.feature --publish-quiet --dry-run`
    Then it should pass with exactly:
      """
      Feature:

        Scenario:                # features/test.feature:2
          Given this step passes # features/step_definitions/steps.rb:1

      1 scenario (1 skipped)
      1 step (1 skipped)

      """
