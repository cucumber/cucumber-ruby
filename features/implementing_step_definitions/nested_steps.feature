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

  Scenario: Use #steps to call a table
    Given a step definition that looks like this:
      """ruby
      Given /turtles:/ do |table|
        table.hashes.each do |row|
          puts row[:name]
        end
      end
      """
    And a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        steps %{
          Given turtles:
            | name      |
            | Sturm     |
            | Liouville |
        }
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      Sturm

      Liouville

      """

  Scenario: Use #steps to call a multi-line string
    Given a step definition that looks like this:
      """ruby
        Given /two turtles/ do
          steps %Q{
            Given turtles:
               \"\"\"
               Sturm
               Liouville
               \"\"\"
          }
        end
      """
    And a step definition that looks like this:
      """ruby
      Given /turtles:/ do |string|
        puts string
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      Sturm
      Liouville
      """

  @spawn
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
    Then it should fail with:
      """
      error (RuntimeError)
      ./features/step_definitions/test_steps2.rb:6:in `/I have a couple turtles/'
      ./features/step_definitions/test_steps2.rb:2:in `/two turtles/'
      features/test_feature_1.feature:3:in `Given two turtles'

      Failing Scenarios:
      cucumber features/test_feature_1.feature:2 # Scenario: Test Scenario 1

      1 scenario (1 failed)
      1 step (1 failed)
      """
