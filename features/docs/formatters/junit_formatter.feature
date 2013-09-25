@spawn
Feature: JUnit output formatter
  In order for developers to create test reports with ant
  Cucumber should be able to output JUnit xml files
  
  Background:
    Given a file named "features/step_definitions/steps.rb" with:
      """
      Given /a passing scenario/ do
	#does nothing
      end

      Given /a failing scenario/ do
	fail
      end

      Given /a pending step/ do
	pending
      end

      Given /a skipping scenario/ do
	skipping
      end
      """
    And a file named "features/one_passing_one_failing.feature" with:
      """
      Feature: One passing scenario, one failing scenario

        Scenario: Passing
          Given a passing scenario

        Scenario: Failing
          Given a failing scenario
      """
    And a file named "features/some_subdirectory/one_passing_one_failing.feature" with:
      """
      Feature: Subdirectory - One passing scenario, one failing scenario

        Scenario: Passing
          Given a passing scenario

        Scenario: Failing
          Given a failing scenario
      """
    And a file named "features/pending.feature" with:
      """
      Feature: Pending step

        Scenario: Pending
          Given a pending step

        Scenario: Undefined
          Given an undefined step
      """
    And a file named "features/pending.feature" with:
      """
      Feature: Pending step

        Scenario: Pending
          Given a pending step

        Scenario: Undefined
          Given an undefined step
      """
    And a file named "features/scenario_outline.feature" with:
      """
      Feature: Scenario outlines

        Scenario Outline: Using scenario outlines
          Given a <type> scenario

          Examples:
            | type    |
            | passing |
            | failing |
      """
  
  Scenario: one feature, one passing scenario, one failing scenario
    When I run `cucumber --format junit --out tmp/ features/one_passing_one_failing.feature`
    Then it should fail with:
      """

      """
    And "tmp/TEST-features-one_passing_one_failing.xml" with junit duration "0.005" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="One passing scenario, one failing scenario" skipped="0" tests="2" time="0.005">
      <testcase classname="One passing scenario, one failing scenario" name="Passing" time="0.005">
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="One passing scenario, one failing scenario" name="Failing" time="0.005">
        <failure message="failed Failing" type="failed">
          <![CDATA[Scenario: Failing

      Given a failing scenario

      Message:
	]]>
          <![CDATA[ (RuntimeError)
	./features/step_definitions/steps.rb:6:in `/a failing scenario/'
	features/one_passing_one_failing.feature:7:in `Given a failing scenario']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>

      """
  
  Scenario: one feature in a subdirectory, one passing scenario, one failing scenario
    When I run `cucumber --format junit --out tmp/ features/some_subdirectory/one_passing_one_failing.feature --require features`
    Then it should fail with:
      """

      """
    And "tmp/TEST-features-some_subdirectory-one_passing_one_failing.xml" with junit duration "0.005" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="Subdirectory - One passing scenario, one failing scenario" skipped="0" tests="2" time="0.005">
      <testcase classname="Subdirectory - One passing scenario, one failing scenario" name="Passing" time="0.005">
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Subdirectory - One passing scenario, one failing scenario" name="Failing" time="0.005">
        <failure message="failed Failing" type="failed">
          <![CDATA[Scenario: Failing

      Given a failing scenario

      Message:
	]]>
          <![CDATA[ (RuntimeError)
	./features/step_definitions/steps.rb:6:in `/a failing scenario/'
	features/some_subdirectory/one_passing_one_failing.feature:7:in `Given a failing scenario']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>

      """
  
  Scenario: pending and undefined steps are reported as skipped
    When I run `cucumber --format junit --out tmp/ features/pending.feature`
    Then it should pass with:
      """
      
      """
    And "tmp/TEST-features-pending.xml" with junit duration "0.009" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="0" name="Pending step" skipped="2" tests="2" time="0.009">
      <testcase classname="Pending step" name="Pending" time="0.009">
        <skipped/>
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Pending step" name="Undefined" time="0.009">
        <skipped/>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>
      
      """

  Scenario: pending and undefined steps with strict option should fail
    When I run `cucumber --format junit --out tmp/ features/pending.feature --strict`
    Then it should fail with:
      """

      """
    And "tmp/TEST-features-pending.xml" with junit duration "0.000160" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="2" name="Pending step" skipped="0" tests="2" time="0.000160">
      <testcase classname="Pending step" name="Pending" time="0.000160">
        <failure message="pending Pending" type="pending">
          <![CDATA[Scenario: Pending

      ]]>
          <![CDATA[TODO (Cucumber::Pending)
      ./features/step_definitions/steps.rb:10:in `/a pending step/'
      features/pending.feature:4:in `Given a pending step']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Pending step" name="Undefined" time="0.000160">
        <failure message="undefined Undefined" type="undefined">
          <![CDATA[Scenario: Undefined
      
      ]]>
          <![CDATA[Undefined step: "an undefined step" (Cucumber::Undefined)
      features/pending.feature:7:in `Given an undefined step']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>

      """
    
  Scenario: run all features
    When I run `cucumber --format junit --out tmp/ features`
    Then it should fail with:
      """
      
      """
    And a file named "tmp/TEST-features-one_passing_one_failing.xml" should exist
    And a file named "tmp/TEST-features-pending.xml" should exist
  
  Scenario: show correct error message if no --out is passed
    When I run `cucumber --format junit features`
    Then the stderr should not contain:
      """
can't convert .* into String \(TypeError\)
      """
    And the stderr should contain:
      """
You *must* specify --out DIR for the junit formatter
      """

  Scenario: one feature, one scenario outline, two examples: one passing, one failing
    When I run `cucumber --format junit --out tmp/ features/scenario_outline.feature`
    Then it should fail with:
      """

      """
    And "tmp/TEST-features-scenario_outline.xml" with junit duration "0.005" should contain
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite errors="0" failures="1" name="Scenario outlines" skipped="0" tests="2" time="0.005">
      <testcase classname="Scenario outlines" name="Using scenario outlines (outline example : | passing |)" time="0.005">
        <system-out/>
        <system-err/>
      </testcase>
      <testcase classname="Scenario outlines" name="Using scenario outlines (outline example : | failing |)" time="0.005">
        <failure message="failed Using scenario outlines (outline example : | failing |)" type="failed">
          <![CDATA[Scenario Outline: Using scenario outlines
      
      Example row: | failing |
      
      Message:
      ]]>
          <![CDATA[ (RuntimeError)
      ./features/step_definitions/steps.rb:6:in `/a failing scenario/'
      features/scenario_outline.feature:4:in `Given a <type> scenario']]>
        </failure>
        <system-out/>
        <system-err/>
      </testcase>
        <system-out>
          <![CDATA[]]>
        </system-out>
        <system-err>
          <![CDATA[]]>
        </system-err>
      </testsuite>

      """ 
