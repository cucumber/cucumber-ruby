Feature: BeforeAll Hooks

  BeforeAll hooks can be used if you have some set-up to be done before all
  scenarios are executed.

  BeforeAll hooks are not aware of your configuration. Use AfterConfiguration if
  you need it.

  Scenario: A single BeforeAll hook

    A BeforeAll hook will be invoked a single time before all the scenarios are
    executed.

    Given a file named "features/f.feature" with:
      """
      Feature: BeforeAll hook
        Scenario: #1
          Then the BeforeAll hook have been called

        Scenario: #2
          Then the BeforeAll hook have been called
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      hookCalled = 0

      BeforeAll do
        hookCalled += 1
      end

      Then /^the BeforeAll hook have been called$/ do
        expect(hookCalled).to eq 1
      end
      """
    When I run `cucumber features/f.feature`
    Then it should pass with:
      """
      Feature: BeforeAll hook

        Scenario: #1                               # features/f.feature:2
          Then the BeforeAll hook have been called # features/step_definitions/steps.rb:7

        Scenario: #2                               # features/f.feature:5
          Then the BeforeAll hook have been called # features/step_definitions/steps.rb:7

      2 scenarios (2 passed)
      2 steps (2 passed)

      """
