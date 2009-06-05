Feature: JUnit output formatter
  In order for developers to create test reports with ant
  Cucumber should be able to output JUnit xml files
  
  Background:
    Given I am in junit
    And the tmp directory is empty
  
  @mri186 @diffxml
  Scenario: one feature, one passing scenario, one failing scenario
    When I run cucumber --format junit --out tmp/ features/one_passing_one_failing.feature
    Then it should fail with
      """

      """
    And "examples/junit/tmp/TEST-One_passing_scenario__one_failing_scenario.xml" should contain XML
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" tests="2" name="One passing scenario, one failing scenario" failures="1">
      <testcase name="Given a passing scenario" classname="One passing scenario, one failing scenario.Passing">
      </testcase>
      <testcase name="Given a failing scenario" classname="One passing scenario, one failing scenario.Failing">
        <failure message="Given a failing scenario">
       (RuntimeError)
      ./features/step_definitions/steps.rb:6:in `/a failing scenario/'
      features/one_passing_one_failing.feature:7:in `Given a failing scenario'  </failure>
      </testcase>
      </testsuite>
      
      """
  
  @mri186 @diffxml
  Scenario: pending step
    When I run cucumber --format junit --out tmp/ features/pending.feature
    Then it should pass with
      """
      
      """
    And "examples/junit/tmp/TEST-Pending_step.xml" should contain XML
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" tests="1" name="Pending step" failures="1">
      <testcase name="Given a pending step" classname="Pending step.Pending">
        <failure message="Given a pending step">
      TODO (Cucumber::Pending)
      ./features/step_definitions/steps.rb:10:in `/a pending step/'
      features/pending.feature:4:in `Given a pending step'  </failure>
      </testcase>
      </testsuite>
      
      """
    
  Scenario: run all features
    When I run cucumber --format junit --out tmp/ features
    Then it should fail with
      """
      
      """
    And "examples/junit/tmp/TEST-One_passing_scenario__one_failing_scenario.xml" should exist
    And "examples/junit/tmp/TEST-Pending_step.xml" should exist
  
  Scenario: show correct error message if no --out is passed
    When I run cucumber --format junit features
	  Then STDERR should not match 
		  """
can't convert .* into String \(TypeError\)
		  """
    And STDERR should match
		  """
You \*must\* specify \-\-out DIR for the junit formatter
	    """