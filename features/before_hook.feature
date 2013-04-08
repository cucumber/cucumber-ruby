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
        names << scenario.feature_name
        if scenario.respond_to?(:scenario_name)
          names << scenario.scenario_name
        else
          names << scenario.scenario_outline_name
          names << scenario.examples_table_name
          names << scenario.examples_table_row
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

