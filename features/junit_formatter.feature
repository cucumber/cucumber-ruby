Feature: JUnit output formatter
  In order for developers to create test reports with ant
  Cucumber should be able to output JUnit xml files
  
  Background:
    Given I am in junit
    And the tmp directory is empty
    
  Scenario: one feature, one passing scenario, one failing scenario
    When I run cucumber --format junit --reportdir tmp/ features/one_passing_one_failing.feature
    Then it should fail with
      """
      Beginning Feature: One passing scenario, one failing scenario
      Running Scenario: Passing
      Running Scenario: Failing
      Writing test output tmp/TEST-One_passing_scenario__one_failing_scenario.xml
      
      """
    And "examples/junit/tmp/TEST-One_passing_scenario__one_failing_scenario.xml" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite failures="1" errors="0" name="One passing scenario, one failing scenario" tests="2">
      <testcase classname="One passing scenario, one failing scenario.Passing" name="Given a passing scenario">
      </testcase>
      <testcase classname="One passing scenario, one failing scenario.Failing" name="Given a failing scenario">
        <failure message="Given a failing scenario">
       (RuntimeError)
      features/one_passing_one_failing.feature:7:in `Given a failing scenario'  </failure>
      </testcase>
      </testsuite>
      
      """
  Scenario: pending step
    When I run cucumber --format junit --reportdir tmp/ features/pending.feature
    Then it should pass with
      """
      Beginning Feature: Pending step
      Running Scenario: Pending
      Writing test output tmp/TEST-Pending_step.xml
      
      """
    And "examples/junit/tmp/TEST-Pending_step.xml" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite failures="1" errors="0" name="Pending step" tests="1">
      <testcase classname="Pending step.Pending" name="Given a pending step">
        <failure message="Given a pending step">
      TODO (Cucumber::Pending)
      features/pending.feature:4:in `Given a pending step'  </failure>
      </testcase>
      </testsuite>
      
      """
    
  Scenario: run all features
    When I run cucumber --format junit --reportdir tmp/ features
    Then it should fail with
      """
      Beginning Feature: One passing scenario, one failing scenario
      Running Scenario: Passing
      Running Scenario: Failing
      Writing test output tmp/TEST-One_passing_scenario__one_failing_scenario.xml
      Beginning Feature: Pending step
      Running Scenario: Pending
      Writing test output tmp/TEST-Pending_step.xml
      
      """
    And "examples/junit/tmp/TEST-One_passing_scenario__one_failing_scenario.xml" should exist
    And "examples/junit/tmp/TEST-Pending_step.xml" should exist
    
    
