Feature: JUnit output formatter
  In order for developers to create test reports with ant
  Cucumber should be able to output JUnit xml files
  
  Scenario: one feature, one passing scenario, one failing scenario
    When I run cucumber --format junit --reportdir examples/junit/tmp/ examples/junit/features/one_passing_one_failing.feature
    Then it should fail with
      """
      Beginning One passing scenario, one failing scenario
      Running Scenario: Passing
      Running Scenario: Failing
      Writing test output examples/junit/tmp/TEST-One_passing_scenario__one_failing_scenario.xml
      """
    And "examples/junit/tmp/TEST-One_passing_scenario__one_failing_scenario.xml" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite tests="2" errors="0" failures="1" name="One passing scenario, one failing scenario">
        <testcase classname="One passing scenario, one failing scenario.Passing" name="Given a passing scenario">
        </testcase>
        <testcase classname="One passing scenario, one failing scenario.Failing" name="Given a failing scenario">
          <failure>
          </failure>
        </testcase>
      </testsuite>
      """
