Feature: Help

  Running `cucumber --help` shows you command-line options.

  Scenario: Show help
    When I run `cucumber --help`
    Then it should pass
    And I should see the CLI help
