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
      Missing Example Section for Scenario Outline at features/f.feature:2 (Cucumber::Ast::ScenarioOutline::MissingExamples)
      """
