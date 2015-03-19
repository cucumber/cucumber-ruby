Feature: Cucumber command line
  In order to find out what step definitions need to be implemented
  Developers should always see what step definition is missing

  @spawn
  Scenario: Get info at arbitrary levels of nesting
    Given a file named "features/call_undefined_step_from_step_def.feature" with:
      """
      Feature: Calling undefined step

        Scenario: Call from feature
          Given this directly called step does not exist

        Scenario: Call directly
          Given a step that calls an undefined step

        Scenario: Call via another
          Given a step that calls a step that calls an undefined step
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^a step that calls an undefined step$/ do
        step 'this does not exist'
      end

      Given /^a step that calls a step that calls an undefined step$/ do
        step 'a step that calls an undefined step'
      end
      """
    When I run `cucumber --strict -q features/call_undefined_step_from_step_def.feature`
    Then it should fail with exactly:
      """
      Feature: Calling undefined step

        Scenario: Call from feature
          Given this directly called step does not exist
            Undefined step: "this directly called step does not exist" (Cucumber::Undefined)
            features/call_undefined_step_from_step_def.feature:4:in `Given this directly called step does not exist'

        Scenario: Call directly
          Given a step that calls an undefined step
            Undefined nested step: "this does not exist" (Cucumber::UndefinedNestedStep)
            ./features/step_definitions/steps.rb:2:in `/^a step that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:7:in `Given a step that calls an undefined step'

        Scenario: Call via another
          Given a step that calls a step that calls an undefined step
            Undefined nested step: "this does not exist" (Cucumber::UndefinedNestedStep)
            ./features/step_definitions/steps.rb:2:in `/^a step that calls an undefined step$/'
            ./features/step_definitions/steps.rb:6:in `/^a step that calls a step that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:10:in `Given a step that calls a step that calls an undefined step'

      Failing Scenarios:
      cucumber features/call_undefined_step_from_step_def.feature:6
      cucumber features/call_undefined_step_from_step_def.feature:9

      3 scenarios (2 failed, 1 undefined)
      3 steps (2 failed, 1 undefined)
      0m0.012s

      """
