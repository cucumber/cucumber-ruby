Feature: After All Hook

  In order to extend Cucumber
  As a developer
  I want to run code after all Cucumber tests are finished

  Background:
    Given the standard step definitions

  Scenario: AfterAll hook gets executed after all steps are executed
    Given a file named "features/support/env.rb" with:
      """
      AfterAll do
        puts "After All"
      end
      """
    And a file named "features/step_definitions/puts_steps.rb" with:
      """
      Given /^I use puts with text "(.*)"$/ do |text|
        puts(text)
      end
      """
    And a file named "features/test1.feature" with:
      """
      Feature:

        Scenario:
          Given I use puts with text "Step 1"
          And I use puts with text "Step 2"
      """
    And a file named "features/test2.feature" with:
      """
      Feature:

        Scenario:
          Given I use puts with text "Step 3"
          And I use puts with text "Step 4"
      """
    When I run `cucumber -f progress features`
    Then the output should contain:
      """
      Step 1

      Step 2

      Step 3

      Step 4

      After All
      """

  Scenario: AfterAll hook gets executed after all hooks are executed
    Given a file named "features/support/env.rb" with:
      """
      Before do
        puts "Before"
      end

      After do
        puts "After"
      end

      AfterAll do
        puts "After All"
      end
      """
    And a file named "features/step_definitions/puts_steps.rb" with:
      """
      Given /^I use puts with text "(.*)"$/ do |text|
        puts(text)
      end
      """
    And a file named "features/test.feature" with:
      """
      Feature:

        Scenario:
          Given I use puts with text "Step 1"
          And I use puts with text "Step 2"
      """
    When I run `cucumber -f progress features`
    Then the output should contain:
      """
      Before

      Step 1

      Step 2

      After

      After All
      """

  Scenario: AfterAll hooks are executed in reverse order of definition
    Given a file named "features/support/hooks.rb" with:
      """
      AfterAll do
        puts "First"
      end

      AfterAll do
        puts "Second"
      end
      """
    And a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given this step passes
      """
    When I run `cucumber features`
    Then the output should contain:
      """
      Second

      First
      """

  Scenario: AfterAll hook is executed if test failed
    Given a file named "features/support/hooks.rb" with:
      """
      AfterAll do
        puts "After All"
      end
      """
    And a file named "features/test.feature" with:
      """
      Feature:
        Scenario:
          Given this step fails
      """
    When I run `cucumber -f progress features`
    Then the output should contain:
      """
      After All
      """
