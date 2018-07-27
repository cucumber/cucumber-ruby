Feature: Before Hook

  @todo-windows
  Scenario: Examine name of scenario
    Given a file named "features/foo.feature" with:
      """
      Feature: Feature name

        Scenario: Scenario name
          Given a step
      """
    And a file named "features/support/hook.rb" with:
      """
      names = []
      Before do |scenario|
        names << scenario.name.split("\n").first
        if(names.size == 1)
          raise "NAMES:\n" + names.join("\n") + "\n"
        end
      end
      """
    When I run `cucumber`
    Then the output should contain:
      """
            NAMES:
            Scenario name

      """

  @todo-windows
  Scenario: Examine name of scenario outline
    Given a file named "features/foo.feature" with:
      """
      Feature: Feature name

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
        names << scenario.name.split("\n").first
        if(names.size == 1)
          raise "NAMES:\n" + names.join("\n") + "\n"
        end
      end
      """
    When I run `cucumber`
    Then the output should contain:
      """
            NAMES:
            Scenario Outline name

      """
