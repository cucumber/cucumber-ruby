Feature: Cucumber command line
  In order to find out what step definitions need to be implemented
  Developers should always see what step definition is missing

  @spawn
  Scenario: Get info at arbitrary levels of nesting
    Given a file named "features/call_undefined_step_from_step_def.feature" with:
      """
      Feature: Calling undefined step

        Scenario: Call directly
          Given a step definition that calls an undefined step

        Scenario: Call via another
          Given call step "a step definition that calls an undefined step"
      """
    And a file named "features/step_definitions/sample_steps.rb" with:
      """
      Given /^a step definition that calls an undefined step$/ do
        step 'this does not exist'
      end

      Given /^call step "(.*)"$/ do |step_name| x=1
        step step_name
      end
      """
    When I run `cucumber features/call_undefined_step_from_step_def.feature`
    Then it should pass with:
      """
      Feature: Calling undefined step

        Scenario: Call directly                                # features/call_undefined_step_from_step_def.feature:3
          Given a step definition that calls an undefined step # features/step_definitions/sample_steps.rb:1
            Undefined step: "this does not exist" (Cucumber::Undefined)
            ./features/step_definitions/sample_steps.rb:2:in `/^a step definition that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:4:in `Given a step definition that calls an undefined step'

        Scenario: Call via another                                         # features/call_undefined_step_from_step_def.feature:6
          Given call step "a step definition that calls an undefined step" # features/step_definitions/sample_steps.rb:5
            Undefined step: "this does not exist" (Cucumber::Undefined)
            ./features/step_definitions/sample_steps.rb:2:in `/^a step definition that calls an undefined step$/'
            ./features/step_definitions/sample_steps.rb:6:in `/^call step "(.*)"$/'
            features/call_undefined_step_from_step_def.feature:7:in `Given call step "a step definition that calls an undefined step"'

      2 scenarios (2 undefined)
      2 steps (2 undefined)
      """
    And the output should contain:
      """

      You can implement step definitions for undefined steps with these snippets:

      Given(/^this does not exist$/) do
        pending # express the regexp above with the code you wish you had
      end


      """

