Feature: Hooks execute in defined order
  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given('background step') { log(:background_step) }
      Given('scenario step') { log(:scenario_step) }
      """
    And a file named "features/support/hooks.rb" with:
      """
      $EventOrder = []
      Around('@around') do |scenario,block|
        log(:around_begin)
        block.call
        log(:around_end)
      end

      Before('@before') do
        log(:before)
      end

      After('@after') do |scenario|
        log(:after)
      end
      """
    And a file named "features/around_hook_covers_background.feature" with:
      """
      @around
      Feature: Around hooks cover background steps
        Background:
          Given background step
        Scenario:
          Given scenario step
      """
    And a file named "features/all_hook_order.feature" with:
      """
      @around
      @before
      @after
      Feature: All hooks execute in expected order
        Background:
          Given background step
        Scenario:
          Given scenario step
      """
    And log only formatter is declared

  Scenario: Around hooks cover background steps
    When I run `cucumber features/around_hook_covers_background.feature --format LogOnlyFormatter --publish-quiet`
    Then the output should contain:
      """
      around_begin
      background_step
      scenario_step
      around_end
      """
    And the exit status should be 0

  Scenario: All hooks execute in expected order
    When I run `cucumber features/all_hook_order.feature --format LogOnlyFormatter --publish-quiet`
    Then the output should contain:
      """
      around_begin
      before
      background_step
      scenario_step
      after
      around_end
      """
    And the exit status should be 0
