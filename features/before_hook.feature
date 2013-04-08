Feature: Before Hook

  Scenario: Examine names of elements
    Given a file named "features/foo.feature" with:
      """
      Feature: Feature name

        Scenario: Scenario name
          Given a step

        Scenario Outline: Scenario Outline name
          Given a step

          Examples: Examples Table name
            | row |
      """
    And a file named "features/support/hook.rb" with:
      """
      names = []
      Before do |scenario|
        unless scenario.respond_to?(:scenario_outline)
          names << scenario.feature.name.split("\n").first
          names << scenario.scenario.name.split("\n").first
        else
          names << scenario.scenario_outline.feature.name.split("\n").first
          names << scenario.scenario_outline.name.split("\n").first
          names << scenario.examples_table.name.split("\n").first
          names << scenario.row_number
        end
      end
      at_exit { puts names.join("\n") }
      """
    When I run `cucumber`
    Then the output should contain exactly:
      """
      Feature name
      Scenario name
      Scenario Outline name
      Examples Table name
      1
      """

