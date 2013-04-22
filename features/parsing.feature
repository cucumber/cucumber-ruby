Feature: Scenario Outlines

  Scenario: Scenario Outline requires Example Section
    Given a file named "features/f.feature" with:
      """
      Feature:
        Scenario Outline:
          Given I have <opening balance> cucumbers
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^I have (\d+) cucumbers$/ do; end
      """
    When I run `cucumber features/f.feature`
    Then it should fail with:
      """
      Scenario Outline requires an Examples section (Cucumber::MissingExamples)
      """
