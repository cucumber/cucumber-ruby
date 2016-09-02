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
    And a scenario "Fails-forever" that fails

  Scenario: Retry once, so Fails-once starts to pass
    When I run `cucumber -q --retry 1 --format summary`
    Then it should fail with:
      """
      7 scenarios (5 failed, 2 passed)
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

  Scenario: Retry twice, so Fails-twice starts to pass too
    When I run `cucumber -q --retry 2 --format summary`
    Then it should fail with:
      """
      9 scenarios (6 failed, 3 passed)
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
