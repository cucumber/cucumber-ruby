Feature: Nested Steps


  Background:
    Given a scenario with a step that looks like this:
      """gherkin
      Given two turtles
      """
    And a step definition that looks like this:
      """ruby
      Given /a turtle/ do
        puts "turtle!"
      end
      """

  Scenario: Use #steps to call several steps at once
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        steps %{
          Given a turtle
          And a turtle
        }
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      turtle!

      turtle!

      """

  Scenario: Use #step to call a single step
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        step "a turtle"
        step "a turtle"
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      turtle!

      turtle!

      """

  Scenario: Use deprecated i18n methods
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        Given "a turtle"
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain "WARNING"

  Scenario: Backtrace doesn't skip nested steps
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        step "I have a couple turtles"
      end

      When /I have a couple turtles/ do
        raise 'error'
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain "test_feature_1.feature:3"
    And the output should contain "test_steps2.rb:2"
    And the output should contain "test_steps2.rb:6"