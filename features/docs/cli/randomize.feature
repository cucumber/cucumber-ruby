Feature: Randomize

  Use the `--order random` switch to run scenarios in random order.

  This is especially helpful for detecting situations where you have state
  leaking between scenarios, which can cause flickering or fragile tests.

  If you do find a random run that exposes dependencies between your tests,
  you can reproduce that run by using the seed that's printed at the end of
  the test run.

  Background:
    Given a file named "features/bad_practice_part_1.feature" with:
      """
      Feature: Bad practice, part 1
        
        Scenario: Set state
          Given I set some state
      
        Scenario: Depend on state from a preceding scenario
          When I depend on the state
      """
    And a file named "features/bad_practice_part_2.feature" with:
      """
      Feature: Bad practice, part 2

        Scenario: Depend on state from a preceding feature
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
    When I run `cucumber --order random:41529 -q`
    Then it should fail
    And the stdout should contain exactly:
      """
      Feature: Bad practice, part 1

        Scenario: Depend on state from a preceding scenario
          When I depend on the state
            I expect the state to be set! (RuntimeError)
            ./features/step_definitions/steps.rb:6:in `/^I depend on the state$/'
            features/bad_practice_part_1.feature:7:in `When I depend on the state'

      Feature: Bad practice, part 2

        Scenario: Depend on state from a preceding feature
          When I depend on the state
            I expect the state to be set! (RuntimeError)
            ./features/step_definitions/steps.rb:6:in `/^I depend on the state$/'
            features/bad_practice_part_2.feature:4:in `When I depend on the state'

      Feature: Bad practice, part 1

        Scenario: Set state
          Given I set some state
      
      Failing Scenarios:
      cucumber features/bad_practice_part_1.feature:6
      cucumber features/bad_practice_part_2.feature:3
    
      3 scenarios (2 failed, 1 passed)
      3 steps (2 failed, 1 passed)
      
      Randomized with seed 41529
      
      """

