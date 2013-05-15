Feature: Rerun only certain features

  In order to save time, Cucumber allows you do run *only* failed,
  pending and missing features from previous runs (with the help of a
  smart cucumber.yml file.)

  The examples below show which features will be rerun through the use
  of a special `rerun` formatter.

  Scenario:
    Given a file named "features/sample.feature" with:
      """
      Feature: Rerun

        Scenario: Failing
          Given failing

        Scenario: Missing
          Given missing

        Scenario: Pending
          Given pending

        Scenario: Passing
          Given passing
      """
    And a file named "features/all_good.feature" with:
      """
      Feature: Rerun

        Scenario: Passing
          Given passing
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /failing/ do
        raise 'FAIL'
      end

      Given /pending/ do
        pending
      end

      Given /passing/ do
      end
      """

    When I run `cucumber -f rerun features/sample.feature features/all_good.feature`
    Then it should fail with:
      """
      features/sample.feature:3:6:9
      """
