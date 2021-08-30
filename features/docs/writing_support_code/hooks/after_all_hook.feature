Feature: AfterAll Hooks

  AfterAll hooks can be used if you have some clean-up to be done after all
  scenarios have been executed.

  Scenario: A single AfterAll hook

    An AfterAll hook will be invoked a single time after all the scenarios have
    been executed.

    Given a file named "features/f.feature" with:
      """
      Feature: AfterAll hook
        Scenario: #1
          Then the AfterAll hook has not been called yet

        Scenario: #2
          Then the AfterAll hook has not been called yet
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      hookCalled = 0

      AfterAll do
        hookCalled += 1

        raise "AfterAll hook error has been raised"
      end

      Then /^the AfterAll hook has not been called yet$/ do
        expect(hookCalled).to eq 0
      end
      """
    When I run `cucumber features/f.feature --publish-quiet`
    Then it should fail with:
      """
      Feature: AfterAll hook

        Scenario: #1                                     # features/f.feature:2
          Then the AfterAll hook has not been called yet # features/step_definitions/steps.rb:9

        Scenario: #2                                     # features/f.feature:5
          Then the AfterAll hook has not been called yet # features/step_definitions/steps.rb:9

      2 scenarios (2 passed)
      2 steps (2 passed)
      """
    And the output should contain:
      """
      AfterAll hook error has been raised (RuntimeError)
      """

  Scenario: It is invoked also when scenario has failed

    Given a file named "features/f.feature" with:
      """
      Feature: AfterAll hook
        Scenario: failed
          Given a failed step
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      AfterAll do
        raise "AfterAll hook error has been raised"
      end

      Given /^a failed step$/ do
        expect(0).to eq 1
      end
      """
    When I run `cucumber features/f.feature --publish-quiet`
    Then it should fail with:
      """
      1 scenario (1 failed)
      1 step (1 failed)
      """
    And the output should contain:
      """
      AfterAll hook error has been raised (RuntimeError)
      """
