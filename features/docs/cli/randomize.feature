Feature: Randomize

  Use the `--randomize` switch to run scenarios in random order.

  This is especially helpful for detecting situations where you have state
  leaking between scenarios, which can cause flickering or fragile tests.

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
    When I run `cucumber --random` 4 times
    Then it should fail at least once

