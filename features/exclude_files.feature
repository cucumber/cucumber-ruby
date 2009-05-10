Feature: Exclude ruby and feature files from runs
  Developers should be able to easily exclude files from cucumber runs

  Scenario: explicitly exclude ruby file
    Given a standard Cucumber project directory structure
    And a file named "features/support/dont_require_me.rb"
    And a file named "features/support/require_me.rb"

    When I run cucumber features -q --verbose --exclude dont_require_me.rb

    Then "features/support/require_me.rb" should be required
    And "features/support/dont_require_me.rb" should not be required
