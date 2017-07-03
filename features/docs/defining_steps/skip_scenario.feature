Feature: Skip Scenario

  @todo-windows
  Scenario: With a passing step
    Given a file named "features/test.feature" with:
      """
      Feature: test
        Scenario: test
          Given this step says to skip
          And this step passes
      """
    And the standard step definitions
    And a file named "features/step_definitions/skippy.rb" with:
      """
      Given /skip/ do
        skip_this_scenario
      end
      """
    When I run `cucumber -q`
    Then it should pass with exactly:
      """
      Feature: test

        Scenario: test
          Given this step says to skip
          And this step passes

      1 scenario (1 skipped)
      2 steps (2 skipped)

      """
