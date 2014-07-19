Feature: Randomize

  Use the `--order random` switch to run scenarios in random order.

  This is especially helpful for detecting situations where you have state
  leaking between scenarios, which can cause flickering or fragile tests.

  If you do find a randmon run that exposes dependencies between your tests,
  you can reproduce that run by using the seed that's printed at the end of
  the test run.

  Background:
    Given a file named "features/bad_practice.feature" with:
      """
      Feature: Bad practice
        
        Scenario: Set state
          Given I set some state
      
        Scenario: Depend on state
          When I depend on the state
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/^I set some state$/) do
        $global_state = "set"
      end

      Given(/^I depend on the state$/) do
        raise "I expect the state to be set!" unless $global_state == "set"
      end
      """

  Scenario: Run scenarios in order
    When I run `cucumber`
    Then it should pass

  @spawn
  Scenario: Run scenarios randomized
    When I run `cucumber --order random:41515`
    Then it should fail
    And the stdout should contain:
      """
      Randomized with seed 41515
      """

