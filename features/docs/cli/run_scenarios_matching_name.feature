Feature: Run feature elements matching a name with --name/-n

  The `--name NAME` option runs only scenarios which match a certain
name

  Scenario:
    Given a file named "features/first.feature" with:
      """
      Feature: first
        Scenario: foo first
          Given missing
        Scenario: bar first
          Given missing
      """
    Given a file named "features/second.feature" with:
      """
      Feature: second
        Scenario: foo second
          Given missing
        Scenario: bar second
          Given missing
      """
    When I run `cucumber -q --name foo`
    Then it should pass with:
      """
      Feature: first

        Scenario: foo first
          Given missing

      Feature: second

        Scenario: foo second
          Given missing

      2 scenarios (2 undefined)
      2 steps (2 undefined)
      """
