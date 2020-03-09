Feature: Nested Steps

  Background:
    Given a scenario with a step that looks like this:
      """gherkin
      Given two turtles
      """
    And a step definition that looks like this:
      """ruby
      Given /a turtle/ do
        log "turtle!"
      end
      """

  @todo-windows
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

  @todo-windows
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

  @todo-windows
  Scenario: Use #steps to call a table
    Given a step definition that looks like this:
      """ruby
      Given /turtles:/ do |table|
        table.hashes.each do |row|
          log row[:name]
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

  @todo-windows
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
        log string
      end
      """
    When I run the feature with the progress formatter
    Then the output should contain:
      """
      Sturm
      Liouville
      """

  @spawn @todo-windows @todo-jruby @wip-jruby
  Scenario: Backtrace doesn't skip nested steps
    Given a file named "features/nested_steps.feature" with:
      """gherkin
      Feature: nested steps

        Scenario: Test Scenario 1
          Given two turtles
      """
    Given a step definition that looks like this:
      """ruby
      Given /two turtles/ do
        step "I have a couple turtles"
      end

      When(/I have a couple turtles/) { raise 'error' }
      """
    When I run `cucumber features/nested_steps.feature --format progress`
    Then it should fail with:
      """
      error (RuntimeError)
      ./features/step_definitions/steps2.rb:5:in `/I have a couple turtles/'
      ./features/step_definitions/steps2.rb:2:in `/two turtles/'
      features/nested_steps.feature:4:in `two turtles'

      Failing Scenarios:
      cucumber features/nested_steps.feature:3 # Scenario: Test Scenario 1

      1 scenario (1 failed)
      1 step (1 failed)
      """

  Scenario: Undefined nested step
    Given a file named "features/call_undefined_step_from_step_def.feature" with:
      """
      Feature: Calling undefined step

        Scenario: Call directly
          Given a step that calls an undefined step

        Scenario: Call via another
          Given a step that calls a step that calls an undefined step
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given /^a step that calls an undefined step$/ do
        step 'this does not exist'
      end

      Given /^a step that calls a step that calls an undefined step$/ do
        step 'a step that calls an undefined step'
      end
      """
    When I run `cucumber -q features/call_undefined_step_from_step_def.feature`
    Then it should fail with exactly:
      """
      Feature: Calling undefined step

        Scenario: Call directly
          Given a step that calls an undefined step
            Undefined dynamic step: "this does not exist" (Cucumber::UndefinedDynamicStep)
            ./features/step_definitions/steps.rb:2:in `/^a step that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:4:in `a step that calls an undefined step'

        Scenario: Call via another
          Given a step that calls a step that calls an undefined step
            Undefined dynamic step: "this does not exist" (Cucumber::UndefinedDynamicStep)
            ./features/step_definitions/steps.rb:2:in `/^a step that calls an undefined step$/'
            ./features/step_definitions/steps.rb:6:in `/^a step that calls a step that calls an undefined step$/'
            features/call_undefined_step_from_step_def.feature:7:in `a step that calls a step that calls an undefined step'

      Failing Scenarios:
      cucumber features/call_undefined_step_from_step_def.feature:3
      cucumber features/call_undefined_step_from_step_def.feature:6

      2 scenarios (2 failed)
      2 steps (2 failed)

      """
