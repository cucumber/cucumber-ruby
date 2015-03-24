Feature: After Hooks

  After hooks can be used to clean up any state you've altered during your
  scenario, or to check the status of the scenario and act accordingly.

  You can ask a scenario whether it has failed, for example.

  Mind you, even if it hasn't failed yet, you can still make the scenario
  fail if your After hook throws an error.

  Background:
    Given the standard step definitions

  Scenario: Check the failed status of a scenario in a hook
    Given a file named "features/support/debug_hook.rb" with:
      """
      After do |scenario|
        if scenario.failed?
          puts "eek"
        end
      end
      """
    And a file named "features/fail.feature" with:
      """
      Feature:
        Scenario:
          Given this step fails
      """
    When I run `cucumber -f progress`
    Then the output should contain:
      """
      eek
      """

  Scenario: Make a scenario fail from an After hook
    Given a file named "features/support/bad_hook.rb" with:
      """
      After do
        fail 'yikes'
      end
      """
    And a file named "features/pass.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
      """
    When I run `cucumber -f pretty`
    Then it should fail with:
      """
        Scenario:                # features/pass.feature:2
          Given this step passes # features/step_definitions/steps.rb:1
            yikes (RuntimeError)
            ./features/support/bad_hook.rb:2:in `After'
      """

  Scenario: The World still exists in an After hook
    Given a file named "features/support/after_hook.rb" with:
      """
      After do
        expect(@set_in_step).to be(true)
      end
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/we set a world variable/) do
        @set_in_step = true
      end
      """
    And a file named "features/feature.feature" with:
      """
      Feature:
        Scenario:
          Given we set a world variable
      """
    When I run `cucumber -q`
    Then it should pass
