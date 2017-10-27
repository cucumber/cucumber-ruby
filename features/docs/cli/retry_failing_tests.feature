Feature: Retry failing tests

  Retry gives you a way to get through flaky tests that usually pass after a few runs.
  This gives a development team a way forward other than disabling a valuable test.

  - Specify max retry count in option
  - Output information to the screen
  - Output retry information in test report

  Questions:
  use a tag for flaky tests?  Global option to retry any test that fails?

  Background:
    Given a scenario "Fails-once" that fails once, then passes
    And a scenario "Fails-twice" that fails twice, then passes
    And a scenario "Solid" that passes

  @todo-windows
  Scenario: Retry once, so Fails-once starts to pass
    Given a scenario "Fails-forever" that fails
    When I run `cucumber -q --retry 1 --format summary`
    Then it should fail with:
      """
      4 scenarios (2 failed, 1 flaky, 1 passed)
      """
    And it should fail with:
      """
      Fails-forever
        Fails-forever ✗
        Fails-forever ✗

      Solid
        Solid ✓

      Fails-once feature
        Fails-once ✗
        Fails-once ✓

      Fails-twice feature
        Fails-twice ✗
        Fails-twice ✗
      """

  @todo-windows
  Scenario: Retry twice, so Fails-twice starts to pass too
    Given a scenario "Fails-forever" that fails
    When I run `cucumber -q --retry 2 --format summary`
    Then it should fail with:
      """
      4 scenarios (1 failed, 2 flaky, 1 passed)
      """
    And it should fail with:
      """
      Fails-forever
        Fails-forever ✗
        Fails-forever ✗
        Fails-forever ✗

      Solid
        Solid ✓

      Fails-once feature
        Fails-once ✗
        Fails-once ✓

      Fails-twice feature
        Fails-twice ✗
        Fails-twice ✗
        Fails-twice ✓
      """

  @todo-windows
  Scenario: Flaky scenarios gives exit code zero in non-strict mode
    When I run `cucumber -q --retry 2 --format summary`
    Then it should pass with:
      """


      3 scenarios (2 flaky, 1 passed)
      """

  @todo-windows
  Scenario: Flaky scenarios gives non-zero exit code in strict mode
    When I run `cucumber -q --retry 2 --format summary --strict`
    Then it should fail with:
      """
      Flaky Scenarios:
      cucumber features/fails_once.feature:2
      cucumber features/fails_twice.feature:2

      3 scenarios (2 flaky, 1 passed)
      """
