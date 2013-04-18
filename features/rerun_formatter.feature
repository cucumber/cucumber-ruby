Feature: Rerun formatter
  For details see https://github.com/cucumber/cucumber/issues/57

  Background:
    Given a file named "features/one_passing_one_failing.feature" with:
      """
      Feature: One passing example, one failing example

        Scenario Outline:
          Given a <certain> step
        
        Examples:
          |certain|
          |passing|
          |failing|

      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /a passing step/ do
        #does nothing
      end

      Given /a failing step/ do
        fail
      end
      """

  Scenario: Handle examples with the rerun formatter
    When I run `cucumber features/one_passing_one_failing.feature -r features -f rerun`
    Then it should fail with:
    """
    features/one_passing_one_failing.feature:9
    """

