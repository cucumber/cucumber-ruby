Feature: Usage formatter

  In order to see where step definitions are used
  Developers should be able to see a list of step definitions and their use

  Background:
    Given a file named "features/f.feature" with:
      """
      Feature: F
        Background: A
          Given A
        Scenario: B
          Given B
        Scenario Outline: CA
          Given <x>
          And B
          Examples:
            |x|
            |C|
            |A|
        Scenario: AC
          Given A
          Given C
      """
    And a file named "features/step_definitions/steps.rb" with:
      """
      Given(/A/) { }
      Given(/B/) { }
      Given(/C/) { }
      Given(/D/) { }
      """

  @todo-windows
  Scenario: Run with --format usage
    When I run `cucumber -f usage --dry-run`
    Then it should pass with exactly:
      """
      -----------

      /A/       # features/step_definitions/steps.rb:1
        Given A # features/f.feature:3
        Given A # features/f.feature:12:7
        Given A # features/f.feature:14
      /B/       # features/step_definitions/steps.rb:2
        Given B # features/f.feature:5
        And B   # features/f.feature:11:8
        And B   # features/f.feature:12:8
      /C/       # features/step_definitions/steps.rb:3
        Given C # features/f.feature:11:7
        Given C # features/f.feature:15
      /D/       # features/step_definitions/steps.rb:4
        NOT MATCHED BY ANY STEPS

      4 scenarios (4 skipped)
      11 steps (11 skipped)

      """

  @todo-windows
  Scenario: Run with --expand --format usage
    When I run `cucumber -x -f usage --dry-run`
    Then it should pass with exactly:
      """
      -----------

      /A/       # features/step_definitions/steps.rb:1
        Given A # features/f.feature:3
        Given A # features/f.feature:12:7
        Given A # features/f.feature:14
      /B/       # features/step_definitions/steps.rb:2
        Given B # features/f.feature:5
        And B   # features/f.feature:11:8
        And B   # features/f.feature:12:8
      /C/       # features/step_definitions/steps.rb:3
        Given C # features/f.feature:11:7
        Given C # features/f.feature:15
      /D/       # features/step_definitions/steps.rb:4
        NOT MATCHED BY ANY STEPS

      4 scenarios (4 skipped)
      11 steps (11 skipped)

      """

    @todo-windows
    Scenario: Run with --format stepdefs
      When I run `cucumber -f stepdefs --dry-run`
      Then it should pass with exactly:
        """
        -----------

        /A/   # features/step_definitions/steps.rb:1
        /B/   # features/step_definitions/steps.rb:2
        /C/   # features/step_definitions/steps.rb:3
        /D/   # features/step_definitions/steps.rb:4
          NOT MATCHED BY ANY STEPS

        4 scenarios (4 skipped)
        11 steps (11 skipped)

        """

    Scenario: Run with --format stepdefs when some steps are undefined
      Given a file named "features/calculator.feature" with:
      """
      Feature: Calculator
        Scenario: Adding numbers
          When I add 4 and 5
          Then I should get 9
      """
      When I run `cucumber -f stepdefs features/calculator.feature`
      Then it should pass with:
      """
      You can implement step definitions for undefined steps with these snippets:

      When('I add {int} and {int}') do |int, int2|
        pending # Write code here that turns the phrase above into concrete actions
      end

      Then('I should get {int}') do |int|
        pending # Write code here that turns the phrase above into concrete actions
      end
      """
