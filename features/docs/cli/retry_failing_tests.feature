@wip
Feature: Retry failing tests

  Retry gives you a way to get through flaky tests that usually pass after a few runs.
  This gives a development team a way forward other than disabling a valuable test.
  
  - Specify max retry count in option
  - Output information to the screen
  - Output retry information in test report
  
  Questions:
  use a tag for flaky tests?  Global option to retry any test that fails?
  
  Background:
    Given a scenario "Flakey" that fails once, then passes
    And a scenario "Shakey" that fails twice, then passes
    And a scenario "Solid" that passes
  
  Scenario:
    When I run `cucumber --retry 1`
    Then it should fail with:
      """
      3 scenarios (2 passed, 1 failed)
      """

  Scenario:
    When I run `cucumber --retry 2`
    Then it should pass with:
      """
      3 scenarios (3 passed)
      """