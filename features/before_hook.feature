Feature: Before Hook

  Background:
    Given a file named "features/foo.feature" with:
      """
      Feature: Feature name

        Scenario: Scenario name
          Given a step

        Scenario Outline: Scenario Outline name
          Given a <placeholder>

          Examples: Examples Table name
            | <placeholder> |
            | step          |
      """

  Scenario: Examine object passed into hook

    The object yielded to the Before hook is a `Cucumber::Unit`
    which represents a test-case executed by Cucumber. Each Unit
    has a _source_, which could either be a regular Scenario, or
    a row from a Scenario Outline's Examples table.

    If you need to look at the source, you can send a visitor
    to `Unit#describe_source_to` and the unit will call back
    to different methods on the visitor depending on the type
    of source the Unit originated from.

    Given a file named "features/support/hook.rb" with:
      """
      $names = []
      at_exit { puts $names.join("\n") }

      class UnitVisitor
        def scenario(scenario)
          $names << scenario.name
        end

        def scenario_outline_example(example_row)
          $names << example_row.scenario_outline_name
          $names << example_row.examples_table_name
          $names << example_row.number
        end
      end

      visitor = UnitVisitor.new
      Before do |unit|
        $names << unit.feature_name
        unit.describe_source_to(visitor)
      end
      """
    When I run `cucumber`
    Then the output should contain:
      """
      Feature name
      Scenario name
      Feature name
      Scenario Outline name
      """

