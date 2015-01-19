Feature: Exception in BeforeStep Block
  In order to use custom cs ssertions at the beginning of each step
  As a developer
  I want exceptions raised in BeforeStep blocks to be handled gracefully and reported by the formatters

  Background:
    Given the standard step definitions
    And a file named "features/step_definitions/steps.rb" with:
    """
      Given /^this step does nothing naughty$/ do x=1
      	# Step intentionally empty
      end

      Given /^this step makes BeforeStep raise exceptions$/ do x=1
      	@naughty = true
      end

      Then /^this step does not execute$/ do x=1
      	raise Exception.new("This step should not execute")
      end

      Given /^this step passes$/ do x=1
      	# Step intentionally empty
      end
      """
    And a file named "features/support/env.rb" with:
    """
      class NaughtyStepException < Exception; end
      BeforeStep do
        if @naughty
          raise NaughtyStepException.new("This step has been very very naughty")
        end
      end
      """

  Scenario: Handle Exception in standard scenario step and carry on
    Given a file named "features/naughty_step_in_scenario.feature" with:
    """
      Feature: Sample

        Scenario: Failure in BeforeStep
          Given this step does nothing naughty
            And this step makes BeforeStep raise exceptions
          Then this step does not execute

        Scenario: Successful
        	Given this step passes
      """
    When I run `cucumber features`
    Then it should fail with:
    """
    Feature: Sample

      Scenario: Failure in BeforeStep                   # features/naughty_step_in_scenario.feature:3
        Given this step does nothing naughty            # features/step_definitions/steps.rb:1
        And this step makes BeforeStep raise exceptions # features/step_definitions/steps.rb:5
        Then this step does not execute                 # features/step_definitions/steps.rb:9
          This step has been very very naughty (NaughtyStepException)
          ./features/support/env.rb:4:in `BeforeStep'
          features/naughty_step_in_scenario.feature:6:in `Then this step does not execute'

      Scenario: Successful     # features/naughty_step_in_scenario.feature:8
        Given this step passes # features/step_definitions/steps.rb:13

    Failing Scenarios:
    cucumber features/naughty_step_in_scenario.feature:3 # Scenario: Failure in BeforeStep

    2 scenarios (1 failed, 1 passed)
    4 steps (1 failed, 3 passed)
    """

#  Scenario: Handle Exception in scenario outline table row and carry on
#    Given a file named "features/naughty_step_in_scenario_outline.feature" with:
#      """
#      Feature: Sample
#
#        Scenario Outline: Naughty Step
#          Given this step <Might Work>
#
#          Examples:
#          | Might Work             |
#          | passes                 |
#          | makes BeforeStep raise exceptions |
#          | passes                 |
#
#        Scenario: Success
#          Given this step passes
#
#      """
#    When I run `cucumber features`
#    Then it should fail with:
#      """
#      Feature: Sample
#
#        Scenario Outline: Naughty Step # features/naughty_step_in_scenario_outline.feature:3
#          Given this step <Might Work> # features/naughty_step_in_scenario_outline.feature:4
#
#          Examples:
#            | Might Work             |
#            | passes                 |
#            | does something naughty |
#            This step has been very very naughty (NaughtyStepException)
#            ./features/support/env.rb:4:in `BeforeStep'
#            features/naughty_step_in_scenario_outline.feature:9:in `Given this step does something naughty'
#            features/naughty_step_in_scenario_outline.feature:4:in `Given this step <Might Work>'
#            | passes                 |
#
#        Scenario: Success        # features/naughty_step_in_scenario_outline.feature:12
#          Given this step passes # features/step_definitions/steps.rb:1
#
#      Failing Scenarios:
#      cucumber features/naughty_step_in_scenario_outline.feature:9 # Scenario Outline: Naughty Step, Examples (row 2)
#
#      4 scenarios (1 failed, 3 passed)
#      4 steps (4 passed)
#
#      """
