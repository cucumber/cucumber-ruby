Feature: HTML output formatter

  Background:
    Given a file named "features/scenario_outline_with_undefined_steps.feature" with:
      """
      Feature:

        Scenario Outline:
          Given an undefined step
        
        Examples:
          |foo|
          |bar|
      """
    And a file named "features/scenario_outline_with_pending_step.feature" with:
      """
      Feature: Outline

        Scenario Outline: Will it blend?
          Given this hasn't been implemented yet
          And other step
          When I do something with <example>
          Then I should see something
          Examples:
            | example |
            | one     |
            | two     |
            | three   |
      """
    And a file named "features/scenario_outline_with_background.feature" with:
     """
     Feature:

       Background:
         Given I have set up state

       Scenario:
         Given a number 1

       Scenario Outline:
         Given a number <number>

         Examples: 
           | number |
           | 2      |
           | 3      |
           | 4      |
          """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^this hasn't been implemented yet$/ do
        pending
      end

      Given(/I have set up state/) do
        @state = %w{1 2 3 4}
      end

      Given(/a number (\d+)/) do |n|
        @state.should include(n)
      end
      """

  Scenario: an scenario outline, one undefined step, one random example, expand flag on
    When I run `cucumber features/scenario_outline_with_undefined_steps.feature --format html --expand `
    Then it should pass

  Scenario Outline: an scenario outline, one pending step
    When I run `cucumber <file> --format html <flag>`
    Then it should pass
    And the output should contain:
    """
    makeYellow('scenario_1')
    """
    And the output should not contain:
    """
    makeRed('scenario_1')
    """
    Examples:
      | file                                                   | flag     |
      | features/scenario_outline_with_pending_step.feature    | --expand |
      | features/scenario_outline_with_pending_step.feature    |          |
      | features/scenario_outline_with_undefined_steps.feature | --expand |
      | features/scenario_outline_with_undefined_steps.feature |          |

  Scenario: when using a profile the html shouldn't include 'Using the default profile...'
    And a file named "cucumber.yml" with:
    """
      default: -r features
    """
    When I run `cucumber --profile default --format html`
    Then it should pass
    And the output should not contain:
    """
    Using the default profile...
    """

  Scenario: the background should run for all scenarios and example rows
    When I run `cucumber features/scenario_outline_with_background.feature --format html`
    Then it should pass
