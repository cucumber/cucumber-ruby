Feature: JUnit output formatter

  Scenario: it writes the filenames including the subdirectory
    See https://github.com/cucumber/cucumber/issues/176

    Given a file named "tmp/junit-test/features/one.feature" with:
      """
      Feature: Feature One
        Scenario: Passing
          Given a passing scenario
      """
    And a file named "tmp/junit-test/features/sub_features/one.feature" with:
      """
      Feature: Sub-Feature One
        Scenario: Passing
          Given a passing scenario
      """
    When I run cucumber "--format junit --out . tmp/junit-test/features"
    Then a file named "TEST-one.xml" should exist
    And a file named "TEST-sub_features-one.xml" should exist