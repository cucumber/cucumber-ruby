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
    And a file named "features/failing_background.feature" with:
      """
      Feature: Failing background sample

        Background:
          Given a failing step

        Scenario: failing background
          Then a passing step

        Scenario: another failing background
          Then a passing step
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

  Scenario: Failing background
    When I run `cucumber features/failing_background.feature -r features -f rerun`
    Then it should fail with:
    """
    features/failing_background.feature:6:9
    """
