Feature: Before Hook

  Scenario: Examine names of elements
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
    And a file named "features/support/hook.rb" with:
      """
      names = []
      Before do |scenario|
        unless scenario.respond_to?(:scenario_outline)
          names << scenario.feature.name.split("\n").first
          names << scenario.name.split("\n").first
        else
          names << scenario.scenario_outline.feature.name.split("\n").first
          names << scenario.scenario_outline.name.split("\n").first
        end
        if(names.size == 4)
          raise "NAMES:\n" + names.join("\n") + "\n"
        end
      end
      """
    When I run `cucumber`
    Then the output should contain:
      """
            NAMES:
            Feature name
            Scenario name
            Feature name
            Scenario Outline name
      """

